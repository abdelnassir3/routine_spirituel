import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class HapticAdapter {
  Future<void> lightImpact();
  Future<void> mediumImpact();
  Future<void> heavyImpact();
  Future<void> selectionClick();
}

class HapticAdapterMobile implements HapticAdapter {
  @override
  Future<void> lightImpact() => HapticFeedback.lightImpact();
  
  @override
  Future<void> mediumImpact() => HapticFeedback.mediumImpact();
  
  @override
  Future<void> heavyImpact() => HapticFeedback.heavyImpact();
  
  @override
  Future<void> selectionClick() => HapticFeedback.selectionClick();
}

class HapticAdapterWeb implements HapticAdapter {
  @override
  Future<void> lightImpact() async {
    if (kDebugMode) print('🔔 Haptic: light (web stub)');
  }
  
  @override
  Future<void> mediumImpact() async {
    if (kDebugMode) print('🔔 Haptic: medium (web stub)');
  }
  
  @override
  Future<void> heavyImpact() async {
    if (kDebugMode) print('🔔 Haptic: heavy (web stub)');
  }
  
  @override
  Future<void> selectionClick() async {
    if (kDebugMode) print('🔔 Haptic: selection (web stub)');
  }
}

HapticAdapter getHapticAdapter() {
  if (kIsWeb || defaultTargetPlatform == TargetPlatform.macOS) {
    return HapticAdapterWeb();
  }
  return HapticAdapterMobile();
}
