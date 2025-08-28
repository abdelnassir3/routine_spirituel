import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';
import 'haptic_service.dart';

/// Service d'auto-resume pour la reprise automatique des sessions
///
/// Complète le SessionService existant avec détection automatique
/// des interruptions et reprise transparente pour l'utilisateur
class AutoResumeService with WidgetsBindingObserver {
  static AutoResumeService? _instance;

  // État de reprise
  ResumeState? _pendingResume;
  Timer? _autoSaveTimer;
  bool _isInitialized = false;
  DateTime? _lastPauseTime;

  // Configuration
  static const Duration _autoSaveInterval = Duration(seconds: 5);
  static const Duration _resumeTimeout = Duration(minutes: 30);
  static const Duration _quickResumeThreshold = Duration(seconds: 10);

  // Clés de stockage
  static const String _keyResumeState = 'auto_resume_state';
  static const String _keyResumeEnabled = 'auto_resume_enabled';
  static const String _keyQuickResumeEnabled = 'quick_resume_enabled';

  // Callbacks
  VoidCallback? onSessionNeedsResume;
  Function(ResumeState)? onSessionResumed;
  VoidCallback? onSessionExpired;

  // Services
  final HapticService _hapticService = HapticService.instance;

  // Singleton
  static AutoResumeService get instance {
    _instance ??= AutoResumeService._();
    return _instance!;
  }

  AutoResumeService._();

  /// Initialiser le service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Observer le cycle de vie
      WidgetsBinding.instance.addObserver(this);

      // Charger l'état de reprise s'il existe
      await _loadResumeState();

      _isInitialized = true;

      AppLogger.logDebugInfo('AutoResumeService initialized', {
        'hasPendingResume': _pendingResume != null,
      });

      // Vérifier si une reprise est nécessaire
      if (_pendingResume != null && !_pendingResume!.isExpired) {
        // Notifier qu'une session peut être reprise
        onSessionNeedsResume?.call();
      }
    } catch (e) {
      AppLogger.logError('AutoResumeService initialization failed', e);
    }
  }

  // ===== Configuration =====

  Future<bool> get isEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyResumeEnabled) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyResumeEnabled, enabled);

    if (!enabled) {
      await clearResumeState();
    }

    AppLogger.logUserAction('auto_resume_toggled', {'enabled': enabled});
  }

  Future<bool> get isQuickResumeEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyQuickResumeEnabled) ?? true;
  }

  Future<void> setQuickResumeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyQuickResumeEnabled, enabled);

    AppLogger.logUserAction('quick_resume_toggled', {'enabled': enabled});
  }

  // ===== Cycle de vie =====

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.inactive:
        _onAppInactive();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      default:
        break;
    }
  }

  void _onAppPaused() {
    _lastPauseTime = DateTime.now();

    if (_pendingResume != null) {
      // Sauvegarder l'état actuel
      _saveResumeState();

      AppLogger.logDebugInfo('App paused with active session', {
        'sessionId': _pendingResume!.sessionId,
        'progress': _pendingResume!.progress,
      });
    }
  }

  void _onAppResumed() async {
    if (_lastPauseTime == null) return;

    final pauseDuration = DateTime.now().difference(_lastPauseTime!);
    final isQuickResumeEnabled = await this.isQuickResumeEnabled;

    AppLogger.logDebugInfo('App resumed', {
      'pauseDuration': pauseDuration.inSeconds,
      'quickResumeEnabled': isQuickResumeEnabled,
    });

    // Quick resume si l'app était en pause moins de 10 secondes
    if (isQuickResumeEnabled &&
        pauseDuration < _quickResumeThreshold &&
        _pendingResume != null) {
      // Reprise automatique immédiate
      await _performQuickResume();
    } else if (_pendingResume != null && !_pendingResume!.isExpired) {
      // Proposer la reprise normale
      onSessionNeedsResume?.call();
    }

    _lastPauseTime = null;
  }

  void _onAppInactive() {
    // L'app devient inactive (ex: appel entrant)
    if (_pendingResume != null) {
      _saveResumeState();
    }
  }

  void _onAppDetached() {
    // L'app va être détruite
    if (_pendingResume != null) {
      _saveResumeState();
    }
    _stopAutoSave();
  }

  // ===== Gestion de la reprise =====

  /// Enregistrer une session pour auto-resume
  Future<void> registerSession({
    required String sessionId,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final isEnabled = await this.isEnabled;
    if (!isEnabled) return;

    _pendingResume = ResumeState(
      sessionId: sessionId,
      type: type,
      timestamp: DateTime.now(),
      data: data,
      progress: 0,
    );

    _startAutoSave();
    await _saveResumeState();

    AppLogger.logDebugInfo('Session registered for auto-resume', {
      'sessionId': sessionId,
      'type': type,
    });
  }

  /// Mettre à jour le progrès
  Future<void> updateProgress(int progress) async {
    if (_pendingResume == null) return;

    _pendingResume = _pendingResume!.copyWith(
      progress: progress,
      timestamp: DateTime.now(),
    );

    // Sauvegarder périodiquement
    if (progress % 10 == 0) {
      await _saveResumeState();
    }
  }

  /// Reprendre la session
  Future<bool> resumeSession() async {
    if (_pendingResume == null || _pendingResume!.isExpired) {
      return false;
    }

    try {
      // Haptic feedback
      await _hapticService.success();

      // Notifier la reprise
      onSessionResumed?.call(_pendingResume!);

      AppLogger.logUserAction('session_resumed', {
        'sessionId': _pendingResume!.sessionId,
        'progress': _pendingResume!.progress,
        'age': _pendingResume!.age.inSeconds,
      });

      // Redémarrer l'auto-save
      _startAutoSave();

      return true;
    } catch (e) {
      AppLogger.logError('Failed to resume session', e);
      return false;
    }
  }

  /// Reprise rapide automatique
  Future<void> _performQuickResume() async {
    if (_pendingResume == null) return;

    // Vibration légère pour indiquer la reprise
    await _hapticService.lightTap();

    // Notifier
    onSessionResumed?.call(_pendingResume!);

    AppLogger.logDebugInfo('Quick resume performed', {
      'sessionId': _pendingResume!.sessionId,
      'progress': _pendingResume!.progress,
    });
  }

  /// Terminer une session
  Future<void> completeSession() async {
    if (_pendingResume == null) return;

    AppLogger.logUserAction('session_completed_with_resume', {
      'sessionId': _pendingResume!.sessionId,
      'finalProgress': _pendingResume!.progress,
    });

    await clearResumeState();
    _stopAutoSave();
  }

  /// Abandonner une session
  Future<void> abandonSession() async {
    if (_pendingResume == null) return;

    AppLogger.logUserAction('session_abandoned', {
      'sessionId': _pendingResume!.sessionId,
      'progress': _pendingResume!.progress,
    });

    await clearResumeState();
    _stopAutoSave();
  }

  // ===== Persistance =====

  Future<void> _loadResumeState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString(_keyResumeState);

      if (stateJson != null) {
        _pendingResume = ResumeState.fromJson(json.decode(stateJson));

        // Vérifier l'expiration
        if (_pendingResume!.isExpired) {
          onSessionExpired?.call();
          await clearResumeState();
        }
      }
    } catch (e) {
      AppLogger.logError('Failed to load resume state', e);
    }
  }

  Future<void> _saveResumeState() async {
    if (_pendingResume == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = json.encode(_pendingResume!.toJson());
      await prefs.setString(_keyResumeState, stateJson);
    } catch (e) {
      AppLogger.logError('Failed to save resume state', e);
    }
  }

  Future<void> clearResumeState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyResumeState);
      _pendingResume = null;
    } catch (e) {
      AppLogger.logError('Failed to clear resume state', e);
    }
  }

  // ===== Auto-save =====

  void _startAutoSave() {
    _stopAutoSave();
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (_) {
      _saveResumeState();
    });
  }

  void _stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  // ===== Getters =====

  ResumeState? get pendingResume => _pendingResume;
  bool get hasPendingResume =>
      _pendingResume != null && !_pendingResume!.isExpired;

  // ===== Nettoyage =====

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAutoSave();
  }
}

// ===== Modèle de reprise =====

/// État de reprise d'une session
class ResumeState {
  final String sessionId;
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final int progress;

  ResumeState({
    required this.sessionId,
    required this.type,
    required this.timestamp,
    required this.data,
    required this.progress,
  });

  /// Âge de l'état
  Duration get age => DateTime.now().difference(timestamp);

  /// Vérifier si expiré (30 minutes)
  bool get isExpired => age > AutoResumeService._resumeTimeout;

  /// Temps restant avant expiration
  Duration get timeRemaining {
    final remaining = AutoResumeService._resumeTimeout - age;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  ResumeState copyWith({
    String? sessionId,
    String? type,
    DateTime? timestamp,
    Map<String, dynamic>? data,
    int? progress,
  }) {
    return ResumeState(
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'progress': progress,
    };
  }

  factory ResumeState.fromJson(Map<String, dynamic> json) {
    return ResumeState(
      sessionId: json['sessionId'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      data: Map<String, dynamic>.from(json['data']),
      progress: json['progress'] ?? 0,
    );
  }
}

/// Types de reprise
enum ResumeType {
  quick, // Reprise rapide (<10s)
  normal, // Reprise normale avec confirmation
  expired, // Session expirée
}
