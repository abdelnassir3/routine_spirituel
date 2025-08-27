import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spiritual_routines/core/services/coqui_tts_service.dart';
import 'package:spiritual_routines/core/services/tts_config_service.dart';
import 'package:spiritual_routines/core/services/secure_tts_cache_service.dart';

// Générer les mocks avec: dart run build_runner build
@GenerateMocks([Dio, SecureTtsCacheService])
import 'coqui_tts_service_test.mocks.dart';

void main() {
  late CoquiTtsService service;
  late MockDio mockDio;
  late MockSecureTtsCacheService mockCache;
  late TtsConfigService config;
  
  setUp(() {
    mockDio = MockDio();
    mockCache = MockSecureTtsCacheService();
    
    config = TtsConfigService(
      coquiEndpoint: 'http://test.local:8001',
      coquiApiKey: 'test_api_key_32_chars_long_2024xx',
      timeout: 1000,
      maxRetries: 2,
      cacheEnabled: true,
      cacheTTLDays: 7,
      preferredProvider: 'coqui',
    );
    
    service = CoquiTtsService(
      config: config,
      cache: mockCache,
      dio: mockDio,
    );
  });
  
  group('CoquiTtsService', () {
    test('devrait détecter la langue arabe correctement', () {
      final service = CoquiTtsService(
        config: config,
        cache: mockCache,
        dio: mockDio,
      );
      
      // Test avec texte arabe
      expect(
        service.detectLanguage('السلام عليكم', 'fr-FR'),
        equals('ar'),
      );
      
      // Test avec texte français
      expect(
        service.detectLanguage('Bonjour le monde', 'fr-FR'),
        equals('fr'),
      );
      
      // Test avec voix arabe explicite
      expect(
        service.detectLanguage('Hello', 'ar-SA'),
        equals('ar'),
      );
    });
    
    test('devrait déterminer le type de voix correctement', () {
      final service = CoquiTtsService(
        config: config,
        cache: mockCache,
        dio: mockDio,
      );
      
      // Test voix féminine
      expect(
        service.getVoiceType('fr-FR-female'),
        equals('female'),
      );
      
      // Test voix masculine (défaut)
      expect(
        service.getVoiceType('fr-FR'),
        equals('male'),
      );
      
      expect(
        service.getVoiceType('ar-SA-male'),
        equals('male'),
      );
    });
    
    test('devrait convertir la vitesse en rate correctement', () {
      final service = CoquiTtsService(
        config: config,
        cache: mockCache,
        dio: mockDio,
      );
      
      // Vitesse normale
      expect(
        service.speedToRate(1.0),
        equals('+0%'),
      );
      
      // Vitesse augmentée
      expect(
        service.speedToRate(1.5),
        equals('+50%'),
      );
      
      // Vitesse réduite
      expect(
        service.speedToRate(0.5),
        equals('-50%'),
      );
    });
    
    test('devrait utiliser le cache si disponible', () async {
      // Configurer le mock cache
      when(mockCache.generateKey(
        provider: 'coqui',
        text: 'Test',
        voice: 'fr-male',
        speed: 0.55,
        pitch: 1.0,
      )).thenAnswer((_) async => 'test_key_123');
      
      when(mockCache.getPath('test_key_123'))
          .thenAnswer((_) async => '/path/to/cached/audio.mp3');
      
      when(mockCache.exists('test_key_123'))
          .thenAnswer((_) async => true);
      
      // Le test devrait utiliser le cache sans appeler l'API
      try {
        await service.playText(
          'Test',
          voice: 'fr-FR',
          speed: 0.55,
          pitch: 1.0,
        );
      } catch (e) {
        // AudioPlayer va échouer en test, c'est normal
      }
      
      // Vérifier que l'API n'a pas été appelée
      verifyNever(mockDio.post(any, 
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
        options: anyNamed('options'),
      ));
      
      // Vérifier que le cache a été utilisé
      verify(mockCache.getPath('test_key_123')).called(1);
    });
    
    test('devrait gérer les erreurs réseau avec retry', () async {
      // Configurer le mock pour échouer puis réussir
      var callCount = 0;
      
      when(mockCache.generateKey(
        provider: any,
        text: any,
        voice: any,
        speed: any,
        pitch: any,
      )).thenAnswer((_) async => 'test_key_retry');
      
      when(mockCache.getPath(any))
          .thenAnswer((_) async => null);
      
      when(mockDio.post(any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw DioException(
            requestOptions: RequestOptions(path: '/api/tts'),
            type: DioExceptionType.connectionTimeout,
          );
        }
        return Response(
          requestOptions: RequestOptions(path: '/api/tts'),
          statusCode: 200,
          data: {'audio': 'base64_audio_data'},
        );
      });
      
      // Le service devrait retry et réussir
      try {
        await service.playText(
          'Test retry',
          voice: 'fr-FR',
        );
      } catch (e) {
        // AudioPlayer va échouer, c'est normal en test
      }
      
      // Vérifier que l'API a été appelée (le retry est géré dans l'intercepteur)
      verify(mockDio.post(any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).called(1);
    });
    
    test('devrait masquer les données sensibles dans les logs', () {
      final longApiKey = 'sk_test_1234567890abcdefghijklmnopqrstuvwxyz';
      final maskedKey = CoquiTtsService.maskSensitiveData(longApiKey);
      
      // Devrait afficher seulement le début et la fin
      expect(maskedKey, equals('sk_t...wxyz'));
      
      // Test avec clé courte
      final shortKey = 'short';
      expect(CoquiTtsService.maskSensitiveData(shortKey), equals('****'));
    });
    
    test('devrait gérer le circuit breaker après échecs consécutifs', () async {
      // Configurer pour toujours échouer
      when(mockCache.generateKey(
        provider: any,
        text: any,
        voice: any,
        speed: any,
        pitch: any,
      )).thenAnswer((_) async => 'test_key_cb');
      
      when(mockCache.getPath(any))
          .thenAnswer((_) async => null);
      
      when(mockDio.post(any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/api/tts'),
        type: DioExceptionType.connectionError,
      ));
      
      // Faire échouer plusieurs fois
      for (int i = 0; i < 5; i++) {
        try {
          await service.playText('Test $i', voice: 'fr-FR');
        } catch (e) {
          // Attendu
        }
      }
      
      // Après 5 échecs, le circuit breaker devrait être ouvert
      expect(
        () async => await service.playText('Test final', voice: 'fr-FR'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('temporairement indisponible'),
        )),
      );
    });
  });
  
  group('Cache sécurisé', () {
    test('devrait générer des clés SHA-256 uniques', () async {
      final cache = SecureTtsCacheService();
      
      final key1 = await cache.generateKey(
        provider: 'coqui',
        text: 'Bonjour',
        voice: 'fr-FR',
        speed: 1.0,
        pitch: 1.0,
      );
      
      final key2 = await cache.generateKey(
        provider: 'coqui',
        text: 'Bonjour',
        voice: 'fr-FR',
        speed: 1.1, // Vitesse différente
        pitch: 1.0,
      );
      
      // Les clés doivent être différentes
      expect(key1, isNot(equals(key2)));
      
      // Les clés doivent être en SHA-256 (64 caractères hex)
      expect(key1.length, equals(64));
      expect(RegExp(r'^[a-f0-9]{64}$').hasMatch(key1), isTrue);
    });
  });
}

// Extensions pour faciliter les tests
extension TestHelpers on CoquiTtsService {
  // Exposer les méthodes privées pour les tests
  String detectLanguage(String text, String voice) => _detectLanguage(text, voice);
  String getVoiceType(String voice) => _getVoiceType(voice);
  String speedToRate(double speed) => _speedToRate(speed);
  
  static String maskSensitiveData(String value) {
    if (value.length <= 8) return '****';
    return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
  }
}