import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/gesture_service.dart';
import '../../core/providers/gesture_provider.dart';
import '../../core/widgets/smart_gesture_detector.dart';
import '../../core/widgets/haptic_wrapper.dart';

/// Écran de configuration des gestes intelligents
class GestureSettingsScreen extends ConsumerStatefulWidget {
  const GestureSettingsScreen({super.key});
  
  @override
  ConsumerState<GestureSettingsScreen> createState() => _GestureSettingsScreenState();
}

class _GestureSettingsScreenState extends ConsumerState<GestureSettingsScreen> {
  int _testCounter = 0;
  bool _isPaused = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gesturePrefs = ref.watch(gesturePreferencesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestes Intelligents'),
      ),
      body: ListView(
        children: [
          // Activation des gestes
          SwitchListTile(
            title: const Text('Activer les gestes intelligents'),
            subtitle: const Text('Contrôlez l\'app avec des gestes tactiles'),
            value: gesturePrefs.enabled,
            onChanged: (value) async {
              await ref.read(gesturePreferencesProvider.notifier)
                  .setEnabled(value);
            },
          ),
          
          const Divider(),
          
          // Configuration
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuration',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                
                // Sensibilité
                Text(
                  'Sensibilité',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...GestureSensitivity.values.map((sensitivity) {
                  return RadioListTile<GestureSensitivity>(
                    title: Text(_getSensitivityLabel(sensitivity)),
                    subtitle: Text(_getSensitivityDescription(sensitivity)),
                    value: sensitivity,
                    groupValue: gesturePrefs.sensitivity,
                    onChanged: gesturePrefs.enabled
                        ? (value) async {
                            if (value != null) {
                              await ref.read(gesturePreferencesProvider.notifier)
                                  .setSensitivity(value);
                            }
                          }
                        : null,
                  );
                }),
                
                const SizedBox(height: 16),
                
                // Mode gaucher
                SwitchListTile(
                  title: const Text('Mode gaucher'),
                  subtitle: const Text('Inverse la direction des gestes pour les gauchers'),
                  value: gesturePrefs.leftHandedMode,
                  onChanged: gesturePrefs.enabled
                      ? (value) async {
                          await ref.read(gesturePreferencesProvider.notifier)
                              .setLeftHandedMode(value);
                        }
                      : null,
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Guide des gestes
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guide des gestes',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                
                // Gestes de base
                _GestureGuideItem(
                  icon: Icons.touch_app,
                  gesture: 'Tap',
                  action: 'Incrémenter le compteur (+1)',
                ),
                _GestureGuideItem(
                  icon: Icons.touch_app,
                  gesture: 'Double tap',
                  action: 'Pause / Reprendre',
                ),
                _GestureGuideItem(
                  icon: Icons.timer,
                  gesture: 'Appui long',
                  action: 'Réinitialiser le compteur',
                ),
                
                const SizedBox(height: 16),
                Text(
                  'Swipes',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                
                _GestureGuideItem(
                  icon: Icons.swipe_up,
                  gesture: 'Swipe vers le haut',
                  action: 'Ajouter 10',
                ),
                _GestureGuideItem(
                  icon: Icons.swipe_down,
                  gesture: 'Swipe vers le bas',
                  action: 'Retirer 1',
                ),
                _GestureGuideItem(
                  icon: Icons.swipe_right,
                  gesture: 'Swipe vers la droite',
                  action: 'Ajouter 5',
                ),
                _GestureGuideItem(
                  icon: Icons.swipe_left,
                  gesture: 'Swipe vers la gauche',
                  action: 'Retirer 10',
                ),
                
                const SizedBox(height: 16),
                Text(
                  'Gestes avancés',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                
                _GestureGuideItem(
                  icon: Icons.circle_outlined,
                  gesture: 'Dessiner un cercle',
                  action: 'Réinitialiser le compteur',
                ),
                _GestureGuideItem(
                  icon: Icons.gesture,
                  gesture: 'Zigzag',
                  action: 'Annuler la dernière action',
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
                  'Testez les gestes dans cette zone interactive',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Zone interactive
                if (gesturePrefs.enabled)
                  GestureCounterZone(
                    count: _testCounter,
                    onCountChanged: (newCount) {
                      setState(() {
                        _testCounter = newCount;
                      });
                    },
                    onReset: () {
                      setState(() {
                        _testCounter = 0;
                      });
                    },
                    onPauseResume: () {
                      setState(() {
                        _isPaused = !_isPaused;
                      });
                    },
                    showVisualFeedback: true,
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.gesture,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Activez les gestes pour tester',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                if (_isPaused) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Chip(
                      label: const Text('En pause'),
                      backgroundColor: Colors.orange.withOpacity(0.2),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const Divider(),
          
          // Patterns personnalisés
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patterns de gestes',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Combinez plusieurs gestes pour des actions rapides',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                
                ListTile(
                  leading: const Icon(Icons.save),
                  title: const Text('Sauvegarde rapide'),
                  subtitle: const Text('Double tap + Appui long'),
                  trailing: Switch(
                    value: false, // TODO: Implémenter la gestion des patterns
                    onChanged: gesturePrefs.enabled ? (value) {} : null,
                  ),
                ),
                
                ListTile(
                  leading: const Icon(Icons.undo),
                  title: const Text('Annuler'),
                  subtitle: const Text('Swipe gauche × 2'),
                  trailing: Switch(
                    value: false,
                    onChanged: gesturePrefs.enabled ? (value) {} : null,
                  ),
                ),
                
                ListTile(
                  leading: const Icon(Icons.skip_next),
                  title: const Text('Aller à la fin'),
                  subtitle: const Text('Swipe haut × 3'),
                  trailing: Switch(
                    value: false,
                    onChanged: gesturePrefs.enabled ? (value) {} : null,
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
  
  String _getSensitivityLabel(GestureSensitivity sensitivity) {
    switch (sensitivity) {
      case GestureSensitivity.low:
        return 'Faible';
      case GestureSensitivity.medium:
        return 'Moyen';
      case GestureSensitivity.high:
        return 'Élevé';
    }
  }
  
  String _getSensitivityDescription(GestureSensitivity sensitivity) {
    switch (sensitivity) {
      case GestureSensitivity.low:
        return 'Gestes amples requis (moins sensible)';
      case GestureSensitivity.medium:
        return 'Sensibilité équilibrée (recommandé)';
      case GestureSensitivity.high:
        return 'Gestes subtils détectés (très sensible)';
    }
  }
}

/// Item du guide des gestes
class _GestureGuideItem extends StatelessWidget {
  final IconData icon;
  final String gesture;
  final String action;
  
  const _GestureGuideItem({
    required this.icon,
    required this.gesture,
    required this.action,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gesture,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  action,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}