import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';

/// États de completion pour une routine
enum RoutineCompletionStatus {
  completed, // ✅ Accomplie selon la fréquence
  pending, // 🔄 En cours ou pas encore faite aujourd'hui/cette période
  overdue, // ⚠️ En retard selon la fréquence
}

/// Provider pour obtenir le statut de completion d'une routine
/// Utilise autoDispose pour éviter les fuites mémoire et keepAlive pour le cache
final routineCompletionStatusProvider =
    FutureProvider.family.autoDispose<RoutineCompletionStatus, String>(
        (ref, routineId) async {
  // Cache pendant 30 secondes pour éviter les requêtes répétitives
  ref.keepAlive();
  
  // Timer pour invalider le cache après 30 secondes
  final timer = Timer(const Duration(seconds: 30), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());

  final sessionDao = ref.read(sessionDaoProvider);
  final themeDaoRef = ref.read(themeDaoProvider);
  final routineDaoRef = ref.read(routineDaoProvider);

  print('🔍 Calcul du statut pour routine: $routineId');

  try {
    // Récupérer la routine spécifique
    final routineQuery = routineDaoRef.select(routineDaoRef.routines)
      ..where((r) => r.id.equals(routineId));
    final routine = await routineQuery.getSingleOrNull();

    if (routine == null) {
      print('❌ Routine non trouvée: $routineId');
      return RoutineCompletionStatus.pending;
    }

    // Récupérer le thème associé
    final themeQuery = themeDaoRef.select(themeDaoRef.themes)
      ..where((t) => t.id.equals(routine.themeId));
    final theme = await themeQuery.getSingleOrNull();

    if (theme == null) {
      print('❌ Thème non trouvé pour routine: $routineId');
      return RoutineCompletionStatus.pending;
    }

    // ✅ FIX: Vérification supplémentaire de la fréquence du thème
    if (theme.frequency.isEmpty) {
      print('❌ Fréquence du thème vide pour routine: $routineId');
      return RoutineCompletionStatus.pending;
    }

    // Récupérer les sessions complétées
    final completedSessions =
        await sessionDao.getCompletedSessionsForRoutine(routineId);
    print('📊 Sessions complétées trouvées: ${completedSessions.length}');

    if (completedSessions.isNotEmpty) {
      print('✅ Dernière session complétée: ${completedSessions.first.endedAt}');
      for (final session in completedSessions) {
        print(
            '   📋 Session ${session.id}: état=${session.state}, fin=${session.endedAt}');
      }
    }

    // Calculer le statut selon la fréquence
    final status = _calculateCompletionStatus(
      theme.frequency,
      completedSessions,
    );

    print('🎯 Statut calculé pour routine $routineId: ${status.description}');
    return status;
  } catch (e) {
    print('❌ Erreur lors du calcul du statut pour routine $routineId: $e');
    // En cas d'erreur, retourner statut pending
    return RoutineCompletionStatus.pending;
  }
});

/// Calcule le statut de completion basé sur la fréquence et les sessions
RoutineCompletionStatus _calculateCompletionStatus(
  String frequency,
  List<SessionRow> completedSessions,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  switch (frequency.toLowerCase()) {
    case 'daily':
      // Vérifier s'il y a une session complétée aujourd'hui
      final todaySessions = completedSessions.where((session) {
        // Protection supplémentaire contre les valeurs null
        if (session.endedAt == null) return false;
        final sessionDate = DateTime(
          session.endedAt!.year,
          session.endedAt!.month,
          session.endedAt!.day,
        );
        return sessionDate == today;
      }).toList();

      if (todaySessions.isNotEmpty) {
        return RoutineCompletionStatus.completed;
      }

      // Vérifier si on est en retard (après 20h du jour)
      if (now.hour >= 20) {
        return RoutineCompletionStatus.overdue;
      }

      return RoutineCompletionStatus.pending;

    case 'weekly':
      // Trouver le début de la semaine (lundi)
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final weekSessions = completedSessions.where((session) {
        // Protection supplémentaire contre les valeurs null
        if (session.endedAt == null) return false;
        final sessionDate = DateTime(
          session.endedAt!.year,
          session.endedAt!.month,
          session.endedAt!.day,
        );
        return sessionDate
                .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            sessionDate.isBefore(endOfWeek.add(const Duration(days: 1)));
      }).toList();

      if (weekSessions.isNotEmpty) {
        return RoutineCompletionStatus.completed;
      }

      // En retard si on est dimanche après 18h
      if (today.weekday == 7 && now.hour >= 18) {
        return RoutineCompletionStatus.overdue;
      }

      return RoutineCompletionStatus.pending;

    case 'monthly':
      // Premier jour du mois
      final startOfMonth = DateTime(today.year, today.month, 1);
      final endOfMonth = DateTime(today.year, today.month + 1, 0);

      final monthSessions = completedSessions.where((session) {
        // Protection supplémentaire contre les valeurs null
        if (session.endedAt == null) return false;
        final sessionDate = DateTime(
          session.endedAt!.year,
          session.endedAt!.month,
          session.endedAt!.day,
        );
        return sessionDate
                .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            sessionDate.isBefore(endOfMonth.add(const Duration(days: 1)));
      }).toList();

      if (monthSessions.isNotEmpty) {
        return RoutineCompletionStatus.completed;
      }

      // En retard si on est après le 25 du mois
      if (today.day >= 25) {
        return RoutineCompletionStatus.overdue;
      }

      return RoutineCompletionStatus.pending;

    default:
      return RoutineCompletionStatus.pending;
  }
}

/// Extension pour obtenir les couleurs et icônes selon le statut
extension RoutineCompletionStatusExtension on RoutineCompletionStatus {
  /// Icône à afficher pour ce statut
  String get iconName {
    switch (this) {
      case RoutineCompletionStatus.completed:
        return 'check_circle';
      case RoutineCompletionStatus.pending:
        return 'schedule';
      case RoutineCompletionStatus.overdue:
        return 'warning';
    }
  }

  /// Couleur associée au statut
  String get colorName {
    switch (this) {
      case RoutineCompletionStatus.completed:
        return 'success';
      case RoutineCompletionStatus.pending:
        return 'primary';
      case RoutineCompletionStatus.overdue:
        return 'warning';
    }
  }

  /// Message descriptif
  String get description {
    switch (this) {
      case RoutineCompletionStatus.completed:
        return 'Accomplie';
      case RoutineCompletionStatus.pending:
        return 'En attente';
      case RoutineCompletionStatus.overdue:
        return 'En retard';
    }
  }
}
