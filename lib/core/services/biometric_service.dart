import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'secure_storage_service.dart';

/// Service d'authentification biométrique
/// 
/// Gère l'authentification par empreinte digitale, Face ID, et autres
/// méthodes biométriques disponibles sur l'appareil
class BiometricService {
  static BiometricService? _instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final SecureStorageService _secureStorage = SecureStorageService.instance;
  
  // Cache des capacités de l'appareil
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  
  // Singleton
  static BiometricService get instance {
    _instance ??= BiometricService._();
    return _instance!;
  }
  
  BiometricService._();
  
  /// Vérifier si l'appareil supporte la biométrie
  Future<bool> canCheckBiometrics() async {
    try {
      _canCheckBiometrics ??= await _localAuth.canCheckBiometrics;
      return _canCheckBiometrics!;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('BiometricService: Error checking biometrics capability: $e');
      }
      return false;
    }
  }
  
  /// Vérifier si l'appareil a des méthodes biométriques configurées
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('BiometricService: Error checking device support: $e');
      }
      return false;
    }
  }
  
  /// Obtenir la liste des méthodes biométriques disponibles
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      _availableBiometrics ??= await _localAuth.getAvailableBiometrics();
      return _availableBiometrics!;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('BiometricService: Error getting available biometrics: $e');
      }
      return [];
    }
  }
  
  /// Vérifier si Face ID est disponible (iOS)
  Future<bool> hasFaceId() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }
  
  /// Vérifier si Touch ID / Empreinte digitale est disponible
  Future<bool> hasFingerprint() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }
  
  /// Vérifier si l'iris scan est disponible (certains Android)
  Future<bool> hasIris() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.iris);
  }
  
  /// Authentifier l'utilisateur avec la biométrie
  Future<BiometricAuthResult> authenticate({
    String localizedReason = 'Veuillez vous authentifier pour accéder à l\'application',
    bool stickyAuth = true,
    bool biometricOnly = false,
  }) async {
    try {
      // Vérifier d'abord si la biométrie est disponible
      final canCheck = await canCheckBiometrics();
      if (!canCheck) {
        return BiometricAuthResult(
          success: false,
          error: BiometricError.notAvailable,
          message: 'La biométrie n\'est pas disponible sur cet appareil',
        );
      }
      
      // Vérifier si des méthodes sont configurées
      final biometrics = await getAvailableBiometrics();
      if (biometrics.isEmpty) {
        return BiometricAuthResult(
          success: false,
          error: BiometricError.notEnrolled,
          message: 'Aucune méthode biométrique configurée',
        );
      }
      
      // Tenter l'authentification
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );
      
      if (isAuthenticated) {
        // Enregistrer le succès dans le stockage sécurisé
        await _secureStorage.write(
          key: 'last_biometric_auth',
          value: DateTime.now().toIso8601String(),
        );
        
        return BiometricAuthResult(
          success: true,
          message: 'Authentification réussie',
        );
      } else {
        return BiometricAuthResult(
          success: false,
          error: BiometricError.failed,
          message: 'Authentification échouée',
        );
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('BiometricService: Authentication error: $e');
      }
      
      // Analyser l'erreur pour donner un message approprié
      BiometricError errorType;
      String message;
      
      switch (e.code) {
        case 'NotEnrolled':
          errorType = BiometricError.notEnrolled;
          message = 'Aucune empreinte biométrique enregistrée';
          break;
        case 'NotAvailable':
          errorType = BiometricError.notAvailable;
          message = 'Biométrie non disponible';
          break;
        case 'PasscodeNotSet':
          errorType = BiometricError.passcodeNotSet;
          message = 'Code de verrouillage non configuré';
          break;
        case 'LockedOut':
          errorType = BiometricError.lockedOut;
          message = 'Trop de tentatives échouées';
          break;
        case 'PermanentlyLockedOut':
          errorType = BiometricError.permanentlyLockedOut;
          message = 'Biométrie verrouillée. Utilisez le code PIN';
          break;
        case 'UserCanceled':
          errorType = BiometricError.userCanceled;
          message = 'Authentification annulée';
          break;
        default:
          errorType = BiometricError.unknown;
          message = 'Erreur d\'authentification: ${e.message}';
      }
      
      return BiometricAuthResult(
        success: false,
        error: errorType,
        message: message,
      );
    }
  }
  
  /// Arrêter l'authentification en cours
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      if (kDebugMode) {
        print('BiometricService: Error stopping authentication: $e');
      }
    }
  }
  
  /// Activer la protection biométrique pour l'app
  Future<bool> enableBiometricProtection() async {
    try {
      // Vérifier que la biométrie est disponible
      final canUse = await canCheckBiometrics();
      if (!canUse) return false;
      
      // Authentifier l'utilisateur d'abord
      final result = await authenticate(
        localizedReason: 'Confirmer l\'activation de la protection biométrique',
      );
      
      if (result.success) {
        await _secureStorage.setBiometricEnabled(true);
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('BiometricService: Error enabling biometric protection: $e');
      }
      return false;
    }
  }
  
  /// Désactiver la protection biométrique
  Future<bool> disableBiometricProtection() async {
    try {
      // Authentifier l'utilisateur d'abord
      final result = await authenticate(
        localizedReason: 'Confirmer la désactivation de la protection biométrique',
      );
      
      if (result.success) {
        await _secureStorage.setBiometricEnabled(false);
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('BiometricService: Error disabling biometric protection: $e');
      }
      return false;
    }
  }
  
  /// Vérifier si la protection biométrique est activée
  Future<bool> isBiometricProtectionEnabled() async {
    return _secureStorage.isBiometricEnabled();
  }
  
  /// Obtenir le type de biométrie principal disponible
  Future<String> getPrimaryBiometricType() async {
    final biometrics = await getAvailableBiometrics();
    
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Empreinte digitale';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Scan de l\'iris';
    } else if (biometrics.contains(BiometricType.strong)) {
      return 'Biométrie forte';
    } else if (biometrics.contains(BiometricType.weak)) {
      return 'Biométrie faible';
    }
    
    return 'Non disponible';
  }
  
  /// Réinitialiser le cache
  void resetCache() {
    _canCheckBiometrics = null;
    _availableBiometrics = null;
  }
}

/// Résultat de l'authentification biométrique
class BiometricAuthResult {
  final bool success;
  final BiometricError? error;
  final String message;
  
  BiometricAuthResult({
    required this.success,
    this.error,
    required this.message,
  });
  
  bool get isSuccess => success;
  bool get isFailure => !success;
  bool get isCanceled => error == BiometricError.userCanceled;
  bool get isLocked => error == BiometricError.lockedOut || 
                       error == BiometricError.permanentlyLockedOut;
}

/// Types d'erreurs biométriques
enum BiometricError {
  notAvailable,
  notEnrolled,
  passcodeNotSet,
  failed,
  userCanceled,
  lockedOut,
  permanentlyLockedOut,
  unknown,
}