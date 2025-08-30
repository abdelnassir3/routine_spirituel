import 'dart:async';
import 'package:spiritual_routines/core/services/persistence_service.dart';

/// Version web stub du service de persistance
/// Simule les opérations sans accéder à Drift database
class WebStubPersistenceService implements PersistenceService {
  final StreamController<SyncStatus> _syncController =
      StreamController<SyncStatus>.broadcast();

  String? _currentSessionId;

  void setCurrentSession(String sessionId) => _currentSessionId = sessionId;
  String? getCurrentSession() => _currentSessionId;
  void clearCurrentSession() => _currentSessionId = null;

  @override
  Stream<void> autoSave(Duration interval) async* {
    // Stub implementation - no actual auto-save on web
    while (true) {
      await Future<void>.delayed(interval);
      yield null;
    }
  }

  @override
  Future<SessionSnapshot> captureSnapshot() async {
    // Stub implementation - return empty snapshot
    print('🌐 Web stub: captureSnapshot called');
    return const SessionSnapshot({
      'sessionId': 'web-stub-session',
      'timestamp': 0,
      'tasks': [],
    });
  }

  @override
  Future<void> restoreSnapshot(SessionSnapshot snapshot) async {
    // Stub implementation - just log
    print('🌐 Web stub: restoreSnapshot called');
  }

  @override
  Future<RecoveryOptions> detectInterruption() async {
    // Stub implementation - no interruption detection on web
    print('🌐 Web stub: detectInterruption called');
    return const RecoveryOptions(hasSnapshot: false);
  }

  @override
  Future<SyncResult> syncWithCloud() async {
    // Stub implementation - no cloud sync on web
    print('🌐 Web stub: syncWithCloud called');
    return const SyncResult(true, message: 'Web stub - no sync');
  }

  @override
  Future<void> handleRecovery(RecoveryChoice choice) async {
    // Stub implementation - just log
    print('🌐 Web stub: handleRecovery called with $choice');
  }

  @override
  Stream<SyncStatus> watchSyncStatus() => _syncController.stream;
}
