import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift; // ✅ pour Value<T>

import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';
import 'package:spiritual_routines/core/services/persistence_service.dart';

class DriftPersistenceService implements PersistenceService {
  DriftPersistenceService(this._ref)
      : _syncController = StreamController<SyncStatus>.broadcast();

  final Ref _ref;
  final StreamController<SyncStatus> _syncController;

  String? _currentSessionId;
  void setCurrentSession(String sessionId) => _currentSessionId = sessionId;
  String? getCurrentSession() => _currentSessionId;
  void clearCurrentSession() => _currentSessionId = null;

  @override
  Stream<void> autoSave(Duration interval) async* {
    while (true) {
      await Future<void>.delayed(interval);
      if (_currentSessionId != null) {
        await _saveSnapshot(_currentSessionId!);
      }
      yield null;
    }
  }

  Future<void> _saveSnapshot(String sessionId) async {
    final progressDao = _ref.read(progressDaoProvider);
    final items = await progressDao.getBySession(sessionId);
    final payload = {
      'sessionId': sessionId,
      'progress': items
          .map((e) => {
                'id': e.id,
                'taskId': e.taskId,
                'remainingReps': e.remainingReps,
                'elapsedMs': e.elapsedMs,
                'wordIndex': e.wordIndex,
                'verseIndex': e.verseIndex,
                'lastUpdate': e.lastUpdate.toIso8601String(),
              })
          .toList(),
    };
    final snapshotDao = _ref.read(snapshotDaoProvider);
    await snapshotDao.addSnapshot(SnapshotsCompanion.insert(
      id: _genId(),
      sessionId: sessionId,
      payload: jsonEncode(payload),
    ));
  }

  @override
  Future<SessionSnapshot> captureSnapshot() async {
    final sessionId = _currentSessionId;
    if (sessionId == null) return const SessionSnapshot({});
    final progressDao = _ref.read(progressDaoProvider);
    final items = await progressDao.getBySession(sessionId);
    final payload = {
      'sessionId': sessionId,
      'progress': items
          .map((e) => {
                'id': e.id,
                'taskId': e.taskId,
                'remainingReps': e.remainingReps,
                'elapsedMs': e.elapsedMs,
                'wordIndex': e.wordIndex,
                'verseIndex': e.verseIndex,
                'lastUpdate': e.lastUpdate.toIso8601String(),
              })
          .toList(),
    };
    return SessionSnapshot(payload);
  }

  @override
  Future<void> restoreSnapshot(SessionSnapshot snapshot) async {
    final map = snapshot.payload;
    final sessionId = map['sessionId'] as String?;
    if (sessionId == null) return;
    _currentSessionId = sessionId;
    final progressDao = _ref.read(progressDaoProvider);
    final List<dynamic> list = (map['progress'] as List<dynamic>? ?? []);
    for (final e in list) {
      final m = e as Map<String, dynamic>;
      await progressDao.upsertProgress(TaskProgressCompanion(
        id: drift.Value(m['id'] as String),
        sessionId: drift.Value(sessionId),
        taskId: drift.Value(m['taskId'] as String),
        remainingReps: drift.Value(m['remainingReps'] as int),
        elapsedMs: drift.Value(m['elapsedMs'] as int),
        wordIndex: drift.Value(m['wordIndex'] as int),
        verseIndex: drift.Value(m['verseIndex'] as int),
        lastUpdate: drift.Value(DateTime.parse(m['lastUpdate'] as String)),
      ));
    }
  }

  @override
  Future<RecoveryOptions> detectInterruption() async {
    final sessionDao = _ref.read(sessionDaoProvider);
    final last = await sessionDao.latestAnyActiveOrPaused();
    if (last == null) return const RecoveryOptions(hasSnapshot: false);
    final snapshotDao = _ref.read(snapshotDaoProvider);
    final snap = await snapshotDao.latestForSession(last.id);
    if (snap == null) return const RecoveryOptions(hasSnapshot: false);
    return RecoveryOptions(
      hasSnapshot: true,
      snapshot:
          SessionSnapshot(jsonDecode(snap.payload) as Map<String, dynamic>),
    );
  }

  @override
  Future<void> handleRecovery(RecoveryChoice choice) async {
    final options = await detectInterruption();
    if (!options.hasSnapshot || options.snapshot == null) return;
    final sessionId = (options.snapshot!.payload['sessionId'] as String?) ??
        _currentSessionId;
    if (sessionId == null) return;
    final sessionDao = _ref.read(sessionDaoProvider);
    if (choice == RecoveryChoice.resume) {
      await sessionDao.upsertSession(SessionsCompanion(
        id: drift.Value(sessionId),
        state: const drift.Value('active'),
      ));
      await restoreSnapshot(options.snapshot!);
    } else {
      // reset: clear progress rows and set state to active with defaults (left for business logic)
      final progressDao = _ref.read(progressDaoProvider);
      await progressDao.deleteBySession(sessionId);
      await sessionDao.upsertSession(SessionsCompanion(
        id: drift.Value(sessionId),
        state: const drift.Value('active'),
      ));
    }
  }

  @override
  Future<SyncResult> syncWithCloud() async {
    _syncController.add(SyncStatus.syncing);
    // TODO: integrate Supabase; for now, stub success
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _syncController.add(SyncStatus.success);
    return const SyncResult(true, message: 'Stub sync complete');
  }

  @override
  Stream<SyncStatus> watchSyncStatus() => _syncController.stream;

  String _genId() => DateTime.now().microsecondsSinceEpoch.toString();
}

final persistenceServiceProvider =
    Provider<DriftPersistenceService>((ref) => DriftPersistenceService(ref));

final recoveryOptionsProvider = FutureProvider<RecoveryOptions>((ref) async {
  final svc = ref.read(persistenceServiceProvider);
  return svc.detectInterruption();
});
