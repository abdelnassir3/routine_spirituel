import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'audio_api_config.dart';

/// Service de test de connexion VPS
class VpsConnectionTest {
  static final Dio _dio = Dio();

  /// Teste la connectivité de base avec le VPS
  static Future<VpsTestResult> testConnection() async {
    debugPrint('🧪 Test de connexion VPS: ${AudioApiConfig.edgeTtsBaseUrl}');

    final result = VpsTestResult();

    try {
      // Test 1: Ping de base
      await _testBasicConnection(result);

      // Test 2: Health check (si disponible)
      await _testHealthEndpoint(result);

      // Test 3: Test API Key
      await _testApiKey(result);

      // Test 4: Test simple de synthèse
      await _testSimpleSynthesis(result);
    } catch (e) {
      result.overallStatus = VpsTestStatus.failed;
      result.errors.add('Exception générale: $e');
      debugPrint('❌ Test VPS échoué: $e');
    }

    // Résumé final
    debugPrint('📊 Résumé test VPS:');
    debugPrint('  Status: ${result.overallStatus}');
    debugPrint('  Latence: ${result.latency}ms');
    debugPrint('  Erreurs: ${result.errors.length}');

    return result;
  }

  static Future<void> _testBasicConnection(VpsTestResult result) async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.get(
        AudioApiConfig.edgeTtsBaseUrl,
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      result.latency = stopwatch.elapsedMilliseconds;
      result.basicConnection =
          response.statusCode != null && response.statusCode! < 500;

      debugPrint(
          '✅ Connexion de base: ${response.statusCode} (${result.latency}ms)');
    } catch (e) {
      result.basicConnection = false;
      result.errors.add('Connexion de base échouée: $e');
      debugPrint('❌ Connexion de base échouée: $e');
    }

    stopwatch.stop();
  }

  static Future<void> _testHealthEndpoint(VpsTestResult result) async {
    try {
      final response = await _dio.get(
        AudioApiConfig.edgeTtsHealthEndpoint,
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          validateStatus: (status) => status != null,
        ),
      );

      result.healthEndpoint = response.statusCode == 200;
      debugPrint('✅ Health check: ${response.statusCode}');
    } catch (e) {
      result.healthEndpoint = false;
      result.errors.add('Health endpoint inaccessible: $e');
      debugPrint(
          '⚠️ Health endpoint non disponible (normal si pas implémenté)');
    }
  }

  static Future<void> _testApiKey(VpsTestResult result) async {
    try {
      // Test avec un appel simple pour valider l'API key
      final response = await _dio.post(
        '${AudioApiConfig.edgeTtsBaseUrl}/test',
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          headers: AudioApiConfig.edgeTtsHeaders,
          validateStatus: (status) => status != null,
        ),
      );

      result.apiKeyValid =
          response.statusCode != 401 && response.statusCode != 403;
      debugPrint('✅ API Key validation: ${response.statusCode}');
    } catch (e) {
      result.apiKeyValid = false;
      result.errors.add('Validation API Key échouée: $e');
      debugPrint(
          '⚠️ Impossible de valider l\'API Key (endpoint test non disponible)');
    }
  }

  static Future<void> _testSimpleSynthesis(VpsTestResult result) async {
    try {
      final response = await _dio.post(
        AudioApiConfig.edgeTtsSynthesizeEndpoint,
        data: {
          'text': 'Test',
          'voice':
              'Microsoft Server Speech Text to Speech Voice (fr-FR, DeniseNeural)',
          'rate': '100%',
          'pitch': '0Hz',
        },
        options: Options(
          timeout: AudioApiConfig.edgeTtsTimeout,
          headers: AudioApiConfig.edgeTtsHeaders,
          responseType: ResponseType.bytes,
          validateStatus: (status) => status != null,
        ),
      );

      result.synthesisWorking = response.statusCode == 200 &&
          response.data != null &&
          (response.data as List).isNotEmpty;

      if (result.synthesisWorking) {
        result.sampleAudioSize = (response.data as List).length;
        debugPrint('✅ Synthèse test réussie: ${result.sampleAudioSize} bytes');
      } else {
        debugPrint('❌ Synthèse test échouée: ${response.statusCode}');
      }
    } catch (e) {
      result.synthesisWorking = false;
      result.errors.add('Test de synthèse échoué: $e');
      debugPrint('❌ Test de synthèse échoué: $e');
    }
  }
}

/// Résultat du test de connexion VPS
class VpsTestResult {
  bool basicConnection = false;
  bool healthEndpoint = false;
  bool apiKeyValid = false;
  bool synthesisWorking = false;

  int latency = 0;
  int sampleAudioSize = 0;
  List<String> errors = [];
  VpsTestStatus _overallStatus = VpsTestStatus.failed;

  VpsTestStatus get overallStatus {
    // Auto-calculate if not explicitly set
    if (_overallStatus == VpsTestStatus.failed) {
      if (synthesisWorking && basicConnection) {
        return VpsTestStatus.success;
      } else if (basicConnection) {
        return VpsTestStatus.partial;
      } else {
        return VpsTestStatus.failed;
      }
    }
    return _overallStatus;
  }

  set overallStatus(VpsTestStatus status) {
    _overallStatus = status;
  }

  String get summary {
    return '''
🔧 Test VPS Edge-TTS
Status: ${overallStatus.name.toUpperCase()}
Latence: ${latency}ms

Détails:
• Connexion de base: ${basicConnection ? '✅' : '❌'}
• Health endpoint: ${healthEndpoint ? '✅' : '⚠️'}  
• API Key valide: ${apiKeyValid ? '✅' : '⚠️'}
• Synthèse TTS: ${synthesisWorking ? '✅' : '❌'}

${errors.isNotEmpty ? '\nErreurs:\n${errors.map((e) => '• $e').join('\n')}' : ''}
    ''';
  }
}

enum VpsTestStatus {
  success,
  partial,
  failed,
}
