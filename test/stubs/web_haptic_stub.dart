/// Stub pour les tests Haptic Web sur plateformes non-web
class WebHapticStub {
  bool get isSupported => false;

  Future<void> lightImpact() async {
    // Stub pour impact léger
  }

  Future<void> mediumImpact() async {
    // Stub pour impact moyen
  }

  Future<void> heavyImpact() async {
    // Stub pour impact fort
  }

  Future<void> selectionClick() async {
    // Stub pour clic de sélection
  }

  Future<void> customVibration(int duration) async {
    // Stub pour vibration personnalisée
  }
}
