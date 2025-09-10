import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';

/// Provider pour compter le nombre total de routines
final routineCountProvider = StreamProvider<int>((ref) {
  final routineDao = ref.watch(routineDaoProvider);
  return routineDao.watchAll().map((routines) => routines.length);
});

/// Provider pour les statistiques des routines
final routineStatsProvider = StreamProvider<RoutineStats>((ref) async* {
  try {
    final routineDao = ref.watch(routineDaoProvider);
    final sessionDao = ref.watch(sessionDaoProvider);
    
    await for (final routines in routineDao.watchAll()) {
      final totalRoutines = routines.length;
      final activeRoutines = routines.where((r) => r.isActive).length;
      
      // Compter les sessions complétées aujourd'hui
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      int completedToday = 0;
      int totalSessions = 0;
      
      try {
        // Optimisation: récupérer toutes les sessions en une seule requête
        final allSessions = await sessionDao.getAllSessions();
        totalSessions = allSessions.length;
        
        // Filtrer les sessions complétées aujourd'hui
        final routineIds = routines.map((r) => r.id).toSet();
        completedToday = allSessions.where((s) => 
          routineIds.contains(s.routineId) &&
          s.state == 'completed' && 
          s.endedAt != null &&
          s.endedAt!.isAfter(startOfDay) && 
          s.endedAt!.isBefore(endOfDay)
        ).length;
      } catch (e) {
        print('⚠️ Error calculating session stats: $e');
        // Continuer avec les stats de routine même si les sessions échouent
      }
      
      yield RoutineStats(
        totalRoutines: totalRoutines,
        activeRoutines: activeRoutines,
        completedToday: completedToday,
        totalSessions: totalSessions,
      );
    }
  } catch (e) {
    print('❌ Error in routineStatsProvider: $e');
    // Retourner des stats par défaut en cas d'erreur
    yield const RoutineStats(
      totalRoutines: 0,
      activeRoutines: 0,
      completedToday: 0,
      totalSessions: 0,
    );
  }
});

/// Provider pour les routines récentes (3 dernières créées)
final recentRoutinesProvider = StreamProvider<List<RoutineRow>>((ref) async* {
  try {
    final routineDao = ref.watch(routineDaoProvider);
    await for (final routines in routineDao.watchAll()) {
      // Trier par ordre décroissant et prendre les 3 premières
      final sortedRoutines = List<RoutineRow>.from(routines)
        ..sort((a, b) => b.orderIndex.compareTo(a.orderIndex));
      yield sortedRoutines.take(3).toList();
    }
  } catch (e) {
    print('❌ Error in recentRoutinesProvider: $e');
    // Retourner une liste vide en cas d'erreur au lieu de propager l'erreur
    yield <RoutineRow>[];
  }
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