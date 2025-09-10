import 'package:flutter/foundation.dart';
import 'package:spiritual_routines/core/adapters/haptic_adapter.dart';
import 'package:spiritual_routines/core/adapters/haptic_mobile.dart';
import 'package:spiritual_routines/core/adapters/haptic_web.dart';
import 'package:spiritual_routines/core/platform/platform_service.dart';

/// Factory pour créer l'adaptateur haptic approprié selon la plateforme
class HapticAdapterFactory {
  static HapticAdapter create() {
    final platform = PlatformService.instance;

    if (platform.isMobile) {
      // iOS/Android: haptic natif supporté
      return MobileHapticAdapter();
    } else if (platform.isWeb || platform.isDesktop) {
      // Web/Desktop: stub no-op
      return WebHapticStub();
    }

    // Fallback par défaut
    if (kDebugMode) {
      debugPrint('⚠️ Platform non reconnue pour haptic, utilisation du stub');
    }
    return WebHapticStub();
  }
}
