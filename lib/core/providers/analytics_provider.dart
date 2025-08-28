import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';

/// Provider pour le service d'analytics
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final service = AnalyticsService.instance;

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider pour les métriques quotidiennes
final dailyMetricsProvider =
    FutureProvider.family<DailyMetrics, DateTime?>((ref, date) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getDailyMetrics(date);
});

/// Provider pour les métriques d'aujourd'hui
final todayMetricsProvider = FutureProvider<DailyMetrics>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getDailyMetrics();
});

/// Provider pour les métriques hebdomadaires
final weeklyMetricsProvider = FutureProvider<WeeklyMetrics>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getWeeklyMetrics();
});

/// Provider pour les métriques mensuelles
final monthlyMetricsProvider = FutureProvider<MonthlyMetrics>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getMonthlyMetrics();
});

/// Provider pour les statistiques globales
final allTimeStatsProvider = FutureProvider<AllTimeStats>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getAllTimeStats();
});

/// Provider pour les données de streak
final streakDataProvider = FutureProvider<StreakData>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getStreakData();
});

/// Provider pour les milestones
final milestonesProvider = FutureProvider<List<Milestone>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getMilestones();
});

/// Provider pour le graphique des répétitions (7 derniers jours)
final repetitionsChartProvider = FutureProvider<List<ChartData>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 6));

  return await service.getRepetitionsChart(
    startDate: startDate,
    endDate: endDate,
  );
});

/// Provider pour le graphique des sessions (7 derniers jours)
final sessionsChartProvider = FutureProvider<List<ChartData>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 6));

  return await service.getSessionsChart(
    startDate: startDate,
    endDate: endDate,
  );
});

/// Provider pour le graphique mensuel
final monthlyChartProvider = FutureProvider<List<ChartData>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  final endDate = DateTime(now.year, now.month + 1, 0);

  return await service.getRepetitionsChart(
    startDate: startDate,
    endDate: endDate,
  );
});

/// Provider pour la distribution des prières
final prayerDistributionProvider =
    FutureProvider<Map<String, double>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getPrayerDistribution();
});

/// Actions pour l'analytics
class AnalyticsActions {
  final Ref _ref;

  AnalyticsActions(this._ref);

  /// Tracker le début d'une session
  Future<void> trackSessionStart({
    required String sessionId,
    required String type,
    required String routineName,
    Map<String, dynamic>? metadata,
  }) async {
    final service = _ref.read(analyticsServiceProvider);
    await service.trackSessionStart(
      sessionId: sessionId,
      type: type,
      routineName: routineName,
      metadata: metadata,
    );
  }

  /// Tracker la fin d'une session
  Future<void> trackSessionComplete({
    required String sessionId,
    required Duration duration,
    required int repetitions,
    bool completed = true,
  }) async {
    final service = _ref.read(analyticsServiceProvider);
    await service.trackSessionComplete(
      sessionId: sessionId,
      duration: duration,
      repetitions: repetitions,
      completed: completed,
    );

    // Invalider les providers affectés
    _ref.invalidate(todayMetricsProvider);
    _ref.invalidate(weeklyMetricsProvider);
    _ref.invalidate(monthlyMetricsProvider);
    _ref.invalidate(streakDataProvider);
  }

  /// Tracker une répétition
  Future<void> trackRepetition({
    required String sessionId,
    required int count,
    String? prayerName,
  }) async {
    final service = _ref.read(analyticsServiceProvider);
    await service.trackRepetition(
      sessionId: sessionId,
      count: count,
      prayerName: prayerName,
    );
  }

  /// Tracker un milestone
  Future<void> trackMilestone({
    required String type,
    required int value,
    String? description,
  }) async {
    final service = _ref.read(analyticsServiceProvider);
    await service.trackMilestone(
      type: type,
      value: value,
      description: description,
    );

    // Invalider les milestones
    _ref.invalidate(milestonesProvider);
  }
}

/// Provider pour les actions d'analytics
final analyticsActionsProvider = Provider<AnalyticsActions>((ref) {
  return AnalyticsActions(ref);
});

/// Extension pour faciliter l'usage dans les widgets
extension AnalyticsWidgetRef on WidgetRef {
  /// Tracker le début d'une session
  Future<void> trackSessionStart({
    required String sessionId,
    required String type,
    required String routineName,
    Map<String, dynamic>? metadata,
  }) async {
    await read(analyticsActionsProvider).trackSessionStart(
      sessionId: sessionId,
      type: type,
      routineName: routineName,
      metadata: metadata,
    );
  }

  /// Tracker la fin d'une session
  Future<void> trackSessionComplete({
    required String sessionId,
    required Duration duration,
    required int repetitions,
    bool completed = true,
  }) async {
    await read(analyticsActionsProvider).trackSessionComplete(
      sessionId: sessionId,
      duration: duration,
      repetitions: repetitions,
      completed: completed,
    );
  }

  /// Tracker une répétition
  Future<void> trackRepetition({
    required String sessionId,
    required int count,
    String? prayerName,
  }) async {
    await read(analyticsActionsProvider).trackRepetition(
      sessionId: sessionId,
      count: count,
      prayerName: prayerName,
    );
  }

  /// Tracker un milestone
  Future<void> trackMilestone({
    required String type,
    required int value,
    String? description,
  }) async {
    await read(analyticsActionsProvider).trackMilestone(
      type: type,
      value: value,
      description: description,
    );
  }
}
