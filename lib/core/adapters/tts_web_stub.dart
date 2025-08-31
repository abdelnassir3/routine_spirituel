import 'package:flutter/foundation.dart';
import 'tts_adapter.dart';

/// Stub TTS pour Web - Compatible avec compilation mobile
/// Cette classe permet au code de compiler sur mobile sans erreurs
class WebTtsAdapter implements TtsAdapter {
  bool _isSpeaking = false;
  bool _isPaused = false;
  VoidCallback? _completionCallback;

  @override
  Future<void> speak(
    String text, {
    required String voice,
    double speed = 0.55,
    double pitch = 1.0,
    bool allowFallback = true,
  }) async {
    if (kDebugMode) {
      debugPrint('🔇 Web TTS Stub: Simulation (mobile platform)');
    }
    
    _isSpeaking = true;
    _isPaused = false;

    // Simulation basée sur longueur du texte
    final estimatedDuration = Duration(
      milliseconds: (text.length * 50 / speed).round(),
    );

    await Future.delayed(estimatedDuration);

    _isSpeaking = false;
    _completionCallback?.call();
  }

  @override
  Future<void> stop() async {
    _isSpeaking = false;
    _isPaused = false;
  }

  @override
  Future<void> pause() async {
    _isPaused = true;
  }

  @override
  Future<void> resume() async {
    _isPaused = false;
  }

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  bool get isPaused => _isPaused;

  @override
  Future<List<String>> getAvailableVoices() async {
    return [
      'fr-FR-DeniseNeural',
      'ar-SA-HamedNeural',
      'en-US-AriaNeural',
    ];
  }

  @override
  Future<bool> isVoiceAvailable(String voice) async {
    final voices = await getAvailableVoices();
    return voices.contains(voice);
  }

  @override
  void setCompletionCallback(VoidCallback? callback) {
    _completionCallback = callback;
  }

  @override
  Future<void> dispose() async {
    await stop();
    _completionCallback = null;
  }
}