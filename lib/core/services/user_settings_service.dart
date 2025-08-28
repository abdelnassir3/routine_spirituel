import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift; // ✅ pour Value()

import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';
import 'package:spiritual_routines/features/reader/reading_prefs.dart';
import 'package:spiritual_routines/design_system/theme.dart';

class UserSettingsService {
  UserSettingsService(this._ref);
  final Ref _ref;
  static const _defaultId = 'local';

  Future<UserSettingsRow> _getOrCreate() async {
    final dao = _ref.read(userSettingsDaoProvider);
    final existing = await dao.getById(_defaultId);
    if (existing != null) return existing;
    await dao.upsert(UserSettingsCompanion.insert(id: _defaultId));
    return (await dao.getById(_defaultId))!;
  }

  Future<BilingualDisplay> getDisplayPreference() async {
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    final v = (map['readingDisplay'] as String?) ?? 'both';
    switch (v) {
      case 'arOnly':
        return BilingualDisplay.arOnly;
      case 'frOnly':
        return BilingualDisplay.frOnly;
      default:
        return BilingualDisplay.both;
    }
  }

  Future<void> setDisplayPreference(BilingualDisplay mode) async {
    final dao = _ref.read(userSettingsDaoProvider);
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    map['readingDisplay'] = switch (mode) {
      BilingualDisplay.arOnly => 'arOnly',
      BilingualDisplay.frOnly => 'frOnly',
      BilingualDisplay.both => 'both',
    };
    await dao.upsert(UserSettingsCompanion(
      id: const drift.Value(_defaultId),
      fontPrefs: drift.Value(jsonEncode(map)),
    ));
  }

  Future<String?> getDiacritizerEndpoint() async {
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    return map['diacritizerEndpoint'] as String?;
  }

  Future<void> setDiacritizerEndpoint(String? endpoint) async {
    final dao = _ref.read(userSettingsDaoProvider);
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    if (endpoint == null || endpoint.trim().isEmpty) {
      map.remove('diacritizerEndpoint');
    } else {
      map['diacritizerEndpoint'] = endpoint.trim();
    }
    await dao.upsert(UserSettingsCompanion(
      id: const drift.Value(_defaultId),
      fontPrefs: drift.Value(jsonEncode(map)),
    ));
  }

  Future<String> getDiacritizerMode() async {
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    return (map['diacritizerMode'] as String?) ?? 'stub';
  }

  Future<void> setDiacritizerMode(String mode) async {
    final dao = _ref.read(userSettingsDaoProvider);
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    map['diacritizerMode'] = mode;
    await dao.upsert(UserSettingsCompanion(
      id: const drift.Value(_defaultId),
      fontPrefs: drift.Value(jsonEncode(map)),
    ));
  }

  // -------- OCR engine preference ----------
  // Values: 'auto' (default), 'mlkit', 'tesseract', 'stub'
  Future<String> getOcrEngine() async {
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    return (map['ocrEngine'] as String?) ?? 'auto';
  }

  Future<void> setOcrEngine(String engine) async {
    final dao = _ref.read(userSettingsDaoProvider);
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    map['ocrEngine'] = engine;
    await dao.upsert(UserSettingsCompanion(
      id: const drift.Value(_defaultId),
      fontPrefs: drift.Value(jsonEncode(map)),
    ));
  }

  // -------- OCR PDF page limit ----------
  Future<int> getOcrPdfPageLimit() async {
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    final v = (map['ocrPdfPageLimit'] as num?)?.toInt();
    if (v == null || v <= 0) return 5;
    return v.clamp(1, 20);
  }

  Future<void> setOcrPdfPageLimit(int limit) async {
    final dao = _ref.read(userSettingsDaoProvider);
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    map['ocrPdfPageLimit'] = limit.clamp(1, 20);
    await dao.upsert(UserSettingsCompanion(
      id: const drift.Value(_defaultId),
      fontPrefs: drift.Value(jsonEncode(map)),
    ));
  }

  // -------- TTS preferences ----------
  Future<double> getTtsSpeed() async {
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    final v = (map['ttsSpeed'] as num?)?.toDouble();
    if (v == null)
      return 0.9; // Vitesse normale par défaut (90% = proche de la normale)
    // Clamp to allowed range [0.5, 1.5]
    if (v < 0.5) return 0.5;
    if (v > 1.5) return 1.5;
    return v;
  }

  Future<void> setTtsSpeed(double speed) async {
    final dao = _ref.read(userSettingsDaoProvider);
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    map['ttsSpeed'] = speed.clamp(0.5, 1.5);
    await dao.upsert(UserSettingsCompanion(
      id: const drift.Value(_defaultId),
      fontPrefs: drift.Value(jsonEncode(map)),
    ));
  }

  Future<double> getTtsPitch() async {
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    final v = (map['ttsPitch'] as num?)?.toDouble();
    if (v == null) return 1.02;
    if (v < 0.8) return 0.8;
    if (v > 1.2) return 1.2;
    return v;
  }

  Future<void> setTtsPitch(double pitch) async {
    final dao = _ref.read(userSettingsDaoProvider);
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    map['ttsPitch'] = pitch.clamp(0.8, 1.2);
    await dao.upsert(UserSettingsCompanion(
      id: const drift.Value(_defaultId),
      fontPrefs: drift.Value(jsonEncode(map)),
    ));
  }

  Future<String> getTtsLocaleFr() async {
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    return (map['ttsLocaleFr'] as String?) ?? 'fr-FR';
  }

  Future<void> setTtsLocaleFr(String locale) async {
    final dao = _ref.read(userSettingsDaoProvider);
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    map['ttsLocaleFr'] = locale;
    await dao.upsert(UserSettingsCompanion(
      id: const drift.Value(_defaultId),
      fontPrefs: drift.Value(jsonEncode(map)),
    ));
  }

  Future<String> getTtsLocaleAr() async {
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    return (map['ttsLocaleAr'] as String?) ?? 'ar-SA';
  }

  Future<void> setTtsLocaleAr(String locale) async {
    final dao = _ref.read(userSettingsDaoProvider);
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    map['ttsLocaleAr'] = locale;
    await dao.upsert(UserSettingsCompanion(
      id: const drift.Value(_defaultId),
      fontPrefs: drift.Value(jsonEncode(map)),
    ));
  }

  Future<String?> getTtsVoiceFrName() async {
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    final v = map['ttsVoiceFrName'];
    return v is String && v.trim().isNotEmpty ? v : null;
  }

  Future<void> setTtsVoiceFrName(String? name) async {
    final dao = _ref.read(userSettingsDaoProvider);
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    if (name == null || name.trim().isEmpty) {
      map.remove('ttsVoiceFrName');
    } else {
      map['ttsVoiceFrName'] = name.trim();
    }
    await dao.upsert(UserSettingsCompanion(
      id: const drift.Value(_defaultId),
      fontPrefs: drift.Value(jsonEncode(map)),
    ));
  }

  Future<String?> getTtsVoiceArName() async {
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    final v = map['ttsVoiceArName'];
    return v is String && v.trim().isNotEmpty ? v : null;
  }

  Future<void> setTtsVoiceArName(String? name) async {
    final dao = _ref.read(userSettingsDaoProvider);
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    if (name == null || name.trim().isEmpty) {
      map.remove('ttsVoiceArName');
    } else {
      map['ttsVoiceArName'] = name.trim();
    }
    await dao.upsert(UserSettingsCompanion(
      id: const drift.Value(_defaultId),
      fontPrefs: drift.Value(jsonEncode(map)),
    ));
  }

  Future<String> getTtsPreferredFr() async {
    final byName = await getTtsVoiceFrName();
    if (byName != null) return byName;
    return getTtsLocaleFr();
  }

  Future<String> getTtsPreferredAr() async {
    final byName = await getTtsVoiceArName();
    if (byName != null) return byName;
    return getTtsLocaleAr();
  }

  // Theme selection persistence
  Future<String> getSelectedThemeId() async {
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    return (map['selectedThemeId'] as String?) ?? AppTheme.defaultThemeId;
  }

  Future<void> setSelectedThemeId(String themeId) async {
    final dao = _ref.read(userSettingsDaoProvider);
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    map['selectedThemeId'] = themeId;
    await dao.upsert(UserSettingsCompanion(
      id: const drift.Value(_defaultId),
      fontPrefs: drift.Value(jsonEncode(map)),
    ));
  }

  Map<String, dynamic> _parsePrefs(String jsonStr) {
    try {
      final m = jsonDecode(jsonStr) as Object?;
      if (m is Map<String, dynamic>) return m;
      return {};
    } catch (_) {
      return {};
    }
  }

  // Font settings
  Future<double> getFontScale() async {
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    final v = (map['fontScale'] as num?)?.toDouble();
    return v ?? 1.0;
  }

  Future<void> setFontScale(double scale) async {
    final dao = _ref.read(userSettingsDaoProvider);
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    map['fontScale'] = scale.clamp(0.5, 2.0);
    await dao.upsert(UserSettingsCompanion(
      id: const drift.Value(_defaultId),
      fontPrefs: drift.Value(jsonEncode(map)),
    ));
  }

  Future<String?> getFrenchFontFamily() async {
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    return map['frenchFontFamily'] as String?;
  }

  Future<void> setFrenchFontFamily(String font) async {
    final dao = _ref.read(userSettingsDaoProvider);
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    map['frenchFontFamily'] = font;
    await dao.upsert(UserSettingsCompanion(
      id: const drift.Value(_defaultId),
      fontPrefs: drift.Value(jsonEncode(map)),
    ));
  }

  Future<String?> getArabicFontFamily() async {
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    return map['arabicFontFamily'] as String?;
  }

  Future<void> setArabicFontFamily(String font) async {
    final dao = _ref.read(userSettingsDaoProvider);
    final u = await _getOrCreate();
    final map = _parsePrefs(u.fontPrefs);
    map['arabicFontFamily'] = font;
    await dao.upsert(UserSettingsCompanion(
      id: const drift.Value(_defaultId),
      fontPrefs: drift.Value(jsonEncode(map)),
    ));
  }
}

final userSettingsServiceProvider =
    Provider<UserSettingsService>((ref) => UserSettingsService(ref));

final readingDisplayPrefProvider =
    FutureProvider<BilingualDisplay>((ref) async {
  return ref.read(userSettingsServiceProvider).getDisplayPreference();
});
