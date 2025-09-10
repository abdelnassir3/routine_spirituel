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
    TestWidgetsFlutterBinding.ensureInitialized();
    
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
  });

  group('CoquiTtsService - Méthodes de détection', () {
    late CoquiTtsService testService;

    setUp(() {
      // Créer un service minimal juste pour tester les méthodes publiques
      testService = CoquiTtsService(
        config: config,
        cache: mockCache,
        dio: Dio(), // Utiliser un vrai Dio car ces tests n'appellent pas l'API
      );
    });

    tearDown(() {
      testService.dispose();
    });

    test('devrait détecter la langue arabe correctement', () {
      // Test avec texte arabe
      expect(
        testService.detectLanguage('السلام عليكم', 'fr-FR'),
        equals('ar'),
      );

      // Test avec texte français
      expect(
        testService.detectLanguage('Bonjour le monde', 'fr-FR'),
        equals('fr'),
      );

      // Test avec voix arabe explicite
      expect(
        testService.detectLanguage('Hello', 'ar-SA'),
        equals('ar'),
      );
    });

    test('devrait déterminer le type de voix correctement', () {
      // Test voix féminine
      expect(
        testService.getVoiceType('fr-FR-female'),
        equals('female'),
      );

      // Test voix masculine (défaut)
      expect(
        testService.getVoiceType('fr-FR'),
        equals('male'),
      );

      expect(
        testService.getVoiceType('ar-SA-male'),
        equals('male'),
      );
    });

    test('devrait convertir la vitesse en rate correctement', () {
      // Vitesse normale
      expect(
        testService.speedToRate(1.0),
        equals('+0%'),
      );

      // Vitesse augmentée
      expect(
        testService.speedToRate(1.5),
        equals('+50%'),
      );

      // Vitesse réduite
      expect(
        testService.speedToRate(0.5),
        equals('-50%'),
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

