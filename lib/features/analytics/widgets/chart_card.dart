import 'package:flutter/material.dart';
import '../../../core/services/analytics_service.dart';

/// Types de graphiques
enum ChartType {
  line,
  bar,
  pie,
}

/// Card pour afficher un graphique
class ChartCard extends StatelessWidget {
  final String title;
  final List<ChartData> chartData;
  final ChartType type;
  final Color color;
  final bool showTrend;

  const ChartCard({
    super.key,
    required this.title,
    required this.chartData,
    required this.type,
    required this.color,
    this.showTrend = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculer les tendances si demandé
    double? trendPercentage;
    if (showTrend && chartData.length >= 2) {
      final firstValue = chartData.first.value;
      final lastValue = chartData.last.value;
      if (firstValue > 0) {
        trendPercentage = ((lastValue - firstValue) / firstValue) * 100;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (trendPercentage != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (trendPercentage > 0 ? Colors.green : Colors.red)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          trendPercentage > 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 16,
                          color:
                              trendPercentage > 0 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${trendPercentage > 0 ? '+' : ''}${trendPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color:
                                trendPercentage > 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Graphique
            Container(
              height: 150,
              child: _buildChart(),
            ),

            // Légende ou statistiques
            if (chartData.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildStats(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (type) {
      case ChartType.line:
        return _LineChart(data: chartData, color: color);
      case ChartType.bar:
        return _BarChart(data: chartData, color: color);
      case ChartType.pie:
        return _PieChart(data: chartData, color: color);
    }
  }

  Widget _buildStats() {
    if (chartData.isEmpty) return const SizedBox.shrink();

    final values = chartData.map((d) => d.value).toList();
    final total = values.fold(0.0, (sum, value) => sum + value);
    final average = total / values.length;
    final max = values.reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(label: 'Total', value: total.round().toString()),
        _StatItem(label: 'Moyenne', value: average.round().toString()),
        _StatItem(label: 'Maximum', value: max.round().toString()),
      ],
    );
  }
}

/// Item de statistique
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
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

/// Graphique en ligne
class _LineChart extends StatelessWidget {
  final List<ChartData> data;
  final Color color;

  const _LineChart({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((d) => d.value).reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    return CustomPaint(
      painter: _LineChartPainter(
        data: data,
        color: color,
        maxValue: maxValue,
        minValue: minValue,
      ),
      child: Container(),
    );
  }
}

/// Painter pour le graphique en ligne
class _LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Color color;
  final double maxValue;
  final double minValue;

  _LineChartPainter({
    required this.data,
    required this.color,
    required this.maxValue,
    required this.minValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final range = maxValue > minValue ? maxValue - minValue : 1;
    final xStep = size.width / (data.length - 1).clamp(1, double.infinity);

    // Créer le chemin
    for (int i = 0; i < data.length; i++) {
      final x = i * xStep;
      final normalizedValue = (data[i].value - minValue) / range;
      final y = size.height -
          (normalizedValue * size.height * 0.8) -
          size.height * 0.1;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Dessiner le point
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }

    // Fermer le chemin de remplissage
    if (data.isNotEmpty) {
      fillPath.lineTo((data.length - 1) * xStep, size.height);
      fillPath.close();
    }

    // Dessiner
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Graphique en barres
class _BarChart extends StatelessWidget {
  final List<ChartData> data;
  final Color color;

  const _BarChart({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((item) {
        final percentage = maxValue > 0 ? item.value / maxValue : 0.0;
        final dayLabel = _getDayLabel(item.date);

        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                item.value.round().toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 100 * percentage,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dayLabel,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getDayLabel(DateTime date) {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[date.weekday - 1];
  }
}

/// Graphique en secteurs (pie chart)
class _PieChart extends StatelessWidget {
  final List<ChartData> data;
  final Color color;

  const _PieChart({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    // Simplification : afficher comme une liste pour l'instant
    return Center(
      child: Text(
        'Graphique en secteurs',
        style: TextStyle(color: color),
      ),
    );
  }
}
