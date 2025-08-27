import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';
import 'haptic_service.dart';

/// Service de gestion des gestes intelligents
/// 
/// Fournit des interactions gestuelles avancées pour :
/// - Navigation par swipe
/// - Compteur par tap/swipe
/// - Raccourcis gestuels
/// - Gestes de prière spécifiques
class GestureService {
  static GestureService? _instance;
  
  // Configuration
  bool _isEnabled = true;
  GestureSensitivity _sensitivity = GestureSensitivity.medium;
  bool _leftHandedMode = false;
  
  // Détection de patterns
  final List<GestureEvent> _recentGestures = [];
  static const int _maxGestureHistory = 10;
  static const Duration _patternTimeout = Duration(seconds: 2);
  
  // Callbacks
  final Map<GesturePattern, VoidCallback> _patternCallbacks = {};
  
  // Services
  final HapticService _hapticService = HapticService.instance;
  
  // Clés de préférences
  static const String _keyEnabled = 'gestures_enabled';
  static const String _keySensitivity = 'gestures_sensitivity';
  static const String _keyLeftHanded = 'gestures_left_handed';
  
  // Singleton
  static GestureService get instance {
    _instance ??= GestureService._();
    return _instance!;
  }
  
  GestureService._() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_keyEnabled) ?? true;
      final sensitivityIndex = prefs.getInt(_keySensitivity) ?? GestureSensitivity.medium.index;
      _sensitivity = GestureSensitivity.values[sensitivityIndex];
      _leftHandedMode = prefs.getBool(_keyLeftHanded) ?? false;
      
      AppLogger.logDebugInfo('GestureService initialized', {
        'enabled': _isEnabled,
        'sensitivity': _sensitivity.name,
        'leftHanded': _leftHandedMode,
      });
    } catch (e) {
      AppLogger.logError('GestureService initialization failed', e);
    }
  }
  
  // ===== Configuration =====
  
  bool get isEnabled => _isEnabled;
  GestureSensitivity get sensitivity => _sensitivity;
  bool get leftHandedMode => _leftHandedMode;
  
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, enabled);
    
    AppLogger.logUserAction('gestures_toggled', {'enabled': enabled});
  }
  
  Future<void> setSensitivity(GestureSensitivity sensitivity) async {
    _sensitivity = sensitivity;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySensitivity, sensitivity.index);
    
    AppLogger.logUserAction('gesture_sensitivity_changed', {'sensitivity': sensitivity.name});
  }
  
  Future<void> setLeftHandedMode(bool leftHanded) async {
    _leftHandedMode = leftHanded;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLeftHanded, leftHanded);
    
    AppLogger.logUserAction('left_handed_mode_changed', {'leftHanded': leftHanded});
  }
  
  // ===== Seuils de détection =====
  
  double get swipeThreshold {
    switch (_sensitivity) {
      case GestureSensitivity.low:
        return 100.0;
      case GestureSensitivity.medium:
        return 50.0;
      case GestureSensitivity.high:
        return 25.0;
    }
  }
  
  double get velocityThreshold {
    switch (_sensitivity) {
      case GestureSensitivity.low:
        return 500.0;
      case GestureSensitivity.medium:
        return 300.0;
      case GestureSensitivity.high:
        return 150.0;
    }
  }
  
  Duration get longPressThreshold {
    switch (_sensitivity) {
      case GestureSensitivity.low:
        return const Duration(milliseconds: 800);
      case GestureSensitivity.medium:
        return const Duration(milliseconds: 500);
      case GestureSensitivity.high:
        return const Duration(milliseconds: 300);
    }
  }
  
  // ===== Détection de gestes =====
  
  /// Analyser un swipe et retourner sa direction
  SwipeDirection? analyzeSwipe({
    required Offset start,
    required Offset end,
    required Duration duration,
  }) {
    if (!_isEnabled) return null;
    
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final velocity = distance / duration.inMilliseconds * 1000;
    
    // Vérifier les seuils
    if (distance < swipeThreshold || velocity < velocityThreshold) {
      return null;
    }
    
    // Déterminer la direction
    final angle = math.atan2(dy, dx);
    final degrees = angle * 180 / math.pi;
    
    // Ajuster pour le mode gaucher
    final adjustedDegrees = _leftHandedMode ? -degrees : degrees;
    
    if (adjustedDegrees.abs() < 45) {
      return SwipeDirection.right;
    } else if (adjustedDegrees.abs() > 135) {
      return SwipeDirection.left;
    } else if (adjustedDegrees > -135 && adjustedDegrees < -45) {
      return SwipeDirection.up;
    } else {
      return SwipeDirection.down;
    }
  }
  
  /// Détecter un cercle dessiné
  bool detectCircleGesture(List<Offset> points) {
    if (!_isEnabled || points.length < 8) return false;
    
    // Calculer le centre
    double centerX = 0, centerY = 0;
    for (final point in points) {
      centerX += point.dx;
      centerY += point.dy;
    }
    centerX /= points.length;
    centerY /= points.length;
    
    // Calculer le rayon moyen
    double avgRadius = 0;
    for (final point in points) {
      final dx = point.dx - centerX;
      final dy = point.dy - centerY;
      avgRadius += math.sqrt(dx * dx + dy * dy);
    }
    avgRadius /= points.length;
    
    // Vérifier la circularité
    double maxDeviation = 0;
    for (final point in points) {
      final dx = point.dx - centerX;
      final dy = point.dy - centerY;
      final radius = math.sqrt(dx * dx + dy * dy);
      final deviation = (radius - avgRadius).abs() / avgRadius;
      maxDeviation = math.max(maxDeviation, deviation);
    }
    
    // Tolérance selon la sensibilité
    final tolerance = _sensitivity == GestureSensitivity.high ? 0.3 : 0.5;
    return maxDeviation < tolerance;
  }
  
  /// Détecter un geste de zigzag (pour annuler)
  bool detectZigzagGesture(List<Offset> points) {
    if (!_isEnabled || points.length < 4) return false;
    
    int directionChanges = 0;
    double? lastDirection;
    
    for (int i = 1; i < points.length; i++) {
      final dx = points[i].dx - points[i - 1].dx;
      
      if (dx.abs() > 10) {
        final currentDirection = dx > 0 ? 1.0 : -1.0;
        
        if (lastDirection != null && currentDirection != lastDirection) {
          directionChanges++;
        }
        
        lastDirection = currentDirection;
      }
    }
    
    // Au moins 3 changements de direction pour un zigzag
    return directionChanges >= 3;
  }
  
  // ===== Gestes de prière =====
  
  /// Geste pour incrémenter le compteur (swipe up ou tap)
  Future<void> handleCounterIncrement() async {
    if (!_isEnabled) return;
    
    await _hapticService.counterTick();
    _recordGesture(GestureType.counterIncrement);
    
    AppLogger.logUserAction('gesture_counter_increment');
  }
  
  /// Geste pour décrémenter le compteur (swipe down)
  Future<void> handleCounterDecrement() async {
    if (!_isEnabled) return;
    
    await _hapticService.lightTap();
    _recordGesture(GestureType.counterDecrement);
    
    AppLogger.logUserAction('gesture_counter_decrement');
  }
  
  /// Geste pour reset le compteur (long press ou cercle)
  Future<void> handleCounterReset() async {
    if (!_isEnabled) return;
    
    await _hapticService.impact();
    _recordGesture(GestureType.counterReset);
    
    AppLogger.logUserAction('gesture_counter_reset');
  }
  
  /// Geste pour pause/resume (double tap)
  Future<void> handlePauseResume() async {
    if (!_isEnabled) return;
    
    await _hapticService.selection();
    _recordGesture(GestureType.pauseResume);
    
    AppLogger.logUserAction('gesture_pause_resume');
  }
  
  // ===== Patterns de gestes =====
  
  /// Enregistrer un callback pour un pattern de gestes
  void registerPatternCallback(GesturePattern pattern, VoidCallback callback) {
    _patternCallbacks[pattern] = callback;
  }
  
  /// Détecter et exécuter un pattern
  Future<void> detectAndExecutePattern() async {
    if (!_isEnabled || _recentGestures.isEmpty) return;
    
    // Nettoyer les gestes trop anciens
    _cleanOldGestures();
    
    // Vérifier les patterns connus
    for (final entry in _patternCallbacks.entries) {
      if (_matchesPattern(entry.key)) {
        await _hapticService.success();
        entry.value();
        _recentGestures.clear(); // Reset après exécution
        
        AppLogger.logUserAction('gesture_pattern_executed', {
          'pattern': entry.key.toString(),
        });
        break;
      }
    }
  }
  
  bool _matchesPattern(GesturePattern pattern) {
    if (_recentGestures.length < pattern.gestures.length) return false;
    
    // Vérifier si les derniers gestes correspondent au pattern
    final startIndex = _recentGestures.length - pattern.gestures.length;
    for (int i = 0; i < pattern.gestures.length; i++) {
      if (_recentGestures[startIndex + i].type != pattern.gestures[i]) {
        return false;
      }
    }
    
    return true;
  }
  
  void _recordGesture(GestureType type) {
    _recentGestures.add(GestureEvent(
      type: type,
      timestamp: DateTime.now(),
    ));
    
    // Limiter l'historique
    if (_recentGestures.length > _maxGestureHistory) {
      _recentGestures.removeAt(0);
    }
  }
  
  void _cleanOldGestures() {
    final cutoff = DateTime.now().subtract(_patternTimeout);
    _recentGestures.removeWhere((g) => g.timestamp.isBefore(cutoff));
  }
  
  // ===== Raccourcis clavier (desktop) =====
  
  /// Gérer les raccourcis clavier pour desktop
  bool handleKeyEvent(KeyEvent event) {
    if (!_isEnabled || !kIsWeb) return false;
    
    if (event is KeyDownEvent) {
      // Ctrl/Cmd + Space : Pause/Resume
      if (event.logicalKey == LogicalKeyboardKey.space &&
          (HardwareKeyboard.instance.isControlPressed ||
           HardwareKeyboard.instance.isMetaPressed)) {
        handlePauseResume();
        return true;
      }
      
      // Flèche haut : Incrémenter
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        handleCounterIncrement();
        return true;
      }
      
      // Flèche bas : Décrémenter
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        handleCounterDecrement();
        return true;
      }
      
      // Escape : Reset
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        handleCounterReset();
        return true;
      }
    }
    
    return false;
  }
}

// ===== Enums et classes =====

/// Sensibilité de détection des gestes
enum GestureSensitivity {
  low,
  medium,
  high,
}

/// Direction d'un swipe
enum SwipeDirection {
  up,
  down,
  left,
  right,
}

/// Types de gestes
enum GestureType {
  tap,
  doubleTap,
  longPress,
  swipeUp,
  swipeDown,
  swipeLeft,
  swipeRight,
  circle,
  zigzag,
  counterIncrement,
  counterDecrement,
  counterReset,
  pauseResume,
}

/// Événement de geste
class GestureEvent {
  final GestureType type;
  final DateTime timestamp;
  
  const GestureEvent({
    required this.type,
    required this.timestamp,
  });
}

/// Pattern de gestes
class GesturePattern {
  final List<GestureType> gestures;
  final String name;
  
  const GesturePattern({
    required this.gestures,
    required this.name,
  });
  
  // Patterns prédéfinis
  static const quickSave = GesturePattern(
    name: 'Quick Save',
    gestures: [GestureType.doubleTap, GestureType.longPress],
  );
  
  static const undoLast = GesturePattern(
    name: 'Undo Last',
    gestures: [GestureType.swipeLeft, GestureType.swipeLeft],
  );
  
  static const skipToEnd = GesturePattern(
    name: 'Skip to End',
    gestures: [GestureType.swipeUp, GestureType.swipeUp, GestureType.swipeUp],
  );
  
  @override
  String toString() => name;
}