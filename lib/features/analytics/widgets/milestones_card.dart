import 'package:flutter/material.dart';
import '../../../core/services/analytics_service.dart';

/// Card pour afficher les milestones
class MilestonesCard extends StatelessWidget {
  final List<Milestone> milestones;
  
  const MilestonesCard({
    super.key,
    required this.milestones,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (milestones.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun milestone atteint',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Continuez votre pratique pour débloquer des milestones',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Limiter à 5 milestones récents
    final recentMilestones = milestones.take(5).toList();
    
    return Column(
      children: recentMilestones.map((milestone) {
        return _MilestoneItem(milestone: milestone);
      }).toList(),
    );
  }
}

/// Item de milestone
class _MilestoneItem extends StatelessWidget {
  final Milestone milestone;
  
  const _MilestoneItem({required this.milestone});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getColorForMilestone(milestone).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconForMilestone(milestone),
            color: _getColorForMilestone(milestone),
            size: 24,
          ),
        ),
        title: Text(
          _getFormattedValue(milestone),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              milestone.description,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(milestone.achievedAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
            ),
          ],
        ),
        trailing: _getMilestoneBadge(milestone),
      ),
    );
  }
  
  IconData _getIconForMilestone(Milestone milestone) {
    switch (milestone.type) {
      case 'repetitions':
        return Icons.refresh;
      case 'sessions':
        return Icons.check_circle;
      case 'streak':
        return Icons.local_fire_department;
      case 'duration':
        return Icons.timer;
      default:
        return Icons.emoji_events;
    }
  }
  
  Color _getColorForMilestone(Milestone milestone) {
    if (milestone.value >= 1000000) {
      return Colors.purple;
    } else if (milestone.value >= 100000) {
      return Colors.amber;
    } else if (milestone.value >= 10000) {
      return Colors.orange;
    } else if (milestone.value >= 1000) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }
  
  String _getFormattedValue(Milestone milestone) {
    if (milestone.value < 1000) {
      return '${milestone.value} ${milestone.type}';
    } else if (milestone.value < 1000000) {
      return '${(milestone.value / 1000).toStringAsFixed(milestone.value % 1000 == 0 ? 0 : 1)}K ${milestone.type}';
    } else {
      return '${(milestone.value / 1000000).toStringAsFixed(milestone.value % 1000000 == 0 ? 0 : 1)}M ${milestone.type}';
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'À l\'instant';
        }
        return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
      }
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).round();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).round();
      return 'Il y a $months mois';
    } else {
      final years = (difference.inDays / 365).round();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    }
  }
  
  Widget? _getMilestoneBadge(Milestone milestone) {
    String? badgeText;
    Color? badgeColor;
    
    if (milestone.value >= 1000000) {
      badgeText = 'LÉGENDAIRE';
      badgeColor = Colors.purple;
    } else if (milestone.value >= 100000) {
      badgeText = 'ÉPIQUE';
      badgeColor = Colors.amber;
    } else if (milestone.value >= 10000) {
      badgeText = 'RARE';
      badgeColor = Colors.orange;
    } else if (milestone.value >= 1000) {
      badgeText = 'SPÉCIAL';
      badgeColor = Colors.blue;
    }
    
    if (badgeText == null) return null;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}