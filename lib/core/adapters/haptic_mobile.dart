import 'package:flutter/foundation.dart';
import 'package:spiritual_routines/core/services/haptic_service.dart';
import 'haptic_adapter.dart';

/// Implémentation mobile du retour haptique (iOS/Android)
/// Utilise le HapticService existant pour les vraies vibrations
class MobileHapticAdapter implements HapticAdapter {
  final HapticService _hapticService = HapticService.instance;

  @override
  Future<void> lightImpact() async {
    if (kDebugMode) {
      debugPrint('🔊 Mobile Haptic: light impact');
    }
    await _hapticService.lightImpact();
  }

  @override
  Future<void> mediumImpact() async {
    if (kDebugMode) {
      debugPrint('🔊 Mobile Haptic: medium impact');
    }
    await _hapticService.mediumImpact();
  }

  @override
  Future<void> heavyImpact() async {
    if (kDebugMode) {
      debugPrint('🔊 Mobile Haptic: heavy impact');
    }
    await _hapticService.heavyImpact();
  }

  @override
  Future<void> selectionClick() async {
    if (kDebugMode) {
      debugPrint('🔊 Mobile Haptic: selection click');
    }
    await _hapticService.selectionClick();
  }

  @override
  Future<void> customVibration(int milliseconds) async {
    if (kDebugMode) {
      debugPrint('🔊 Mobile Haptic: custom vibration ${milliseconds}ms');
    }
    await _hapticService.customVibration(milliseconds);
  }

  @override
  bool get isSupported => _hapticService.canVibrate;
}
