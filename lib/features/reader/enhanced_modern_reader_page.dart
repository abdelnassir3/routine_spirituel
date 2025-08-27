import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spiritual_routines/features/reader/reading_session_page.dart';

import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';
import 'package:spiritual_routines/core/services/audio_player_service.dart';
import 'package:spiritual_routines/core/services/session_service.dart';
import 'package:spiritual_routines/core/services/tts_cache_service.dart';
import 'package:spiritual_routines/core/services/content_service.dart';
import 'package:spiritual_routines/core/services/progress_service.dart';
import 'package:spiritual_routines/features/settings/user_settings_service.dart'
    as secure;
import 'package:spiritual_routines/features/reader/reading_prefs.dart';
import 'package:spiritual_routines/features/session/session_state.dart';
import 'package:spiritual_routines/features/counter/smart_counter.dart';
import 'package:spiritual_routines/features/counter/hands_free_controller.dart';
import 'package:spiritual_routines/features/reader/current_progress.dart';
import 'package:spiritual_routines/features/reader/modern_reader_page.dart'
    show
        readerCurrentTaskProvider,
        readerProgressProvider,
        readerLanguageProvider;
import 'package:spiritual_routines/core/services/smart_tts_service.dart';
import 'package:spiritual_routines/core/services/user_settings_service.dart';
import 'package:spiritual_routines/l10n/app_localizations.dart';

// Design system moderne
import 'package:spiritual_routines/design_system/inspired_theme.dart';
import 'package:spiritual_routines/design_system/components/modern_task_card.dart';
import 'package:spiritual_routines/design_system/components/modern_navigation.dart';
import 'package:spiritual_routines/design_system/components/modern_layouts.dart';
import 'package:spiritual_routines/design_system/animations/premium_animations.dart';

// Import des providers de la page reader existante
import 'package:spiritual_routines/features/reader/modern_reader_page.dart';

// Providers supplémentaires pour les fonctionnalités avancées
final enhancedReaderTextScaleProvider = StateProvider<double>((ref) => 1.0);
final enhancedReaderLineHeightProvider = StateProvider<double>((ref) => 1.8);
final enhancedReaderJustifyProvider = StateProvider<bool>((ref) => false);
final enhancedReaderSidePaddingProvider = StateProvider<double>((ref) => 0.0);
final enhancedReaderFocusModeProvider = StateProvider<bool>((ref) => false);
final enhancedReaderControlsCompactProvider =
    StateProvider<bool>((ref) => false);

// Enum pour les thèmes de lecture
enum EnhancedReaderThemeMode {
  system,
  sepia,
  paper,
  black,
  cream,
  sepiaSoft,
  paperCreamPlus
}

final enhancedReaderThemeModeProvider = StateProvider<EnhancedReaderThemeMode>(
    (ref) => EnhancedReaderThemeMode.system);

class EnhancedModernReaderPage extends ConsumerStatefulWidget {
  final String? startTaskId;
  const EnhancedModernReaderPage({super.key, this.startTaskId});

  @override
  ConsumerState<EnhancedModernReaderPage> createState() =>
      _EnhancedModernReaderPageState();
}

class _EnhancedModernReaderPageState
    extends ConsumerState<EnhancedModernReaderPage>
    with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late AnimationController _playButtonController;
  bool _attemptedAutoSelect = false;
  Timer? _sessionSyncTimer;
  bool _isStartingSession = false; // Protection contre appels multiples

  @override
  void initState() {
    super.initState();

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Configurer le callback de completion de routine pour navigation automatique
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(handsFreeControllerProvider.notifier).onRoutineCompleted = () {
          _handleRoutineCompletion();
        };
      }
    });

    // Si un startTaskId est fourni, naviguer vers cette tâche
    if (widget.startTaskId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToSpecificTask(widget.startTaskId!);
      });
    }

    // La synchronisation sera gérée dans build() avec ref.listen
  }
  

  /// Démarrer le timer de synchronisation pour le mode mains libres
  void _startSessionSyncTimer(String sessionId) {
    _stopSessionSyncTimer(); // Arrêter le timer existant

    // Synchroniser toutes les 500ms pendant le mode mains libres
    _sessionSyncTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted && ref.read(handsFreeControllerProvider)) {
        _synchronizeWithSession(sessionId);
      }
    });
  }

  /// Arrêter le timer de synchronisation
  void _stopSessionSyncTimer() {
    _sessionSyncTimer?.cancel();
    _sessionSyncTimer = null;
  }

  /// Synchroniser l'interface avec l'état de la session
  Future<void> _synchronizeWithSession(String sessionId) async {
    try {
      final progress =
          await ref.read(progressServiceProvider).getCurrentProgress(sessionId);
      if (progress == null || !mounted) return;

      // Récupérer la tâche actuelle de la session
      final currentTask =
          await ref.read(taskDaoProvider).getById(progress.taskId);
      if (currentTask == null || !mounted) return;

      // Mettre à jour l'interface seulement si la tâche a changé
      final currentDisplayedTask = ref.read(readerCurrentTaskProvider);
      if (currentDisplayedTask?.id != currentTask.id) {
        // Changer la tâche affichée
        ref.read(readerCurrentTaskProvider.notifier).state = currentTask;

        // Mettre à jour le compteur avec le nombre restant de répétitions
        ref
            .read(smartCounterProvider.notifier)
            .setInitial(progress.remainingReps);

        // Mettre à jour le progress
        final progressRatio =
            progress.remainingReps / currentTask.defaultReps.toDouble();
        ref.read(readerProgressProvider.notifier).state = 1.0 - progressRatio;

        // Animation du progress
        _progressAnimationController.animateTo(1.0 - progressRatio);
      } else {
        // Même tâche, juste mettre à jour le compteur
        final currentCounter = ref.read(smartCounterProvider);
        if (currentCounter != progress.remainingReps) {
          ref
              .read(smartCounterProvider.notifier)
              .setInitial(progress.remainingReps);

          // Mettre à jour le progress
          final progressRatio =
              progress.remainingReps / currentTask.defaultReps.toDouble();
          ref.read(readerProgressProvider.notifier).state = 1.0 - progressRatio;
          _progressAnimationController.animateTo(1.0 - progressRatio);
        }
      }

      // Vérifier si la routine est terminée
      if (progress.remainingReps <= 0) {
        await _checkRoutineCompletion(sessionId);
      }
    } catch (e) {
      debugPrint('Erreur de synchronisation avec la session: $e');
    }
  }

  /// Vérifier si la routine est terminée et afficher la notification
  Future<void> _checkRoutineCompletion(String sessionId) async {
    try {
      // Attendre un peu pour être sûr que la session est bien terminée
      await Future.delayed(const Duration(milliseconds: 500));

      final progress =
          await ref.read(progressServiceProvider).getCurrentProgress(sessionId);
      if (progress != null) return; // La session n'est pas encore terminée

      // La session est terminée, arrêter le mode mains libres
      if (ref.read(handsFreeControllerProvider)) {
        await ref.read(handsFreeControllerProvider.notifier).stop();
      }

      // Afficher la notification de completion
      if (mounted) {
        await _showRoutineCompletionNotification();
      }

      // Remettre les états à zéro
      ref.read(readerProgressProvider.notifier).state = 0.0;
      _progressAnimationController.reset();
    } catch (e) {
      debugPrint('Erreur lors de la vérification de completion: $e');
    }
  }

  /// Gérer la completion automatique d'une routine (mode mains libres)
  Future<void> _handleRoutineCompletion() async {
    if (!mounted) return;

    print('🎉 Gestion de la completion automatique de routine');

    // Effet visuel de completion (comme le bouton Terminer)
    await _showCompletionEffect();

    // Attendre un petit délai supplémentaire après la fermeture du dialog
    await Future.delayed(const Duration(milliseconds: 500));

    // Naviguer vers la liste des routines
    if (mounted) {
      print('🔄 Navigation vers la liste des routines');
      context.go('/routines');
    }
  }

  /// Afficher l'effet de completion (comme quand on clique Terminer)
  Future<void> _showCompletionEffect() async {
    if (!mounted) return;

    // Vibration haptique
    HapticFeedback.heavyImpact();

    // Afficher un dialog de félicitations moderne qui se ferme automatiquement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône de succès
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 50,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            // Titre
            Text(
              'Routine terminée !',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 12),
            // Message
            Text(
              '🎉 Félicitations ! Votre routine spirituelle a été accomplie avec succès.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );

    // Fermer le dialog automatiquement après 2 secondes
    await Future.delayed(const Duration(seconds: 2));
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  /// Afficher la notification de completion de routine
  Future<void> _showRoutineCompletionNotification() async {
    final theme = Theme.of(context);

    // Vibration haptique pour succès
    HapticFeedback.heavyImpact();

    // Afficher dialog de félicitations
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green,
                    Colors.green.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.celebration_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Routine terminée !',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.1),
                    Colors.green.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 60,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Félicitations !',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vous avez terminé toutes les tâches de votre routine spirituelle.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (context.mounted) {
                context.go('/routines');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Retour aux routines',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    // Optionnel: Afficher aussi un SnackBar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.celebration_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Routine spirituelle terminée avec succès !',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
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

  Future<void> _navigateToSpecificTask(String taskId) async {
    try {
      // Récupérer la tâche spécifique
      final taskDao = ref.read(taskDaoProvider);
      final task = await taskDao.getById(taskId);

      if (task != null) {
        // Définir cette tâche comme tâche courante
        ref.read(readerCurrentTaskProvider.notifier).state = task;

        // Réinitialiser le progress pour cette tâche
        ref.read(readerProgressProvider.notifier).state = 0.0;

        // Réinitialiser le compteur pour cette tâche
        final counterNotifier = ref.read(smartCounterProvider.notifier);
        counterNotifier.setInitial(task.defaultReps);
      }
    } catch (e) {
      // En cas d'erreur, continuer avec le comportement normal
      debugPrint('Erreur lors de la navigation vers la tâche $taskId: $e');
    }
  }

  @override
  void dispose() {
    _stopSessionSyncTimer();
    _progressAnimationController.dispose();
    _playButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Les sessions sont maintenant gérées dans une page séparée (ReadingSessionPage)

    final routinesStream = ref.watch(routineDaoProvider).watchAll();
    final currentTask = ref.watch(readerCurrentTaskProvider);
    final progress = ref.watch(readerProgressProvider);
    final isPlaying = ref.watch(readerIsPlayingProvider);
    final language = ref.watch(readerLanguageProvider);
    final handsFree = ref.watch(readerHandsFreeProvider);
    final counterState = ref.watch(smartCounterProvider);
    final handsFreeMode = ref.watch(handsFreeControllerProvider);
    final theme = Theme.of(context);


    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // Header moderne avec gradient - FIXE
          _buildEnhancedHeader(
              context, currentTask, progress, isPlaying, language),

          // Contenu principal avec scroll indépendant
          if (currentTask != null) ...[
            // Zone de contenu scrollable - EXPANDABLE
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête de la tâche - FIXE dans la carte
                    _buildTaskHeader(context, currentTask, language),

                    // Contenu textuel SCROLLABLE
                    Expanded(
                      child: _buildScrollableTextContent(
                          context, currentTask, language),
                    ),
                  ],
                ),
              ),
            ),

            // Zone d'actions indépendante - FIXE EN BAS
            Transform.translate(
              offset: const Offset(0, -6),
              child: _buildActionSection(context, currentTask),
            ),
          ] else
            Expanded(
              child: StreamBuilder<List<RoutineRow>>(
                stream: routinesStream,
                builder: (context, snapshot) {
                  final routines = snapshot.data ?? [];

                  // Auto-sélection prioritaire : session active d'abord, puis première tâche disponible
                  if (!_attemptedAutoSelect && currentTask == null) {
                    _attemptedAutoSelect = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      try {
                        // D'abord vérifier s'il y a une session active
                        final sessionId = ref.read(currentSessionIdProvider);
                        if (sessionId != null && sessionId.isNotEmpty) {
                          // Charger les tâches de la session active
                          final sessionDao = ref.read(sessionDaoProvider);
                          final session = await sessionDao.getById(sessionId);
                          
                          if (session != null && mounted) {
                            final tasks = await ref.read(taskDaoProvider).watchByRoutine(session.routineId).first;
                            if (tasks.isNotEmpty && mounted) {
                              // Charger la première tâche de la routine de la session
                              final firstTask = tasks.first;
                              ref.read(readerCurrentTaskProvider.notifier).state = firstTask;
                              
                              // Initialiser le compteur
                              ref.read(smartCounterProvider.notifier).setInitial(firstTask.defaultReps);
                              
                              // Initialiser le progress
                              ref.read(readerProgressProvider.notifier).state = 0.0;
                              
                              return; // Session chargée avec succès
                            }
                          }
                        }
                        
                        // Si pas de session active ou erreur, utiliser la logique existante
                        if (routines.isNotEmpty) {
                          for (final routine in routines) {
                            final tasks = await ref
                                .read(taskDaoProvider)
                                .watchByRoutine(routine.id)
                                .first;
                            if (tasks.isNotEmpty) {
                              ref.read(readerCurrentTaskProvider.notifier).state =
                                  tasks.first;
                              break;
                            }
                          }
                        }
                      } catch (_) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Aucune tâche de lecture disponible')),
                          );
                        }
                      }
                    });
                  }

                  if (routines.isEmpty) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 120),
                        child: Transform.translate(
                          offset: const Offset(0, -20),
                          child: _buildEmptyStateCard(context),
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 120),
                      child: Transform.translate(
                        offset: const Offset(0, -20),
                        child: _buildRoutineSelectionCard(context, routines),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),

      // FAB supprimé - Actions maintenant dans la section dédiée

      // Navigation moderne
      bottomNavigationBar: ModernBottomNavigation(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/routines');
              break;
            case 2:
              break; // Déjà sur reader
          }
        },
        items: const [
          ModernNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Accueil',
          ),
          ModernNavItem(
            icon: Icons.list_alt_outlined,
            activeIcon: Icons.list_alt_rounded,
            label: 'Routines',
          ),
          ModernNavItem(
            icon: Icons.auto_stories_outlined,
            activeIcon: Icons.auto_stories_rounded,
            label: 'Lecture',
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHeader(
    BuildContext context,
    TaskRow? currentTask,
    double progress,
    bool isPlaying,
    String language,
  ) {
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
            cs.secondary.withOpacity(0.6),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(
              20), // 🎯 Uniformisé avec routine_editor_page
          child: Column(
            children: [
              // Barre de navigation
              Row(
                children: [
                  // Bouton retour moderne uniformisé
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
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white, size: 20 // 🎯 Uniformisé à 20px
                          ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Zone de titre optimisée
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre principal compact
                        Text(
                          currentTask?.notesFr?.isNotEmpty == true
                              ? currentTask!.notesFr!
                              : 'Lecture spirituelle',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20, // 🎯 Uniformisé à 20px
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Sous-titre compact - une seule ligne
                        Text(
                          currentTask != null
                              ? 'Étape ${(progress * 100).toInt()}%'
                              : 'Organisez vos pratiques spirituelles',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                            fontSize: 14, // Taille uniformisée
                            height: 1.2,
                            letterSpacing: 0.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),

                  // Zone de contrôles compacte
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Barre de progression intégrée (mini)
                      if (currentTask != null) ...[
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: progress,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      // Toggle langue compact
                      _buildCompactLanguageToggle(currentTask, language),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard(
      BuildContext context, TaskRow task, String language) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la tâche
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.notesFr?.isNotEmpty == true
                          ? task.notesFr!
                          : 'Rappel de gratitude',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      language == 'ar' ? 'العربية' : 'Français',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'x${task.defaultReps}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Zone de contenu de lecture avec texte réel
          _buildTextContent(context, task, language),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune routine disponible',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez une routine pour commencer votre lecture spirituelle',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go('/routines'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Créer une routine'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineSelectionCard(
      BuildContext context, List<RoutineRow> routines) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Choisir une routine',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...routines
              .take(3)
              .map((routine) => _buildRoutineItem(context, routine)),
          if (routines.length > 3) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () => context.go('/routines'),
                child: Text('Voir toutes les routines (${routines.length})'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoutineItem(BuildContext context, RoutineRow routine) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final tasks =
              await ref.read(taskDaoProvider).watchByRoutine(routine.id).first;
          if (tasks.isNotEmpty) {
            ref.read(readerCurrentTaskProvider.notifier).state = tasks.first;
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.2),
                      theme.colorScheme.primary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.nameFr,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Routine de lecture',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(String language) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final newLang = language == 'fr' ? 'ar' : 'fr';
            ref.read(readerLanguageProvider.notifier).state = newLang;
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              language == 'fr' ? 'FR' : 'ع',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Sélecteur de langue intelligent qui s'adapte au contenu affiché
  /// 🎨 Version compacte du toggle langue pour header unifié
  Widget _buildCompactLanguageToggle(TaskRow? currentTask, String language) {
    if (currentTask == null) {
      return _buildCompactLanguageToggleBase(language);
    }

    return FutureBuilder<(String?, String?)>(
      future:
          ref.read(contentServiceProvider).getBuiltTextsForTask(currentTask.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCompactLanguageToggleBase(language);
        }

        final (textFr, textAr) = snapshot.data ?? (null, null);
        final currentText = language == 'ar' ? textAr : textFr;
        final actuallyArabic =
            currentText != null ? _isArabicText(currentText) : false;
        final displayLanguage = actuallyArabic ? 'ar' : 'fr';

        return Container(
          width: 48,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final newLang = language == 'fr' ? 'ar' : 'fr';
                ref.read(readerLanguageProvider.notifier).state = newLang;
              },
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Text(
                  displayLanguage == 'ar' ? 'AR' : 'FR',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactLanguageToggleBase(String language) {
    return Container(
      width: 48,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final newLang = language == 'fr' ? 'ar' : 'fr';
            ref.read(readerLanguageProvider.notifier).state = newLang;
          },
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              language == 'ar' ? 'AR' : 'FR',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmartLanguageToggle(TaskRow? currentTask, String language) {
    if (currentTask == null) {
      return _buildLanguageToggle(language);
    }

    return FutureBuilder<(String?, String?)>(
      future:
          ref.read(contentServiceProvider).getBuiltTextsForTask(currentTask.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLanguageToggle(language);
        }

        final (textFr, textAr) = snapshot.data ?? (null, null);
        final currentText = language == 'ar' ? textAr : textFr;

        // Détecter automatiquement la langue du contenu affiché
        final actuallyArabic =
            currentText != null ? _isArabicText(currentText) : false;
        final displayLanguage = actuallyArabic ? 'ar' : 'fr';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final newLang = language == 'fr' ? 'ar' : 'fr';
                ref.read(readerLanguageProvider.notifier).state = newLang;
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indicateur de langue basé sur le contenu réel
                    Text(
                      displayLanguage == 'ar' ? 'AR' : 'FR',
                      style: TextStyle(
                        color: displayLanguage != language
                            ? Colors.orange
                                .shade200 // Couleur différente si incohérence
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    // Petit indicateur si détection automatique
                    if (displayLanguage != language) ...[
                      const SizedBox(width: 2),
                      Icon(
                        Icons.auto_fix_high,
                        size: 10,
                        color: Colors.orange.shade200,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () {
          // Ouvrir les paramètres de lecture
        },
        icon: const Icon(
          Icons.tune_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildProgressBarModern(double progress) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progression',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Méthode _buildModernFAB supprimée - Actions maintenant dans _buildActionSection

  /// En-tête de la tâche (fixe dans la carte)
  Widget _buildTaskHeader(BuildContext context, TaskRow task, String language) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.notesFr?.isNotEmpty == true
                      ? task.notesFr!
                      : 'Rappel de gratitude',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  language == 'ar' ? 'العربية' : 'Français',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'x${task.defaultReps}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Contenu textuel scrollable indépendamment
  Widget _buildScrollableTextContent(
      BuildContext context, TaskRow task, String language) {
    final theme = Theme.of(context);

    return FutureBuilder<(String?, String?)>(
      future: ref.read(contentServiceProvider).getBuiltTextsForTask(task.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final (textFr, textAr) = snapshot.data ?? (null, null);
        final currentText = language == 'ar' ? textAr : textFr;

        // DÉTECTION AUTOMATIQUE: Analyser la langue réelle du contenu affiché
        final actuallyArabic =
            currentText != null ? _isArabicText(currentText) : false;
        final isArabic =
            actuallyArabic; // Utiliser la langue détectée automatiquement

        if (currentText == null || currentText.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Contenu non défini',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez du contenu pour commencer la lecture',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.push('/task/${task.id}/content'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Ajouter du contenu'),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête avec compteur de répétitions
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.repeat_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.defaultReps}x répétitions',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isArabic ? 'عربي' : 'Français',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenu textuel
                _buildTextWithVerseNumbers(
                  currentText,
                  theme.textTheme.bodyLarge?.copyWith(
                        fontFamily: isArabic ? 'NotoNaskhArabic' : 'Inter',
                        fontSize: 18,
                        height: isArabic ? 2.0 : 1.6,
                        letterSpacing: isArabic ? 0 : 0.2,
                      ) ??
                      const TextStyle(),
                  isArabic,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionSection(BuildContext context, TaskRow task) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Bouton Modifier - Design épuré
          Expanded(
            flex: 2,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(
                  color: cs.primary.withOpacity(0.3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    cs.primary.withOpacity(0.05),
                    cs.primary.withOpacity(0.02),
                  ],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/task/${task.id}/content'),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Modifier',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Bouton Commencer - Design principal
          Expanded(
            flex: 3,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary,
                    cs.primary.withOpacity(0.9),
                    cs.secondary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _navigateToReadingSession(task),
                  borderRadius: BorderRadius.circular(18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Commencer',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(
      BuildContext context, TaskRow task, String language) {
    final theme = Theme.of(context);

    return FutureBuilder<(String?, String?)>(
      future: ref.read(contentServiceProvider).getBuiltTextsForTask(task.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            height: 400,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final (textFr, textAr) = snapshot.data ?? (null, null);
        final currentText = language == 'ar' ? textAr : textFr;

        // DÉTECTION AUTOMATIQUE: Analyser la langue réelle du contenu affiché
        final actuallyArabic =
            currentText != null ? _isArabicText(currentText) : false;
        final isArabic =
            actuallyArabic; // Utiliser la langue détectée automatiquement

        if (currentText == null || currentText.isEmpty) {
          return Container(
            width: double.infinity,
            height: 400,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Contenu non défini',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez du contenu pour commencer la lecture',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.push('/task/${task.id}/content'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Ajouter du contenu'),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 400),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête avec compteur de répétitions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.repeat_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.defaultReps}x répétitions',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isArabic ? 'عربي' : 'Français',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Contenu textuel
                _buildTextWithVerseNumbers(
                  currentText,
                  theme.textTheme.bodyLarge?.copyWith(
                        fontFamily: isArabic ? 'NotoNaskhArabic' : 'Inter',
                        fontSize: 18,
                        height: isArabic ? 2.0 : 1.6,
                        letterSpacing: isArabic ? 0 : 0.2,
                      ) ??
                      const TextStyle(),
                  isArabic,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Démarrer une session de lecture
  Future<void> _navigateToReadingSession(TaskRow task) async {
    // Protection contre les appels multiples
    if (_isStartingSession) {
      // print('⚠️ Démarrage de session déjà en cours, ignoré');
      return;
    }
    
    _isStartingSession = true;
    try {
      // IMPORTANT: Récupérer la routine à laquelle appartient la tâche sélectionnée
      String routineId = task.routineId;
      
      // Vérifier que la routine existe
      final allRoutines = await ref.read(routineDaoProvider).watchAll().first;
      final routine = allRoutines.where((r) => r.id == routineId).firstOrNull;
      if (routine == null) {
        // print('⚠️ Routine ${task.routineId} non trouvée, création d\'une routine temporaire');
        // Créer une routine temporaire si la routine n'existe pas
        routineId = DateTime.now().millisecondsSinceEpoch.toString();

        // Créer ou utiliser un thème par défaut
        final themes = await ref.read(themeDaoProvider).watchAll().first;
        String themeId;
        if (themes.isNotEmpty) {
          themeId = themes.first.id;
        } else {
          // Créer un thème par défaut
          themeId = 'default-theme';
          await ref.read(themeDaoProvider).upsertTheme(
                ThemesCompanion.insert(
                  id: themeId,
                  nameFr: 'Lecture spirituelle',
                  nameAr: 'القراءة الروحية',
                  frequency: 'daily',
                ),
              );
        }

        await ref.read(routineDaoProvider).upsertRoutine(
              RoutinesCompanion.insert(
                id: routineId,
                themeId: themeId,
                nameFr: 'Lecture temporaire',
                nameAr: 'قراءة مؤقتة',
              ),
            );
      } else {
        // print('✅ Routine ${task.routineId} trouvée: ${routine.nameFr}');
      }

      // IMPORTANT: Terminer l'ancienne session active avant de démarrer une nouvelle
      final currentSessionId = ref.read(currentSessionIdProvider);
      if (currentSessionId != null && currentSessionId.isNotEmpty) {
        // print('🔄 Terminaison de l\'ancienne session: $currentSessionId');
        try {
          // Arrêter le mode mains libres s'il est actif
          if (ref.read(handsFreeControllerProvider)) {
            await ref.read(handsFreeControllerProvider.notifier).stop();
          }
          // Terminer l'ancienne session
          await ref.read(sessionServiceProvider).completeSession(currentSessionId);
        } catch (e) {
          print('⚠️ Erreur lors de la terminaison de l\'ancienne session: $e');
        }
      }
      
      // Démarrer la nouvelle session à la tâche spécifique
      // print('🚀 Démarrage de la routine: $routineId avec tâche: ${task.id}');
      // print('📋 Tâche sélectionnée: ${task.notesFr ?? task.notesAr ?? task.category}');
      final sessionId =
          await ref.read(sessionServiceProvider).startRoutine(routineId, startTaskId: task.id);
      
      // IMPORTANT: Mettre à jour le provider de session courante
      ref.read(currentSessionIdProvider.notifier).state = sessionId;
      // print('✅ Nouvelle session créée: $sessionId pour tâche: ${task.id}');

      // Initialiser le compteur avec le nombre de répétitions
      ref.read(smartCounterProvider.notifier).setInitial(task.defaultReps);

      // Naviguer vers la page de session de lecture
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReadingSessionPage(
              sessionId: sessionId,
              task: task,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du démarrage: $e')),
        );
      }
    } finally {
      _isStartingSession = false;
    }
  }

  /// Interface de lecture avec session active

  /// Contenu textuel pour session active

  // Méthode obsolète - session gérée dans ReadingSessionPage

  // Méthodes obsolètes - session gérée dans ReadingSessionPage

  /// Aller à la tâche précédente dans la routine
  Future<void> _goToPrevious() async {
    final currentTask = ref.read(readerCurrentTaskProvider);
    if (currentTask == null) return;

    try {
      // Récupérer toutes les tâches de la routine courante
      final tasks = await ref
          .read(taskDaoProvider)
          .watchByRoutine(currentTask.routineId)
          .first;
      if (tasks.length <= 1) return; // Pas de navigation possible

      // Trouver l'index de la tâche actuelle
      final currentIndex =
          tasks.indexWhere((task) => task.id == currentTask.id);
      if (currentIndex <= 0) return; // Déjà à la première tâche

      // Naviguer vers la tâche précédente
      final previousTask = tasks[currentIndex - 1];
      ref.read(readerCurrentTaskProvider.notifier).state = previousTask;

      // Réinitialiser le compteur pour la nouvelle tâche
      ref
          .read(smartCounterProvider.notifier)
          .setInitial(previousTask.defaultReps);

      // Réinitialiser le progress
      ref.read(readerProgressProvider.notifier).state = 0.0;

      HapticFeedback.lightImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Tâche précédente: ${previousTask.notesFr ?? "Rappel de gratitude"}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la navigation: $e')),
        );
      }
    }
  }

  /// Aller à la tâche suivante dans la routine
  Future<void> _goToNext() async {
    final currentTask = ref.read(readerCurrentTaskProvider);
    if (currentTask == null) return;

    try {
      // Récupérer toutes les tâches de la routine courante
      final tasks = await ref
          .read(taskDaoProvider)
          .watchByRoutine(currentTask.routineId)
          .first;
      if (tasks.length <= 1) return; // Pas de navigation possible

      // Trouver l'index de la tâche actuelle
      final currentIndex =
          tasks.indexWhere((task) => task.id == currentTask.id);
      if (currentIndex >= tasks.length - 1) return; // Déjà à la dernière tâche

      // Naviguer vers la tâche suivante
      final nextTask = tasks[currentIndex + 1];
      ref.read(readerCurrentTaskProvider.notifier).state = nextTask;

      // Réinitialiser le compteur pour la nouvelle tâche
      ref.read(smartCounterProvider.notifier).setInitial(nextTask.defaultReps);

      // Réinitialiser le progress
      ref.read(readerProgressProvider.notifier).state = 0.0;

      HapticFeedback.lightImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Tâche suivante: ${nextTask.notesFr ?? "Rappel de gratitude"}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la navigation: $e')),
        );
      }
    }
  }

  /// Vérifier s'il y a une tâche précédente
  Future<bool> _hasPreviousTask() async {
    final currentTask = ref.read(readerCurrentTaskProvider);
    if (currentTask == null) return false;

    try {
      final tasks = await ref
          .read(taskDaoProvider)
          .watchByRoutine(currentTask.routineId)
          .first;
      final currentIndex =
          tasks.indexWhere((task) => task.id == currentTask.id);
      return currentIndex > 0;
    } catch (e) {
      return false;
    }
  }

  /// Vérifier s'il y a une tâche suivante
  Future<bool> _hasNextTask() async {
    final currentTask = ref.read(readerCurrentTaskProvider);
    if (currentTask == null) return false;

    try {
      final tasks = await ref
          .read(taskDaoProvider)
          .watchByRoutine(currentTask.routineId)
          .first;
      final currentIndex =
          tasks.indexWhere((task) => task.id == currentTask.id);
      return currentIndex < tasks.length - 1;
    } catch (e) {
      return false;
    }
  }

  /// Détecter automatiquement si un texte est en arabe
  bool _isArabicText(String text) {
    if (text.trim().isEmpty) return false;

    int arabicChars = 0;
    int totalChars = 0;

    for (int i = 0; i < text.length; i++) {
      final char = text.codeUnitAt(i);
      if (char >= 0x0600 && char <= 0x06FF) arabicChars++; // Bloc Unicode arabe
      if (char > 32) totalChars++; // Ignorer les espaces
    }

    return totalChars > 0 && (arabicChars / totalChars) > 0.5;
  }

  /// Lire le texte avec détection automatique de langue
  Future<void> _playCurrentText(TaskRow task, String interfaceLanguage) async {
    try {
      // Récupérer le contenu textuel des deux langues
      final (textFr, textAr) =
          await ref.read(contentServiceProvider).getBuiltTextsForTask(task.id);

      // Déterminer quel texte utiliser selon l'interface
      final currentText = interfaceLanguage == 'ar' ? textAr : textFr;

      if (currentText == null || currentText.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucun contenu à lire')),
          );
        }
        return;
      }

      // DÉTECTION AUTOMATIQUE: Analyser le contenu réel du texte
      final isActuallyArabic = _isArabicText(currentText);

      // Obtenir les préférences TTS selon la LANGUE RÉELLE du contenu
      final coreSettings = ref.read(userSettingsServiceProvider);
      final ttsLang = isActuallyArabic
          ? await coreSettings
              .getTtsPreferredAr() // Voix arabe pour texte arabe
          : await coreSettings
              .getTtsPreferredFr(); // Voix française pour texte français
      final ttsSpeed = await coreSettings.getTtsSpeed();
      final ttsPitch = await coreSettings.getTtsPitch();

      // Vérifier le provider choisi
      final securePrefs = ref.read(secure.userSettingsServiceProvider);
      final provider = await securePrefs.readValue('tts_preferred_provider') ?? 'coqui';
      
      // Afficher un indicateur de chargement pour Coqui
      if (provider == 'coqui' && mounted) {
        // Vérifier si le texte est en cache (simplification: texte court = probablement en cache)
        final isFirstTime = currentText.length > 50; // Heuristique simple
        
        if (isFirstTime) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Première synthèse Coqui en cours... (3-10s)\nLes prochaines fois seront instantanées !',
                    ),
                  ),
                ],
              ),
              duration: Duration(seconds: 10),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
      
      // Lancer la lecture TTS avec la langue détectée automatiquement
      final tts = ref.read(audioTtsServiceProvider);
      await tts.playText(
        currentText,
        voice: ttsLang,
        speed: ttsSpeed,
        pitch: ttsPitch,
      );

      if (mounted) {
        // Masquer le message de chargement si présent
        ScaffoldMessenger.of(context).clearSnackBars();
        
        // Afficher le message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider == 'coqui'
                ? (isActuallyArabic 
                    ? 'Lecture Coqui en arabe...'
                    : 'Lecture Coqui en français...')
                : (isActuallyArabic
                    ? 'Lecture système en arabe...'
                    : 'Lecture système en français...'),
            ),
            backgroundColor: provider == 'coqui' ? Colors.green : null,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de lecture: $e')),
        );
      }
    }
  }

  // ===== NOUVELLES FONCTIONNALITÉS =====

  /// Contrôles de texte rapides (taille, mode focus)
  Widget _buildQuickTextControls(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = ref.watch(enhancedReaderTextScaleProvider);
    final focusMode = ref.watch(enhancedReaderFocusModeProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Mode focus
          Container(
            decoration: BoxDecoration(
              color: focusMode
                  ? theme.colorScheme.primary.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () {
                ref.read(enhancedReaderFocusModeProvider.notifier).state =
                    !focusMode;
                HapticFeedback.lightImpact();
              },
              icon: Icon(
                focusMode
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: focusMode
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                size: 20,
              ),
              tooltip: 'Mode focus',
            ),
          ),

          const SizedBox(width: 8),

          // Contrôles taille texte
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextSizeButton(
                icon: Icons.text_decrease_rounded,
                onTap: () => _adjustTextScale(-0.1),
                enabled: textScale > 0.8,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(textScale * 100).round()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              _buildTextSizeButton(
                icon: Icons.text_increase_rounded,
                onTap: () => _adjustTextScale(0.1),
                enabled: textScale < 1.6,
              ),
            ],
          ),

          const Spacer(),

          // Indicateur du thème actuel
          Consumer(builder: (context, ref, _) {
            final readerTheme = ref.watch(enhancedReaderThemeModeProvider);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getReaderThemeBackgroundColor(readerTheme, theme),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Text(
                _getReaderThemeName(readerTheme),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getReaderThemeTextColor(readerTheme, theme),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Bouton de contrôle de taille de texte
  Widget _buildTextSizeButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: enabled ? theme.colorScheme.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        onPressed: enabled ? onTap : null,
        icon: Icon(
          icon,
          size: 16,
          color: enabled
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withOpacity(0.3),
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Ajuster la taille du texte
  Future<void> _adjustTextScale(double delta) async {
    final current = ref.read(enhancedReaderTextScaleProvider);
    final newScale = (current + delta).clamp(0.8, 1.6);
    ref.read(enhancedReaderTextScaleProvider.notifier).state = newScale;
    HapticFeedback.selectionClick();

    // TODO: Sauvegarder la préférence
    try {
      await ref
          .read(secure.userSettingsServiceProvider)
          .writeValue('enhanced_reader_text_scale', newScale.toString());
    } catch (e) {
      // Ignore silently
    }
  }

  /// Afficher le bottom sheet de paramètres avancés
  void _showEnhancedSettingsBottomSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEnhancedSettingsBottomSheet(),
    );
  }

  /// Bottom sheet de paramètres avancés
  Widget _buildEnhancedSettingsBottomSheet() {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Titre
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Paramètres de lecture',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          // Contenu
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Thèmes
                  _buildSettingSection(
                    title: 'Thèmes de lecture',
                    icon: Icons.palette_rounded,
                    child: _buildThemeSelector(),
                  ),

                  const SizedBox(height: 24),

                  // Section Texte
                  _buildSettingSection(
                    title: 'Personnalisation du texte',
                    icon: Icons.text_fields_rounded,
                    child: _buildTextCustomization(),
                  ),

                  const SizedBox(height: 24),

                  // Section Interface
                  _buildSettingSection(
                    title: 'Interface',
                    icon: Icons.settings_rounded,
                    child: _buildInterfaceSettings(),
                  ),

                  const SizedBox(height: 24),

                  // Boutons d'action
                  _buildActionButtons(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section de paramètres avec titre
  Widget _buildSettingSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  /// Sélecteur de thèmes
  Widget _buildThemeSelector() {
    final theme = Theme.of(context);

    return Consumer(builder: (context, ref, _) {
      final currentTheme = ref.watch(enhancedReaderThemeModeProvider);

      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: EnhancedReaderThemeMode.values.map((themeMode) {
          final isSelected = currentTheme == themeMode;

          return GestureDetector(
            onTap: () {
              ref.read(enhancedReaderThemeModeProvider.notifier).state =
                  themeMode;
              HapticFeedback.selectionClick();
            },
            child: Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: _getReaderThemeBackgroundColor(themeMode, theme),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getReaderThemeTextColor(themeMode, theme),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getReaderThemeName(themeMode),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: _getReaderThemeTextColor(themeMode, theme),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  /// Personnalisation du texte
  Widget _buildTextCustomization() {
    return Consumer(builder: (context, ref, _) {
      final textScale = ref.watch(enhancedReaderTextScaleProvider);
      final lineHeight = ref.watch(enhancedReaderLineHeightProvider);
      final justify = ref.watch(enhancedReaderJustifyProvider);
      final sidePadding = ref.watch(enhancedReaderSidePaddingProvider);

      return Column(
        children: [
          // Taille du texte
          _buildSliderSetting(
            label: 'Taille du texte',
            value: textScale,
            min: 0.8,
            max: 1.6,
            divisions: 16,
            displayValue: '${(textScale * 100).round()}%',
            onChanged: (value) {
              ref.read(enhancedReaderTextScaleProvider.notifier).state = value;
            },
          ),

          const SizedBox(height: 16),

          // Hauteur de ligne
          _buildSliderSetting(
            label: 'Hauteur de ligne',
            value: lineHeight,
            min: 1.2,
            max: 2.4,
            divisions: 12,
            displayValue: '${lineHeight.toStringAsFixed(1)}x',
            onChanged: (value) {
              ref.read(enhancedReaderLineHeightProvider.notifier).state = value;
            },
          ),

          const SizedBox(height: 16),

          // Padding latéral
          _buildSliderSetting(
            label: 'Espacement latéral',
            value: sidePadding,
            min: 0.0,
            max: 40.0,
            divisions: 20,
            displayValue: '${sidePadding.toInt()}px',
            onChanged: (value) {
              ref.read(enhancedReaderSidePaddingProvider.notifier).state =
                  value;
            },
          ),

          const SizedBox(height: 16),

          // Justification
          _buildSwitchSetting(
            title: 'Justifier le texte',
            subtitle: 'Alignement justifié',
            value: justify,
            onChanged: (value) {
              ref.read(enhancedReaderJustifyProvider.notifier).state = value;
            },
          ),
        ],
      );
    });
  }

  /// Paramètres d'interface
  Widget _buildInterfaceSettings() {
    return Consumer(builder: (context, ref, _) {
      final focusMode = ref.watch(enhancedReaderFocusModeProvider);
      final compactControls = ref.watch(enhancedReaderControlsCompactProvider);

      return Column(
        children: [
          _buildSwitchSetting(
            title: 'Mode focus',
            subtitle: 'Interface épurée sans distractions',
            value: focusMode,
            onChanged: (value) {
              ref.read(enhancedReaderFocusModeProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: 16),
          _buildSwitchSetting(
            title: 'Contrôles compacts',
            subtitle: 'Interface minimaliste',
            value: compactControls,
            onChanged: (value) {
              ref.read(enhancedReaderControlsCompactProvider.notifier).state =
                  value;
            },
          ),
        ],
      );
    });
  }

  /// Slider de paramètre
  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayValue,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor:
                theme.colorScheme.primaryContainer.withOpacity(0.3),
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  /// Switch de paramètre
  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  /// Boutons d'action du bottom sheet
  Widget _buildActionButtons() {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetAllSettings,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réinitialiser'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: _saveAllSettings,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Sauvegarder'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Réinitialiser tous les paramètres
  void _resetAllSettings() {
    ref.read(enhancedReaderTextScaleProvider.notifier).state = 1.0;
    ref.read(enhancedReaderLineHeightProvider.notifier).state = 1.8;
    ref.read(enhancedReaderJustifyProvider.notifier).state = false;
    ref.read(enhancedReaderSidePaddingProvider.notifier).state = 0.0;
    ref.read(enhancedReaderFocusModeProvider.notifier).state = false;
    ref.read(enhancedReaderControlsCompactProvider.notifier).state = false;
    ref.read(enhancedReaderThemeModeProvider.notifier).state =
        EnhancedReaderThemeMode.system;

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paramètres réinitialisés')),
    );
  }

  /// Sauvegarder tous les paramètres
  Future<void> _saveAllSettings() async {
    try {
      final prefs = ref.read(secure.userSettingsServiceProvider);

      await prefs.writeValue('enhanced_reader_text_scale',
          ref.read(enhancedReaderTextScaleProvider).toString());
      await prefs.writeValue('enhanced_reader_line_height',
          ref.read(enhancedReaderLineHeightProvider).toString());
      await prefs.writeValue('enhanced_reader_justify',
          ref.read(enhancedReaderJustifyProvider).toString());
      await prefs.writeValue('enhanced_reader_side_padding',
          ref.read(enhancedReaderSidePaddingProvider).toString());
      await prefs.writeValue('enhanced_reader_focus_mode',
          ref.read(enhancedReaderFocusModeProvider).toString());
      await prefs.writeValue('enhanced_reader_compact_controls',
          ref.read(enhancedReaderControlsCompactProvider).toString());
      await prefs.writeValue('enhanced_reader_theme_mode',
          ref.read(enhancedReaderThemeModeProvider).name);

      HapticFeedback.lightImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paramètres sauvegardés')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de sauvegarde: $e')),
        );
      }
    }
  }

  // ===== UTILITAIRES POUR THÈMES =====

  /// Obtenir la couleur de fond pour un thème
  Color _getReaderThemeBackgroundColor(
      EnhancedReaderThemeMode themeMode, ThemeData theme) {
    switch (themeMode) {
      case EnhancedReaderThemeMode.system:
        return theme.colorScheme.surface;
      case EnhancedReaderThemeMode.sepia:
        return const Color(0xFFF4E9D3);
      case EnhancedReaderThemeMode.paper:
        return const Color(0xFFFFFEF7);
      case EnhancedReaderThemeMode.black:
        return const Color(0xFF1B1B1B);
      case EnhancedReaderThemeMode.cream:
        return const Color(0xFFFDF6E3);
      case EnhancedReaderThemeMode.sepiaSoft:
        return const Color(0xFFF7F0E8);
      case EnhancedReaderThemeMode.paperCreamPlus:
        return const Color(0xFFFBF8F0);
    }
  }

  /// Obtenir la couleur de texte pour un thème
  Color _getReaderThemeTextColor(
      EnhancedReaderThemeMode themeMode, ThemeData theme) {
    switch (themeMode) {
      case EnhancedReaderThemeMode.system:
        return theme.colorScheme.onSurface;
      case EnhancedReaderThemeMode.sepia:
        return const Color(0xFF5D4E37);
      case EnhancedReaderThemeMode.paper:
        return const Color(0xFF2E2E2E);
      case EnhancedReaderThemeMode.black:
        return const Color(0xFFE8E8E8);
      case EnhancedReaderThemeMode.cream:
        return const Color(0xFF586E75);
      case EnhancedReaderThemeMode.sepiaSoft:
        return const Color(0xFF4A4A4A);
      case EnhancedReaderThemeMode.paperCreamPlus:
        return const Color(0xFF3C3C3C);
    }
  }

  /// Obtenir le nom d'affichage du thème
  String _getReaderThemeName(EnhancedReaderThemeMode themeMode) {
    switch (themeMode) {
      case EnhancedReaderThemeMode.system:
        return 'Système';
      case EnhancedReaderThemeMode.sepia:
        return 'Sepia';
      case EnhancedReaderThemeMode.paper:
        return 'Papier';
      case EnhancedReaderThemeMode.black:
        return 'Noir';
      case EnhancedReaderThemeMode.cream:
        return 'Crème';
      case EnhancedReaderThemeMode.sepiaSoft:
        return 'Sépia doux';
      case EnhancedReaderThemeMode.paperCreamPlus:
        return 'Papier+';
    }
  }

  /// Widget pour afficher les numéros de verset en cercle
  Widget _buildVerseNumberCircle(String verseReference) {
    final theme = Theme.of(context);

    // Ajuster la taille du cercle selon la longueur du texte
    final isLongReference = verseReference.length > 2;
    final circleSize = isLongReference ? 32.0 : 24.0;
    final fontSize = isLongReference ? 9.0 : 11.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary.withOpacity(0.15),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          verseReference,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  /// Convertit le texte avec marqueurs en RichText avec cercles de verset
  // Helper function to handle line breaks in text
  List<InlineSpan> _buildTextSpansWithLineBreaks(String text, TextStyle style) {
    final spans = <InlineSpan>[];
    final lines = text.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].isNotEmpty) {
        spans.add(TextSpan(
          text: lines[i],
          style: style,
        ));
      }
      // Add line break except for the last line
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }
    
    return spans;
  }

  Widget _buildTextWithVerseNumbers(
      String text, TextStyle style, bool isArabic) {
    // Support pour les deux formats : {{V:verset}} et {{V:sourate:verset}}
    final versePattern = RegExp(r'\{\{V:(\d+)(?::(\d+))?\}\}');
    final matches = versePattern.allMatches(text);

    final spans = <InlineSpan>[];
    int lastIndex = 0;

    for (final match in versePattern.allMatches(text)) {
      // Ajouter le texte avant le marqueur avec support des sauts de ligne
      if (match.start > lastIndex) {
        final textBeforeMarker = text.substring(lastIndex, match.start);
        spans.addAll(_buildTextSpansWithLineBreaks(textBeforeMarker, style));
      }

      // Parser les numéros de sourate et verset
      final group1 = match.group(1);
      final group2 = match.group(2);

      String verseReference;
      if (group2 != null) {
        // Format {{V:sourate:verset}}
        verseReference = '$group1:$group2';
      } else {
        // Format ancien {{V:verset}} - pour compatibilité
        verseReference = group1 ?? '';
      }

      if (verseReference.isNotEmpty) {
        spans.add(WidgetSpan(
          child: _buildVerseNumberCircle(verseReference),
          alignment: PlaceholderAlignment.middle,
        ));
      }

      lastIndex = match.end;
    }

    // Ajouter le texte restant avec support des sauts de ligne
    if (lastIndex < text.length) {
      final remainingText = text.substring(lastIndex);
      spans.addAll(_buildTextSpansWithLineBreaks(remainingText, style));
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
    );
  }
}
