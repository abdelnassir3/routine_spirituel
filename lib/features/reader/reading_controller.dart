import 'package:flutter_riverpod/flutter_riverpod.dart';

class HighlightPosition {
  final int wordIndex;
  final int verseIndex;
  const HighlightPosition(this.wordIndex, this.verseIndex);
}

class ReadingController extends StateNotifier<HighlightPosition> {
  ReadingController() : super(const HighlightPosition(0, 0));

  Stream<HighlightPosition> syncAudioWithText() async* {
    // Placeholder: in real impl, hook into just_audio position stream
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 1));
      final next = HighlightPosition(state.wordIndex + 1, state.verseIndex);
      state = next;
      yield next;
    }
  }

  void adjustReadingSpeed(double factor) {
    // Wire to audio_service/just_audio
  }
}

final readingControllerProvider =
    StateNotifierProvider<ReadingController, HighlightPosition>((ref) {
  return ReadingController();
});
