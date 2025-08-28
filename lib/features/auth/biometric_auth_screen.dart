import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/providers/secure_storage_provider.dart';

/// Écran d'authentification biométrique
///
/// Affiché au démarrage si la protection biométrique est activée
class BiometricAuthScreen extends ConsumerStatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  ConsumerState<BiometricAuthScreen> createState() =>
      _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends ConsumerState<BiometricAuthScreen>
    with WidgetsBindingObserver {
  final BiometricService _biometricService = BiometricService.instance;
  final SecureStorageService _secureStorage = SecureStorageService.instance;

  bool _isAuthenticating = false;
  String? _errorMessage;
  String _biometricType = 'biométrique';
  int _failedAttempts = 0;
  static const int _maxFailedAttempts = 3;

  // PIN fallback
  final TextEditingController _pinController = TextEditingController();
  bool _showPinInput = false;
  bool _obscurePin = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBiometricType();
    // Tenter l'authentification automatiquement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Réauthentifier quand l'app revient au premier plan
    if (state == AppLifecycleState.resumed && !_isAuthenticating) {
      _authenticate();
    }
  }

  Future<void> _loadBiometricType() async {
    final type = await _biometricService.getPrimaryBiometricType();
    if (mounted) {
      setState(() {
        _biometricType = type;
      });
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final result = await _biometricService.authenticate(
      localizedReason:
          'Authentifiez-vous pour accéder à vos routines spirituelles',
      biometricOnly: false, // Permettre le fallback au code PIN système
    );

    if (mounted) {
      setState(() {
        _isAuthenticating = false;
      });

      if (result.success) {
        // Authentification réussie, naviguer vers l'app
        _onAuthenticationSuccess();
      } else {
        // Gérer l'échec
        _handleAuthenticationFailure(result);
      }
    }
  }

  void _handleAuthenticationFailure(BiometricAuthResult result) {
    setState(() {
      _failedAttempts++;

      if (result.isCanceled) {
        _errorMessage = 'Authentification annulée';
      } else if (result.isLocked) {
        _errorMessage = 'Trop de tentatives. Utilisez votre code PIN.';
        _showPinInput = true;
      } else if (_failedAttempts >= _maxFailedAttempts) {
        _errorMessage = 'Trop de tentatives échouées. Utilisez votre code PIN.';
        _showPinInput = true;
      } else {
        _errorMessage = result.message;
      }
    });
  }

  Future<void> _authenticateWithPin() async {
    if (_pinController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer votre code PIN';
      });
      return;
    }

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    // Vérifier le code PIN
    final isValid = await _secureStorage.verifyPinCode(_pinController.text);

    if (mounted) {
      setState(() {
        _isAuthenticating = false;
      });

      if (isValid) {
        _onAuthenticationSuccess();
      } else {
        setState(() {
          _errorMessage = 'Code PIN incorrect';
          _pinController.clear();
        });
      }
    }
  }

  void _onAuthenticationSuccess() {
    // Réinitialiser les compteurs
    _failedAttempts = 0;

    // Naviguer vers l'écran principal
    context.go('/home');
  }

  Future<void> _skipAuthentication() async {
    // Option pour désactiver la protection (nécessite une authentification)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Désactiver la protection ?'),
        content: const Text(
          'Voulez-vous désactiver la protection biométrique ?\n\n'
          'Vos données ne seront plus protégées au démarrage de l\'application.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Désactiver'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _biometricService.disableBiometricProtection();
      if (success && mounted) {
        _onAuthenticationSuccess();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withOpacity(0.1),
              theme.primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ou icône
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _showPinInput ? Icons.pin : Icons.fingerprint,
                      size: 60,
                      color: theme.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Titre
                  Text(
                    'RISAQ',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Sous-titre
                  Text(
                    _showPinInput
                        ? 'Entrez votre code PIN'
                        : 'Authentification requise',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Zone d'authentification
                  if (_showPinInput) ...[
                    // Input PIN
                    SizedBox(
                      width: size.width > 400 ? 400 : null,
                      child: TextField(
                        controller: _pinController,
                        obscureText: _obscurePin,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        style: theme.textTheme.headlineSmall,
                        decoration: InputDecoration(
                          hintText: '• • • • • •',
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePin
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePin = !_obscurePin;
                              });
                            },
                          ),
                        ),
                        onSubmitted: (_) => _authenticateWithPin(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bouton valider PIN
                    SizedBox(
                      width: size.width > 400 ? 400 : null,
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            _isAuthenticating ? null : _authenticateWithPin,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isAuthenticating
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Valider'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bouton retour biométrie
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showPinInput = false;
                          _pinController.clear();
                          _errorMessage = null;
                        });
                        _authenticate();
                      },
                      icon: const Icon(Icons.fingerprint),
                      label: Text('Utiliser $_biometricType'),
                    ),
                  ] else ...[
                    // Bouton authentification biométrique
                    SizedBox(
                      width: size.width > 400 ? 400 : null,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isAuthenticating ? null : _authenticate,
                        icon: _isAuthenticating
                            ? const SizedBox.shrink()
                            : const Icon(Icons.fingerprint),
                        label: _isAuthenticating
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text('Utiliser $_biometricType'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bouton code PIN
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showPinInput = true;
                          _errorMessage = null;
                        });
                      },
                      icon: const Icon(Icons.pin),
                      label: const Text('Utiliser le code PIN'),
                    ),
                  ],

                  // Message d'erreur
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 48),

                  // Option pour désactiver
                  TextButton(
                    onPressed: _skipAuthentication,
                    child: Text(
                      'Désactiver la protection',
                      style: TextStyle(
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
