/// Interface commune pour le service de feedback haptique
/// Compatible avec toutes les plateformes (mobile, web, desktop)
abstract class HapticServiceInterface {
  // Getters
  bool get isEnabled;
  HapticIntensity get intensity;
  bool get canVibrate;
  
  // Configuration
  Future<void> setEnabled(bool enabled);
  Future<void> setIntensity(HapticIntensity intensity);
  
  // Méthodes de prière
  Future<void> prayerStart();
  Future<void> prayerComplete();
  Future<void> counterTick();
  Future<void> milestone(int count);
  
  // Méthodes UI
  Future<void> lightImpact();
  Future<void> mediumImpact();
  Future<void> heavyImpact();
  Future<void> selectionClick();
  
  // Méthodes gestures
  Future<void> swipeGesture();
  Future<void> longPress();
  Future<void> notification();
  
  // Vibration personnalisée
  Future<void> customVibration(int milliseconds);
  
  // Test
  Future<void> testHaptic();
  
  // Cleanup
  void dispose();
}

/// Niveaux d'intensité pour le feedback haptique
enum HapticIntensity {
  light,
  medium,
  strong,
}

/// Préférences haptiques
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