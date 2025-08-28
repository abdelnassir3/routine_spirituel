import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';
import 'package:spiritual_routines/core/utils/id.dart';
import 'package:spiritual_routines/core/services/persistence_service_drift.dart';
import 'package:spiritual_routines/core/services/progress_service.dart';
import 'package:spiritual_routines/features/session/session_state.dart';

class SessionService {
  SessionService(this._ref);
  final Ref _ref;

  // Verrou pour empêcher les appels concurrents à startRoutine
  static bool _isStartingRoutine = false;
  static final Map<String, DateTime> _lastStartTime = {};

  Future<String> startRoutine(String routineId, {String? startTaskId}) async {
    // Protection contre les appels multiples rapides
    final now = DateTime.now();
    final lastStart = _lastStartTime[routineId];
    if (lastStart != null && now.difference(lastStart).inMilliseconds < 500) {
      // print('⚠️ Appel trop rapide ignoré pour routine: $routineId');
      // Retourner la session existante si elle existe
      final existingSession = await _getActiveSession(routineId);
      if (existingSession != null) {
        return existingSession.id;
      }
    }
    _lastStartTime[routineId] = now;

    // Verrou pour empêcher les appels concurrents
    if (_isStartingRoutine) {
      // print('⚠️ Une création de session est déjà en cours, attente...');
      int attempts = 0;
      while (_isStartingRoutine && attempts < 20) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      // Vérifier si une session active existe maintenant
      final activeSession = await _getActiveSession(routineId);
      if (activeSession != null) {
        // print('✅ Session active trouvée après attente: ${activeSession.id}');
        return activeSession.id;
      }
    }

    _isStartingRoutine = true;
    try {
      // Vérifier d'abord s'il y a déjà UNE session active
      final existingActive = await _getActiveSession(routineId);
      if (existingActive != null) {
        // print('ℹ️ Session active existante réutilisée: ${existingActive.id}');
        _ref
            .read(persistenceServiceProvider)
            .setCurrentSession(existingActive.id);
        _ref.read(currentSessionIdProvider.notifier).state = existingActive.id;
        return existingActive.id;
      }

      // Nettoyer TOUTES les sessions de cette routine (active, stopped, etc.) sauf completed
      final allSessions =
          await _ref.read(sessionDaoProvider).getAllByRoutine(routineId);
      int cleanedCount = 0;
      for (final session in allSessions) {
        if (session.state != 'completed') {
          // print('🧹 Nettoyage de la session ${session.state}: ${session.id}');
          // Supprimer directement au lieu de compléter pour éviter la prolifération
          await _deleteSession(session.id);
          cleanedCount++;
        }
      }
      if (cleanedCount > 0) {
        // print('🧹 Total sessions nettoyées: $cleanedCount');
      }

      final sessionId = newId();
      // print('📋 Création de la nouvelle session: $sessionId pour routine: $routineId');

      await _ref.read(sessionDaoProvider).upsertSession(
            SessionsCompanion.insert(
              id: sessionId,
              routineId: routineId,
              state: const drift.Value('active'),
            ),
          );
      _ref.read(persistenceServiceProvider).setCurrentSession(sessionId);
      // IMPORTANT: Mettre à jour le provider global de session courante
      _ref.read(currentSessionIdProvider.notifier).state = sessionId;

      // Attendre un peu pour s'assurer que les anciennes progressions sont bien supprimées
      await Future.delayed(const Duration(milliseconds: 100));

      await _ref
          .read(progressServiceProvider)
          .initProgressForSession(sessionId, startTaskId: startTaskId);

      if (startTaskId != null) {
        // print('✅ Session et progressions initialisées pour: $sessionId (démarrage à la tâche: $startTaskId)');
      } else {
        // print('✅ Session et progressions initialisées pour: $sessionId');
      }
      return sessionId;
    } finally {
      _isStartingRoutine = false;
    }
  }

  /// Obtenir la session active pour une routine (s'il y en a une)
  Future<SessionRow?> _getActiveSession(String routineId) async {
    final sessions =
        await _ref.read(sessionDaoProvider).getAllByRoutine(routineId);
    for (final session in sessions) {
      if (session.state == 'active') {
        return session;
      }
    }
    return null;
  }

  /// Supprimer complètement une session et ses progressions
  Future<void> _deleteSession(String sessionId) async {
    // Supprimer les progressions
    await _ref.read(progressServiceProvider).clearProgressForSession(sessionId);
    // Supprimer la session
    final sessionDao = _ref.read(sessionDaoProvider);
    await (sessionDao.delete(sessionDao.sessions)
          ..where((s) => s.id.equals(sessionId)))
        .go();
  }

  /// Terminer une session avec succès
  Future<void> completeSession(String sessionId) async {
    final sessionDao = _ref.read(sessionDaoProvider);
    final now = DateTime.now();

    print('🔄 Tentative de completion de la session: $sessionId');

    // Vérifier l'état initial de la session
    final currentSession = await sessionDao.getById(sessionId);
    if (currentSession != null) {
      print(
          '📊 Session actuelle - État: ${currentSession.state}, Routine: ${currentSession.routineId}');
    } else {
      print('❌ Session non trouvée: $sessionId');
      return;
    }

    // Mettre à jour la session comme terminée
    await sessionDao.upsertSession(
      SessionsCompanion(
        id: drift.Value(sessionId),
        routineId: drift.Value(
            currentSession.routineId), // ✅ Ajouter le routineId requis
        startedAt: drift.Value(currentSession
            .startedAt), // ✅ Ajouter startedAt pour éviter les erreurs
        state: const drift.Value('completed'),
        endedAt: drift.Value(now),
      ),
    );

    // Vérifier que la mise à jour s'est bien passée
    final updatedSession = await sessionDao.getById(sessionId);
    if (updatedSession != null) {
      print(
          '✅ Session mise à jour - État: ${updatedSession.state}, Fin: ${updatedSession.endedAt}');
    } else {
      print('❌ Erreur: session non trouvée après mise à jour');
    }

    // Nettoyer la session courante si c'est celle-ci
    final currentSessionId =
        _ref.read(persistenceServiceProvider).getCurrentSession();
    if (currentSessionId == sessionId) {
      _ref.read(persistenceServiceProvider).clearCurrentSession();
      // IMPORTANT: Nettoyer aussi le provider global
      _ref.read(currentSessionIdProvider.notifier).state = null;
      print('🧹 Session courante nettoyée');
    }

    // Nettoyer le progress de cette session
    await _ref.read(progressServiceProvider).clearProgressForSession(sessionId);
    print('🧹 Progress de la session nettoyé');
  }

  /// Arrêter une session sans la marquer comme complétée
  Future<void> stopSession(String sessionId) async {
    final sessionDao = _ref.read(sessionDaoProvider);
    final now = DateTime.now();

    // Récupérer la session existante pour obtenir ses informations
    final currentSession = await sessionDao.getById(sessionId);
    if (currentSession == null) {
      print('❌ Session non trouvée pour arrêt: $sessionId');
      return;
    }

    // Mettre à jour la session comme arrêtée avec toutes les informations requises
    await sessionDao.upsertSession(
      SessionsCompanion(
        id: drift.Value(sessionId),
        routineId: drift.Value(currentSession.routineId),
        startedAt: drift.Value(currentSession.startedAt),
        state: const drift.Value('stopped'),
        endedAt: drift.Value(now),
      ),
    );

    // Nettoyer la session courante si c'est celle-ci
    final currentSessionId =
        _ref.read(persistenceServiceProvider).getCurrentSession();
    if (currentSessionId == sessionId) {
      _ref.read(persistenceServiceProvider).clearCurrentSession();
      // IMPORTANT: Nettoyer aussi le provider global
      _ref.read(currentSessionIdProvider.notifier).state = null;
    }

    // Garder le progress pour permettre la reprise
  }

  /// Vérifier s'il y a une session interrompue pour une routine
  Future<SessionRow?> getInterruptedSession(String routineId) async {
    final sessionDao = _ref.read(sessionDaoProvider);
    final sessions = await sessionDao.getAllByRoutine(routineId);

    // Trier par date décroissante pour avoir la plus récente en premier
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));

    // Logique prioritaire :
    // 1. S'il y a une session "completed" récente, pas de reprise possible
    // 2. S'il y a une session "active" ou "stopped" plus récente que toute session "completed", alors reprise possible

    final mostRecent = sessions.isNotEmpty ? sessions.first : null;

    // Si la session la plus récente est "completed", pas de reprise
    if (mostRecent?.state == 'completed') {
      return null;
    }

    // Si la session la plus récente est "active" ou "stopped", reprise possible
    if (mostRecent?.state == 'active' || mostRecent?.state == 'stopped') {
      return mostRecent;
    }

    // Sinon, pas de session à reprendre
    return null;
  }

  /// Reprendre une session interrompue
  Future<String> resumeSession(String sessionId) async {
    final sessionDao = _ref.read(sessionDaoProvider);
    final session = await sessionDao.getById(sessionId);

    if (session == null) {
      throw Exception('Session non trouvée: $sessionId');
    }

    // Réactiver la session
    await sessionDao.upsertSession(
      SessionsCompanion(
        id: drift.Value(sessionId),
        routineId: drift.Value(session.routineId),
        startedAt: drift.Value(session.startedAt),
        state: const drift.Value('active'),
        endedAt: const drift.Value(null), // Remettre à null
      ),
    );

    // Remettre comme session courante
    _ref.read(persistenceServiceProvider).setCurrentSession(sessionId);
    // IMPORTANT: Mettre à jour le provider global de session courante
    _ref.read(currentSessionIdProvider.notifier).state = sessionId;

    return sessionId;
  }
}

final sessionServiceProvider =
    Provider<SessionService>((ref) => SessionService(ref));
