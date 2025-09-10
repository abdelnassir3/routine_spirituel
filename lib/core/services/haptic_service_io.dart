import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';
import 'haptic_service_interface.dart';

/// Factory function pour créer le service IO
HapticServiceInterface createHapticService() => HapticServiceIO.instance;

/// Implémentation du service haptique pour plateformes iOS/Android/Desktop
/// Cette version utilise les packages de vibration réels
class HapticServiceIO implements HapticServiceInterface {
  static HapticServiceIO? _instance;

  // Préférences utilisateur
  bool _isEnabled = true;
  HapticIntensity _intensity = HapticIntensity.medium;
  bool _canVibrate = false;
  bool _hasAmplitudeControl = false;

  // Clés de préférences
  static const String _keyEnabled = 'haptic_enabled';
  static const String _keyIntensity = 'haptic_intensity';

  // Singleton
  static HapticServiceIO get instance {
    _instance ??= HapticServiceIO._();
    return _instance!;
  }

  HapticServiceIO._() {
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
        _hasAmplitudeControl = await Vibration.hasAmplitudeControl() ?? false;

        AppLogger.haptic('Service haptique initialisé');
        AppLogger.haptic('Vibration disponible: $_canVibrate');
        AppLogger.haptic('Contrôle d\'amplitude: $_hasAmplitudeControl');
      } else {
        // Desktop platforms - pas de vibration physique
        _canVibrate = false;
        _hasAmplitudeControl = false;
        AppLogger.haptic('Platform desktop - vibration désactivée');
      }
    } catch (e) {
      AppLogger.error('Erreur initialisation service haptique: $e');
      _canVibrate = false;
      _hasAmplitudeControl = false;
    }
  }

  @override
  bool get isEnabled => _isEnabled;

  @override
  HapticIntensity get intensity => _intensity;

  @override
  bool get canVibrate => _canVibrate;

  @override
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyEnabled, enabled);
      AppLogger.haptic('Feedback haptique ${enabled ? 'activé' : 'désactivé'}');
    } catch (e) {
      AppLogger.error('Erreur sauvegarde préférence haptique: $e');
    }
  }

  @override
  Future<void> setIntensity(HapticIntensity intensity) async {
    _intensity = intensity;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyIntensity, intensity.index);
      AppLogger.haptic('Intensité haptique: ${intensity.name}');
    } catch (e) {
      AppLogger.error('Erreur sauvegarde intensité haptique: $e');
    }
  }

  // ==================== MÉTHODES DE PRIÈRE ====================

  @override
  Future<void> prayerStart() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
      } else if (Platform.isAndroid) {
        await _vibrate(duration: 150, amplitude: _getAmplitude());
        await Future.delayed(const Duration(milliseconds: 50));
        await _vibrate(duration: 200, amplitude: _getAmplitude(strong: true));
      }
      AppLogger.haptic('Début de prière - retour haptique');
    } catch (e) {
      AppLogger.error('Erreur feedback début prière: $e');
    }
  }

  @override
  Future<void> prayerComplete() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      // Pattern de célébration : 3 vibrations courtes
      for (int i = 0; i < 3; i++) {
        if (Platform.isIOS) {
          await HapticFeedback.lightImpact();
        } else if (Platform.isAndroid) {
          await _vibrate(duration: 100, amplitude: _getAmplitude());
        }
        if (i < 2) await Future.delayed(const Duration(milliseconds: 150));
      }
      AppLogger.haptic('Prière terminée - célébration haptique');
    } catch (e) {
      AppLogger.error('Erreur feedback fin prière: $e');
    }
  }

  @override
  Future<void> counterTick() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        await HapticFeedback.selectionClick();
      } else if (Platform.isAndroid) {
        await _vibrate(duration: 50, amplitude: _getAmplitude(light: true));
      }
    } catch (e) {
      AppLogger.error('Erreur feedback compteur: $e');
    }
  }

  @override
  Future<void> milestone(int count) async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      // Feedback spécial pour les milestones (multiples de 10, 33, 100)
      if (count % 100 == 0) {
        // Milestone majeur (100, 200, etc.)
        await prayerComplete(); // Triple vibration
      } else if (count % 33 == 0 || count % 10 == 0) {
        // Milestone modéré
        if (Platform.isIOS) {
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.lightImpact();
        } else if (Platform.isAndroid) {
          await _vibrate(duration: 120, amplitude: _getAmplitude());
          await Future.delayed(const Duration(milliseconds: 80));
          await _vibrate(duration: 80, amplitude: _getAmplitude(light: true));
        }
      }
      AppLogger.haptic('Milestone atteint: $count');
    } catch (e) {
      AppLogger.error('Erreur feedback milestone: $e');
    }
  }

  // ==================== MÉTHODES UI ====================

  @override
  Future<void> lightImpact() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        await HapticFeedback.lightImpact();
      } else if (Platform.isAndroid) {
        await _vibrate(duration: 50, amplitude: _getAmplitude(light: true));
      }
    } catch (e) {
      AppLogger.error('Erreur light impact: $e');
    }
  }

  @override
  Future<void> mediumImpact() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        await HapticFeedback.mediumImpact();
      } else if (Platform.isAndroid) {
        await _vibrate(duration: 100, amplitude: _getAmplitude());
      }
    } catch (e) {
      AppLogger.error('Erreur medium impact: $e');
    }
  }

  @override
  Future<void> heavyImpact() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        await HapticFeedback.heavyImpact();
      } else if (Platform.isAndroid) {
        await _vibrate(duration: 150, amplitude: _getAmplitude(strong: true));
      }
    } catch (e) {
      AppLogger.error('Erreur heavy impact: $e');
    }
  }

  @override
  Future<void> selectionClick() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      if (Platform.isIOS) {
        await HapticFeedback.selectionClick();
      } else if (Platform.isAndroid) {
        await _vibrate(duration: 30, amplitude: _getAmplitude(light: true));
      }
    } catch (e) {
      AppLogger.error('Erreur selection click: $e');
    }
  }

  // ==================== MÉTHODES GESTURES ====================

  @override
  Future<void> swipeGesture() async {
    if (!_isEnabled || !_canVibrate) return;
    await selectionClick(); // Feedback léger pour les swipes
  }

  @override
  Future<void> longPress() async {
    if (!_isEnabled || !_canVibrate) return;
    await mediumImpact(); // Feedback moyen pour les long press
  }

  @override
  Future<void> notification() async {
    if (!_isEnabled || !_canVibrate) return;

    try {
      // Pattern de notification : court-pause-long
      if (Platform.isIOS) {
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
      } else if (Platform.isAndroid) {
        await _vibrate(duration: 80, amplitude: _getAmplitude(light: true));
        await Future.delayed(const Duration(milliseconds: 120));
        await _vibrate(duration: 160, amplitude: _getAmplitude());
      }
      AppLogger.haptic('Notification haptique envoyée');
    } catch (e) {
      AppLogger.error('Erreur notification haptique: $e');
    }
  }

  @override
  Future<void> testHaptic() async {
    if (!_canVibrate) {
      AppLogger.warning('Test haptique impossible - vibration non disponible');
      return;
    }

    AppLogger.haptic('Test du feedback haptique...');
    await mediumImpact();
  }

  // ==================== HELPERS PRIVÉS ====================

  /// Vibration Android avec amplitude personnalisée
  Future<void> _vibrate({
    required int duration,
    int? amplitude,
  }) async {
    try {
      if (_hasAmplitudeControl && amplitude != null) {
        await Vibration.vibrate(duration: duration, amplitude: amplitude);
      } else {
        await Vibration.vibrate(duration: duration);
      }
    } catch (e) {
      AppLogger.error('Erreur vibration Android: $e');
    }
  }

  /// Calcule l'amplitude selon l'intensité configurée
  int _getAmplitude({bool light = false, bool strong = false}) {
    if (light) {
      switch (_intensity) {
        case HapticIntensity.light:
          return 50;
        case HapticIntensity.medium:
          return 80;
        case HapticIntensity.strong:
          return 120;
      }
    } else if (strong) {
      switch (_intensity) {
        case HapticIntensity.light:
          return 150;
        case HapticIntensity.medium:
          return 200;
        case HapticIntensity.strong:
          return 255;
      }
    } else {
      // Amplitude normale
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

  @override
  Future<void> customVibration(int milliseconds) async {
    if (!_canVibrate || !_isEnabled) return;
    
    try {
      AppLogger.haptic('Vibration personnalisée: ${milliseconds}ms');
      
      // Utiliser l'amplitude normale pour la vibration personnalisée
      final amplitude = _getAmplitude();
      await _vibrate(duration: milliseconds, amplitude: amplitude);
    } catch (e) {
      AppLogger.error('Erreur vibration personnalisée: $e');
    }
  }

  @override
  void dispose() {
    _instance = null;
    AppLogger.haptic('Service haptique libéré');
  }
}