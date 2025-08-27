import 'package:flutter/material.dart';
import 'package:spiritual_routines/features/routines/routine_completion_status.dart';

/// Widget de démonstration pour les indicateurs de statut de routine
class RoutineStatusDemo extends StatelessWidget {
  const RoutineStatusDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Démonstration des indicateurs de statut'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statuts de completion des routines',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'Les indicateurs suivants montrent l\'état d\'accomplissement selon le calendrier défini:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            
            // Statut Completed (Accomplie)
            _buildStatusCard(
              context,
              RoutineCompletionStatus.completed,
              'Routine Quotidienne - Prières du Matin',
              'Accomplie aujourd\'hui à 06:30',
              'daily',
            ),
            const SizedBox(height: 16),
            
            // Statut Pending (En attente)
            _buildStatusCard(
              context,
              RoutineCompletionStatus.pending,
              'Routine Hebdomadaire - Récitation Coran',
              'Pas encore faite cette semaine',
              'weekly',
            ),
            const SizedBox(height: 16),
            
            // Statut Overdue (En retard)
            _buildStatusCard(
              context,
              RoutineCompletionStatus.overdue,
              'Routine Mensuelle - Dhikr Intensif',
              'En retard - Non faite ce mois',
              'monthly',
            ),
            const SizedBox(height: 32),
            
            // Légende
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Légende',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLegendItem(context, Icons.check_circle_rounded, Colors.green, 'Accomplie selon la fréquence'),
                  const SizedBox(height: 8),
                  _buildLegendItem(context, Icons.schedule_rounded, Colors.orange, 'En cours ou pas encore faite'),
                  const SizedBox(height: 8),
                  _buildLegendItem(context, Icons.warning_rounded, Colors.red, 'En retard selon la fréquence'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusCard(
    BuildContext context,
    RoutineCompletionStatus status,
    String routineName,
    String description,
    String frequency,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    IconData iconData;
    Color backgroundColor;
    Color iconColor;
    
    switch (status) {
      case RoutineCompletionStatus.completed:
        iconData = Icons.check_circle_rounded;
        backgroundColor = Colors.green.withOpacity(0.15);
        iconColor = Colors.green;
        break;
      case RoutineCompletionStatus.pending:
        iconData = Icons.schedule_rounded;
        backgroundColor = Colors.orange.withOpacity(0.15);
        iconColor = Colors.orange;
        break;
      case RoutineCompletionStatus.overdue:
        iconData = Icons.warning_rounded;
        backgroundColor = Colors.red.withOpacity(0.15);
        iconColor = Colors.red;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface,
            backgroundColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Indicateur de statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  iconData,
                  size: 16,
                  color: iconColor,
                ),
                const SizedBox(width: 4),
                Text(
                  status.description,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Informations de la routine
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routineName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    frequency == 'daily' ? 'Quotidien' :
                    frequency == 'weekly' ? 'Hebdomadaire' : 'Mensuel',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLegendItem(BuildContext context, IconData icon, Color color, String description) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}