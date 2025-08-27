import 'package:spiritual_routines/core/services/transcription_service.dart';

// Placeholder for a future Whisper/Vosk integration
class WhisperTranscriptionService implements TranscriptionService {
  @override
  Future<String> transcribeAudio(String audioPath,
      {String language = 'auto'}) async {
    // TODO: integrate Whisper/Vosk; for now, stub
    return 'Transcription (Whisper stub)';
  }
}
