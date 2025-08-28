import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service de configuration sécurisé pour TTS
/// Gère les API keys et endpoints de manière sécurisée
class TtsConfigService {
  static const _storage = FlutterSecureStorage();

  // Clés de stockage sécurisé
  static const _keyCoquiEndpoint = 'tts_coqui_endpoint';
  static const _keyCoquiApiKey = 'tts_coqui_api_key';
  static const _keyTimeout = 'tts_timeout';
  static const _keyMaxRetries = 'tts_max_retries';
  static const _keyCacheEnabled = 'tts_cache_enabled';
  static const _keyCacheTTLDays = 'tts_cache_ttl_days';
  static const _keyPreferredProvider = 'tts_preferred_provider';

  // Valeurs par défaut sécurisées
  static const _defaultTimeout = 3000; // 3 secondes
  static const _defaultMaxRetries = 3;
  static const _defaultCacheTTLDays = 7;

  final String coquiEndpoint;
  final String coquiApiKey;
  final int timeout;
  final int maxRetries;
  final bool cacheEnabled;
  final int cacheTTLDays;
  final String preferredProvider;

  TtsConfigService({
    required this.coquiEndpoint,
    required this.coquiApiKey,
    this.timeout = _defaultTimeout,
    this.maxRetries = _defaultMaxRetries,
    this.cacheEnabled = true,
    this.cacheTTLDays = _defaultCacheTTLDays,
    this.preferredProvider = 'coqui',
  });

  /// Charge la configuration depuis le stockage sécurisé
  static Future<TtsConfigService> load() async {
    try {
      // Charger les valeurs ou utiliser les défauts
      final endpoint = await _storage.read(key: _keyCoquiEndpoint) ??
          'http://168.231.112.71:8001';

      final apiKey = await _storage.read(key: _keyCoquiApiKey) ?? '';

      final timeout = int.tryParse(
              await _storage.read(key: _keyTimeout) ?? '$_defaultTimeout') ??
          _defaultTimeout;

      final maxRetries = int.tryParse(
              await _storage.read(key: _keyMaxRetries) ??
                  '$_defaultMaxRetries') ??
          _defaultMaxRetries;

      final cacheEnabled =
          (await _storage.read(key: _keyCacheEnabled) ?? 'true') == 'true';

      final cacheTTLDays = int.tryParse(
              await _storage.read(key: _keyCacheTTLDays) ??
                  '$_defaultCacheTTLDays') ??
          _defaultCacheTTLDays;

      final provider =
          await _storage.read(key: _keyPreferredProvider) ?? 'coqui';

      return TtsConfigService(
        coquiEndpoint: endpoint,
        coquiApiKey: apiKey,
        timeout: timeout,
        maxRetries: maxRetries,
        cacheEnabled: cacheEnabled,
        cacheTTLDays: cacheTTLDays,
        preferredProvider: provider,
      );
    } catch (e) {
      // En cas d'erreur, retourner config par défaut
      return TtsConfigService(
        coquiEndpoint: 'http://168.231.112.71:8001',
        coquiApiKey: '',
        timeout: _defaultTimeout,
        maxRetries: _defaultMaxRetries,
        cacheEnabled: true,
        cacheTTLDays: _defaultCacheTTLDays,
        preferredProvider: 'coqui',
      );
    }
  }

  /// Sauvegarde la configuration dans le stockage sécurisé
  Future<void> save() async {
    await _storage.write(key: _keyCoquiEndpoint, value: coquiEndpoint);
    await _storage.write(key: _keyCoquiApiKey, value: coquiApiKey);
    await _storage.write(key: _keyTimeout, value: timeout.toString());
    await _storage.write(key: _keyMaxRetries, value: maxRetries.toString());
    await _storage.write(key: _keyCacheEnabled, value: cacheEnabled.toString());
    await _storage.write(key: _keyCacheTTLDays, value: cacheTTLDays.toString());
    await _storage.write(key: _keyPreferredProvider, value: preferredProvider);
  }

  /// Configure l'API key Coqui de manière sécurisée (une seule fois)
  static Future<void> setupCoquiApiKey(String apiKey) async {
    if (apiKey.isEmpty) return;

    // Valider le format de l'API key
    if (apiKey.length < 32) {
      throw ArgumentError('API key invalide');
    }

    await _storage.write(key: _keyCoquiApiKey, value: apiKey);
  }

  /// Efface toute la configuration (pour logout/reset)
  static Future<void> clear() async {
    await _storage.delete(key: _keyCoquiEndpoint);
    await _storage.delete(key: _keyCoquiApiKey);
    await _storage.delete(key: _keyTimeout);
    await _storage.delete(key: _keyMaxRetries);
    await _storage.delete(key: _keyCacheEnabled);
    await _storage.delete(key: _keyCacheTTLDays);
    await _storage.delete(key: _keyPreferredProvider);
  }

  /// Masque l'API key pour les logs (affiche seulement les 8 premiers caractères)
  String get maskedApiKey {
    if (coquiApiKey.isEmpty) return '<NON_CONFIGURÉ>';
    if (coquiApiKey.length <= 8) return '****';
    return '${coquiApiKey.substring(0, 8)}...';
  }

  Map<String, dynamic> toJson() => {
        'endpoint': coquiEndpoint,
        'apiKey': maskedApiKey, // Jamais l'API key complète
        'timeout': timeout,
        'maxRetries': maxRetries,
        'cacheEnabled': cacheEnabled,
        'cacheTTLDays': cacheTTLDays,
        'preferredProvider': preferredProvider,
      };
}

// Provider Riverpod pour la configuration
final ttsConfigProvider = FutureProvider<TtsConfigService>((ref) async {
  return TtsConfigService.load();
});
