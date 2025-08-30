import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_adapter.dart';

/// Implémentation mobile du stockage sécurisé (iOS/Android)
/// Utilise flutter_secure_storage pour les données sensibles
/// et SharedPreferences pour les données non critiques
class MobileStorageAdapter implements StorageAdapter {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  @override
  Future<void> write({
    required String key,
    required String value,
  }) async {
    if (kDebugMode) {
      debugPrint('📱 Mobile Storage: Writing key "$key"');
    }

    try {
      // Utiliser le stockage sécurisé par défaut sur mobile
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '❌ Secure storage failed, falling back to SharedPreferences');
      }
      // Fallback vers SharedPreferences si le stockage sécurisé échoue
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
  }

  @override
  Future<String?> read({required String key}) async {
    if (kDebugMode) {
      debugPrint('📱 Mobile Storage: Reading key "$key"');
    }

    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Secure storage read failed, trying SharedPreferences');
      }
      // Fallback vers SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
  }

  @override
  Future<void> delete({required String key}) async {
    if (kDebugMode) {
      debugPrint('📱 Mobile Storage: Deleting key "$key"');
    }

    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Secure storage delete failed, trying SharedPreferences');
      }
      // Fallback vers SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    }
  }

  @override
  Future<void> deleteAll() async {
    if (kDebugMode) {
      debugPrint('📱 Mobile Storage: Deleting all keys');
    }

    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '❌ Secure storage deleteAll failed, trying SharedPreferences');
      }
      // Fallback vers SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

  @override
  Future<bool> containsKey({required String key}) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value != null;
    } catch (e) {
      // Fallback vers SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(key);
    }
  }

  @override
  Future<Set<String>> readAll() async {
    if (kDebugMode) {
      debugPrint('📱 Mobile Storage: Reading all keys');
    }

    try {
      final allValues = await _secureStorage.readAll();
      return allValues.keys.toSet();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Secure storage readAll failed, trying SharedPreferences');
      }
      // Fallback vers SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getKeys();
    }
  }

  @override
  Future<void> writeSecure({
    required String key,
    required String value,
    String? groupId,
  }) async {
    if (kDebugMode) {
      debugPrint('🔐 Mobile Storage: Writing secure key "$key"');
    }

    // Préfixer avec groupId si fourni
    final secureKey = groupId != null ? '${groupId}_$key' : key;

    await _secureStorage.write(key: secureKey, value: value);
  }

  @override
  Future<String?> readSecure({
    required String key,
    String? groupId,
  }) async {
    if (kDebugMode) {
      debugPrint('🔐 Mobile Storage: Reading secure key "$key"');
    }

    // Préfixer avec groupId si fourni
    final secureKey = groupId != null ? '${groupId}_$key' : key;

    return await _secureStorage.read(key: secureKey);
  }

  @override
  bool get isSecureStorageAvailable => true; // Toujours disponible sur mobile

  @override
  bool get supportsEncryption =>
      true; // flutter_secure_storage chiffre automatiquement
}
