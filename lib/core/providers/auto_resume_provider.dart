import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auto_resume_service.dart';

/// Provider pour le service d'auto-resume
final autoResumeServiceProvider = Provider<AutoResumeService>((ref) {
  final service = AutoResumeService.instance;
  
  // Initialiser au démarrage
  service.initialize();
  
  // Nettoyer à la destruction
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Provider pour l'état de reprise en attente
final pendingResumeProvider = Provider<ResumeState?>((ref) {
  final service = ref.watch(autoResumeServiceProvider);
  return service.pendingResume;
});

/// Provider pour vérifier si une reprise est disponible
final hasResumeAvailableProvider = Provider<bool>((ref) {
  final service = ref.watch(autoResumeServiceProvider);
  return service.hasPendingResume;
});

/// Provider pour l'état d'activation de l'auto-resume
final autoResumeEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(autoResumeServiceProvider);
  return await service.isEnabled;
});

/// Provider pour l'état du quick resume
final quickResumeEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(autoResumeServiceProvider);
  return await service.isQuickResumeEnabled;
});

/// Notifier pour gérer les préférences d'auto-resume
class AutoResumePreferencesNotifier extends StateNotifier<AutoResumePreferences> {
  final AutoResumeService _service;
  
  AutoResumePreferencesNotifier(this._service)
      : super(AutoResumePreferences(
          enabled: true,
          quickResumeEnabled: true,
        )) {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final enabled = await _service.isEnabled;
    final quickResumeEnabled = await _service.isQuickResumeEnabled;
    
    state = AutoResumePreferences(
      enabled: enabled,
      quickResumeEnabled: quickResumeEnabled,
    );
  }
  
  Future<void> setEnabled(bool enabled) async {
    await _service.setEnabled(enabled);
    state = state.copyWith(enabled: enabled);
  }
  
  Future<void> setQuickResumeEnabled(bool enabled) async {
    await _service.setQuickResumeEnabled(enabled);
    state = state.copyWith(quickResumeEnabled: enabled);
  }
}

/// État des préférences d'auto-resume
class AutoResumePreferences {
  final bool enabled;
  final bool quickResumeEnabled;
  
  const AutoResumePreferences({
    required this.enabled,
    required this.quickResumeEnabled,
  });
  
  AutoResumePreferences copyWith({
    bool? enabled,
    bool? quickResumeEnabled,
  }) {
    return AutoResumePreferences(
      enabled: enabled ?? this.enabled,
      quickResumeEnabled: quickResumeEnabled ?? this.quickResumeEnabled,
    );
  }
}

/// Provider pour les préférences d'auto-resume
final autoResumePreferencesProvider = 
    StateNotifierProvider<AutoResumePreferencesNotifier, AutoResumePreferences>((ref) {
  final service = ref.watch(autoResumeServiceProvider);
  return AutoResumePreferencesNotifier(service);
});

/// Actions pour l'auto-resume
class AutoResumeActions {
  final Ref _ref;
  
  AutoResumeActions(this._ref);
  
  /// Enregistrer une session pour auto-resume
  Future<void> registerSession({
    required String sessionId,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final service = _ref.read(autoResumeServiceProvider);
    await service.registerSession(
      sessionId: sessionId,
      type: type,
      data: data,
    );
  }
  
  /// Mettre à jour le progrès
  Future<void> updateProgress(int progress) async {
    final service = _ref.read(autoResumeServiceProvider);
    await service.updateProgress(progress);
  }
  
  /// Reprendre une session
  Future<bool> resumeSession() async {
    final service = _ref.read(autoResumeServiceProvider);
    return await service.resumeSession();
  }
  
  /// Terminer une session
  Future<void> completeSession() async {
    final service = _ref.read(autoResumeServiceProvider);
    await service.completeSession();
  }
  
  /// Abandonner une session
  Future<void> abandonSession() async {
    final service = _ref.read(autoResumeServiceProvider);
    await service.abandonSession();
  }
  
  /// Effacer l'état de reprise
  Future<void> clearResumeState() async {
    final service = _ref.read(autoResumeServiceProvider);
    await service.clearResumeState();
  }
}

/// Provider pour les actions d'auto-resume
final autoResumeActionsProvider = Provider<AutoResumeActions>((ref) {
  return AutoResumeActions(ref);
});

/// Extension pour faciliter l'usage dans les widgets
extension AutoResumeWidgetRef on WidgetRef {
  /// Enregistrer une session pour auto-resume
  Future<void> registerForAutoResume({
    required String sessionId,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    await read(autoResumeActionsProvider).registerSession(
      sessionId: sessionId,
      type: type,
      data: data,
    );
  }
  
  /// Mettre à jour le progrès de la session
  Future<void> updateSessionProgress(int progress) async {
    await read(autoResumeActionsProvider).updateProgress(progress);
  }
  
  /// Reprendre la session en attente
  Future<bool> resumePendingSession() async {
    return await read(autoResumeActionsProvider).resumeSession();
  }
  
  /// Terminer la session active
  Future<void> completeAutoResumeSession() async {
    await read(autoResumeActionsProvider).completeSession();
  }
  
  /// Abandonner la session
  Future<void> abandonAutoResumeSession() async {
    await read(autoResumeActionsProvider).abandonSession();
  }
}