import 'package:flutter/foundation.dart';

@immutable
class SessionSnapshot {
  final Map<String, Object?> payload;
  const SessionSnapshot(this.payload);
}

enum SyncStatus { idle, syncing, success, error }

@immutable
class SyncResult {
  final bool ok;
  final String? message;
  const SyncResult(this.ok, {this.message});
}

@immutable
class RecoveryOptions {
  final bool hasSnapshot;
  final SessionSnapshot? snapshot;
  const RecoveryOptions({required this.hasSnapshot, this.snapshot});
}

enum RecoveryChoice { resume, reset }

abstract class PersistenceService {
  Stream<void> autoSave(Duration interval);
  Future<SessionSnapshot> captureSnapshot();
  Future<void> restoreSnapshot(SessionSnapshot snapshot);
  Future<RecoveryOptions> detectInterruption();
  Future<void> handleRecovery(RecoveryChoice choice);
  Future<SyncResult> syncWithCloud();
  Stream<SyncStatus> watchSyncStatus();
  
  // Session management
  void setCurrentSession(String sessionId);
  String? getCurrentSession();
  void clearCurrentSession();
}
