import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/adapters/adapters.dart';

/// Clés de stockage
const _kModeKey = 'diacritizer_mode'; // 'stub' | 'api'
const _kEndpointKey = 'diacritizer_endpoint'; // string URL
// Cloud TTS
const _kTtsCloudEnabled = 'tts_cloud_enabled'; // 'on' | 'off'
const _kTtsCloudProvider = 'tts_cloud_provider'; // 'google' | 'azure' | 'polly'
const _kTtsCloudApiKey = 'tts_cloud_api_key'; // secret
const _kTtsCloudEndpoint =
    'tts_cloud_endpoint'; // optional (azure region/endpoint)
// AWS Polly specific
const _kTtsAwsAccessKey = 'tts_aws_access_key';
const _kTtsAwsSecretKey = 'tts_aws_secret_key';
const _kTtsAwsRegion = 'tts_aws_region';
// Cloud voice override
const _kTtsCloudVoiceFr = 'tts_cloud_voice_fr';
const _kTtsCloudVoiceAr = 'tts_cloud_voice_ar';
// Auto pre-cache
const _kTtsAutoPrecache = 'tts_auto_precache';
const _kTtsAutoPrecacheScope =
    'tts_auto_precache_scope'; // 'fr' | 'ar' | 'both'
// UI theme
const _kUiDarkMode = 'ui_dark_mode'; // 'on' | 'off'
const _kUiPaletteId = 'ui_palette_id';

class UserSettingsService {
  UserSettingsService() : _storage = AdapterFactories.storage;

  final StorageAdapter _storage;

  // -------- Diacritizer mode ----------
  Future<String?> getDiacritizerMode() async {
    return await _storage.read(key: _kModeKey) ?? 'stub';
  }

  Future<void> setDiacritizerMode(String mode) async {
    // mode attendu: 'stub' ou 'api'
    await _storage.write(key: _kModeKey, value: mode);
  }

  // -------- Diacritizer endpoint ----------
  Future<String?> getDiacritizerEndpoint() async {
    return await _storage.read(key: _kEndpointKey);
  }

  Future<void> setDiacritizerEndpoint(String? url) async {
    if (url == null || url.isEmpty) {
      await _storage.delete(key: _kEndpointKey);
    } else {
      await _storage.write(key: _kEndpointKey, value: url);
    }
  }

  // -------- Generic small KV helpers (for simple UI prefs) ----------
  Future<String?> readValue(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> writeValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // -------- UI: Dark mode ----------
  Future<bool> getUiDarkMode() async {
    return (await _storage.read(key: _kUiDarkMode)) == 'on';
  }

  Future<void> setUiDarkMode(bool dark) async {
    await _storage.write(key: _kUiDarkMode, value: dark ? 'on' : 'off');
  }

  // -------- UI: Palette selection ----------
  Future<String> getUiPaletteId() async {
    return await _storage.read(key: _kUiPaletteId) ?? 'modern';
  }

  Future<void> setUiPaletteId(String id) async {
    await _storage.write(key: _kUiPaletteId, value: id);
  }

  // -------- Cloud TTS helpers ----------
  Future<bool> getCloudTtsEnabled() async {
    return (await _storage.read(key: _kTtsCloudEnabled)) == 'on';
  }

  Future<void> setCloudTtsEnabled(bool enabled) async {
    await _storage.write(key: _kTtsCloudEnabled, value: enabled ? 'on' : 'off');
  }

  Future<String> getCloudTtsProvider() async {
    return await _storage.read(key: _kTtsCloudProvider) ?? 'google';
  }

  Future<void> setCloudTtsProvider(String provider) async {
    await _storage.write(key: _kTtsCloudProvider, value: provider);
  }

  Future<String?> getCloudTtsApiKey() async {
    return await _storage.readSecure(key: _kTtsCloudApiKey);
  }

  Future<void> setCloudTtsApiKey(String? key) async {
    if (key == null || key.isEmpty) {
      await _storage.delete(key: _kTtsCloudApiKey);
    } else {
      await _storage.writeSecure(key: _kTtsCloudApiKey, value: key);
    }
  }

  Future<String?> getCloudTtsEndpoint() async {
    return await _storage.read(key: _kTtsCloudEndpoint);
  }

  Future<void> setCloudTtsEndpoint(String? endpoint) async {
    if (endpoint == null || endpoint.isEmpty) {
      await _storage.delete(key: _kTtsCloudEndpoint);
    } else {
      await _storage.write(key: _kTtsCloudEndpoint, value: endpoint);
    }
  }

  // -------- AWS Polly creds ----------
  Future<String?> getAwsAccessKey() async =>
      await _storage.readSecure(key: _kTtsAwsAccessKey);
  Future<void> setAwsAccessKey(String? v) async {
    if (v == null || v.isEmpty) {
      await _storage.delete(key: _kTtsAwsAccessKey);
    } else {
      await _storage.writeSecure(key: _kTtsAwsAccessKey, value: v);
    }
  }

  Future<String?> getAwsSecretKey() async =>
      await _storage.readSecure(key: _kTtsAwsSecretKey);
  Future<void> setAwsSecretKey(String? v) async {
    if (v == null || v.isEmpty) {
      await _storage.delete(key: _kTtsAwsSecretKey);
    } else {
      await _storage.writeSecure(key: _kTtsAwsSecretKey, value: v);
    }
  }

  Future<String?> getAwsRegion() async =>
      await _storage.read(key: _kTtsAwsRegion);
  Future<void> setAwsRegion(String? v) async {
    if (v == null || v.isEmpty) {
      await _storage.delete(key: _kTtsAwsRegion);
    } else {
      await _storage.write(key: _kTtsAwsRegion, value: v);
    }
  }

  // -------- Cloud voice overrides ----------
  Future<String?> getCloudVoiceFrName() async =>
      await _storage.read(key: _kTtsCloudVoiceFr);
  Future<void> setCloudVoiceFrName(String? v) async {
    if (v == null || v.isEmpty) {
      await _storage.delete(key: _kTtsCloudVoiceFr);
    } else {
      await _storage.write(key: _kTtsCloudVoiceFr, value: v);
    }
  }

  Future<String?> getCloudVoiceArName() async =>
      await _storage.read(key: _kTtsCloudVoiceAr);
  Future<void> setCloudVoiceArName(String? v) async {
    if (v == null || v.isEmpty) {
      await _storage.delete(key: _kTtsCloudVoiceAr);
    } else {
      await _storage.write(key: _kTtsCloudVoiceAr, value: v);
    }
  }

  // -------- Auto pre-cache toggle ----------
  Future<bool> getAutoPrecacheEnabled() async =>
      (await _storage.read(key: _kTtsAutoPrecache)) == 'on';
  Future<void> setAutoPrecacheEnabled(bool v) async =>
      _storage.write(key: _kTtsAutoPrecache, value: v ? 'on' : 'off');

  Future<String> getAutoPrecacheScope() async {
    return await _storage.read(key: _kTtsAutoPrecacheScope) ?? 'both';
  }

  Future<void> setAutoPrecacheScope(String scope) async {
    // accepted: 'fr' | 'ar' | 'both'
    await _storage.write(key: _kTtsAutoPrecacheScope, value: scope);
  }
}

/// Provider simple à lire dans l’UI: ref.read(userSettingsServiceProvider)
final userSettingsServiceProvider = Provider<UserSettingsService>(
  (ref) => UserSettingsService(),
);
