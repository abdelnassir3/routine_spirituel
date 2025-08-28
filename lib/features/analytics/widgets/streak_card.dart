import 'package:flutter/material.dart';
import '../../../core/services/analytics_service.dart';

/// Card pour afficher le streak
class StreakCard extends StatelessWidget {
  final StreakData streak;

  const StreakCard({
    super.key,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasStreak = streak.currentStreak > 0;

    return Card(
      elevation: 4,
      color: hasStreak ? Colors.orange.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icône de flamme
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: hasStreak
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasStreak
                    ? Icons.local_fire_department
                    : Icons.local_fire_department_outlined,
                size: 32,
                color: hasStreak ? Colors.orange : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),

            // Informations du streak
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasStreak ? 'Série en cours' : 'Aucune série',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${streak.currentStreak}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: hasStreak ? Colors.orange : Colors.grey,
                        ),
                      ),
                      Text(
                        ' jour${streak.currentStreak != 1 ? 's' : ''}',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Record',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            '${streak.longestStreak} jours',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (hasStreak) ...[
                    const SizedBox(height: 8),
                    // Barre de progression vers le prochain milestone
                    _StreakProgressBar(currentStreak: streak.currentStreak),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barre de progression du streak
class _StreakProgressBar extends StatelessWidget {
  final int currentStreak;

  const _StreakProgressBar({required this.currentStreak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Milestones de streak
    final milestones = [3, 7, 14, 30, 60, 90, 180, 365];

    // Trouver le prochain milestone
    int? nextMilestone;
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        nextMilestone = milestone;
        break;
      }
    }

    if (nextMilestone == null) {
      // Streak déjà très élevé
      return Row(
        children: [
          Icon(
            Icons.emoji_events,
            size: 16,
            color: Colors.amber,
          ),
          const SizedBox(width: 4),
          Text(
            'Légendaire !',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    final progress = currentStreak / nextMilestone;
    final remaining = nextMilestone - currentStreak;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Prochain objectif',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            Text(
              '$remaining jour${remaining != 1 ? 's' : ''} restant${remaining != 1 ? 's' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.orange.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Objectif : $nextMilestone jours',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
