import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Initialise l'API key Coqui au premier lancement
/// Cette classe configure automatiquement l'API key si elle n'existe pas
class ApiKeyInitializer {
  static const _storage = FlutterSecureStorage();
  static bool _initialized = false;
  
  /// Nettoie complètement la configuration pour forcer une réinitialisation
  static Future<void> cleanAndReinitialize() async {
    try {
      print('🧹 Nettoyage complet de la configuration TTS...');
      
      // Supprimer toutes les clés TTS
      await _storage.delete(key: 'tts_coqui_endpoint');
      await _storage.delete(key: 'tts_coqui_api_key');
      await _storage.delete(key: 'tts_timeout');
      await _storage.delete(key: 'tts_max_retries');
      await _storage.delete(key: 'tts_cache_enabled');
      await _storage.delete(key: 'tts_cache_ttl_days');
      await _storage.delete(key: 'tts_preferred_provider');
      
      print('✅ Configuration TTS supprimée');
      
      // Réinitialiser
      _initialized = false;
      await initialize();
      
      print('✅ Configuration TTS réinitialisée avec succès');
    } catch (e) {
      print('❌ Erreur lors du nettoyage: $e');
    }
  }
  
  /// Initialise l'API key si nécessaire
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    
    try {
      // Vérifier si l'API key existe déjà
      final existingKey = await _storage.read(key: 'tts_coqui_api_key');
      
      // Forcer la mise à jour si l'API key est différente ou vide
      if (existingKey == null || existingKey.isEmpty || 
          existingKey != '8e88bed4c0c2e2f35e4b7e96e967c2a7fd1e7e21e582b14c1f2b81a983b8b9e1') {
        // Configuration initiale avec votre API key
        await _storage.write(
          key: 'tts_coqui_endpoint', 
          value: 'http://168.231.112.71:8001'
        );
        
        await _storage.write(
          key: 'tts_coqui_api_key',
          value: '8e88bed4c0c2e2f35e4b7e96e967c2a7fd1e7e21e582b14c1f2b81a983b8b9e1'
        );
        
        await _storage.write(key: 'tts_timeout', value: '3000');
        await _storage.write(key: 'tts_max_retries', value: '3');
        await _storage.write(key: 'tts_cache_enabled', value: 'true');
        await _storage.write(key: 'tts_cache_ttl_days', value: '7');
        await _storage.write(key: 'tts_preferred_provider', value: 'coqui'); // Coqui par défaut
        
        print('✅ API key Coqui configurée automatiquement');
      } else {
        print('✅ API key Coqui déjà configurée');
      }
    } catch (e) {
      print('⚠️ Erreur lors de l\'initialisation de l\'API key: $e');
      // L'app continuera avec flutter_tts comme fallback
    }
  }
  
  /// Vérifie si l'API est configurée
  static Future<bool> isConfigured() async {
    try {
      final apiKey = await _storage.read(key: 'tts_coqui_api_key');
      return apiKey != null && apiKey.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Récupère la configuration actuelle (pour debug)
  static Future<Map<String, String>> getConfig() async {
    try {
      return {
        'endpoint': await _storage.read(key: 'tts_coqui_endpoint') ?? 'Non configuré',
        'apiKey': (await _storage.read(key: 'tts_coqui_api_key') ?? '').isNotEmpty 
          ? 'Configurée' 
          : 'Non configurée',
        'provider': await _storage.read(key: 'tts_preferred_provider') ?? 'flutter_tts',
      };
    } catch (e) {
      return {
        'status': 'Erreur: $e'
      };
    }
  }
}