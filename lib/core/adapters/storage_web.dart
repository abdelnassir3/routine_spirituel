import 'dart:convert';
import 'dart:html' as html;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'storage_adapter.dart';

/// Implémentation Web du stockage (localStorage avec chiffrement basique)
/// Note: Le stockage web n'est pas aussi sécurisé que le Keychain iOS/Android
class WebStorageAdapter implements StorageAdapter {
  static const String _prefix = 'spiritual_routines_';
  static const String _securePrefix = 'secure_';

  // Clé de chiffrement simple (en production, utiliser une vraie dérivation)
  static const String _encryptionKey = 'SpiritualRoutines2025SecureKey';

  String _getStorageKey(String key, {bool secure = false}) {
    return secure ? '$_prefix$_securePrefix$key' : '$_prefix$key';
  }

  String _simpleEncrypt(String value) {
    try {
      // Chiffrement XOR simple (pour la démo - pas cryptographiquement sûr)
      final keyBytes = utf8.encode(_encryptionKey);
      final valueBytes = utf8.encode(value);
      final encrypted = <int>[];

      for (int i = 0; i < valueBytes.length; i++) {
        encrypted.add(valueBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return base64.encode(encrypted);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Encryption failed: $e');
      }
      return value; // Fallback sans chiffrement
    }
  }

  String _simpleDecrypt(String encryptedValue) {
    try {
      final encrypted = base64.decode(encryptedValue);
      final keyBytes = utf8.encode(_encryptionKey);
      final decrypted = <int>[];

      for (int i = 0; i < encrypted.length; i++) {
        decrypted.add(encrypted[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(decrypted);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Decryption failed: $e');
      }
      return encryptedValue; // Fallback sans déchiffrement
    }
  }

  @override
  Future<void> write({
    required String key,
    required String value,
  }) async {
    if (kDebugMode) {
      debugPrint('🌐 Web Storage: Writing key "$key"');
    }

    final storageKey = _getStorageKey(key);
    html.window.localStorage[storageKey] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    if (kDebugMode) {
      debugPrint('🌐 Web Storage: Reading key "$key"');
    }

    final storageKey = _getStorageKey(key);
    return html.window.localStorage[storageKey];
  }

  @override
  Future<void> delete({required String key}) async {
    if (kDebugMode) {
      debugPrint('🌐 Web Storage: Deleting key "$key"');
    }

    final storageKey = _getStorageKey(key);
    html.window.localStorage.remove(storageKey);
  }

  @override
  Future<void> deleteAll() async {
    if (kDebugMode) {
      debugPrint('🌐 Web Storage: Deleting all keys');
    }

    // Supprimer seulement nos clés (celles avec notre préfixe)
    final keysToRemove = <String>[];
    for (final key in html.window.localStorage.keys) {
      if (key.startsWith(_prefix)) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      html.window.localStorage.remove(key);
    }
  }

  @override
  Future<bool> containsKey({required String key}) async {
    final storageKey = _getStorageKey(key);
    return html.window.localStorage.containsKey(storageKey);
  }

  @override
  Future<Set<String>> readAll() async {
    if (kDebugMode) {
      debugPrint('🌐 Web Storage: Reading all keys');
    }

    final ourKeys = <String>{};
    for (final key in html.window.localStorage.keys) {
      if (key.startsWith(_prefix)) {
        // Enlever le préfixe pour retourner la clé originale
        final originalKey = key.substring(_prefix.length);
        if (!originalKey.startsWith(_securePrefix)) {
          ourKeys.add(originalKey);
        }
      }
    }

    return ourKeys;
  }

  @override
  Future<void> writeSecure({
    required String key,
    required String value,
    String? groupId,
  }) async {
    if (kDebugMode) {
      debugPrint('🔐 Web Storage: Writing secure key "$key"');
    }

    final secureKey = groupId != null ? '${groupId}_$key' : key;
    final storageKey = _getStorageKey(secureKey, secure: true);
    final encryptedValue = _simpleEncrypt(value);

    html.window.localStorage[storageKey] = encryptedValue;
  }

  @override
  Future<String?> readSecure({
    required String key,
    String? groupId,
  }) async {
    if (kDebugMode) {
      debugPrint('🔐 Web Storage: Reading secure key "$key"');
    }

    final secureKey = groupId != null ? '${groupId}_$key' : key;
    final storageKey = _getStorageKey(secureKey, secure: true);
    final encryptedValue = html.window.localStorage[storageKey];

    if (encryptedValue == null) {
      return null;
    }

    return _simpleDecrypt(encryptedValue);
  }

  @override
  bool get isSecureStorageAvailable => true; // localStorage toujours disponible

  @override
  bool get supportsEncryption => true; // Support chiffrement basique
}
