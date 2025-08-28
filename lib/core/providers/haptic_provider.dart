import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/haptic_service.dart';

/// Provider pour le service de feedback haptique
final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService.instance;
});

/// Provider pour l'état d'activation du feedback haptique
final hapticEnabledProvider = StateProvider<bool>((ref) {
  return ref.watch(hapticServiceProvider).isEnabled;
});

/// Provider pour l'intensité du feedback haptique
final hapticIntensityProvider = StateProvider<HapticIntensity>((ref) {
  return ref.watch(hapticServiceProvider).intensity;
});

/// Provider pour vérifier si l'appareil supporte la vibration
final canVibrateProvider = Provider<bool>((ref) {
  return ref.watch(hapticServiceProvider).canVibrate;
});

/// Notifier pour gérer les préférences haptiques
class HapticPreferencesNotifier extends StateNotifier<HapticPreferences> {
  final HapticService _hapticService;

  HapticPreferencesNotifier(this._hapticService)
      : super(HapticPreferences(
          enabled: _hapticService.isEnabled,
          intensity: _hapticService.intensity,
        ));

  Future<void> setEnabled(bool enabled) async {
    await _hapticService.setEnabled(enabled);
    state = state.copyWith(enabled: enabled);
  }

  Future<void> setIntensity(HapticIntensity intensity) async {
    await _hapticService.setIntensity(intensity);
    state = state.copyWith(intensity: intensity);
  }

  Future<void> testHaptic() async {
    await _hapticService.testHaptic();
  }
}

/// État des préférences haptiques
class HapticPreferences {
  final bool enabled;
  final HapticIntensity intensity;

  const HapticPreferences({
    required this.enabled,
    required this.intensity,
  });

  HapticPreferences copyWith({
    bool? enabled,
    HapticIntensity? intensity,
  }) {
    return HapticPreferences(
      enabled: enabled ?? this.enabled,
      intensity: intensity ?? this.intensity,
    );
  }
}

/// Provider pour les préférences haptiques
final hapticPreferencesProvider =
    StateNotifierProvider<HapticPreferencesNotifier, HapticPreferences>((ref) {
  final hapticService = ref.watch(hapticServiceProvider);
  return HapticPreferencesNotifier(hapticService);
});

/// Extension pour faciliter l'utilisation du haptic dans les widgets
extension HapticWidgetRef on WidgetRef {
  HapticService get haptic => read(hapticServiceProvider);

  // Méthodes de prière
  Future<void> hapticPrayerStart() => haptic.prayerStart();
  Future<void> hapticPrayerComplete() => haptic.prayerComplete();
  Future<void> hapticCounterTick() => haptic.counterTick();
  Future<void> hapticMilestone(int count) => haptic.milestone(count);

  // Méthodes UI
  Future<void> hapticLightTap() => haptic.lightTap();
  Future<void> hapticSelection() => haptic.selection();
  Future<void> hapticImpact() => haptic.impact();
  Future<void> hapticError() => haptic.error();
  Future<void> hapticSuccess() => haptic.success();

  // Méthodes gestures
  Future<void> hapticSwipe() => haptic.swipeGesture();
  Future<void> hapticLongPress() => haptic.longPress();
  Future<void> hapticNotification() => haptic.notification();
}
