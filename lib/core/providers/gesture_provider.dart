import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gesture_service.dart';

/// Provider pour le service de gestes
final gestureServiceProvider = Provider<GestureService>((ref) {
  return GestureService.instance;
});

/// Provider pour l'état d'activation des gestes
final gesturesEnabledProvider = StateProvider<bool>((ref) {
  return ref.watch(gestureServiceProvider).isEnabled;
});

/// Provider pour la sensibilité des gestes
final gestureSensitivityProvider = StateProvider<GestureSensitivity>((ref) {
  return ref.watch(gestureServiceProvider).sensitivity;
});

/// Provider pour le mode gaucher
final leftHandedModeProvider = StateProvider<bool>((ref) {
  return ref.watch(gestureServiceProvider).leftHandedMode;
});

/// Notifier pour gérer les préférences de gestes
class GesturePreferencesNotifier extends StateNotifier<GesturePreferences> {
  final GestureService _gestureService;

  GesturePreferencesNotifier(this._gestureService)
      : super(GesturePreferences(
          enabled: _gestureService.isEnabled,
          sensitivity: _gestureService.sensitivity,
          leftHandedMode: _gestureService.leftHandedMode,
        ));

  Future<void> setEnabled(bool enabled) async {
    await _gestureService.setEnabled(enabled);
    state = state.copyWith(enabled: enabled);
  }

  Future<void> setSensitivity(GestureSensitivity sensitivity) async {
    await _gestureService.setSensitivity(sensitivity);
    state = state.copyWith(sensitivity: sensitivity);
  }

  Future<void> setLeftHandedMode(bool leftHanded) async {
    await _gestureService.setLeftHandedMode(leftHanded);
    state = state.copyWith(leftHandedMode: leftHanded);
  }

  void registerPattern(GesturePattern pattern, void Function() callback) {
    _gestureService.registerPatternCallback(pattern, callback);
  }
}

/// État des préférences de gestes
class GesturePreferences {
  final bool enabled;
  final GestureSensitivity sensitivity;
  final bool leftHandedMode;

  const GesturePreferences({
    required this.enabled,
    required this.sensitivity,
    required this.leftHandedMode,
  });

  GesturePreferences copyWith({
    bool? enabled,
    GestureSensitivity? sensitivity,
    bool? leftHandedMode,
  }) {
    return GesturePreferences(
      enabled: enabled ?? this.enabled,
      sensitivity: sensitivity ?? this.sensitivity,
      leftHandedMode: leftHandedMode ?? this.leftHandedMode,
    );
  }
}

/// Provider pour les préférences de gestes
final gesturePreferencesProvider =
    StateNotifierProvider<GesturePreferencesNotifier, GesturePreferences>(
        (ref) {
  final gestureService = ref.watch(gestureServiceProvider);
  return GesturePreferencesNotifier(gestureService);
});

/// Provider pour détecter les gestes de compteur
final counterGestureProvider = Provider<CounterGestureHandler>((ref) {
  return CounterGestureHandler(ref.watch(gestureServiceProvider));
});

/// Gestionnaire de gestes pour le compteur
class CounterGestureHandler {
  final GestureService _gestureService;

  CounterGestureHandler(this._gestureService);

  Future<void> increment() => _gestureService.handleCounterIncrement();
  Future<void> decrement() => _gestureService.handleCounterDecrement();
  Future<void> reset() => _gestureService.handleCounterReset();
  Future<void> pauseResume() => _gestureService.handlePauseResume();

  SwipeDirection? analyzeSwipe({
    required Offset start,
    required Offset end,
    required Duration duration,
  }) {
    return _gestureService.analyzeSwipe(
      start: start,
      end: end,
      duration: duration,
    );
  }

  bool detectCircle(List<Offset> points) {
    return _gestureService.detectCircleGesture(points);
  }

  bool detectZigzag(List<Offset> points) {
    return _gestureService.detectZigzagGesture(points);
  }
}
