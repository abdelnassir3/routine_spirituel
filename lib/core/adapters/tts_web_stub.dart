/// Stub pour les adaptateurs TTS Web sur plateformes non-web
class TtsWebStub {
  bool get isSupported => false;
  
  Future<List<String>> getVoices() async => [];
  
  Future<void> speak(String text, {
    String? voice,
    double rate = 1.0,
    double pitch = 1.0,
  }) async {
    // No-op pour tests sur plateformes non-web
  }
  
  Future<void> stop() async {}
  Future<void> pause() async {}
  Future<void> resume() async {}
  void dispose() {}
}

/// Stub pour WebEdgeTtsService sur plateformes non-web  
class WebEdgeTtsServiceStub {
  bool get isSupported => false;
  
  Future<List<String>> getAvailableVoices() async => [
    'fr-FR-DeniseNeural',
    'ar-SA-HamedNeural'
  ];
  
  Future<void> speak(String text, {
    String? voice,
    double rate = 1.0,
    double pitch = 1.0,
  }) async {
    // Simulation pour tests
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  Future<void> stop() async {}
  Future<void> pause() async {}
  Future<void> resume() async {}
  void dispose() {}
}