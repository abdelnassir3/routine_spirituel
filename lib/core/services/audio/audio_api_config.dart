/// Configuration centralisée des APIs audio
class AudioApiConfig {
  // Configuration Edge-TTS VPS
  static const String edgeTtsBaseUrl = 'http://168.231.112.71:8010';
  static const String edgeTtsApiKey =
      'e828cb8856742db10d4c87bace9889c3795ff63b1343b0ced4b2156113db826a';

  // Endpoints
  static const String edgeTtsSynthesizeEndpoint = '$edgeTtsBaseUrl/api/tts';
  static const String edgeTtsHealthEndpoint = '$edgeTtsBaseUrl/health';
  static const String edgeTtsVoicesEndpoint = '$edgeTtsBaseUrl/voices';

  // Configuration APIs Coraniques (publiques)
  // Utilise proxy CORS en développement pour éviter les erreurs CORS
  static const String _corsProxyUrl = 'http://localhost:3000';
  static const bool _useCorsProxy = true; // Set to false for production
  
  static String get alQuranBaseUrl => _useCorsProxy 
    ? '$_corsProxyUrl/?url=https://cdn.alquran.cloud/media/audio/ayah'
    : 'https://cdn.alquran.cloud/media/audio/ayah';
    
  static String get everyayahBaseUrl => _useCorsProxy
    ? '$_corsProxyUrl/?url=https://everyayah.com/data' 
    : 'https://everyayah.com/data';
    
  static String get quranComBaseUrl => _useCorsProxy
    ? '$_corsProxyUrl/?url=https://verses.quran.com'
    : 'https://verses.quran.com';

  // Timeouts et limites
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration edgeTtsTimeout = Duration(minutes: 2);
  static const int maxRetries = 3;
  static const int maxTextLength = 5000;

  // Cache TTL
  static const Duration edgeTtsCacheTtl = Duration(days: 7);
  static const Duration quranicAudioCacheTtl = Duration(days: 30);

  // Headers par défaut
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'User-Agent': 'ProjetSpirit/1.0.0 (Flutter Mobile App)',
      };

  static Map<String, String> get edgeTtsHeaders => {
        'Authorization': 'Bearer $edgeTtsApiKey',
        'X-API-Key': edgeTtsApiKey,
        'User-Agent': 'ProjetSpirit/1.0.0 (Flutter Mobile App)',
      };

  // Validation de configuration
  static bool get isEdgeTtsConfigured =>
      edgeTtsBaseUrl.isNotEmpty && edgeTtsApiKey.isNotEmpty;

  static bool get isConfigurationValid {
    if (!isEdgeTtsConfigured) return false;
    if (edgeTtsApiKey.length < 32) return false;
    if (!edgeTtsBaseUrl.startsWith('http')) return false;
    return true;
  }

  // Logging et debug
  static void logConfiguration() {
    print('🔧 Configuration Audio API:');
    print('  Edge-TTS: $edgeTtsBaseUrl');
    print('  API Key: ${edgeTtsApiKey.substring(0, 8)}...');
    print('  AlQuran: $alQuranBaseUrl');
    print('  Proxy CORS: $_useCorsProxy');
    print('  Configuré: $isEdgeTtsConfigured');
    print('  Valide: $isConfigurationValid');
  }
}
