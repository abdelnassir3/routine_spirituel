import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Service de retour haptique pour améliorer l'expérience utilisateur
///
/// Fournit des vibrations et retours tactiles contextuels pour :
/// - Actions de prière (début, fin, milestones)
/// - Interactions UI (boutons, swipes)
/// - Notifications et alertes
/// - Feedback de progression
class HapticService {
  static HapticService? _instance;

  // Préférences utilisateur
  bool _isEnabled = true;
  HapticIntensity _intensity = HapticIntensity.medium;
  bool _canVibrate = false;
  bool _hasAmplitudeControl = false;

  // Clés de préférences
  static const String _keyEnabled = 'haptic_enabled';
  static const String _keyIntensity = 'haptic_intensity';

  // Singleton
  static HapticService get instance {
    _instance ??= HapticService._();
    return _instance!;
  }

  HapticService._() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Charger les préférences
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_keyEnabled) ?? true;
      final intensityIndex =
          prefs.getInt(_keyIntensity) ?? HapticIntensity.medium.index;
      _intensity = HapticIntensity.values[intensityIndex];

      // Vérifier les capacités de l'appareil
      if (Platform.isAndroid || Platform.isIOS) {
        _canVibrate = await Haptics.canVibrate() ?? false;

        if (Platform.isAndroid) {
          _hasAmplitudeControl = await Vibration.hasAmplitudeControl() ?? false;
        }
      }

      AppLogger.logDebugInfo('HapticService initialized', {
        'enabled': _isEnabled,
        'intensity': _intensity.name,
        'canVibrate': _canVibrate,
        'hasAmplitudeControl': _hasAmplitudeControl,
      });
    } catch (e) {
      AppLogger.logError('HapticService initialization failed', e);
    }
  }

  // ===== Configuration =====

  bool get isEnabled => _isEnabled;
  HapticIntensity get intensity => _intensity;
  bool get canVibrate => _canVibrate;

  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, enabled);

    AppLogger.logUserAction('haptic_feedback_toggled', {'enabled': enabled});
  }

  Future<void> setIntensity(HapticIntensity intensity) async {
    _intensity = intensity;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyIntensity, intensity.index);

    // Tester le nouveau niveau
    await testHaptic();

    AppLogger.logUserAction(
        'haptic_intensity_changed', {'intensity': intensity.name});
  }

  // ===== Haptic Patterns pour Prières =====

  /// Vibration au début d'une session de prière
  Future<void> prayerStart() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        await Haptics.vibrate(HapticsType.success);
      } else if (Platform.isAndroid) {
        // Pattern: court-pause-court-pause-long
        await Vibration.vibrate(
          pattern: [0, 100, 50, 100, 50, 200],
          intensities: _hasAmplitudeControl ? [0, 128, 0, 128, 0, 255] : null,
        );
      }
    } catch (e) {
      if (kDebugMode) print('Haptic error: $e');
    }
  }

  /// Vibration à la fin d'une session de prière
  Future<void> prayerComplete() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        // Double success pour marquer la complétion
        await Haptics.vibrate(HapticsType.success);
        await Future.delayed(const Duration(milliseconds: 100));
        await Haptics.vibrate(HapticsType.success);
      } else if (Platform.isAndroid) {
        // Pattern célébration : série de vibrations croissantes
        await Vibration.vibrate(
          pattern: [0, 50, 50, 100, 50, 150, 50, 200],
          intensities:
              _hasAmplitudeControl ? [0, 100, 0, 150, 0, 200, 0, 255] : null,
        );
      }
    } catch (e) {
      if (kDebugMode) print('Haptic error: $e');
    }
  }

  /// Vibration pour chaque compte/répétition
  Future<void> counterTick() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      final duration = _getDurationForIntensity();

      if (Platform.isIOS) {
        await Haptics.vibrate(HapticsType.light);
      } else if (Platform.isAndroid) {
        await Vibration.vibrate(
          duration: duration,
          amplitude: _getAmplitudeForIntensity(),
        );
      }
    } catch (e) {
      if (kDebugMode) print('Haptic error: $e');
    }
  }

  /// Vibration pour milestone (33, 66, 99 répétitions)
  Future<void> milestone(int count) async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        // Utiliser différents types selon le milestone
        if (count == 33) {
          await Haptics.vibrate(HapticsType.medium);
        } else if (count == 66) {
          await Haptics.vibrate(HapticsType.heavy);
        } else if (count == 99 || count == 100) {
          await Haptics.vibrate(HapticsType.success);
        }
      } else if (Platform.isAndroid) {
        // Pattern différent selon le milestone
        if (count == 33) {
          await Vibration.vibrate(pattern: [0, 200], intensities: [0, 200]);
        } else if (count == 66) {
          await Vibration.vibrate(
              pattern: [0, 100, 100, 100], intensities: [0, 200, 0, 200]);
        } else if (count == 99 || count == 100) {
          await Vibration.vibrate(
            pattern: [0, 100, 50, 100, 50, 300],
            intensities: [0, 200, 0, 200, 0, 255],
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('Haptic error: $e');
    }
  }

  // ===== Haptic Patterns pour UI =====

  /// Feedback léger pour les taps
  Future<void> lightTap() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        await Haptics.vibrate(HapticsType.light);
      } else if (Platform.isAndroid) {
        await Vibration.vibrate(
          duration: 10,
          amplitude: _getAmplitudeForIntensity(light: true),
        );
      }
    } catch (e) {
      if (kDebugMode) print('Haptic error: $e');
    }
  }

  /// Feedback moyen pour les sélections
  Future<void> selection() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        await Haptics.vibrate(HapticsType.selection);
      } else if (Platform.isAndroid) {
        await Vibration.vibrate(
          duration: 20,
          amplitude: _getAmplitudeForIntensity(),
        );
      }
    } catch (e) {
      if (kDebugMode) print('Haptic error: $e');
    }
  }

  /// Feedback fort pour les actions importantes
  Future<void> impact() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        await Haptics.vibrate(HapticsType.heavy);
      } else if (Platform.isAndroid) {
        await Vibration.vibrate(
          duration: 30,
          amplitude: _getAmplitudeForIntensity(heavy: true),
        );
      }
    } catch (e) {
      if (kDebugMode) print('Haptic error: $e');
    }
  }

  /// Feedback pour les erreurs
  Future<void> error() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        await Haptics.vibrate(HapticsType.warning);
      } else if (Platform.isAndroid) {
        // Pattern d'erreur : buzz rapide
        await Vibration.vibrate(
          pattern: [0, 50, 30, 50, 30, 50],
          intensities: _hasAmplitudeControl ? [0, 255, 0, 255, 0, 255] : null,
        );
      }
    } catch (e) {
      if (kDebugMode) print('Haptic error: $e');
    }
  }

  /// Feedback pour le succès
  Future<void> success() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        await Haptics.vibrate(HapticsType.success);
      } else if (Platform.isAndroid) {
        // Pattern de succès : deux taps distincts
        await Vibration.vibrate(
          pattern: [0, 100, 100, 100],
          intensities: _hasAmplitudeControl ? [0, 200, 0, 200] : null,
        );
      }
    } catch (e) {
      if (kDebugMode) print('Haptic error: $e');
    }
  }

  // ===== Patterns spéciaux =====

  /// Pattern pour le swipe/gesture
  Future<void> swipeGesture() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        await Haptics.vibrate(HapticsType.selection);
      } else if (Platform.isAndroid) {
        // Pattern fluide pour swipe
        await Vibration.vibrate(
          duration: 15,
          amplitude: 128,
        );
      }
    } catch (e) {
      if (kDebugMode) print('Haptic error: $e');
    }
  }

  /// Pattern pour le long press
  Future<void> longPress() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        await Haptics.vibrate(HapticsType.medium);
      } else if (Platform.isAndroid) {
        await Vibration.vibrate(
          duration: 50,
          amplitude: _getAmplitudeForIntensity(),
        );
      }
    } catch (e) {
      if (kDebugMode) print('Haptic error: $e');
    }
  }

  /// Pattern pour notification/rappel
  Future<void> notification() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        await Haptics.vibrate(HapticsType.warning);
      } else if (Platform.isAndroid) {
        // Pattern de notification : long-court-court
        await Vibration.vibrate(
          pattern: [0, 200, 100, 100, 100, 100],
          intensities: _hasAmplitudeControl ? [0, 255, 0, 150, 0, 150] : null,
        );
      }
    } catch (e) {
      if (kDebugMode) print('Haptic error: $e');
    }
  }

  // ===== Custom Patterns =====

  /// Créer un pattern custom
  Future<void> customPattern({
    required List<int> pattern,
    List<int>? intensities,
  }) async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isAndroid) {
        await Vibration.vibrate(
          pattern: pattern,
          intensities: _hasAmplitudeControl ? intensities : null,
        );
      } else if (Platform.isIOS) {
        // iOS ne supporte pas les patterns custom, utiliser le plus proche
        await Haptics.vibrate(HapticsType.medium);
      }
    } catch (e) {
      if (kDebugMode) print('Haptic error: $e');
    }
  }

  /// Vibration continue pour une durée donnée
  Future<void> continuous(Duration duration) async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isAndroid) {
        await Vibration.vibrate(
          duration: duration.inMilliseconds,
          amplitude: _getAmplitudeForIntensity(),
        );
      } else if (Platform.isIOS) {
        // iOS ne supporte pas la vibration continue, simuler avec des pulses
        final pulses = duration.inMilliseconds ~/ 100;
        for (int i = 0; i < pulses; i++) {
          await Haptics.vibrate(HapticsType.light);
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    } catch (e) {
      if (kDebugMode) print('Haptic error: $e');
    }
  }

  // ===== Helpers =====

  int _getDurationForIntensity() {
    switch (_intensity) {
      case HapticIntensity.light:
        return 10;
      case HapticIntensity.medium:
        return 20;
      case HapticIntensity.strong:
        return 30;
    }
  }

  int _getAmplitudeForIntensity({bool light = false, bool heavy = false}) {
    if (!_hasAmplitudeControl) return -1;

    if (light) {
      switch (_intensity) {
        case HapticIntensity.light:
          return 50;
        case HapticIntensity.medium:
          return 75;
        case HapticIntensity.strong:
          return 100;
      }
    } else if (heavy) {
      switch (_intensity) {
        case HapticIntensity.light:
          return 150;
        case HapticIntensity.medium:
          return 200;
        case HapticIntensity.strong:
          return 255;
      }
    } else {
      switch (_intensity) {
        case HapticIntensity.light:
          return 100;
        case HapticIntensity.medium:
          return 150;
        case HapticIntensity.strong:
          return 200;
      }
    }
  }

  /// Tester le feedback haptique
  Future<void> testHaptic() async {
    await impact();
  }

  /// Arrêter toute vibration en cours
  Future<void> cancel() async {
    try {
      if (Platform.isAndroid) {
        await Vibration.cancel();
      }
    } catch (e) {
      if (kDebugMode) print('Haptic cancel error: $e');
    }
  }
}

/// Intensité du feedback haptique
enum HapticIntensity {
  light,
  medium,
  strong,
}
