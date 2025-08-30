/// Export conditionnel pour l'adaptateur TTS
/// - Mobile (iOS/Android) : utilise Edge TTS → Coqui TTS → Flutter TTS
/// - Web : utilise un stub compatible pour éviter les erreurs
export 'tts_mobile.dart' if (dart.library.html) 'tts_web.dart';
