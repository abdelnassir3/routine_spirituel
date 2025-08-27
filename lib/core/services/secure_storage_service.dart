import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

/// Service de stockage sécurisé pour les données sensibles
/// 
/// Utilise flutter_secure_storage pour stocker de manière sécurisée :
/// - Tokens d'authentification
/// - Sessions utilisateur
/// - Clés API temporaires
/// - Données sensibles en cache
class SecureStorageService {
  static SecureStorageService? _instance;
  late final FlutterSecureStorage _storage;
  
  // Cache en mémoire pour éviter les lectures répétées
  final Map<String, String?> _memoryCache = {};
  
  // Singleton
  static SecureStorageService get instance {
    _instance ??= SecureStorageService._();
    return _instance!;
  }
  
  SecureStorageService._() {
    // Configuration optimale pour chaque plateforme
    const androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,
      // Réinitialiser le stockage si l'app est réinstallée
      resetOnError: true,
    );
    
    const iosOptions = IOSOptions(
      // Utiliser le trousseau iCloud si disponible
      accessibility: KeychainAccessibility.first_unlock_this_device,
      // Synchroniser avec iCloud Keychain (optionnel)
      synchronizable: false,
    );
    
    const webOptions = WebOptions();
    const macOsOptions = MacOsOptions();
    const windowsOptions = WindowsOptions();
    const linuxOptions = LinuxOptions();
    
    _storage = const FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
      webOptions: webOptions,
      mOptions: macOsOptions,
      wOptions: windowsOptions,
      lOptions: linuxOptions,
    );
  }
  
  // ===== Keys standardisées =====
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserSession = 'user_session';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyPinCode = 'pin_code';
  static const String keyEncryptionKey = 'encryption_key';
  static const String keyLastSessionData = 'last_session_data';
  
  // ===== Méthodes de base =====
  
  /// Stocker une valeur de manière sécurisée
  Future<void> write({
    required String key,
    required String? value,
  }) async {
    try {
      if (value == null) {
        await delete(key: key);
        return;
      }
      
      await _storage.write(key: key, value: value);
      _memoryCache[key] = value;
      
      if (kDebugMode) {
        print('SecureStorage: Stored key=$key');
      }
    } catch (e) {
      _handleStorageError('write', e);
    }
  }
  
  /// Lire une valeur sécurisée
  Future<String?> read({required String key}) async {
    try {
      // Vérifier le cache mémoire d'abord
      if (_memoryCache.containsKey(key)) {
        return _memoryCache[key];
      }
      
      final value = await _storage.read(key: key);
      _memoryCache[key] = value;
      return value;
    } catch (e) {
      _handleStorageError('read', e);
      return null;
    }
  }
  
  /// Supprimer une valeur
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
      _memoryCache.remove(key);
      
      if (kDebugMode) {
        print('SecureStorage: Deleted key=$key');
      }
    } catch (e) {
      _handleStorageError('delete', e);
    }
  }
  
  /// Supprimer toutes les valeurs
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      _memoryCache.clear();
      
      if (kDebugMode) {
        print('SecureStorage: Cleared all data');
      }
    } catch (e) {
      _handleStorageError('deleteAll', e);
    }
  }
  
  /// Vérifier si une clé existe
  Future<bool> containsKey({required String key}) async {
    try {
      if (_memoryCache.containsKey(key)) {
        return _memoryCache[key] != null;
      }
      
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      _handleStorageError('containsKey', e);
      return false;
    }
  }
  
  /// Lire toutes les clés
  Future<Map<String, String>> readAll() async {
    try {
      final all = await _storage.readAll();
      _memoryCache.addAll(all);
      return all;
    } catch (e) {
      _handleStorageError('readAll', e);
      return {};
    }
  }
  
  // ===== Méthodes spécialisées =====
  
  /// Stocker les tokens d'authentification
  Future<void> saveAuthTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await write(key: keyAuthToken, value: accessToken);
    if (refreshToken != null) {
      await write(key: keyRefreshToken, value: refreshToken);
    }
  }
  
  /// Récupérer le token d'accès
  Future<String?> getAuthToken() async {
    return read(key: keyAuthToken);
  }
  
  /// Récupérer le refresh token
  Future<String?> getRefreshToken() async {
    return read(key: keyRefreshToken);
  }
  
  /// Stocker la session utilisateur
  Future<void> saveUserSession(Map<String, dynamic> session) async {
    final jsonString = jsonEncode(session);
    await write(key: keyUserSession, value: jsonString);
  }
  
  /// Récupérer la session utilisateur
  Future<Map<String, dynamic>?> getUserSession() async {
    final jsonString = await read(key: keyUserSession);
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('SecureStorage: Failed to decode user session: $e');
      }
      return null;
    }
  }
  
  /// Nettoyer toutes les données d'authentification
  Future<void> clearAuthData() async {
    await delete(key: keyAuthToken);
    await delete(key: keyRefreshToken);
    await delete(key: keyUserId);
    await delete(key: keyUserSession);
  }
  
  // ===== Biométrie et PIN =====
  
  /// Activer/désactiver l'authentification biométrique
  Future<void> setBiometricEnabled(bool enabled) async {
    await write(
      key: keyBiometricEnabled,
      value: enabled.toString(),
    );
  }
  
  /// Vérifier si la biométrie est activée
  Future<bool> isBiometricEnabled() async {
    final value = await read(key: keyBiometricEnabled);
    return value == 'true';
  }
  
  /// Stocker un code PIN hashé
  Future<void> savePinCode(String pin) async {
    // Hasher le PIN avant de le stocker
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    await write(key: keyPinCode, value: digest.toString());
  }
  
  /// Vérifier un code PIN
  Future<bool> verifyPinCode(String pin) async {
    final storedHash = await read(key: keyPinCode);
    if (storedHash == null) return false;
    
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString() == storedHash;
  }
  
  /// Supprimer le code PIN
  Future<void> removePinCode() async {
    await delete(key: keyPinCode);
  }
  
  // ===== Clés de chiffrement =====
  
  /// Générer et stocker une clé de chiffrement
  Future<String> generateEncryptionKey() async {
    // Générer une clé aléatoire
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.toString() + UniqueKey().toString();
    final bytes = utf8.encode(random);
    final digest = sha256.convert(bytes);
    final key = digest.toString();
    
    await write(key: keyEncryptionKey, value: key);
    return key;
  }
  
  /// Récupérer la clé de chiffrement
  Future<String?> getEncryptionKey() async {
    var key = await read(key: keyEncryptionKey);
    
    // Si pas de clé, en générer une
    if (key == null) {
      key = await generateEncryptionKey();
    }
    
    return key;
  }
  
  // ===== Session Recovery =====
  
  /// Sauvegarder les données de la dernière session
  Future<void> saveLastSessionData(Map<String, dynamic> data) async {
    final jsonString = jsonEncode(data);
    await write(key: keyLastSessionData, value: jsonString);
  }
  
  /// Récupérer les données de la dernière session
  Future<Map<String, dynamic>?> getLastSessionData() async {
    final jsonString = await read(key: keyLastSessionData);
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('SecureStorage: Failed to decode last session: $e');
      }
      return null;
    }
  }
  
  /// Effacer les données de session
  Future<void> clearLastSessionData() async {
    await delete(key: keyLastSessionData);
  }
  
  // ===== Migration et maintenance =====
  
  /// Migrer les données depuis SharedPreferences (si nécessaire)
  Future<void> migrateFromSharedPreferences() async {
    // Cette méthode peut être utilisée pour migrer
    // des données sensibles depuis SharedPreferences
    // vers le stockage sécurisé
  }
  
  /// Vérifier l'intégrité du stockage
  Future<bool> checkStorageIntegrity() async {
    try {
      // Tester une lecture/écriture
      const testKey = '_integrity_check';
      const testValue = 'test';
      
      await write(key: testKey, value: testValue);
      final readValue = await read(key: testKey);
      await delete(key: testKey);
      
      return readValue == testValue;
    } catch (e) {
      if (kDebugMode) {
        print('SecureStorage: Integrity check failed: $e');
      }
      return false;
    }
  }
  
  // ===== Error handling =====
  
  void _handleStorageError(String operation, dynamic error) {
    if (kDebugMode) {
      print('SecureStorage: Error in $operation: $error');
    }
    
    // En production, logger l'erreur sans exposer de détails
    // Possibilité d'envoyer à Sentry ou autre service de monitoring
  }
  
  // ===== Debug utilities =====
  
  /// [DEBUG ONLY] Afficher toutes les clés stockées
  Future<void> debugPrintAllKeys() async {
    if (!kDebugMode) return;
    
    final all = await readAll();
    print('=== SecureStorage Debug ===');
    print('Total keys: ${all.length}');
    for (final key in all.keys) {
      // Ne pas afficher les valeurs pour la sécurité
      print('  - $key: [REDACTED]');
    }
    print('===========================');
  }
}