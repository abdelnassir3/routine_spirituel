import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift; // ✅ pour Value<T>
import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';
import 'package:spiritual_routines/core/utils/id.dart';
import 'package:spiritual_routines/core/services/content_service.dart';
import 'package:spiritual_routines/core/services/session_service.dart';
import 'package:spiritual_routines/core/services/audio_player_service.dart';
import 'package:spiritual_routines/features/session/session_state.dart';
import 'package:spiritual_routines/features/settings/user_settings_service.dart'
    as secure;
import 'package:spiritual_routines/l10n/app_localizations.dart';
import 'package:spiritual_routines/core/services/task_audio_prefs.dart';
import 'dart:io';

// Design system moderne
import 'package:spiritual_routines/design_system/inspired_theme.dart';
import 'package:spiritual_routines/design_system/components/modern_navigation.dart';
import 'package:spiritual_routines/design_system/components/modern_layouts.dart';
import 'package:spiritual_routines/design_system/animations/premium_animations.dart';

// Système de statut de completion
import 'package:spiritual_routines/features/routines/routine_completion_status.dart';

class RoutineEditorPage extends ConsumerWidget {
  final String routineId;
  const RoutineEditorPage({super.key, required this.routineId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskDao = ref.watch(taskDaoProvider);
    final tasksStream = taskDao.watchByRoutine(routineId);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          // Header moderne avec gradient
          _buildModernHeader(context, ref),

          // Contenu principal
          Expanded(
            child: _buildTasksList(context, ref, tasksStream),
          ),
        ],
      ),
      floatingActionButton: _buildModernFAB(context, ref),
    );
  }

  /// Header moderne avec gradient et boutons
  Widget _buildModernHeader(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: ModernGradients.header(cs),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Barre de navigation
              Row(
                children: [
                  // Bouton retour moderne
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Zone de texte optimisée pour lignes simples ✨
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Titre principal - une seule ligne
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Éditeur de routine',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize:
                                      20, // Taille optimisée pour une ligne
                                  height: 1.1,
                                  letterSpacing: -0.3,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Indicateur intégré dans la ligne principale
                            _buildPremiumStatusIndicator(
                                context, ref, routineId),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Sous-titre compact - une seule ligne
                        Text(
                          'Organisez vos pratiques spirituelles',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                            fontSize:
                                14, // Taille réduite pour tenir sur une ligne
                            height: 1.2,
                            letterSpacing: 0.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Bouton Lire/Reprendre conditionnel
                  FutureBuilder<SessionRow?>(
                    future: ref
                        .read(sessionServiceProvider)
                        .getInterruptedSession(routineId),
                    builder: (context, snapshot) {
                      final interruptedSession = snapshot.data;
                      final isResume = interruptedSession != null;

                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              late String sessionId;

                              if (isResume) {
                                // Reprendre la session existante
                                sessionId = await ref
                                    .read(sessionServiceProvider)
                                    .resumeSession(interruptedSession.id);
                              } else {
                                // Créer une nouvelle session
                                sessionId = await ref
                                    .read(sessionServiceProvider)
                                    .startRoutine(routineId);
                              }

                              ref
                                  .read(currentSessionIdProvider.notifier)
                                  .state = sessionId;
                              if (context.mounted) context.go('/reader');
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isResume
                                        ? Icons.play_circle_rounded
                                        : Icons.play_arrow_rounded,
                                    color:
                                        isResume ? Colors.orange : cs.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isResume ? 'Reprendre' : 'Lire',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isResume ? Colors.orange : cs.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Liste des tâches modernisée
  Widget _buildTasksList(
      BuildContext context, WidgetRef ref, Stream<List<TaskRow>> tasksStream) {
    final taskDao = ref.watch(taskDaoProvider);

    return StreamBuilder<List<TaskRow>>(
      stream: tasksStream,
      builder: (context, snap) {
        final tasks = snap.data ?? const [];

        if (tasks.isEmpty) {
          return _buildEmptyState(context, ref);
        }

        return ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          buildDefaultDragHandles: false,
          itemCount: tasks.length,
          onReorder: (oldIndex, newIndex) async {
            if (newIndex > oldIndex) newIndex -= 1;
            final updated = [...tasks];
            final item = updated.removeAt(oldIndex);
            updated.insert(newIndex, item);
            for (int i = 0; i < updated.length; i++) {
              await taskDao.updateOrder(updated[i].id, i);
            }
            final hapticsOn = (await ref
                    .read(secure.userSettingsServiceProvider)
                    .readValue('ui_reorder_haptics')) !=
                'off';
            if (hapticsOn) await HapticFeedback.lightImpact();
            // Read snack toggle from secure settings service used in routines feature
            final showSnack = (await ref
                    .read(secure.userSettingsServiceProvider)
                    .readValue('ui_reorder_snackbar')) !=
                'off';
            if (context.mounted && showSnack) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      AppLocalizations.of(context)?.reorderTasksUpdated ??
                          'Ordre des tâches mis à jour'),
                  duration: const Duration(milliseconds: 800),
                ),
              );
            }
          },
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _buildModernTaskCard(context, ref, task, index);
          },
        );
      },
    );
  }

  /// Carte de tâche moderne avec Material Design 3
  Widget _buildModernTaskCard(
      BuildContext context, WidgetRef ref, TaskRow task, int index) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      key: ValueKey(task.id),
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey('dismissible_${task.id}'),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.errorContainer,
                cs.errorContainer.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete_forever_rounded,
                color: cs.error,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                'Supprimer',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Supprimer la tâche ?'),
                  content: Text('"${_titleFor(task)}" sera supprimée.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Annuler')),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              ) ??
              false;
        },
        onDismissed: (_) async {
          final taskDao = ref.read(taskDaoProvider);
          await taskDao.deleteById(task.id);
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.surface,
                cs.surfaceContainerHighest.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Ligne principale avec icône, titre, bouton play et drag handle
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icône compacte
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              cs.primaryContainer,
                              cs.primaryContainer.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _iconForType(task.type),
                          color: cs.primary,
                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Titre avec ellipsis pour éviter le débordement
                      Expanded(
                        child: Text(
                          _titleFor(task),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Bouton play individuel - déplacé en première ligne
                      Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              cs.primary,
                              cs.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              // Démarrer la routine et naviguer vers cette tâche spécifique
                              final sessionId = await ref
                                  .read(sessionServiceProvider)
                                  .startRoutine(routineId);
                              ref
                                  .read(currentSessionIdProvider.notifier)
                                  .state = sessionId;
                              if (context.mounted) {
                                // Passer l'ID de la tâche comme paramètre pour commencer par cette tâche
                                context.go('/reader?startTask=${task.id}');
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      // Drag handle compact
                      ReorderableDragStartListener(
                        index: index,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.drag_indicator_rounded,
                            color: cs.onSurfaceVariant,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Ligne des badges et actions
                  Row(
                    children: [
                      // Badges compacts
                      Expanded(
                        flex: 2,
                        child: _buildCompactTaskInfo(context, ref, task),
                      ),

                      const SizedBox(width: 8),

                      // Actions compactes
                      _buildCompactTaskActions(context, ref, task),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Informations de tâche avec badges modernes
  Widget _buildTaskInfo(BuildContext context, WidgetRef ref, TaskRow task) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Consumer(
      builder: (context, ref, _) {
        return FutureBuilder<(TaskLangAudio, TaskLangAudio)>(
          future: () async {
            final svc = ref.read(taskAudioPrefsProvider);
            final fr = await svc.getForTaskLocale(task.id, 'fr');
            final ar = await svc.getForTaskLocale(task.id, 'ar');
            return (fr, ar);
          }(),
          builder: (context, snap) {
            final fr = snap.data?.$1;
            final ar = snap.data?.$2;
            final frHas = fr?.hasLocalFile == true;
            final arHas = ar?.hasLocalFile == true;

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Badge catégorie
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.category,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Badge répétitions
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.repeat_rounded,
                        size: 16,
                        color: cs.onTertiaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${task.defaultReps}x',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge audio FR
                if (frHas)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.primaryContainer,
                          cs.primaryContainer.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.music_note_rounded,
                          size: 16,
                          color: cs.onPrimaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'FR',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Badge audio AR
                if (arHas)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.primaryContainer,
                          cs.primaryContainer.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.music_note_rounded,
                          size: 16,
                          color: cs.onPrimaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'AR',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  /// Informations de tâche compactes pour éviter le débordement
  Widget _buildCompactTaskInfo(
      BuildContext context, WidgetRef ref, TaskRow task) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Consumer(
      builder: (context, ref, _) {
        return FutureBuilder<(TaskLangAudio, TaskLangAudio)>(
          future: () async {
            final svc = ref.read(taskAudioPrefsProvider);
            final fr = await svc.getForTaskLocale(task.id, 'fr');
            final ar = await svc.getForTaskLocale(task.id, 'ar');
            return (fr, ar);
          }(),
          builder: (context, snap) {
            final fr = snap.data?.$1;
            final ar = snap.data?.$2;
            final frHas = fr?.hasLocalFile == true;
            final arHas = ar?.hasLocalFile == true;

            return Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                // Badge catégorie compact
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.category,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),

                // Badge répétitions compact
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.repeat_rounded,
                        size: 12,
                        color: cs.onTertiaryContainer,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${task.defaultReps}x',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badges audio compacts
                if (frHas)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.primaryContainer,
                          cs.primaryContainer.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.music_note_rounded,
                          size: 10,
                          color: cs.onPrimaryContainer,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'FR',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (arHas)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.primaryContainer,
                          cs.primaryContainer.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.music_note_rounded,
                          size: 10,
                          color: cs.onPrimaryContainer,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'AR',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  /// Boutons d'action compacts
  Widget _buildCompactTaskActions(
      BuildContext context, WidgetRef ref, TaskRow task) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Consumer(
      builder: (context, ref, _) {
        return FutureBuilder<(TaskLangAudio, TaskLangAudio)>(
          future: () async {
            final svc = ref.read(taskAudioPrefsProvider);
            final fr = await svc.getForTaskLocale(task.id, 'fr');
            final ar = await svc.getForTaskLocale(task.id, 'ar');
            return (fr, ar);
          }(),
          builder: (context, snap) {
            final fr = snap.data?.$1;
            final ar = snap.data?.$2;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Actions audio compactes
                if (fr?.hasLocalFile == true)
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        await ref
                            .read(audioPlayerServiceProvider)
                            .playFile(fr!.filePath!);
                      },
                      icon: const Icon(Icons.volume_up_rounded),
                      tooltip: 'Audio FR',
                      iconSize: 16,
                      padding: EdgeInsets.zero,
                    ),
                  ),

                if (ar?.hasLocalFile == true)
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        await ref
                            .read(audioPlayerServiceProvider)
                            .playFile(ar!.filePath!);
                      },
                      icon: const Icon(Icons.volume_up_rounded),
                      tooltip: 'Audio AR',
                      iconSize: 16,
                      padding: EdgeInsets.zero,
                    ),
                  ),

                if ((fr?.hasLocalFile == true) || (ar?.hasLocalFile == true))
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        try {
                          await ref.read(audioPlayerServiceProvider).stop();
                        } catch (_) {}
                      },
                      icon: const Icon(Icons.stop_rounded),
                      tooltip: 'Stop',
                      iconSize: 16,
                      padding: EdgeInsets.zero,
                    ),
                  ),

                // Actions principales compactes
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => context.push('/task/${task.id}/content'),
                    icon: const Icon(Icons.description_outlined),
                    tooltip: 'Contenu',
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                  ),
                ),

                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => _showTaskDialog(context, ref, routineId,
                        existing: task),
                    icon: const Icon(Icons.edit_rounded),
                    tooltip: 'Modifier',
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                  ),
                ),

                // Bouton de suppression explicite
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: cs.errorContainer.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () =>
                        _showDeleteConfirmation(context, ref, task),
                    icon: const Icon(Icons.delete_outline_rounded),
                    tooltip: 'Supprimer',
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    color: cs.error,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Boutons d'action modernes (méthode conservée pour compatibilité)
  Widget _buildTaskActions(BuildContext context, WidgetRef ref, TaskRow task) {
    return _buildCompactTaskActions(context, ref, task);
  }

  /// État vide moderne
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primaryContainer,
                    cs.primaryContainer.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.task_alt_rounded,
                size: 60,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune tâche',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre première tâche spirituelle\npour commencer votre routine',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showTaskDialog(context, ref, routineId),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ajouter une tâche'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FAB moderne
  Widget _buildModernFAB(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary,
            cs.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showTaskDialog(context, ref, routineId),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  /// Indicateur de statut de completion de la routine
  Widget _buildRoutineStatusIndicator(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Consumer(
      builder: (context, ref, _) {
        final statusAsync =
            ref.watch(routineCompletionStatusProvider(routineId));

        return statusAsync.when(
          data: (status) {
            IconData iconData;
            Color backgroundColor;
            Color iconColor;

            switch (status) {
              case RoutineCompletionStatus.completed:
                iconData = Icons.check_circle_rounded;
                backgroundColor = Colors.green.withOpacity(0.2);
                iconColor = Colors.green;
                break;
              case RoutineCompletionStatus.pending:
                iconData = Icons.schedule_rounded;
                backgroundColor = Colors.orange.withOpacity(0.2);
                iconColor = Colors.orange;
                break;
              case RoutineCompletionStatus.overdue:
                iconData = Icons.warning_rounded;
                backgroundColor = Colors.red.withOpacity(0.2);
                iconColor = Colors.red;
                break;
            }

            return Container(
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
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
            ),
          ),
          error: (error, stack) => const SizedBox.shrink(),
        );
      },
    );
  }

  /// Afficher la confirmation de suppression
  Future<void> _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, TaskRow task) async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_forever_rounded,
                color: cs.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Supprimer la tâche ?',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cette action est irréversible.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tâche à supprimer :',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _titleFor(task),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Catégorie: ${task.category}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.delete_forever_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'Supprimer',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Si l'utilisateur confirme, supprimer la tâche
    if (confirmed == true && context.mounted) {
      try {
        final taskDao = ref.read(taskDaoProvider);
        await taskDao.deleteById(task.id);

        // Feedback haptique
        HapticFeedback.lightImpact();

        // Message de confirmation
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tâche "${_titleFor(task)}" supprimée',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: cs.primary,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } catch (e) {
        // Gestion d'erreur
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Erreur lors de la suppression: $e',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: cs.error,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  String _titleFor(TaskRow task) {
    if (task.notesFr != null && task.notesFr!.isNotEmpty) return task.notesFr!;
    return switch (task.type) {
      'text' => 'Texte',
      'verses' => 'Versets',
      'surah' => 'Sourate',
      'mixed' => 'Mix',
      _ => 'Tâche'
    };
  }
}

IconData _iconForType(String type) {
  switch (type) {
    case 'text':
      return Icons.notes_rounded;
    case 'verses':
      return Icons.menu_book_rounded;
    case 'surah':
      return Icons.auto_stories_rounded;
    case 'mixed':
      return Icons.layers_rounded;
    default:
      return Icons.task_alt_rounded;
  }
}

bool _validateRefs(String input) {
  // Accept patterns like: 2:255; 2:1-5; 18
  final parts = input.split(RegExp(r'[;,]\s*'));
  final reSurah = RegExp(r'^\d{1,3}$');
  final reAyah = RegExp(r'^(\d{1,3}):(\d{1,3})(?:-(\d{1,3}))?$');
  for (final p in parts) {
    final s = p.trim();
    if (s.isEmpty) continue;
    if (reSurah.hasMatch(s)) continue;
    final m = reAyah.firstMatch(s);
    if (m == null) return false;
    if (m.group(3) != null) {
      final a = int.parse(m.group(2)!);
      final b = int.parse(m.group(3)!);
      if (b < a) return false;
    }
  }
  return true;
}

/// 🎨 Status Indicator avec Design Expert Premium
Widget _buildPremiumStatusIndicator(
    BuildContext context, WidgetRef ref, String routineId) {
  final routineCompletionStatus =
      ref.watch(routineCompletionStatusProvider(routineId));

  return routineCompletionStatus.when(
    data: (status) {
      final isCompleted = status == RoutineCompletionStatus.completed;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: _getStatusGradient(status),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _getStatusColor(status).withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: _getStatusColor(status).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(status),
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              status.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    },
    loading: () => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const SizedBox(
        width: 80,
        height: 14,
        child: LinearProgressIndicator(
          minHeight: 2,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    ),
    error: (error, stack) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Status',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

/// 🎨 Gradients Premium pour les statuts
LinearGradient _getStatusGradient(RoutineCompletionStatus status) {
  switch (status) {
    case RoutineCompletionStatus.completed:
      return const LinearGradient(
        colors: [
          Color(0xFF4CAF50), // Vert nature
          Color(0xFF66BB6A), // Vert plus clair
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case RoutineCompletionStatus.overdue:
      return const LinearGradient(
        colors: [
          Color(0xFFF44336), // Rouge attention
          Color(0xFFEF5350), // Rouge plus clair
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case RoutineCompletionStatus.pending:
    default:
      return const LinearGradient(
        colors: [
          Color(0xFFFF9800), // Orange chaleureux
          Color(0xFFFFB74D), // Orange plus clair
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  }
}

/// 🎨 Couleurs d'accent pour les ombres
Color _getStatusColor(RoutineCompletionStatus status) {
  switch (status) {
    case RoutineCompletionStatus.completed:
      return const Color(0xFF4CAF50);
    case RoutineCompletionStatus.overdue:
      return const Color(0xFFF44336);
    case RoutineCompletionStatus.pending:
    default:
      return const Color(0xFFFF9800);
  }
}

/// 🎨 Icônes expressives pour les statuts
IconData _getStatusIcon(RoutineCompletionStatus status) {
  switch (status) {
    case RoutineCompletionStatus.completed:
      return Icons.check_circle;
    case RoutineCompletionStatus.overdue:
      return Icons.warning;
    case RoutineCompletionStatus.pending:
    default:
      return Icons.schedule;
  }
}

Future<void> _showTaskDialog(
  BuildContext context,
  WidgetRef ref,
  String routineId, {
  TaskRow? existing,
}) async {
  final formKey = GlobalKey<FormState>();
  String type = existing?.type ?? 'text';
  String category = existing?.category ?? 'custom';
  int defaultReps = existing?.defaultReps ?? 1;
  final notesCtrl = TextEditingController(text: existing?.notesFr ?? '');
  final titleFrCtrl = TextEditingController();
  final bodyFrCtrl = TextEditingController();
  final titleArCtrl = TextEditingController();
  final bodyArCtrl = TextEditingController();
  final refsCtrl = TextEditingController();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: FutureBuilder(
        future: existing == null
            ? Future.value(null)
            : Future.wait([
                ref
                    .read(contentServiceProvider)
                    .getByTaskAndLocale(existing.id, 'fr'),
                ref
                    .read(contentServiceProvider)
                    .getByTaskAndLocale(existing.id, 'ar'),
              ]),
        builder: (ctx, snap) {
          if (snap.hasData) {
            final fr = (snap.data as List?)?[0];
            final ar = (snap.data as List?)?[1];
            if (fr != null) {
              titleFrCtrl.text = fr.title ?? '';
              bodyFrCtrl.text = fr.body ?? '';
            }
            if (ar != null) {
              titleArCtrl.text = ar.title ?? '';
              bodyArCtrl.text = ar.body ?? '';
            }
          }
          return Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: [
                Text(
                  existing == null ? 'Nouvelle tâche' : 'Modifier la tâche',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  items: const [
                    DropdownMenuItem(value: 'text', child: Text('Texte libre')),
                    DropdownMenuItem(value: 'verses', child: Text('Versets')),
                    DropdownMenuItem(value: 'surah', child: Text('Sourate')),
                    DropdownMenuItem(value: 'mixed', child: Text('Mix')),
                  ],
                  onChanged: (v) => type = v ?? 'text',
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: category,
                  items: const [
                    DropdownMenuItem(value: 'louange', child: Text('Louange')),
                    DropdownMenuItem(
                        value: 'protection', child: Text('Protection')),
                    DropdownMenuItem(value: 'pardon', child: Text('Pardon')),
                    DropdownMenuItem(
                        value: 'guidance', child: Text('Guidance')),
                    DropdownMenuItem(
                        value: 'gratitude', child: Text('Gratitude')),
                    DropdownMenuItem(value: 'healing', child: Text('Guérison')),
                    DropdownMenuItem(
                        value: 'custom', child: Text('Personnalisé')),
                  ],
                  onChanged: (v) => category = v ?? 'custom',
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                ),
                const SizedBox(height: 8),
                if (type == 'verses' || type == 'surah') ...[
                  TextFormField(
                    controller: refsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Références (ex: 2:255; 2:1-5; 18)',
                    ),
                    maxLines: 2,
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return null; // optional
                      return _validateRefs(s) ? null : 'Format invalide';
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                TextFormField(
                  controller: notesCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Titre / Note (FR)'),
                  maxLines: 1,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: '$defaultReps',
                  decoration: const InputDecoration(
                      labelText: 'Répétitions par défaut'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Doit être > 0';
                    return null;
                  },
                  onSaved: (v) => defaultReps = int.parse(v!),
                ),
                const SizedBox(height: 12),
                ExpansionTile(
                  initiallyExpanded: existing != null,
                  title: const Text('Contenu FR/AR'),
                  children: [
                    TextFormField(
                      controller: titleFrCtrl,
                      decoration: const InputDecoration(labelText: 'Titre FR'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: bodyFrCtrl,
                      decoration: const InputDecoration(labelText: 'Texte FR'),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: titleArCtrl,
                      decoration: const InputDecoration(labelText: 'Titre AR'),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: bodyArCtrl,
                      decoration: const InputDecoration(labelText: 'Texte AR'),
                      maxLines: 4,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Annuler'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        formKey.currentState!.save();

                        final taskDao = ref.read(taskDaoProvider);
                        String taskId;

                        if (existing == null) {
                          taskId = newId();
                          await taskDao.upsertTask(TasksCompanion.insert(
                            id: taskId,
                            routineId: routineId,
                            type: type,
                            category: category,
                            defaultReps: drift.Value(defaultReps), // ✅
                            orderIndex: const drift.Value(9999), // ✅
                            notesFr: drift.Value(notesCtrl.text.trim()), // ✅
                          ));
                        } else {
                          taskId = existing.id;
                          await taskDao.upsertTask(TasksCompanion(
                            id: drift.Value(existing.id), // ✅
                            routineId: drift.Value(existing.routineId), // ✅
                            type: drift.Value(type), // ✅
                            category: drift.Value(category), // ✅
                            defaultReps: drift.Value(defaultReps), // ✅
                            notesFr: drift.Value(notesCtrl.text.trim()), // ✅
                          ));
                        }

                        // Sauvegarde FR/AR si fourni
                        final content = ref.read(contentServiceProvider);
                        if (titleFrCtrl.text.trim().isNotEmpty ||
                            bodyFrCtrl.text.trim().isNotEmpty) {
                          await content.putContent(
                            taskId: taskId,
                            locale: 'fr',
                            kind: type,
                            title: titleFrCtrl.text.trim(),
                            body: bodyFrCtrl.text.trim(),
                          );
                        }
                        if (titleArCtrl.text.trim().isNotEmpty ||
                            bodyArCtrl.text.trim().isNotEmpty) {
                          await content.putContent(
                            taskId: taskId,
                            locale: 'ar',
                            kind: type,
                            title: titleArCtrl.text.trim(),
                            body: bodyArCtrl.text.trim(),
                          );
                        }

                        // Si références fournies pour verses/surah et pas de texte saisi, stocker refs
                        final refs = refsCtrl.text.trim();
                        if ((type == 'verses' || type == 'surah') &&
                            refs.isNotEmpty) {
                          if (bodyFrCtrl.text.trim().isEmpty &&
                              titleFrCtrl.text.trim().isEmpty) {
                            await content.putContent(
                              taskId: taskId,
                              locale: 'fr',
                              kind: type,
                              title: 'Références',
                              body: refs,
                            );
                          }
                          if (bodyArCtrl.text.trim().isEmpty &&
                              titleArCtrl.text.trim().isEmpty) {
                            await content.putContent(
                              taskId: taskId,
                              locale: 'ar',
                              kind: type,
                              title: 'المراجع',
                              body: refs,
                            );
                          }
                        }

                        if (context.mounted) Navigator.of(ctx).pop();
                      },
                      child: const Text('Enregistrer'),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    ),
  );
}
