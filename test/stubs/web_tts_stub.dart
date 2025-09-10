/// Stub pour les tests TTS Web sur plateformes non-web
class WebTtsStub {
  Future<List<String>> getAvailableVoices() async {
    // Retourner des voix par défaut pour les tests
    return [
      'fr-FR-DeniseNeural',
      'ar-SA-HamedNeural',
      'en-US-JennyNeural',
    ];
  }

  Future<void> speak(
    String text, {
    required String voice,
    double speed = 1.0,
    double pitch = 1.0,
  }) async {
    // Simulation de synthèse vocale pour les tests
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  Future<void> stop() async {
    // Stub pour arrêter la synthèse
  }

  Future<void> pause() async {
    // Stub pour pausar la synthèse
  }

  Future<void> resume() async {
    // Stub pour reprendre la synthèse
  }

  Future<void> dispose() async {
    // Stub pour nettoyer les ressources
  }

  bool get isPlaying => false;
  bool get isPaused => false;
}
