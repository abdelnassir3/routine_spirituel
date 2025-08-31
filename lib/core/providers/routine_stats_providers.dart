import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';

/// Provider pour compter le nombre total de routines
final routineCountProvider = StreamProvider<int>((ref) {
  final routineDao = ref.watch(routineDaoProvider);
  return routineDao.watchAll().map((routines) => routines.length);
});

/// Provider pour les statistiques des routines
final routineStatsProvider = StreamProvider<RoutineStats>((ref) {
  final routineDao = ref.watch(routineDaoProvider);
  final sessionDao = ref.watch(sessionDaoProvider);
  
  return routineDao.watchAll().asyncMap((routines) async {
    final totalRoutines = routines.length;
    final activeRoutines = routines.where((r) => r.isActive).length;
    
    // Compter les sessions complétées aujourd'hui
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    int completedToday = 0;
    int totalSessions = 0;
    
    for (final routine in routines) {
      final sessions = await sessionDao.getAllByRoutine(routine.id);
      totalSessions += sessions.length;
      
      // Compter les sessions complétées aujourd'hui
      final todaySessions = sessions.where((s) => 
        s.state == 'completed' && 
        s.endedAt != null &&
        s.endedAt!.isAfter(startOfDay) && 
        s.endedAt!.isBefore(endOfDay)
      ).length;
      
      completedToday += todaySessions;
    }
    
    return RoutineStats(
      totalRoutines: totalRoutines,
      activeRoutines: activeRoutines,
      completedToday: completedToday,
      totalSessions: totalSessions,
    );
  });
});

/// Provider pour les routines récentes (3 dernières créées)
final recentRoutinesProvider = StreamProvider<List<RoutineRow>>((ref) {
  final routineDao = ref.watch(routineDaoProvider);
  return routineDao.watchAll().map((routines) {
    // Trier par ordre décroissant et prendre les 3 premières
    final sortedRoutines = List<RoutineRow>.from(routines)
      ..sort((a, b) => b.orderIndex.compareTo(a.orderIndex));
    return sortedRoutines.take(3).toList();
  });
});

/// Classe pour les statistiques des routines
class RoutineStats {
  final int totalRoutines;
  final int activeRoutines;
  final int completedToday;
  final int totalSessions;
  
  const RoutineStats({
    required this.totalRoutines,
    required this.activeRoutines,
    required this.completedToday,
    required this.totalSessions,
  });
  
  /// Pourcentage de completion aujourd'hui (0.0 à 1.0)
  double get completionPercentage {
    if (activeRoutines == 0) return 0.0;
    return (completedToday / activeRoutines).clamp(0.0, 1.0);
  }
  
  /// Série actuelle (approximation basée sur les sessions récentes)
  int get currentStreak {
    // TODO: Implémenter calcul série basé sur sessions quotidiennes
    // Pour l'instant retourner une valeur par défaut
    return totalSessions > 0 ? (totalSessions / 7).ceil() : 0;
  }
}