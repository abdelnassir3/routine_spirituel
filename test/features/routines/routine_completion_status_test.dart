import 'package:flutter_test/flutter_test.dart';
import 'package:spiritual_routines/features/routines/routine_completion_status.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';

void main() {
  group('RoutineCompletionStatus', () {
    test('calcule le statut daily completed correctement', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Créer une session complétée aujourd'hui
      final session = SessionRow(
        id: 'test-session',
        routineId: 'test-routine',
        startedAt: today.add(const Duration(hours: 10)),
        endedAt: today.add(const Duration(hours: 10, minutes: 30)),
        state: 'completed',
        snapshotRef: null,
      );
      
      final status = _calculateCompletionStatus('daily', [session]);
      expect(status, equals(RoutineCompletionStatus.completed));
    });
    
    test('calcule le statut daily pending correctement', () {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      
      // Créer une session complétée hier
      final session = SessionRow(
        id: 'test-session',
        routineId: 'test-routine',
        startedAt: yesterday.add(const Duration(hours: 10)),
        endedAt: yesterday.add(const Duration(hours: 10, minutes: 30)),
        state: 'completed',
        snapshotRef: null,
      );
      
      final status = _calculateCompletionStatus('daily', [session]);
      
      // Si on est avant 20h, doit être pending
      if (now.hour < 20) {
        expect(status, equals(RoutineCompletionStatus.pending));
      } else {
        // Si on est après 20h, doit être overdue
        expect(status, equals(RoutineCompletionStatus.overdue));
      }
    });
    
    test('calcule le statut weekly completed correctement', () {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      
      // Session dans la semaine courante
      final session = SessionRow(
        id: 'test-session',
        routineId: 'test-routine',
        startedAt: startOfWeek.add(const Duration(hours: 10)),
        endedAt: startOfWeek.add(const Duration(hours: 10, minutes: 30)),
        state: 'completed',
        snapshotRef: null,
      );
      
      final status = _calculateCompletionStatus('weekly', [session]);
      expect(status, equals(RoutineCompletionStatus.completed));
    });
    
    test('calcule le statut monthly completed correctement', () {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      // Session dans le mois courant
      final session = SessionRow(
        id: 'test-session',
        routineId: 'test-routine',
        startedAt: startOfMonth.add(const Duration(days: 5, hours: 10)),
        endedAt: startOfMonth.add(const Duration(days: 5, hours: 10, minutes: 30)),
        state: 'completed',
        snapshotRef: null,
      );
      
      final status = _calculateCompletionStatus('monthly', [session]);
      expect(status, equals(RoutineCompletionStatus.completed));
    });
    
    test('gère la fréquence inconnue correctement', () {
      final status = _calculateCompletionStatus('unknown', []);
      expect(status, equals(RoutineCompletionStatus.pending));
    });
  });
  
  group('RoutineCompletionStatusExtension', () {
    test('retourne les bonnes icônes', () {
      expect(RoutineCompletionStatus.completed.iconName, equals('check_circle'));
      expect(RoutineCompletionStatus.pending.iconName, equals('schedule'));
      expect(RoutineCompletionStatus.overdue.iconName, equals('warning'));
    });
    
    test('retourne les bonnes couleurs', () {
      expect(RoutineCompletionStatus.completed.colorName, equals('success'));
      expect(RoutineCompletionStatus.pending.colorName, equals('primary'));
      expect(RoutineCompletionStatus.overdue.colorName, equals('warning'));
    });
    
    test('retourne les bonnes descriptions', () {
      expect(RoutineCompletionStatus.completed.description, equals('Accomplie'));
      expect(RoutineCompletionStatus.pending.description, equals('En attente'));
      expect(RoutineCompletionStatus.overdue.description, equals('En retard'));
    });
  });
}

// Copie de la fonction privée pour les tests
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
        if (session.endedAt == null) return false;
        final sessionDate = DateTime(
          session.endedAt!.year,
          session.endedAt!.month,
          session.endedAt!.day,
        );
        return sessionDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
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
        if (session.endedAt == null) return false;
        final sessionDate = DateTime(
          session.endedAt!.year,
          session.endedAt!.month,
          session.endedAt!.day,
        );
        return sessionDate.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
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