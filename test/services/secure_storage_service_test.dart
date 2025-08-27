import 'package:flutter_test/flutter_test.dart';
import 'package:spiritual_routines/core/services/secure_storage_service.dart';

void main() {
  group('SecureStorageService', () {
    late SecureStorageService storage;
    
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      storage = SecureStorageService.instance;
    });
    
    tearDown(() async {
      // Nettoyer après chaque test
      await storage.deleteAll();
    });
    
    group('Basic Operations', () {
      test('should write and read a value', () async {
        const key = 'test_key';
        const value = 'test_value';
        
        await storage.write(key: key, value: value);
        final result = await storage.read(key: key);
        
        expect(result, equals(value));
      });
      
      test('should return null for non-existent key', () async {
        final result = await storage.read(key: 'non_existent');
        expect(result, isNull);
      });
      
      test('should delete a value', () async {
        const key = 'test_key';
        const value = 'test_value';
        
        await storage.write(key: key, value: value);
        await storage.delete(key: key);
        final result = await storage.read(key: key);
        
        expect(result, isNull);
      });
      
      test('should check if key exists', () async {
        const key = 'test_key';
        const value = 'test_value';
        
        expect(await storage.containsKey(key: key), isFalse);
        
        await storage.write(key: key, value: value);
        expect(await storage.containsKey(key: key), isTrue);
        
        await storage.delete(key: key);
        expect(await storage.containsKey(key: key), isFalse);
      });
      
      test('should read all values', () async {
        await storage.write(key: 'key1', value: 'value1');
        await storage.write(key: 'key2', value: 'value2');
        await storage.write(key: 'key3', value: 'value3');
        
        final all = await storage.readAll();
        
        expect(all.length, equals(3));
        expect(all['key1'], equals('value1'));
        expect(all['key2'], equals('value2'));
        expect(all['key3'], equals('value3'));
      });
      
      test('should delete all values', () async {
        await storage.write(key: 'key1', value: 'value1');
        await storage.write(key: 'key2', value: 'value2');
        
        await storage.deleteAll();
        final all = await storage.readAll();
        
        expect(all.isEmpty, isTrue);
      });
    });
    
    group('Authentication Tokens', () {
      test('should save and retrieve auth tokens', () async {
        const accessToken = 'access_token_123';
        const refreshToken = 'refresh_token_456';
        
        await storage.saveAuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        
        expect(await storage.getAuthToken(), equals(accessToken));
        expect(await storage.getRefreshToken(), equals(refreshToken));
      });
      
      test('should save auth token without refresh token', () async {
        const accessToken = 'access_token_123';
        
        await storage.saveAuthTokens(accessToken: accessToken);
        
        expect(await storage.getAuthToken(), equals(accessToken));
        expect(await storage.getRefreshToken(), isNull);
      });
      
      test('should clear auth data', () async {
        await storage.saveAuthTokens(
          accessToken: 'token',
          refreshToken: 'refresh',
        );
        await storage.write(key: SecureStorageService.keyUserId, value: 'user123');
        await storage.saveUserSession({'test': 'data'});
        
        await storage.clearAuthData();
        
        expect(await storage.getAuthToken(), isNull);
        expect(await storage.getRefreshToken(), isNull);
        expect(await storage.read(key: SecureStorageService.keyUserId), isNull);
        expect(await storage.getUserSession(), isNull);
      });
    });
    
    group('User Session', () {
      test('should save and retrieve user session', () async {
        final session = {
          'user_id': '123',
          'email': 'test@example.com',
          'name': 'Test User',
        };
        
        await storage.saveUserSession(session);
        final retrieved = await storage.getUserSession();
        
        expect(retrieved, isNotNull);
        expect(retrieved!['user_id'], equals('123'));
        expect(retrieved['email'], equals('test@example.com'));
        expect(retrieved['name'], equals('Test User'));
      });
      
      test('should return null for invalid JSON', () async {
        // Simuler un JSON invalide
        await storage.write(
          key: SecureStorageService.keyUserSession,
          value: 'invalid json',
        );
        
        final result = await storage.getUserSession();
        expect(result, isNull);
      });
    });
    
    group('PIN Code', () {
      test('should save and verify PIN code', () async {
        const pin = '1234';
        
        await storage.savePinCode(pin);
        
        expect(await storage.verifyPinCode(pin), isTrue);
        expect(await storage.verifyPinCode('0000'), isFalse);
        expect(await storage.verifyPinCode('1235'), isFalse);
      });
      
      test('should remove PIN code', () async {
        const pin = '1234';
        
        await storage.savePinCode(pin);
        expect(await storage.verifyPinCode(pin), isTrue);
        
        await storage.removePinCode();
        expect(await storage.verifyPinCode(pin), isFalse);
      });
      
      test('should hash PIN before storage', () async {
        const pin = '1234';
        
        await storage.savePinCode(pin);
        
        // Le PIN stocké ne doit pas être le PIN en clair
        final storedPin = await storage.read(key: SecureStorageService.keyPinCode);
        expect(storedPin, isNotNull);
        expect(storedPin, isNot(equals(pin)));
        expect(storedPin!.length, greaterThan(pin.length)); // Un hash est plus long
      });
    });
    
    group('Biometric Settings', () {
      test('should save and retrieve biometric enabled state', () async {
        await storage.setBiometricEnabled(true);
        expect(await storage.isBiometricEnabled(), isTrue);
        
        await storage.setBiometricEnabled(false);
        expect(await storage.isBiometricEnabled(), isFalse);
      });
      
      test('should default to false when not set', () async {
        expect(await storage.isBiometricEnabled(), isFalse);
      });
    });
    
    group('Encryption Key', () {
      test('should generate encryption key', () async {
        final key1 = await storage.generateEncryptionKey();
        
        expect(key1, isNotNull);
        expect(key1.length, greaterThan(0));
        
        // Vérifier que la clé est stockée
        final storedKey = await storage.getEncryptionKey();
        expect(storedKey, equals(key1));
      });
      
      test('should generate new key if none exists', () async {
        final key = await storage.getEncryptionKey();
        
        expect(key, isNotNull);
        expect(key!.length, greaterThan(0));
        
        // Appeler à nouveau devrait retourner la même clé
        final key2 = await storage.getEncryptionKey();
        expect(key2, equals(key));
      });
      
      test('should generate different keys on each generation', () async {
        final key1 = await storage.generateEncryptionKey();
        
        // Attendre un peu pour que le timestamp change
        await Future.delayed(const Duration(milliseconds: 10));
        
        final key2 = await storage.generateEncryptionKey();
        
        expect(key1, isNot(equals(key2)));
      });
    });
    
    group('Last Session Data', () {
      test('should save and retrieve last session data', () async {
        final sessionData = {
          'routine_id': 'routine_123',
          'counter': 42,
          'timestamp': DateTime.now().toIso8601String(),
        };
        
        await storage.saveLastSessionData(sessionData);
        final retrieved = await storage.getLastSessionData();
        
        expect(retrieved, isNotNull);
        expect(retrieved!['routine_id'], equals('routine_123'));
        expect(retrieved['counter'], equals(42));
      });
      
      test('should clear last session data', () async {
        await storage.saveLastSessionData({'test': 'data'});
        await storage.clearLastSessionData();
        
        final result = await storage.getLastSessionData();
        expect(result, isNull);
      });
    });
    
    group('Storage Integrity', () {
      test('should verify storage integrity', () async {
        final isValid = await storage.checkStorageIntegrity();
        expect(isValid, isTrue);
      });
    });
    
    group('Memory Cache', () {
      test('should use memory cache for repeated reads', () async {
        const key = 'cached_key';
        const value = 'cached_value';
        
        await storage.write(key: key, value: value);
        
        // Premier read - depuis le stockage
        final result1 = await storage.read(key: key);
        
        // Second read - devrait utiliser le cache
        final result2 = await storage.read(key: key);
        
        expect(result1, equals(value));
        expect(result2, equals(value));
      });
      
      test('should update cache on write', () async {
        const key = 'cached_key';
        const value1 = 'value1';
        const value2 = 'value2';
        
        await storage.write(key: key, value: value1);
        expect(await storage.read(key: key), equals(value1));
        
        await storage.write(key: key, value: value2);
        expect(await storage.read(key: key), equals(value2));
      });
      
      test('should clear cache on delete', () async {
        const key = 'cached_key';
        const value = 'cached_value';
        
        await storage.write(key: key, value: value);
        await storage.delete(key: key);
        
        expect(await storage.read(key: key), isNull);
      });
    });
  });
}