import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import 'haptic_adapter.dart';

/// Implementation Web réelle du retour haptique avec Vibration API + feedback alternatif
/// Fournit vibration sur mobile Web et feedback visuel/sonore sur desktop
class WebHapticStub implements HapticAdapter {
  bool _isVibrationSupported = false;

  WebHapticStub() {
    _initializeVibration();
  }

  void _initializeVibration() {
    try {
      // Vérifier support de l'API Vibration
      _isVibrationSupported = js.context.hasProperty('navigator') == true &&
          js.context['navigator'].hasProperty('vibrate') == true;

      if (kDebugMode) {
        debugPrint('📳 Web Vibration API supported: $_isVibrationSupported');
        if (_isVibrationSupported) {
          debugPrint(
              '📳 Web Haptic: Vibration API available for mobile devices');
        } else {
          debugPrint('📳 Web Haptic: Using visual/audio feedback alternatives');
        }
      }
    } catch (e) {
      _isVibrationSupported = false;
      if (kDebugMode) {
        debugPrint('❌ Error initializing vibration: $e');
      }
    }
  }

  @override
  Future<void> lightImpact() async {
    await _performHapticFeedback(
      vibrationPattern: [25],
      intensity: 'light',
      description: 'Light impact',
    );
  }

  @override
  Future<void> mediumImpact() async {
    await _performHapticFeedback(
      vibrationPattern: [50],
      intensity: 'medium',
      description: 'Medium impact',
    );
  }

  @override
  Future<void> heavyImpact() async {
    await _performHapticFeedback(
      vibrationPattern: [100],
      intensity: 'heavy',
      description: 'Heavy impact',
    );
  }

  @override
  Future<void> selectionClick() async {
    await _performHapticFeedback(
      vibrationPattern: [15],
      intensity: 'selection',
      description: 'Selection click',
    );
  }

  @override
  Future<void> customVibration(int milliseconds) async {
    await _performHapticFeedback(
      vibrationPattern: [milliseconds.clamp(10, 1000)],
      intensity: 'custom',
      description: 'Custom vibration ${milliseconds}ms',
    );
  }

  /// Exécute le feedback haptique avec fallbacks alternatifs
  Future<void> _performHapticFeedback({
    required List<int> vibrationPattern,
    required String intensity,
    required String description,
  }) async {
    bool success = false;

    // 1. Essayer vibration native si supportée (mobile Web)
    if (_isVibrationSupported) {
      success = await _attemptVibration(vibrationPattern);
    }

    // 2. Fallback feedback alternatif (desktop ou échec vibration)
    if (!success) {
      await _alternativeFeedback(intensity, description);
    }

    if (kDebugMode) {
      debugPrint(
          '📳 Web Haptic: $description ${success ? "(vibration)" : "(alternative)"}');
    }
  }

  /// Tente vibration native avec l'API Vibration
  Future<bool> _attemptVibration(List<int> pattern) async {
    try {
      if (_isVibrationSupported && pattern.isNotEmpty) {
        final navigator = js.context['navigator'];
        if (pattern.length == 1) {
          // Vibration simple
          final result = navigator.callMethod('vibrate', [pattern.first]);
          return result == true;
        } else {
          // Pattern de vibration
          final jsPattern = js.JsArray.from(pattern);
          final result = navigator.callMethod('vibrate', [jsPattern]);
          return result == true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Vibration failed: $e');
      }
    }
    return false;
  }

  /// Feedback alternatif pour desktop ou cas d'échec
  Future<void> _alternativeFeedback(
      String intensity, String description) async {
    try {
      // 1. Feedback sonore court (Web Audio API)
      await _playFeedbackSound(intensity);

      // 2. Feedback visuel CSS (flash/pulse)
      _triggerVisualFeedback(intensity);

      // 3. Feedback système (limité mais essayer)
      await _systemFeedback(intensity);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Alternative feedback failed: $e');
      }
    }
  }

  /// Son de feedback court avec Web Audio API
  Future<void> _playFeedbackSound(String intensity) async {
    try {
      if (!js.context.hasProperty('AudioContext')) return;

      // Créer contexte audio temporaire
      final audioContext = js.JsObject(js.context['AudioContext'] as js.JsFunction);
      final oscillator = audioContext.callMethod('createOscillator');
      final gainNode = audioContext.callMethod('createGain');

      // Configuration selon l'intensité
      double frequency = 800.0; // Hz
      double duration = 0.05; // secondes
      double volume = 0.1;

      switch (intensity) {
        case 'light':
        case 'selection':
          frequency = 1000.0;
          duration = 0.03;
          volume = 0.05;
          break;
        case 'medium':
          frequency = 800.0;
          duration = 0.05;
          volume = 0.08;
          break;
        case 'heavy':
          frequency = 600.0;
          duration = 0.08;
          volume = 0.1;
          break;
      }

      // Configurer oscillateur
      oscillator['frequency']['value'] = frequency;
      oscillator['type'] = 'sine';

      // Configurer gain (volume)
      gainNode['gain']['value'] = volume;

      // Connecter nodes
      oscillator.callMethod('connect', [gainNode]);
      gainNode.callMethod('connect', [audioContext['destination']]);

      // Jouer son
      oscillator.callMethod('start');
      oscillator.callMethod('stop', [audioContext['currentTime'] + duration]);
    } catch (e) {
      // Silent fail pour éviter logs excessifs
    }
  }

  /// Flash visuel CSS pour feedback
  void _triggerVisualFeedback(String intensity) {
    try {
      final body = html.document.body;
      if (body == null) return;

      // Créer élément flash temporaire
      final flashElement = html.DivElement()
        ..style.position = 'fixed'
        ..style.top = '0'
        ..style.left = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.pointerEvents = 'none'
        ..style.zIndex = '9999'
        ..style.transition = 'opacity 0.1s ease-out';

      // Style selon intensité
      switch (intensity) {
        case 'light':
        case 'selection':
          flashElement.style.backgroundColor = 'rgba(255, 255, 255, 0.1)';
          break;
        case 'medium':
          flashElement.style.backgroundColor = 'rgba(255, 255, 255, 0.15)';
          break;
        case 'heavy':
          flashElement.style.backgroundColor = 'rgba(255, 255, 255, 0.2)';
          break;
        default:
          flashElement.style.backgroundColor = 'rgba(255, 255, 255, 0.1)';
      }

      // Ajouter et supprimer avec animation
      body.append(flashElement);

      // Déclencher animation
      Future.delayed(const Duration(milliseconds: 10), () {
        flashElement.style.opacity = '0';
      });

      // Nettoyer après animation
      Future.delayed(const Duration(milliseconds: 150), () {
        flashElement.remove();
      });
    } catch (e) {
      // Silent fail
    }
  }

  /// Feedback système limité
  Future<void> _systemFeedback(String intensity) async {
    try {
      // Tenter SystemSound si disponible (Flutter Web)
      if (intensity == 'selection') {
        // Son de clic système si possible
        SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      // Silent fail - normal sur Web
    }
  }

  @override
  bool get isSupported =>
      _isVibrationSupported; // Support basé sur Vibration API
}
