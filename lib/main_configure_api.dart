import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Application simple pour configurer l'API key Coqui
/// Lancez avec: flutter run -t lib/main_configure_api.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Votre API key Coqui
  const apiKey = '59be8c1f611576f7bd4436d7780426cc4bfcb10decd87e239a8ced6d843aa7c9a9541d8415d3c7a5313a427d1f7fff9a687cd23f60bba4338db0a580bed940c651f7bf2e-2dce-4105-a7ad-092fcc61560d';
  
  // Configuration par défaut
  const storage = FlutterSecureStorage();
  
  try {
    // Sauvegarder la configuration
    await storage.write(key: 'tts_coqui_endpoint', value: 'http://168.231.112.71:8001');
    await storage.write(key: 'tts_coqui_api_key', value: apiKey);
    await storage.write(key: 'tts_timeout', value: '3000');
    await storage.write(key: 'tts_max_retries', value: '3');
    await storage.write(key: 'tts_cache_enabled', value: 'true');
    await storage.write(key: 'tts_cache_ttl_days', value: '7');
    await storage.write(key: 'tts_preferred_provider', value: 'coqui');
    
    print('✅ Configuration Coqui TTS sauvegardée avec succès!');
    print('');
    print('L\'application est maintenant configurée pour utiliser Coqui TTS.');
    print('Vous pouvez fermer cette fenêtre et lancer l\'application principale.');
    
  } catch (e) {
    print('❌ Erreur lors de la configuration: $e');
  }
  
  runApp(const ConfigApp());
}

class ConfigApp extends StatelessWidget {
  const ConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Configuration Coqui TTS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ConfigPage(),
    );
  }
}

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  bool _isConfigured = false;
  String _status = 'Vérification...';
  
  @override
  void initState() {
    super.initState();
    _checkConfiguration();
  }
  
  Future<void> _checkConfiguration() async {
    const storage = FlutterSecureStorage();
    
    try {
      final apiKey = await storage.read(key: 'tts_coqui_api_key');
      final endpoint = await storage.read(key: 'tts_coqui_endpoint');
      
      setState(() {
        if (apiKey != null && apiKey.isNotEmpty) {
          _isConfigured = true;
          _status = '''
Configuration actuelle:
• Endpoint: $endpoint
• API Key: ${apiKey.substring(0, 8)}...
• Provider: Coqui TTS
• Cache: Activé (7 jours)
• Timeout: 3 secondes
''';
        } else {
          _isConfigured = false;
          _status = 'Configuration non trouvée';
        }
      });
    } catch (e) {
      setState(() {
        _status = 'Erreur: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Configuration Coqui TTS'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isConfigured ? Icons.check_circle : Icons.warning,
                size: 64,
                color: _isConfigured ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                _isConfigured 
                  ? '✅ Coqui TTS est configuré!' 
                  : '⚠️ Configuration en attente',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _status,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (_isConfigured) ...[
                const Text(
                  'Vous pouvez maintenant:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('1. Fermer cette fenêtre'),
                const Text('2. Lancer l\'application principale avec:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'flutter run',
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('3. Tester dans Paramètres > Voix et Lecture'),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _checkConfiguration,
                icon: const Icon(Icons.refresh),
                label: const Text('Rafraîchir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}