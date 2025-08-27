import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/analytics_service.dart';
import '../../core/providers/analytics_provider.dart';
import '../../core/widgets/haptic_wrapper.dart';
import 'widgets/metrics_card.dart';
import 'widgets/streak_card.dart';
import 'widgets/chart_card.dart';
import 'widgets/milestones_card.dart';

/// Dashboard principal des analytics
class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});
  
  @override
  ConsumerState<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends ConsumerState<AnalyticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Vue d\'ensemble'),
            Tab(text: 'Progression'),
            Tab(text: 'Accomplissements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(),
          _ProgressionTab(),
          _AchievementsTab(),
        ],
      ),
    );
  }
}

/// Onglet Vue d'ensemble
class _OverviewTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final todayMetrics = ref.watch(todayMetricsProvider);
    final weeklyMetrics = ref.watch(weeklyMetricsProvider);
    final streakData = ref.watch(streakDataProvider);
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(todayMetricsProvider);
        ref.invalidate(weeklyMetricsProvider);
        ref.invalidate(streakDataProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Streak card
          streakData.when(
            data: (streak) => StreakCard(streak: streak),
            loading: () => const _LoadingCard(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 16),
          
          // Métriques du jour
          Text(
            'Aujourd\'hui',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          todayMetrics.when(
            data: (metrics) => Row(
              children: [
                Expanded(
                  child: MetricsCard(
                    title: 'Sessions',
                    value: metrics.sessionsCompleted.toString(),
                    subtitle: 'Terminées',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricsCard(
                    title: 'Répétitions',
                    value: metrics.totalRepetitions.toString(),
                    subtitle: 'Total',
                    icon: Icons.refresh,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            loading: () => const Row(
              children: [
                Expanded(child: _LoadingCard()),
                SizedBox(width: 12),
                Expanded(child: _LoadingCard()),
              ],
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 8),
          
          todayMetrics.when(
            data: (metrics) => Row(
              children: [
                Expanded(
                  child: MetricsCard(
                    title: 'Durée',
                    value: _formatDuration(metrics.totalDuration),
                    subtitle: 'Totale',
                    icon: Icons.timer,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricsCard(
                    title: 'Taux',
                    value: '${(metrics.completionRate * 100).round()}%',
                    subtitle: 'Complétion',
                    icon: Icons.trending_up,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            loading: () => const Row(
              children: [
                Expanded(child: _LoadingCard()),
                SizedBox(width: 12),
                Expanded(child: _LoadingCard()),
              ],
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 24),
          
          // Métriques hebdomadaires
          Text(
            'Cette semaine',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          weeklyMetrics.when(
            data: (metrics) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MetricsCard(
                        title: 'Sessions',
                        value: metrics.totalSessions.toString(),
                        subtitle: '${metrics.averageSessionsPerDay.toStringAsFixed(1)}/jour',
                        icon: Icons.calendar_today,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricsCard(
                        title: 'Jours actifs',
                        value: '${metrics.activeDays}/7',
                        subtitle: 'Cette semaine',
                        icon: Icons.event_available,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                MetricsCard(
                  title: 'Total de répétitions',
                  value: metrics.totalRepetitions.toString(),
                  subtitle: 'Moyenne: ${metrics.averageRepetitionsPerDay.round()}/jour',
                  icon: Icons.assessment,
                  color: Colors.deepPurple,
                  isWide: true,
                ),
              ],
            ),
            loading: () => const Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _LoadingCard()),
                    SizedBox(width: 12),
                    Expanded(child: _LoadingCard()),
                  ],
                ),
                SizedBox(height: 8),
                _LoadingCard(),
              ],
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
  
  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      return '${(seconds / 60).round()}min';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '${hours}h ${minutes}min';
    }
  }
}

/// Onglet Progression
class _ProgressionTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repetitionsChart = ref.watch(repetitionsChartProvider);
    final sessionsChart = ref.watch(sessionsChartProvider);
    final monthlyChart = ref.watch(monthlyChartProvider);
    final prayerDistribution = ref.watch(prayerDistributionProvider);
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(repetitionsChartProvider);
        ref.invalidate(sessionsChartProvider);
        ref.invalidate(monthlyChartProvider);
        ref.invalidate(prayerDistributionProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Graphique des répétitions (7 jours)
          repetitionsChart.when(
            data: (data) => ChartCard(
              title: 'Répétitions (7 derniers jours)',
              chartData: data,
              type: ChartType.line,
              color: Colors.blue,
            ),
            loading: () => const _LoadingCard(height: 200),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 16),
          
          // Graphique des sessions (7 jours)
          sessionsChart.when(
            data: (data) => ChartCard(
              title: 'Sessions complétées',
              chartData: data,
              type: ChartType.bar,
              color: Colors.green,
            ),
            loading: () => const _LoadingCard(height: 200),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 16),
          
          // Graphique mensuel
          monthlyChart.when(
            data: (data) => ChartCard(
              title: 'Progression mensuelle',
              chartData: data,
              type: ChartType.line,
              color: Colors.purple,
              showTrend: true,
            ),
            loading: () => const _LoadingCard(height: 200),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 16),
          
          // Distribution des prières
          prayerDistribution.when(
            data: (data) => _PrayerDistributionCard(distribution: data),
            loading: () => const _LoadingCard(height: 200),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Onglet Accomplissements
class _AchievementsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final milestones = ref.watch(milestonesProvider);
    final allTimeStats = ref.watch(allTimeStatsProvider);
    final monthlyMetrics = ref.watch(monthlyMetricsProvider);
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(milestonesProvider);
        ref.invalidate(allTimeStatsProvider);
        ref.invalidate(monthlyMetricsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Statistiques globales
          allTimeStats.when(
            data: (stats) => _AllTimeStatsCard(stats: stats),
            loading: () => const _LoadingCard(height: 150),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 16),
          
          // Meilleur mois
          monthlyMetrics.when(
            data: (metrics) => _BestMonthCard(metrics: metrics),
            loading: () => const _LoadingCard(height: 120),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 16),
          
          // Milestones
          Text(
            'Milestones récents',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          milestones.when(
            data: (list) => MilestonesCard(milestones: list),
            loading: () => const _LoadingCard(height: 200),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Card de distribution des prières
class _PrayerDistributionCard extends StatelessWidget {
  final Map<String, double> distribution;
  
  const _PrayerDistributionCard({required this.distribution});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = distribution.values.fold(0.0, (sum, value) => sum + value);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribution des prières',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ...distribution.entries.map((entry) {
              final percentage = total > 0 ? entry.value / total : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          minHeight: 20,
                          backgroundColor: theme.dividerColor.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getColorForPrayer(entry.key),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(percentage * 100).round()}%',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Color _getColorForPrayer(String prayer) {
    final colors = {
      'Fajr': Colors.indigo,
      'Dhuhr': Colors.orange,
      'Asr': Colors.amber,
      'Maghrib': Colors.deepOrange,
      'Isha': Colors.purple,
    };
    return colors[prayer] ?? Colors.blue;
  }
}

/// Card des statistiques globales
class _AllTimeStatsCard extends StatelessWidget {
  final AllTimeStats stats;
  
  const _AllTimeStatsCard({required this.stats});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysSinceStart = DateTime.now().difference(stats.firstSessionDate).inDays;
    
    return Card(
      color: theme.primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Statistiques globales',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _StatRow(
              label: 'Total des répétitions',
              value: _formatNumber(stats.totalRepetitions),
            ),
            _StatRow(
              label: 'Sessions complétées',
              value: stats.totalSessions.toString(),
            ),
            _StatRow(
              label: 'Temps total de pratique',
              value: _formatDuration(stats.totalDuration),
            ),
            _StatRow(
              label: 'Pratique depuis',
              value: '$daysSinceStart jours',
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
  }
  
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    if (hours < 24) {
      return '${hours}h';
    } else {
      final days = hours ~/ 24;
      return '${days}j ${hours % 24}h';
    }
  }
}

/// Card du meilleur mois
class _BestMonthCard extends StatelessWidget {
  final MonthlyMetrics metrics;
  
  const _BestMonthCard({required this.metrics});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ce mois-ci',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (metrics.progressionPercent != 0)
                  Chip(
                    label: Text(
                      '${metrics.progressionPercent > 0 ? '+' : ''}${metrics.progressionPercent}%',
                      style: TextStyle(
                        color: metrics.progressionPercent > 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    backgroundColor: (metrics.progressionPercent > 0
                            ? Colors.green
                            : Colors.red)
                        .withOpacity(0.1),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MetricColumn(
                  label: 'Répétitions',
                  value: metrics.totalRepetitions.toString(),
                ),
                _MetricColumn(
                  label: 'Sessions',
                  value: metrics.totalSessions.toString(),
                ),
                _MetricColumn(
                  label: 'Jours actifs',
                  value: '${metrics.activeDays}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Colonne de métrique
class _MetricColumn extends StatelessWidget {
  final String label;
  final String value;
  
  const _MetricColumn({
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

/// Ligne de statistique
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _StatRow({
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de chargement
class _LoadingCard extends StatelessWidget {
  final double height;
  
  const _LoadingCard({this.height = 100});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: height,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}