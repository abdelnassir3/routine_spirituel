import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/haptic_service_interface.dart';
import '../../core/providers/haptic_provider.dart';
import '../../core/widgets/haptic_wrapper.dart';

/// Écran de configuration du feedback haptique
class HapticSettingsScreen extends ConsumerWidget {
  const HapticSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hapticPrefs = ref.watch(hapticPreferencesProvider);
    final canVibrate = ref.watch(canVibrateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Retour Haptique'),
      ),
      body: ListView(
        children: [
          // Information sur l'appareil
          if (!canVibrate)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Votre appareil ne supporte pas la vibration',
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                  ),
                ],
              ),
            ),

          // Activation du feedback haptique
          HapticSwitchListTile(
            title: const Text('Activer le retour haptique'),
            subtitle: const Text('Vibrations lors des interactions'),
            value: hapticPrefs.enabled,
            onChanged: canVibrate
                ? (value) async {
                    await ref
                        .read(hapticPreferencesProvider.notifier)
                        .setEnabled(value);
                  }
                : null,
          ),

          const Divider(),

          // Intensité
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Intensité',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajustez la force des vibrations',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),

                // Options d'intensité
                ...HapticIntensity.values.map((intensity) {
                  return RadioListTile<HapticIntensity>(
                    title: Text(_getIntensityLabel(intensity)),
                    subtitle: Text(_getIntensityDescription(intensity)),
                    value: intensity,
                    groupValue: hapticPrefs.intensity,
                    onChanged: hapticPrefs.enabled && canVibrate
                        ? (value) async {
                            if (value != null) {
                              await ref
                                  .read(hapticPreferencesProvider.notifier)
                                  .setIntensity(value);
                            }
                          }
                        : null,
                  );
                }),
              ],
            ),
          ),

          const Divider(),

          // Tester le feedback
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tester les vibrations',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Appuyez sur les boutons pour tester différents types de vibrations',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),

                // Boutons de test
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TestButton(
                      label: 'Tap léger',
                      onPressed: hapticPrefs.enabled && canVibrate
                          ? () => ref.hapticLightTap()
                          : null,
                    ),
                    _TestButton(
                      label: 'Sélection',
                      onPressed: hapticPrefs.enabled && canVibrate
                          ? () => ref.hapticSelection()
                          : null,
                    ),
                    _TestButton(
                      label: 'Impact',
                      onPressed: hapticPrefs.enabled && canVibrate
                          ? () => ref.hapticImpact()
                          : null,
                    ),
                    _TestButton(
                      label: 'Succès',
                      onPressed: hapticPrefs.enabled && canVibrate
                          ? () => ref.hapticSuccess()
                          : null,
                    ),
                    _TestButton(
                      label: 'Erreur',
                      onPressed: hapticPrefs.enabled && canVibrate
                          ? () => ref.hapticError()
                          : null,
                    ),
                    _TestButton(
                      label: 'Notification',
                      onPressed: hapticPrefs.enabled && canVibrate
                          ? () => ref.hapticNotification()
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          // Patterns de prière
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vibrations de prière',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Testez les vibrations utilisées pendant les sessions de prière',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.play_arrow),
                  title: const Text('Début de prière'),
                  trailing: IconButton(
                    icon: const Icon(Icons.vibration),
                    onPressed: hapticPrefs.enabled && canVibrate
                        ? () => ref.hapticPrayerStart()
                        : null,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('Compteur'),
                  subtitle: const Text('Vibration à chaque répétition'),
                  trailing: IconButton(
                    icon: const Icon(Icons.vibration),
                    onPressed: hapticPrefs.enabled && canVibrate
                        ? () => ref.hapticCounterTick()
                        : null,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Milestone (33)'),
                  subtitle: const Text('Vibration au tiers'),
                  trailing: IconButton(
                    icon: const Icon(Icons.vibration),
                    onPressed: hapticPrefs.enabled && canVibrate
                        ? () => ref.hapticMilestone(33)
                        : null,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Milestone (66)'),
                  subtitle: const Text('Vibration aux deux tiers'),
                  trailing: IconButton(
                    icon: const Icon(Icons.vibration),
                    onPressed: hapticPrefs.enabled && canVibrate
                        ? () => ref.hapticMilestone(66)
                        : null,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Milestone (99)'),
                  subtitle: const Text('Vibration à la fin'),
                  trailing: IconButton(
                    icon: const Icon(Icons.vibration),
                    onPressed: hapticPrefs.enabled && canVibrate
                        ? () => ref.hapticMilestone(99)
                        : null,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: const Text('Fin de prière'),
                  trailing: IconButton(
                    icon: const Icon(Icons.vibration),
                    onPressed: hapticPrefs.enabled && canVibrate
                        ? () => ref.hapticPrayerComplete()
                        : null,
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

  String _getIntensityLabel(HapticIntensity intensity) {
    switch (intensity) {
      case HapticIntensity.light:
        return 'Léger';
      case HapticIntensity.medium:
        return 'Moyen';
      case HapticIntensity.strong:
        return 'Fort';
    }
  }

  String _getIntensityDescription(HapticIntensity intensity) {
    switch (intensity) {
      case HapticIntensity.light:
        return 'Vibrations subtiles et discrètes';
      case HapticIntensity.medium:
        return 'Vibrations équilibrées (recommandé)';
      case HapticIntensity.strong:
        return 'Vibrations prononcées et intenses';
    }
  }
}

/// Bouton de test pour les vibrations
class _TestButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _TestButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }
}

/// SwitchListTile avec feedback haptique
class HapticSwitchListTile extends ConsumerWidget {
  final Widget title;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const HapticSwitchListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwitchListTile(
      title: title,
      subtitle: subtitle,
      value: value,
      onChanged: onChanged != null
          ? (newValue) async {
              await ref.hapticSelection();
              onChanged!(newValue);
            }
          : null,
    );
  }
}
