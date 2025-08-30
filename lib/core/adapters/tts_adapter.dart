/// Interface abstraite pour le Text-to-Speech multi-plateforme
abstract class TtsAdapter {
  /// Synthétiser et jouer du texte avec une voix spécifiée
  Future<void> speak(
    String text, {
    required String voice,
    double speed = 0.55,
    double pitch = 1.0,
    bool allowFallback = true,
  });

  /// Arrêter la synthèse en cours
  Future<void> stop();

  /// Mettre en pause la synthèse
  Future<void> pause();

  /// Reprendre la synthèse
  Future<void> resume();

  /// Vérifier si le TTS est actuellement en train de parler
  bool get isSpeaking;

  /// Vérifier si le TTS est en pause
  bool get isPaused;

  /// Liste des voix disponibles
  Future<List<String>> getAvailableVoices();

  /// Vérifier si une voix spécifique est disponible
  Future<bool> isVoiceAvailable(String voice);

  /// Définir un callback pour la fin de synthèse
  void setCompletionCallback(VoidCallback? callback);

  /// Libérer les ressources
  Future<void> dispose();
}

typedef VoidCallback = void Function();
