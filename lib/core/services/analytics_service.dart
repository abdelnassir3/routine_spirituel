import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Service d'analytics pour le tracking des métriques spirituelles
/// 
/// Collecte et analyse les données d'utilisation pour fournir
/// des insights sur la pratique spirituelle de l'utilisateur
class AnalyticsService {
  static AnalyticsService? _instance;
  
  // Cache des métriques
  final Map<String, dynamic> _metricsCache = {};
  Timer? _aggregationTimer;
  
  // Clés de stockage
  static const String _keyDailyMetrics = 'analytics_daily_metrics';
  static const String _keyWeeklyMetrics = 'analytics_weekly_metrics';
  static const String _keyMonthlyMetrics = 'analytics_monthly_metrics';
  static const String _keyAllTimeMetrics = 'analytics_all_time_metrics';
  static const String _keyStreakData = 'analytics_streak_data';
  static const String _keyMilestones = 'analytics_milestones';
  
  // Configuration
  static const Duration _aggregationInterval = Duration(minutes: 5);
  
  // Singleton
  static AnalyticsService get instance {
    _instance ??= AnalyticsService._();
    return _instance!;
  }
  
  AnalyticsService._() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    try {
      // Charger les métriques en cache
      await _loadMetrics();
      
      // Démarrer l'agrégation périodique
      _startAggregation();
      
      AppLogger.logDebugInfo('AnalyticsService initialized');
    } catch (e) {
      AppLogger.logError('AnalyticsService initialization failed', e);
    }
  }
  
  // ===== Tracking des événements =====
  
  /// Enregistrer le début d'une session de prière
  Future<void> trackSessionStart({
    required String sessionId,
    required String type,
    required String routineName,
    Map<String, dynamic>? metadata,
  }) async {
    final event = AnalyticsEvent(
      type: EventType.sessionStart,
      timestamp: DateTime.now(),
      data: {
        'sessionId': sessionId,
        'sessionType': type,
        'routineName': routineName,
        ...?metadata,
      },
    );
    
    await _recordEvent(event);
    await _updateDailyMetrics('sessionsStarted', 1);
  }
  
  /// Enregistrer la fin d'une session
  Future<void> trackSessionComplete({
    required String sessionId,
    required Duration duration,
    required int repetitions,
    bool completed = true,
  }) async {
    final event = AnalyticsEvent(
      type: EventType.sessionComplete,
      timestamp: DateTime.now(),
      data: {
        'sessionId': sessionId,
        'duration': duration.inSeconds,
        'repetitions': repetitions,
        'completed': completed,
      },
    );
    
    await _recordEvent(event);
    
    // Mettre à jour les métriques
    await _updateDailyMetrics('sessionsCompleted', completed ? 1 : 0);
    await _updateDailyMetrics('totalRepetitions', repetitions);
    await _updateDailyMetrics('totalDuration', duration.inSeconds);
    
    // Vérifier les milestones
    await _checkMilestones(repetitions);
    
    // Mettre à jour le streak
    if (completed) {
      await _updateStreak();
    }
  }
  
  /// Enregistrer une répétition
  Future<void> trackRepetition({
    required String sessionId,
    required int count,
    String? prayerName,
  }) async {
    final event = AnalyticsEvent(
      type: EventType.repetition,
      timestamp: DateTime.now(),
      data: {
        'sessionId': sessionId,
        'count': count,
        'prayerName': prayerName,
      },
    );
    
    await _recordEvent(event);
  }
  
  /// Enregistrer un milestone atteint
  Future<void> trackMilestone({
    required String type,
    required int value,
    String? description,
  }) async {
    final event = AnalyticsEvent(
      type: EventType.milestone,
      timestamp: DateTime.now(),
      data: {
        'milestoneType': type,
        'value': value,
        'description': description,
      },
    );
    
    await _recordEvent(event);
    await _saveMilestone(type, value, description);
  }
  
  // ===== Métriques quotidiennes =====
  
  Future<DailyMetrics> getDailyMetrics([DateTime? date]) async {
    date ??= DateTime.now();
    final key = _getDateKey(date);
    
    final prefs = await SharedPreferences.getInstance();
    final metricsJson = prefs.getString('${_keyDailyMetrics}_$key');
    
    if (metricsJson != null) {
      return DailyMetrics.fromJson(json.decode(metricsJson));
    }
    
    return DailyMetrics(date: date);
  }
  
  Future<void> _updateDailyMetrics(String metric, num value) async {
    final today = DateTime.now();
    final metrics = await getDailyMetrics(today);
    
    // Mettre à jour la métrique
    switch (metric) {
      case 'sessionsStarted':
        metrics.sessionsStarted += value.toInt();
        break;
      case 'sessionsCompleted':
        metrics.sessionsCompleted += value.toInt();
        break;
      case 'totalRepetitions':
        metrics.totalRepetitions += value.toInt();
        break;
      case 'totalDuration':
        metrics.totalDuration += value.toInt();
        break;
    }
    
    // Sauvegarder
    final prefs = await SharedPreferences.getInstance();
    final key = _getDateKey(today);
    await prefs.setString(
      '${_keyDailyMetrics}_$key',
      json.encode(metrics.toJson()),
    );
  }
  
  // ===== Métriques hebdomadaires =====
  
  Future<WeeklyMetrics> getWeeklyMetrics([DateTime? weekStart]) async {
    weekStart ??= _getWeekStart(DateTime.now());
    
    final metrics = WeeklyMetrics(weekStart: weekStart);
    
    // Agréger les métriques quotidiennes
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final daily = await getDailyMetrics(date);
      
      metrics.dailyMetrics.add(daily);
      metrics.totalSessions += daily.sessionsCompleted;
      metrics.totalRepetitions += daily.totalRepetitions;
      metrics.totalDuration += daily.totalDuration;
      
      if (daily.sessionsCompleted > 0) {
        metrics.activeDays++;
      }
    }
    
    // Calculer les moyennes
    metrics.averageSessionsPerDay = metrics.totalSessions / 7;
    metrics.averageRepetitionsPerDay = metrics.totalRepetitions / 7;
    metrics.averageDurationPerDay = metrics.totalDuration / 7;
    
    return metrics;
  }
  
  // ===== Métriques mensuelles =====
  
  Future<MonthlyMetrics> getMonthlyMetrics([DateTime? month]) async {
    month ??= DateTime.now();
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    
    final metrics = MonthlyMetrics(month: monthStart);
    
    // Agréger les métriques quotidiennes
    for (DateTime date = monthStart;
         date.isBefore(monthEnd.add(const Duration(days: 1)));
         date = date.add(const Duration(days: 1))) {
      final daily = await getDailyMetrics(date);
      
      metrics.totalSessions += daily.sessionsCompleted;
      metrics.totalRepetitions += daily.totalRepetitions;
      metrics.totalDuration += daily.totalDuration;
      
      if (daily.sessionsCompleted > 0) {
        metrics.activeDays++;
      }
      
      // Meilleur jour
      if (daily.totalRepetitions > metrics.bestDay.totalRepetitions) {
        metrics.bestDay = daily;
      }
    }
    
    // Calculer la progression
    final previousMonth = DateTime(month.year, month.month - 1, 1);
    final previousMetrics = await getMonthlyMetrics(previousMonth);
    
    if (previousMetrics.totalRepetitions > 0) {
      metrics.progressionPercent = 
          ((metrics.totalRepetitions - previousMetrics.totalRepetitions) / 
           previousMetrics.totalRepetitions * 100).round();
    }
    
    return metrics;
  }
  
  // ===== Statistiques globales =====
  
  Future<AllTimeStats> getAllTimeStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_keyAllTimeMetrics);
    
    if (statsJson != null) {
      return AllTimeStats.fromJson(json.decode(statsJson));
    }
    
    return AllTimeStats();
  }
  
  Future<void> updateAllTimeStats(Function(AllTimeStats) update) async {
    final stats = await getAllTimeStats();
    update(stats);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAllTimeMetrics, json.encode(stats.toJson()));
  }
  
  // ===== Streak tracking =====
  
  Future<StreakData> getStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    final streakJson = prefs.getString(_keyStreakData);
    
    if (streakJson != null) {
      final streak = StreakData.fromJson(json.decode(streakJson));
      
      // Vérifier si le streak est toujours valide
      final today = DateTime.now();
      final daysSinceLastActivity = 
          today.difference(streak.lastActivityDate).inDays;
      
      if (daysSinceLastActivity > 1) {
        // Streak cassé
        streak.currentStreak = 0;
      }
      
      return streak;
    }
    
    return StreakData();
  }
  
  Future<void> _updateStreak() async {
    final streak = await getStreakData();
    final today = DateTime.now();
    final todayKey = _getDateKey(today);
    
    // Si c'est le premier jour ou continuation
    if (streak.lastActivityDate.day != today.day ||
        streak.lastActivityDate.month != today.month ||
        streak.lastActivityDate.year != today.year) {
      
      final daysSinceLastActivity = 
          today.difference(streak.lastActivityDate).inDays;
      
      if (daysSinceLastActivity == 1) {
        // Continuation du streak
        streak.currentStreak++;
      } else if (daysSinceLastActivity > 1) {
        // Streak cassé
        streak.currentStreak = 1;
      }
      
      streak.lastActivityDate = today;
      
      // Mettre à jour le record
      if (streak.currentStreak > streak.longestStreak) {
        streak.longestStreak = streak.currentStreak;
      }
      
      // Sauvegarder
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyStreakData, json.encode(streak.toJson()));
    }
  }
  
  // ===== Milestones =====
  
  Future<List<Milestone>> getMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    final milestonesJson = prefs.getStringList(_keyMilestones) ?? [];
    
    return milestonesJson
        .map((json) => Milestone.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
  }
  
  Future<void> _checkMilestones(int repetitions) async {
    final stats = await getAllTimeStats();
    final totalRepetitions = stats.totalRepetitions + repetitions;
    
    // Définir les milestones
    final milestoneValues = [
      100, 500, 1000, 5000, 10000, 25000, 50000, 100000,
      250000, 500000, 1000000
    ];
    
    for (final value in milestoneValues) {
      if (stats.totalRepetitions < value && totalRepetitions >= value) {
        await trackMilestone(
          type: 'repetitions',
          value: value,
          description: 'Atteint $value répétitions au total',
        );
      }
    }
    
    // Mettre à jour le total
    await updateAllTimeStats((stats) {
      stats.totalRepetitions = totalRepetitions;
    });
  }
  
  Future<void> _saveMilestone(String type, int value, String? description) async {
    final milestone = Milestone(
      type: type,
      value: value,
      description: description ?? '',
      achievedAt: DateTime.now(),
    );
    
    final prefs = await SharedPreferences.getInstance();
    final milestones = prefs.getStringList(_keyMilestones) ?? [];
    milestones.add(json.encode(milestone.toJson()));
    
    // Limiter à 100 milestones
    if (milestones.length > 100) {
      milestones.removeAt(0);
    }
    
    await prefs.setStringList(_keyMilestones, milestones);
  }
  
  // ===== Graphiques et tendances =====
  
  Future<List<ChartData>> getRepetitionsChart({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final data = <ChartData>[];
    
    for (DateTime date = startDate;
         date.isBefore(endDate.add(const Duration(days: 1)));
         date = date.add(const Duration(days: 1))) {
      final metrics = await getDailyMetrics(date);
      data.add(ChartData(
        date: date,
        value: metrics.totalRepetitions.toDouble(),
      ));
    }
    
    return data;
  }
  
  Future<List<ChartData>> getSessionsChart({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final data = <ChartData>[];
    
    for (DateTime date = startDate;
         date.isBefore(endDate.add(const Duration(days: 1)));
         date = date.add(const Duration(days: 1))) {
      final metrics = await getDailyMetrics(date);
      data.add(ChartData(
        date: date,
        value: metrics.sessionsCompleted.toDouble(),
      ));
    }
    
    return data;
  }
  
  Future<Map<String, double>> getPrayerDistribution() async {
    // TODO: Implémenter avec la base de données
    return {
      'Fajr': 20,
      'Dhuhr': 15,
      'Asr': 15,
      'Maghrib': 25,
      'Isha': 25,
    };
  }
  
  // ===== Helpers =====
  
  Future<void> _recordEvent(AnalyticsEvent event) async {
    // TODO: Enregistrer dans la base de données
    AppLogger.logDebugInfo('Analytics event', event.toJson());
  }
  
  Future<void> _loadMetrics() async {
    // Charger les métriques en cache
    final today = await getDailyMetrics();
    _metricsCache['daily'] = today;
    
    final week = await getWeeklyMetrics();
    _metricsCache['weekly'] = week;
    
    final streak = await getStreakData();
    _metricsCache['streak'] = streak;
  }
  
  void _startAggregation() {
    _aggregationTimer = Timer.periodic(_aggregationInterval, (_) {
      _aggregateMetrics();
    });
  }
  
  Future<void> _aggregateMetrics() async {
    // Agréger et optimiser les métriques
    await _loadMetrics();
  }
  
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }
  
  // ===== Nettoyage =====
  
  void dispose() {
    _aggregationTimer?.cancel();
  }
}

// ===== Modèles =====

/// Types d'événements analytiques
enum EventType {
  sessionStart,
  sessionComplete,
  repetition,
  milestone,
  streak,
  error,
}

/// Événement analytique
class AnalyticsEvent {
  final EventType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  
  AnalyticsEvent({
    required this.type,
    required this.timestamp,
    required this.data,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'data': data,
  };
}

/// Métriques quotidiennes
class DailyMetrics {
  final DateTime date;
  int sessionsStarted;
  int sessionsCompleted;
  int totalRepetitions;
  int totalDuration; // en secondes
  
  DailyMetrics({
    required this.date,
    this.sessionsStarted = 0,
    this.sessionsCompleted = 0,
    this.totalRepetitions = 0,
    this.totalDuration = 0,
  });
  
  double get completionRate => sessionsStarted > 0 
      ? sessionsCompleted / sessionsStarted 
      : 0;
  
  double get averageSessionDuration => sessionsCompleted > 0
      ? totalDuration / sessionsCompleted
      : 0;
  
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'sessionsStarted': sessionsStarted,
    'sessionsCompleted': sessionsCompleted,
    'totalRepetitions': totalRepetitions,
    'totalDuration': totalDuration,
  };
  
  factory DailyMetrics.fromJson(Map<String, dynamic> json) => DailyMetrics(
    date: DateTime.parse(json['date']),
    sessionsStarted: json['sessionsStarted'] ?? 0,
    sessionsCompleted: json['sessionsCompleted'] ?? 0,
    totalRepetitions: json['totalRepetitions'] ?? 0,
    totalDuration: json['totalDuration'] ?? 0,
  );
}

/// Métriques hebdomadaires
class WeeklyMetrics {
  final DateTime weekStart;
  final List<DailyMetrics> dailyMetrics = [];
  int totalSessions = 0;
  int totalRepetitions = 0;
  int totalDuration = 0;
  int activeDays = 0;
  double averageSessionsPerDay = 0;
  double averageRepetitionsPerDay = 0;
  double averageDurationPerDay = 0;
  
  WeeklyMetrics({required this.weekStart});
}

/// Métriques mensuelles
class MonthlyMetrics {
  final DateTime month;
  int totalSessions = 0;
  int totalRepetitions = 0;
  int totalDuration = 0;
  int activeDays = 0;
  DailyMetrics bestDay = DailyMetrics(date: DateTime.now());
  int progressionPercent = 0;
  
  MonthlyMetrics({required this.month});
}

/// Statistiques globales
class AllTimeStats {
  int totalSessions = 0;
  int totalRepetitions = 0;
  int totalDuration = 0;
  DateTime firstSessionDate = DateTime.now();
  DateTime lastSessionDate = DateTime.now();
  int totalDays = 0;
  
  AllTimeStats();
  
  Map<String, dynamic> toJson() => {
    'totalSessions': totalSessions,
    'totalRepetitions': totalRepetitions,
    'totalDuration': totalDuration,
    'firstSessionDate': firstSessionDate.toIso8601String(),
    'lastSessionDate': lastSessionDate.toIso8601String(),
    'totalDays': totalDays,
  };
  
  factory AllTimeStats.fromJson(Map<String, dynamic> json) {
    final stats = AllTimeStats();
    stats.totalSessions = json['totalSessions'] ?? 0;
    stats.totalRepetitions = json['totalRepetitions'] ?? 0;
    stats.totalDuration = json['totalDuration'] ?? 0;
    stats.firstSessionDate = DateTime.parse(json['firstSessionDate'] ?? DateTime.now().toIso8601String());
    stats.lastSessionDate = DateTime.parse(json['lastSessionDate'] ?? DateTime.now().toIso8601String());
    stats.totalDays = json['totalDays'] ?? 0;
    return stats;
  }
}

/// Données de streak
class StreakData {
  int currentStreak = 0;
  int longestStreak = 0;
  DateTime lastActivityDate = DateTime.now().subtract(const Duration(days: 2));
  
  StreakData();
  
  Map<String, dynamic> toJson() => {
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastActivityDate': lastActivityDate.toIso8601String(),
  };
  
  factory StreakData.fromJson(Map<String, dynamic> json) {
    final streak = StreakData();
    streak.currentStreak = json['currentStreak'] ?? 0;
    streak.longestStreak = json['longestStreak'] ?? 0;
    streak.lastActivityDate = DateTime.parse(json['lastActivityDate'] ?? DateTime.now().toIso8601String());
    return streak;
  }
}

/// Milestone atteint
class Milestone {
  final String type;
  final int value;
  final String description;
  final DateTime achievedAt;
  
  Milestone({
    required this.type,
    required this.value,
    required this.description,
    required this.achievedAt,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'value': value,
    'description': description,
    'achievedAt': achievedAt.toIso8601String(),
  };
  
  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
    type: json['type'],
    value: json['value'],
    description: json['description'],
    achievedAt: DateTime.parse(json['achievedAt']),
  );
}

/// Données pour les graphiques
class ChartData {
  final DateTime date;
  final double value;
  
  ChartData({required this.date, required this.value});
}