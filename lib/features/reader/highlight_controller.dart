import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class HighlightState {
  final List<String> tokens;
  final int index;
  const HighlightState({this.tokens = const [], this.index = 0});

  HighlightState copyWith({List<String>? tokens, int? index}) =>
      HighlightState(tokens: tokens ?? this.tokens, index: index ?? this.index);
}

class HighlightController extends StateNotifier<HighlightState> {
  HighlightController() : super(const HighlightState());
  Timer? _timer;

  void setText(String text) {
    final tokens = _tokenize(text);
    state = HighlightState(tokens: tokens, index: 0);
  }

  void start({int msPerWord = 300}) {
    stop();
    if (state.tokens.isEmpty) return;
    _timer = Timer.periodic(Duration(milliseconds: msPerWord), (_) {
      final next = state.index + 1;
      if (next >= state.tokens.length) {
        stop();
      } else {
        state = state.copyWith(index: next);
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  List<String> _tokenize(String text) {
    final cleaned = text.replaceAll(RegExp(r"\s+"), ' ').trim();
    if (cleaned.isEmpty) return [];
    return cleaned.split(' ');
  }
}

final highlightControllerProvider =
    StateNotifierProvider<HighlightController, HighlightState>(
        (ref) => HighlightController());
