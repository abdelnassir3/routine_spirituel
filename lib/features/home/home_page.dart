import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spiritual_routines/core/services/persistence_service.dart';
import 'package:spiritual_routines/core/services/persistence_service_drift.dart';
import 'package:spiritual_routines/core/services/progress_service.dart';
import 'package:spiritual_routines/features/session/session_state.dart';
import 'package:spiritual_routines/design_system/components/buttons.dart';
import 'package:spiritual_routines/design_system/components/cards.dart';
import 'package:spiritual_routines/design_system/tokens/spacing.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recovery = ref.watch(recoveryOptionsProvider);
    ref.listen(recoveryOptionsProvider, (prev, next) async {
      next.whenData((opt) async {
        if (!opt.hasSnapshot || opt.snapshot == null) return;
        final sessionId = opt.snapshot!.payload['sessionId'] as String?;
        if (sessionId == null) return;
        // Show modal once
        if (Navigator.of(context).canPop()) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.restore_rounded, size: 48),
            title: const Text('Reprendre la session ?'),
            content: const Text(
                'Vous pouvez reprendre exactement où vous avez arrêté, ou réinitialiser la routine.'),
            actions: [
              M3TextButton(
                onPressed: () async {
                  await ref
                      .read(persistenceServiceProvider)
                      .handleRecovery(RecoveryChoice.reset);
                  ref.read(currentSessionIdProvider.notifier).state = sessionId;
                  ref
                      .read(persistenceServiceProvider)
                      .setCurrentSession(sessionId);
                  await ref
                      .read(progressServiceProvider)
                      .initProgressForSession(sessionId);
                  if (context.mounted) {
                    Navigator.of(ctx).pop();
                    context.go('/reader');
                  }
                },
                icon: Icons.refresh_rounded,
                child: const Text('Réinitialiser'),
              ),
              M3FilledButton(
                onPressed: () async {
                  await ref
                      .read(persistenceServiceProvider)
                      .handleRecovery(RecoveryChoice.resume);
                  ref.read(currentSessionIdProvider.notifier).state = sessionId;
                  ref
                      .read(persistenceServiceProvider)
                      .setCurrentSession(sessionId);
                  if (context.mounted) {
                    Navigator.of(ctx).pop();
                    context.go('/reader');
                  }
                },
                icon: Icons.play_arrow_rounded,
                child: const Text('Reprendre'),
              ),
            ],
          ),
        );
      });
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Aujourd\'hui')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.pagePadding),
        children: [
          // Bandeau d'intro avec nouveau design M3
          M3FilledCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.today_rounded,
                      size: 28,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Text(
                        'Reprendre ou démarrer une routine',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  'Continuez là où vous vous êtes arrêté ou choisissez une routine à pratiquer.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          recovery.maybeWhen(
            data: (opt) => opt.hasSnapshot
                ? Card(
                    child: ListTile(
                      leading: const Icon(Icons.play_circle_fill_rounded),
                      title: const Text('Reprendre la session'),
                      subtitle: const Text('Reprise exacte au dernier point'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () async {
                        final opt =
                            await ref.read(recoveryOptionsProvider.future);
                        final sessionId =
                            opt.snapshot?.payload['sessionId'] as String?;
                        await ref
                            .read(persistenceServiceProvider)
                            .handleRecovery(RecoveryChoice.resume);
                        if (sessionId != null) {
                          ref.read(currentSessionIdProvider.notifier).state =
                              sessionId;
                          ref
                              .read(persistenceServiceProvider)
                              .setCurrentSession(sessionId);
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Session reprise')),
                          );
                          context.go('/reader');
                        }
                      },
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.list_alt_rounded),
              title: const Text('Routines'),
              subtitle: const Text('Parcourir, créer et organiser'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go('/routines'),
              minLeadingWidth: 32,
              isThreeLine: false,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Réglages'),
              subtitle: const Text('Voix, affichage, import de corpus…'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go('/settings'),
              minLeadingWidth: 32,
              isThreeLine: false,
            ),
          ),
        ],
      ),
    );
  }
}
