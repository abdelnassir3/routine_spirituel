import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auto_resume_service.dart';
import '../../core/providers/auto_resume_provider.dart';
import '../../core/widgets/haptic_wrapper.dart';

/// Écran de configuration de l'auto-resume
class AutoResumeSettingsScreen extends ConsumerStatefulWidget {
  const AutoResumeSettingsScreen({super.key});

  @override
  ConsumerState<AutoResumeSettingsScreen> createState() =>
      _AutoResumeSettingsScreenState();
}

class _AutoResumeSettingsScreenState
    extends ConsumerState<AutoResumeSettingsScreen> {
  // Session de test
  bool _hasTestSession = false;
  int _testProgress = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = ref.watch(autoResumePreferencesProvider);
    final pendingResume = ref.watch(pendingResumeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reprise Automatique'),
      ),
      body: ListView(
        children: [
          // État actuel
          if (pendingResume != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Session en attente',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Une session de ${_getSessionTypeLabel(pendingResume.type)} '
                    'peut être reprise (progrès: ${pendingResume.progress})',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await ref.abandonAutoResumeSession();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Abandonner'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            final success = await ref.resumePendingSession();
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Session reprise avec succès'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Reprendre'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Configuration principale
          SwitchListTile(
            title: const Text('Activer la reprise automatique'),
            subtitle: const Text(
              'Sauvegarde et reprend automatiquement vos sessions interrompues',
            ),
            value: prefs.enabled,
            onChanged: (value) async {
              await ref
                  .read(autoResumePreferencesProvider.notifier)
                  .setEnabled(value);
            },
          ),

          const Divider(),

          // Options avancées
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Options avancées',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),

                // Quick Resume
                SwitchListTile(
                  title: const Text('Reprise rapide'),
                  subtitle: const Text(
                    'Reprend automatiquement si l\'app était fermée moins de 10 secondes',
                  ),
                  value: prefs.quickResumeEnabled,
                  onChanged: prefs.enabled
                      ? (value) async {
                          await ref
                              .read(autoResumePreferencesProvider.notifier)
                              .setQuickResumeEnabled(value);
                        }
                      : null,
                ),

                const SizedBox(height: 16),

                // Informations
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Comment ça marche ?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• L\'état est sauvegardé toutes les 5 secondes\n'
                              '• Les sessions expirent après 30 minutes\n'
                              '• La reprise conserve votre progrès exact\n'
                              '• Fonctionne même après un crash de l\'app',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Comportement
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comportement',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),

                // Délai d'expiration
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Délai d\'expiration'),
                  subtitle: const Text('30 minutes'),
                  trailing: Chip(
                    label: const Text('Non modifiable'),
                    backgroundColor: theme.dividerColor.withOpacity(0.3),
                  ),
                ),

                // Fréquence de sauvegarde
                ListTile(
                  leading: const Icon(Icons.save_outlined),
                  title: const Text('Fréquence de sauvegarde'),
                  subtitle: const Text('Toutes les 5 secondes'),
                  trailing: Chip(
                    label: const Text('Automatique'),
                    backgroundColor: theme.primaryColor.withOpacity(0.2),
                  ),
                ),

                // Notification de reprise
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notification de reprise'),
                  subtitle: const Text('Affichée pendant 30 secondes'),
                  trailing: Chip(
                    label: const Text('Activé'),
                    backgroundColor: Colors.green.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Zone de test
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zone de test',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Testez le comportement de la reprise automatique',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),

                // Boutons de test
                if (!_hasTestSession) ...[
                  SizedBox(
                    width: double.infinity,
                    child: HapticWrapper(
                      type: HapticType.selection,
                      onTap: () async {
                        // Créer une session de test
                        await ref.registerForAutoResume(
                          sessionId:
                              'test_${DateTime.now().millisecondsSinceEpoch}',
                          type: 'prayer',
                          data: {'test': true},
                        );

                        setState(() {
                          _hasTestSession = true;
                          _testProgress = 0;
                        });

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Session de test créée. Fermez l\'app pour tester la reprise.'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      child: FilledButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.science),
                        label: const Text('Créer une session de test'),
                      ),
                    ),
                  ),
                ] else ...[
                  // Session de test active
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Session de test active',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            Text(
                              'Progrès: $_testProgress',
                              style: TextStyle(
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Simuler le progrès
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  setState(() {
                                    _testProgress += 10;
                                  });
                                  await ref
                                      .updateSessionProgress(_testProgress);
                                },
                                child: const Text('+10'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await ref.completeAutoResumeSession();
                                  setState(() {
                                    _hasTestSession = false;
                                    _testProgress = 0;
                                  });
                                },
                                child: const Text('Terminer'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Fermez l\'app maintenant pour tester la reprise',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Instructions de test
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.science_outlined,
                            size: 20,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Instructions de test',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Créez une session de test\n'
                        '2. Ajoutez du progrès (optionnel)\n'
                        '3. Fermez l\'application (swipe up)\n'
                        '4. Rouvrez l\'application\n'
                        '5. Une notification de reprise apparaîtra',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getSessionTypeLabel(String type) {
    switch (type) {
      case 'prayer':
        return 'prière';
      case 'meditation':
        return 'méditation';
      case 'reading':
        return 'lecture';
      default:
        return 'session';
    }
  }
}
