import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/adapters/adapters.dart';

/// Provider exposant l'adaptateur TTS cross‑plateforme.
/// - Mobile: Edge→Coqui→Flutter TTS
/// - Web: Web Speech API si dispo, sinon simulation contrôlée
final ttsAdapterProvider = Provider<TtsAdapter>((ref) {
  return AdapterFactories.tts;
});
