import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HapticType { light, medium, heavy }

@immutable
class CounterState {
  final int remaining;
  final bool handsFree;
  const CounterState({required this.remaining, this.handsFree = false});

  CounterState copyWith({int? remaining, bool? handsFree}) =>
      CounterState(remaining: remaining ?? this.remaining, handsFree: handsFree ?? this.handsFree);
}

class SmartCounter extends StateNotifier<CounterState> {
  SmartCounter() : super(const CounterState(remaining: 0));

  void setInitial(int value) => state = state.copyWith(remaining: value);

  void decrementWithFeedback(HapticType feedback) {
    final next = (state.remaining - 1).clamp(0, 1 << 31);
    state = state.copyWith(remaining: next);
    // TODO: trigger haptics/audio via platform channels
  }

  bool shouldAutoAdvance() => state.remaining == 0 && state.handsFree;

  Stream<String> watchHandsFreeMode() async* {
    // Placeholder stream; real impl would tie to audio markers.
    while (state.handsFree) {
      await Future<void>.delayed(const Duration(seconds: 1));
      yield 'tick';
    }
  }

  void configureAutoAdvance({required bool enabled}) => state = state.copyWith(handsFree: enabled);
}

final smartCounterProvider = StateNotifierProvider<SmartCounter, CounterState>((ref) => SmartCounter());

