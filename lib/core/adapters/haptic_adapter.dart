import 'package:flutter/foundation.dart';

/// Interface pour le retour haptique multi-plateforme
abstract class HapticAdapter {
  /// Feedback haptique léger (sélection, navigation)
  Future<void> lightImpact();

  /// Feedback haptique moyen (boutons, actions)
  Future<void> mediumImpact();

  /// Feedback haptique fort (erreurs, validation)
  Future<void> heavyImpact();

  /// Feedback de sélection (switches, pickers)
  Future<void> selectionClick();

  /// Vibration personnalisée (durée en ms)
  Future<void> customVibration(int milliseconds);

  /// Vérifier si le haptic est supporté
  bool get isSupported;
}

/// Implémentation mobile (iOS/Android)
class MobileHapticAdapter implements HapticAdapter {
  @override
  Future<void> lightImpact() async {
    // Implémentation avec haptic_feedback plugin
    if (kDebugMode) {
      debugPrint('🔊 Haptic: light impact');
    }
    // TODO: Intégrer avec HapticService existant
  }

  @override
  Future<void> mediumImpact() async {
    if (kDebugMode) {
      debugPrint('🔊 Haptic: medium impact');
    }
    // TODO: Intégrer avec HapticService existant
  }

  @override
  Future<void> heavyImpact() async {
    if (kDebugMode) {
      debugPrint('🔊 Haptic: heavy impact');
    }
    // TODO: Intégrer avec HapticService existant
  }

  @override
  Future<void> selectionClick() async {
    if (kDebugMode) {
      debugPrint('🔊 Haptic: selection click');
    }
    // TODO: Intégrer avec HapticService existant
  }

  @override
  Future<void> customVibration(int milliseconds) async {
    if (kDebugMode) {
      debugPrint('🔊 Haptic: custom vibration ${milliseconds}ms');
    }
    // TODO: Intégrer avec HapticService existant
  }

  @override
  bool get isSupported => true;
}

/// Stub pour Web/Desktop (pas de haptic)
class DesktopHapticStub implements HapticAdapter {
  @override
  Future<void> lightImpact() async {
    if (kDebugMode) {
      debugPrint('🔇 Haptic stub: light impact (no-op)');
    }
  }

  @override
  Future<void> mediumImpact() async {
    if (kDebugMode) {
      debugPrint('🔇 Haptic stub: medium impact (no-op)');
    }
  }

  @override
  Future<void> heavyImpact() async {
    if (kDebugMode) {
      debugPrint('🔇 Haptic stub: heavy impact (no-op)');
    }
  }

  @override
  Future<void> selectionClick() async {
    if (kDebugMode) {
      debugPrint('🔇 Haptic stub: selection click (no-op)');
    }
  }

  @override
  Future<void> customVibration(int milliseconds) async {
    if (kDebugMode) {
      debugPrint('🔇 Haptic stub: custom vibration ${milliseconds}ms (no-op)');
    }
  }

  @override
  bool get isSupported => false;
}
