import 'package:flutter/foundation.dart';
import 'package:spiritual_routines/core/platform/platform_service.dart';

// Imports conditionnels des implémentations
import 'package:spiritual_routines/core/adapters/haptic.dart';
import 'package:spiritual_routines/core/adapters/storage.dart';
// Interfaces
import 'package:spiritual_routines/core/adapters/haptic_adapter.dart';
import 'package:spiritual_routines/core/adapters/tts_adapter.dart';
import 'package:spiritual_routines/core/adapters/storage_adapter.dart';
// Platform factories
import 'tts_factory_io.dart' if (dart.library.html) 'tts_factory_web.dart'
    as tts_factory;
import 'storage_factory_io.dart'
    if (dart.library.html) 'storage_factory_web.dart' as storage_factory;

/// Factory centralisée pour créer les adaptateurs appropriés selon la plateforme
class AdapterFactories {
  static final PlatformService _platform = PlatformService.instance;

  // Cache des instances pour éviter les créations multiples
  static HapticAdapter? _hapticInstance;
  static TtsAdapter? _ttsInstance;
  static StorageAdapter? _storageInstance;

  /// Crée ou retourne l'instance HapticAdapter appropriée
  static HapticAdapter get haptic {
    if (_hapticInstance != null) {
      return _hapticInstance!;
    }

    if (_platform.isMobile) {
      _hapticInstance = HapticAdapterMobile();
    } else {
      _hapticInstance = HapticAdapterWeb();
    }

    if (kDebugMode) {
      debugPrint(
          '🏭 AdapterFactory: Created haptic adapter for ${_getPlatformName()}');
    }

    return _hapticInstance!;
  }

  /// Crée ou retourne l'instance TtsAdapter appropriée
  static TtsAdapter get tts {
    if (_ttsInstance != null) {
      return _ttsInstance!;
    }

    _ttsInstance = tts_factory.createTtsAdapter();

    if (kDebugMode) {
      debugPrint(
          '🏭 AdapterFactory: Created TTS adapter for ${_getPlatformName()}');
    }

    return _ttsInstance!;
  }

  /// Crée ou retourne l'instance StorageAdapter appropriée
  static StorageAdapter get storage {
    if (_storageInstance != null) {
      return _storageInstance!;
    }

    _storageInstance = storage_factory.createStorageAdapter();

    if (kDebugMode) {
      debugPrint(
          '🏭 AdapterFactory: Created storage adapter for ${_getPlatformName()}');
    }

    return _storageInstance!;
  }

  /// Nettoie les instances mises en cache (utile pour les tests)
  static void clearCache() {
    if (kDebugMode) {
      debugPrint('🏭 AdapterFactory: Clearing adapter cache');
    }

    _hapticInstance?.dispose().catchError((_) {});
    _ttsInstance?.dispose().catchError((_) {});
    // StorageAdapter n'a pas de dispose()

    _hapticInstance = null;
    _ttsInstance = null;
    _storageInstance = null;
  }

  /// Diagnostic : affiche les adaptateurs actifs
  static void printActiveAdapters() {
    if (kDebugMode) {
      debugPrint('🏭 AdapterFactory Active Adapters:');
      debugPrint('   Platform: ${_getPlatformName()}');
      debugPrint('   Haptic: ${_hapticInstance?.runtimeType ?? "Not loaded"}');
      debugPrint('   TTS: ${_ttsInstance?.runtimeType ?? "Not loaded"}');
      debugPrint(
          '   Storage: ${_storageInstance?.runtimeType ?? "Not loaded"}');
    }
  }

  static String _getPlatformName() {
    if (_platform.isIOS) return 'iOS';
    if (_platform.isAndroid) return 'Android';
    if (_platform.isWeb) return 'Web';
    if (_platform.isMacOS) return 'macOS';
    if (_platform.isWindows) return 'Windows';
    if (_platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}

// Extensions pour faciliter l'usage
extension HapticAdapterExtension on HapticAdapter {
  Future<void> dispose() async {
    // Base dispose - override dans les implémentations si nécessaire
  }
}
