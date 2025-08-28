abstract class TranscriptionService {
  Future<String> transcribeAudio(String audioPath, {String language = 'auto'});
}

class StubTranscriptionService implements TranscriptionService {
  @override
  Future<String> transcribeAudio(String audioPath,
      {String language = 'auto'}) async {
    return 'Transcription audio ($language)';
  }
}
