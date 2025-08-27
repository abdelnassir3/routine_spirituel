import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';
import 'package:spiritual_routines/core/services/audio_player_service.dart';
import 'package:spiritual_routines/core/services/session_service.dart';
import 'package:spiritual_routines/core/services/tts_cache_service.dart';
import 'package:spiritual_routines/core/services/content_service.dart';
import 'package:spiritual_routines/features/settings/user_settings_service.dart'
    as secure;
import 'package:spiritual_routines/features/reader/reading_prefs.dart';
import 'package:spiritual_routines/features/session/session_state.dart';
import 'package:spiritual_routines/features/settings/user_settings_service.dart';
import 'package:spiritual_routines/l10n/app_localizations.dart';

// Design system moderne
import 'package:spiritual_routines/design_system/inspired_theme.dart';
import 'package:spiritual_routines/design_system/components/modern_task_card.dart';
import 'package:spiritual_routines/design_system/components/modern_navigation.dart';
import 'package:spiritual_routines/design_system/components/modern_layouts.dart';
import 'package:spiritual_routines/design_system/animations/premium_animations.dart';

// Reader states
final readerCurrentTaskProvider = StateProvider<TaskRow?>((ref) => null);
final readerProgressProvider = StateProvider<double>((ref) => 0.0);
final readerIsPlayingProvider = StateProvider<bool>((ref) => false);
final readerLanguageProvider = StateProvider<String>((ref) => 'fr');
final readerHandsFreeProvider = StateProvider<bool>((ref) => false);
final readerShowVerseNumbersProvider = StateProvider<bool>((ref) => false);
final readerShowSeparatorsProvider = StateProvider<bool>((ref) => true);
final readerFocusModeProvider = StateProvider<bool>((ref) => false);
final readerTextScaleProvider =
    StateProvider<double>((ref) => 1.0); // 1.0 = 16sp
final readerLineHeightProvider = StateProvider<double>((ref) => 1.8);
final readerJustifyProvider = StateProvider<bool>((ref) => false);
final readerSidePaddingProvider =
    StateProvider<double>((ref) => 0.0); // extra px per side
// Direction de navigation: -1 = précédent, 1 = suivant, 0 = neutre
final readerNavDirectionProvider = StateProvider<int>((ref) => 0);

// Thème de lecture
enum ReaderThemeMode {
  system,
  sepia,
  paper,
  black,
  cream,
  sepiaSoft,
  paperCreamPlus
}

final readerThemeModeProvider =
    StateProvider<ReaderThemeMode>((ref) => ReaderThemeMode.system);
// Barre de contrôles compacte
final readerControlsCompactProvider = StateProvider<bool>((ref) => false);

class ModernReaderPage extends ConsumerStatefulWidget {
  const ModernReaderPage({super.key});

  @override
  ConsumerState<ModernReaderPage> createState() => _ModernReaderPageState();
}

class _ModernReaderPageState extends ConsumerState<ModernReaderPage>
    with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late AnimationController _playButtonController;
  late AnimationController _languageToggleController;
  bool _attemptedAutoSelect = false;

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

    _languageToggleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Charger les préférences d'affichage lecteur
    _loadReaderPrefs();

    // Appliquer préférences spécifiques (contenu > routine) quand la tâche courante change
    ref.listen<TaskRow?>(readerCurrentTaskProvider, (prev, next) async {
      final task = next;
      if (task == null) return;
      final appliedContent = await _applyPerContentPrefs(task.id);
      if (!appliedContent) {
        await _applyRoutinePrefs(task.routineId);
      }
    });
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _playButtonController.dispose();
    _languageToggleController.dispose();
    super.dispose();
  }

  Future<void> _loadReaderPrefs() async {
    try {
      final prefs = ref.read(secure.userSettingsServiceProvider);
      final focus = (await prefs.readValue('reader_focus')) == 'on';
      final numbers = (await prefs.readValue('reader_verse_numbers')) == 'on';
      final seps = (await prefs.readValue('reader_separators')) != 'off';
      final scaleStr = await prefs.readValue('reader_text_scale');
      final lhStr = await prefs.readValue('reader_line_height');
      final justify = (await prefs.readValue('reader_justify')) == 'on';
      final sidePadStr = await prefs.readValue('reader_side_padding');
      final themeStr = await prefs.readValue('reader_theme');
      if (mounted) {
        ref.read(readerFocusModeProvider.notifier).state = focus;
        ref.read(readerShowVerseNumbersProvider.notifier).state = numbers;
        ref.read(readerShowSeparatorsProvider.notifier).state = seps;
        if (scaleStr != null) {
          final v = double.tryParse(scaleStr);
          if (v != null && v > 0.6 && v < 2.0) {
            ref.read(readerTextScaleProvider.notifier).state = v;
          }
        }
        if (lhStr != null) {
          final v = double.tryParse(lhStr);
          if (v != null && v >= 1.4 && v <= 2.4) {
            ref.read(readerLineHeightProvider.notifier).state = v;
          }
        }
        ref.read(readerJustifyProvider.notifier).state = justify;
        if (sidePadStr != null) {
          final v = double.tryParse(sidePadStr);
          if (v != null && v >= 0 && v <= 32) {
            ref.read(readerSidePaddingProvider.notifier).state = v;
          }
        }
        if (themeStr != null) {
          final mode = switch (themeStr) {
            'sepia' => ReaderThemeMode.sepia,
            'sepia_soft' => ReaderThemeMode.sepiaSoft,
            'paper' => ReaderThemeMode.paper,
            'paper_cream_plus' => ReaderThemeMode.paperCreamPlus,
            'black' => ReaderThemeMode.black,
            'cream' => ReaderThemeMode.cream,
            _ => ReaderThemeMode.system,
          };
          ref.read(readerThemeModeProvider.notifier).state = mode;
        }
      }
    } catch (_) {}
  }

  Future<bool> _applyPerContentPrefs(String taskId) async {
    try {
      final storage = ref.read(secure.userSettingsServiceProvider);
      final json = await storage.readValue('reader_prefs_$taskId');
      if (json == null || json.isEmpty) return false;
      final map = <String, dynamic>{};
      try {
        map.addAll(Map<String, dynamic>.from(jsonDecode(json)));
      } catch (_) {
        return false;
      }
      if (!mounted) return false;
      // Appliquer sans persister le global
      ref.read(readerFocusModeProvider.notifier).state = (map['focus'] == true);
      ref.read(readerShowVerseNumbersProvider.notifier).state =
          (map['numbers'] == true);
      ref.read(readerShowSeparatorsProvider.notifier).state =
          (map['separators'] != false);
      final scale = (map['scale'] as num?)?.toDouble();
      if (scale != null)
        ref.read(readerTextScaleProvider.notifier).state = scale;
      final lh = (map['lineHeight'] as num?)?.toDouble();
      if (lh != null) ref.read(readerLineHeightProvider.notifier).state = lh;
      ref.read(readerJustifyProvider.notifier).state = (map['justify'] == true);
      final pad = (map['sidePadding'] as num?)?.toDouble();
      if (pad != null) ref.read(readerSidePaddingProvider.notifier).state = pad;
      final themeKey = map['theme'] as String?;
      if (themeKey != null) {
        final mode = switch (themeKey) {
          'sepia' => ReaderThemeMode.sepia,
          'sepia_soft' => ReaderThemeMode.sepiaSoft,
          'paper' => ReaderThemeMode.paper,
          'paper_cream_plus' => ReaderThemeMode.paperCreamPlus,
          'black' => ReaderThemeMode.black,
          'cream' => ReaderThemeMode.cream,
          _ => ReaderThemeMode.system,
        };
        ref.read(readerThemeModeProvider.notifier).state = mode;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _applyRoutinePrefs(String routineId) async {
    try {
      final storage = ref.read(secure.userSettingsServiceProvider);
      final json = await storage.readValue('reader_prefs_routine_$routineId');
      if (json == null || json.isEmpty) return false;
      final map = <String, dynamic>{};
      try {
        map.addAll(Map<String, dynamic>.from(jsonDecode(json)));
      } catch (_) {
        return false;
      }
      if (!mounted) return false;
      ref.read(readerFocusModeProvider.notifier).state = (map['focus'] == true);
      ref.read(readerShowVerseNumbersProvider.notifier).state =
          (map['numbers'] == true);
      ref.read(readerShowSeparatorsProvider.notifier).state =
          (map['separators'] != false);
      final scale = (map['scale'] as num?)?.toDouble();
      if (scale != null)
        ref.read(readerTextScaleProvider.notifier).state = scale;
      final lh = (map['lineHeight'] as num?)?.toDouble();
      if (lh != null) ref.read(readerLineHeightProvider.notifier).state = lh;
      ref.read(readerJustifyProvider.notifier).state = (map['justify'] == true);
      final pad = (map['sidePadding'] as num?)?.toDouble();
      if (pad != null) ref.read(readerSidePaddingProvider.notifier).state = pad;
      final themeKey = map['theme'] as String?;
      if (themeKey != null) {
        final mode = switch (themeKey) {
          'sepia' => ReaderThemeMode.sepia,
          'sepia_soft' => ReaderThemeMode.sepiaSoft,
          'paper' => ReaderThemeMode.paper,
          'paper_cream_plus' => ReaderThemeMode.paperCreamPlus,
          'black' => ReaderThemeMode.black,
          'cream' => ReaderThemeMode.cream,
          _ => ReaderThemeMode.system,
        };
        ref.read(readerThemeModeProvider.notifier).state = mode;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final routinesStream = ref.watch(routineDaoProvider).watchAll();
    final currentTask = ref.watch(readerCurrentTaskProvider);
    final progress = ref.watch(readerProgressProvider);
    final isPlaying = ref.watch(readerIsPlayingProvider);
    final language = ref.watch(readerLanguageProvider);
    final handsFree = ref.watch(readerHandsFreeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Modern Header with gradient
          SliverToBoxAdapter(
            child: _buildModernHeader(
                context, currentTask, progress, isPlaying, language),
          ),

          // Main content area
          if (currentTask != null)
            SliverToBoxAdapter(
              child:
                  _buildContentArea(context, currentTask, language, handsFree),
            )
          else
            StreamBuilder<List<RoutineRow>>(
              stream: routinesStream,
              builder: (context, snapshot) {
                final routines = snapshot.data ?? [];
                // Auto‑sélection de la première tâche disponible si rien n'est sélectionné
                if (!_attemptedAutoSelect && currentTask == null) {
                  _attemptedAutoSelect = true;
                  Future.microtask(() async {
                    try {
                      final rs =
                          await ref.read(routineDaoProvider).watchAll().first;
                      for (final r in rs) {
                        final tasks = await ref
                            .read(taskDaoProvider)
                            .watchByRoutine(r.id)
                            .first;
                        if (tasks.isNotEmpty) {
                          ref.read(readerCurrentTaskProvider.notifier).state =
                              tasks.first;
                          break;
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
                  return SliverToBoxAdapter(
                    child: _buildEmptyState(context),
                  );
                }

                return SliverToBoxAdapter(
                  child: _buildRoutineSelection(context, routines),
                );
              },
            ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),

      // Modern floating controls
      floatingActionButton: currentTask != null
          ? _buildFloatingControls(context, isPlaying, handsFree)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // Bottom Navigation moderne
      bottomNavigationBar: ModernBottomNavigation(
        currentIndex: 2, // Index pour la page lecture
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

  Widget _buildEnhancedHeader(BuildContext context, TaskRow? currentTask) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: ModernGradients.header(cs),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              // Top bar
              Row(
                children: [
                  // Enhanced back button with gradient and border for visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
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

                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lecture spirituelle',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        if (currentTask != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            currentTask.type.isNotEmpty
                                ? currentTask.type
                                : 'Session de lecture',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Settings button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () => _showReaderSettings(context),
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedContentArea(BuildContext context, TaskRow currentTask,
      String language, bool isPlaying) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
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
          // Content header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primary,
                      cs.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getTaskIcon(currentTask),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentTask.category,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    if (currentTask.notesFr?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        currentTask.notesFr!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Text content
          _buildTextContent(currentTask, language),
        ],
      ),
    );
  }

  Widget _buildModernBottomControls(BuildContext context, TaskRow? currentTask,
      bool isPlaying, String language) {
    if (currentTask == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Language toggle and text controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLanguageToggle(language),
              const SizedBox(width: 16),
              _buildQuickTextSizeControls(),
            ],
          ),

          const SizedBox(height: 20),

          // Main "Lire" button with enhanced design
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary,
                  cs.primary.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _togglePlayback(),
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isPlaying ? 'Pause' : 'Lire',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavigationButton(
                Icons.skip_previous_rounded,
                () => _previousTask(),
                'Précédent',
              ),
              const SizedBox(width: 16),
              _buildNavigationButton(
                Icons.skip_next_rounded,
                () => _nextTask(),
                'Suivant',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
      IconData icon, VoidCallback onTap, String label) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Expanded(
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: cs.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: cs.onSecondaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(
    BuildContext context,
    TaskRow? currentTask,
    double progress,
    bool isPlaying,
    String language,
  ) {
    final l10n = AppLocalizations.of(context);

    final cs = Theme.of(context).colorScheme;
    final reduce = ref.watch(reduceMotionProvider);
    final widget = Container(
      decoration: BoxDecoration(
        gradient: ModernGradients.header(cs),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              // Top bar
              Row(
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: (Theme.of(context).brightness == Brightness.light
                          ? Colors.black.withOpacity(0.2)
                          : Colors.white.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.35)),
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

                  // Title
                  Expanded(
                    child: FadeInAnimation(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lecture spirituelle',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          if (currentTask != null) ...[
                            const SizedBox(height: 6),
                            _buildHeaderContextLine(
                                context, currentTask, language),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Language toggle + quick text size controls
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLanguageToggle(language),
                      const SizedBox(width: 8),
                      _buildQuickTextSizeControls(),
                    ],
                  ),
                ],
              ),

              // Progress bar (if task is selected)
              if (currentTask != null) ...[
                const SizedBox(height: 24),
                _buildProgressBar(progress),
              ],
            ],
          ),
        ),
      ),
    );
    if (reduce) return widget;
    return FadeInAnimation(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      slideOffset: const Offset(0, -0.04),
      child: widget,
    );
  }

  Widget _buildHeaderContextLine(
      BuildContext context, TaskRow task, String language) {
    final theme = Theme.of(context);
    final categoryKey = _getCategoryFromTask(task);
    final icon =
        SpiritualCategories.icons[categoryKey] ?? Icons.auto_stories_rounded;
    final categoryLabel = _categoryLabel(categoryKey);
    final typeLabel = task.type.isNotEmpty ? task.type : task.category;

    return Row(
      children: [
        // Subtle category chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                categoryLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Dot separator
        Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
                color: Colors.white70, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        // Task type/title
        Expanded(
          child: Text(
            typeLabel,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: Colors.white.withOpacity(0.95)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection:
                language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
        const SizedBox(width: 10),
        // Progress badge N/M
        _buildProgressBadge(task),
        const SizedBox(width: 8),
        // Estimated duration badge ~X min
        _buildEstimatedDurationBadge(task, language),
      ],
    );
  }

  String _categoryLabel(String key) {
    switch (key) {
      case 'prayer':
        return 'Prière';
      case 'meditation':
        return 'Méditation';
      case 'reading':
        return 'Lecture';
      case 'dhikr':
        return 'Dhikr';
      case 'charity':
        return 'Charité';
      case 'reflection':
        return 'Réflexion';
      case 'protection':
        return 'Protection';
      case 'gratitude':
        return 'Gratitude';
      default:
        return 'Routine';
    }
  }

  Widget _buildProgressBadge(TaskRow task) {
    return FutureBuilder<List<TaskRow>>(
      future: ref.read(taskDaoProvider).watchByRoutine(task.routineId).first,
      builder: (context, snap) {
        final tasks = snap.data ?? const <TaskRow>[];
        if (tasks.isEmpty) return const SizedBox.shrink();
        final idx = tasks.indexWhere((t) => t.id == task.id);
        final n = idx >= 0 ? idx + 1 : 1;
        final m = tasks.length;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Text(
            '$n/$m',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        );
      },
    );
  }

  Widget _buildEstimatedDurationBadge(TaskRow task, String language) {
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<(String?, String?)>(
      future: ref.read(contentServiceProvider).getBuiltTextsForTask(task.id),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final ar = snap.data!.$1 ?? '';
        final fr = snap.data!.$2 ?? '';
        // Choose based on selected language; fallback to the other if empty
        final useAr = language == 'ar' ||
            (language != 'fr' && fr.isEmpty && ar.isNotEmpty);
        final text = useAr ? ar : fr;
        if (text.isEmpty) return const SizedBox.shrink();
        final words = _wordCount(text);
        final wpm = useAr ? 130 : 200;
        final seconds = (words / wpm * 60).clamp(20, 5400); // clamp 20s – 90min
        String label;
        if (seconds < 60) {
          label = '~${seconds.toInt()} s';
        } else {
          final mins = (seconds / 60).ceil();
          label = '~${mins.toString()} min';
        }
        final basis = useAr ? 'AR' : 'FR';
        return Tooltip(
          message: 'Durée estimée (basée sur texte $basis)',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        );
      },
    );
  }

  int _wordCount(String s) {
    final cleaned = s.trim();
    if (cleaned.isEmpty) return 0;
    final parts =
        cleaned.split(RegExp(r"\s+")).where((e) => e.isNotEmpty).toList();
    return parts.length;
  }

  Widget _buildLanguageToggle(String language) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageButton('FR', language == 'fr'),
          _buildLanguageButton('AR', language == 'ar'),
        ],
      ),
    );
  }

  Widget _buildQuickTextSizeControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSizeButton(Icons.remove_rounded, () => _adjustTextScale(-0.05),
              tooltip: 'Réduire la taille du texte'),
          Container(width: 1, height: 18, color: Colors.white24),
          _buildSizeButton(Icons.add_rounded, () => _adjustTextScale(0.05),
              tooltip: 'Augmenter la taille du texte'),
        ],
      ),
    );
  }

  Widget _buildSizeButton(IconData icon, VoidCallback onTap,
      {String? tooltip}) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Future<void> _adjustTextScale(double delta) async {
    final current = ref.read(readerTextScaleProvider);
    final next = (current + delta).clamp(0.9, 1.4);
    if (next == current) return;
    ref.read(readerTextScaleProvider.notifier).state = next;
    try {
      await ref
          .read(secure.userSettingsServiceProvider)
          .writeValue('reader_text_scale', next.toStringAsFixed(2));
    } catch (_) {}
  }

  Widget _buildLanguageButton(String lang, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _languageToggleController.forward().then((_) {
          ref.read(readerLanguageProvider.notifier).state = lang.toLowerCase();
          _languageToggleController.reverse();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          lang,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progression',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildContentArea(
    BuildContext context,
    TaskRow currentTask,
    String language,
    bool handsFree,
  ) {
    final focus = ref.watch(readerFocusModeProvider);
    final cs = Theme.of(context).colorScheme;
    final readerTheme = ref.watch(readerThemeModeProvider);
    // Theme variants
    Color surfaceColor = cs.surface;
    Color onSurfaceColor = cs.onSurface;
    if (readerTheme == ReaderThemeMode.sepia) {
      surfaceColor = const Color(0xFFF4ECD8);
      onSurfaceColor = const Color(0xFF4A3F2A);
    } else if (readerTheme == ReaderThemeMode.paper) {
      surfaceColor = const Color(0xFFFAFAF7);
      onSurfaceColor = const Color(0xFF1E1E1E);
    } else if (readerTheme == ReaderThemeMode.black) {
      surfaceColor = const Color(0xFF000000);
      onSurfaceColor = const Color(0xFFFFFFFF);
    } else if (readerTheme == ReaderThemeMode.cream) {
      surfaceColor = const Color(0xFFFFF8E1); // Crème légère (Amber 50)
      onSurfaceColor = const Color(0xFF4E342E); // Brun doux
    } else if (readerTheme == ReaderThemeMode.sepiaSoft) {
      surfaceColor = const Color(0xFFFFF1E0); // Sépia doux
      onSurfaceColor = const Color(0xFF4A3F2A);
    } else if (readerTheme == ReaderThemeMode.paperCreamPlus) {
      surfaceColor = const Color(0xFFFFF3CD); // Papier crème+
      onSurfaceColor = const Color(0xFF4E342E);
    }
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: focus
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          // Content header (hide in full focus for minimalism?)
          if (!focus) _buildContentHeader(currentTask, language),

          // Text content
          _buildTextContent(currentTask, language,
              overrideTextColor: onSurfaceColor),

          // Verse indicators (if applicable)
          if (!focus && _hasVerseIndicators(currentTask))
            _buildVerseIndicators(),
        ],
      ),
    );
  }

  Widget _buildContentHeader(TaskRow currentTask, String language) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.onSecondaryContainer.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTaskIcon(currentTask),
              color: cs.onSecondaryContainer,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTask.type.isNotEmpty
                      ? currentTask.type
                      : currentTask.category,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: cs.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                  textDirection:
                      language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                ),
                if (currentTask.notesFr?.isNotEmpty == true ||
                    currentTask.notesAr?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      language == 'fr'
                          ? (currentTask.notesFr ?? '')
                          : (currentTask.notesAr ?? ''),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSecondaryContainer.withOpacity(0.85),
                          ),
                      textDirection: language == 'ar'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                    ),
                  ),
              ],
            ),
          ),
          // Play/pause button
          _buildPlayButton(),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    final isPlaying = ref.watch(readerIsPlayingProvider);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _playButtonController.forward().then((_) {
          ref.read(readerIsPlayingProvider.notifier).state = !isPlaying;
          _playButtonController.reverse();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildTextContent(TaskRow currentTask, String language,
      {Color? overrideTextColor}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Consumer(
        builder: (context, ref, _) {
          final contentSvc = ref.watch(contentServiceProvider);
          final display = ref.watch(bilingualDisplayProvider);
          final justify = ref.watch(readerJustifyProvider);
          final sidePad = ref.watch(readerSidePaddingProvider);
          return FutureBuilder<(String?, String?)>(
            future: contentSvc.getBuiltTextsForTask(currentTask.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                final cs = Theme.of(context).colorScheme;
                final reduce = ref.watch(reduceMotionProvider);
                Widget skeleton = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 20,
                        width: 180,
                        decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 12),
                    Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: cs.surfaceContainer,
                            borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 8),
                    Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: cs.surfaceContainer,
                            borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 8),
                    Container(
                        height: 16,
                        width: MediaQuery.of(context).size.width * 0.6,
                        decoration: BoxDecoration(
                            color: cs.surfaceContainer,
                            borderRadius: BorderRadius.circular(6))),
                  ],
                );
                if (!reduce) {
                  skeleton = ShimmerAnimation(
                    baseColor: cs.surfaceContainer,
                    highlightColor: cs.surfaceContainerHighest,
                    child: skeleton,
                  );
                }
                return skeleton;
              }
              final data = snapshot.data;
              final ar = data?.$1;
              final fr = data?.$2;
              // Resolve which text(s) to show based on bilingual preference
              String text = '';
              final showNumbers = ref.watch(readerShowVerseNumbersProvider);
              final showSeps = ref.watch(readerShowSeparatorsProvider);
              Widget? content;
              if (display == BilingualDisplay.both) {
                final parts = <Widget>[];
                if ((ar ?? '').isNotEmpty) {
                  parts.add(_buildVersesBlock(
                      context,
                      ar!,
                      TextDirection.rtl,
                      showNumbers,
                      showSeps,
                      justify,
                      sidePad,
                      overrideTextColor));
                  parts.add(const SizedBox(height: 16));
                }
                if ((fr ?? '').isNotEmpty) {
                  parts.add(_buildVersesBlock(
                      context,
                      fr!,
                      TextDirection.ltr,
                      showNumbers,
                      showSeps,
                      justify,
                      sidePad,
                      overrideTextColor));
                }
                if (parts.isNotEmpty) {
                  content = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: parts);
                }
              } else {
                text = (display == BilingualDisplay.arOnly || language == 'ar')
                    ? (ar ?? '')
                    : (fr ?? '');
              }

              if (content == null && text.isEmpty) {
                content = ModernEmptyState(
                  icon: Icons.text_snippet_outlined,
                  title: 'Contenu non disponible',
                  description:
                      'Le contenu de cette lecture n\'est pas encore disponible.',
                  actionText: 'Éditer',
                  onAction: () {
                    context.go('/task/${currentTask.id}/content');
                  },
                );
              } else
                content ??= _buildVersesBlock(
                  context,
                  text,
                  (display == BilingualDisplay.arOnly || language == 'ar')
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  showNumbers,
                  showSeps,
                  justify,
                  sidePad,
                  overrideTextColor,
                );

              final focus = ref.watch(readerFocusModeProvider);
              final scale = ref.watch(readerTextScaleProvider);
              final lineH = ref.watch(readerLineHeightProvider);
              final signature =
                  '${display.name}|$showNumbers|$showSeps|$justify|$sidePad|$focus|$scale|$lineH|$language|${text.hashCode}|${(ar ?? '').hashCode}|${(fr ?? '').hashCode}';
              final dir = ref.watch(readerNavDirectionProvider);
              final reduce = ref.watch(reduceMotionProvider);
              return AnimatedSwitcher(
                duration: reduce
                    ? const Duration(milliseconds: 0)
                    : const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  // Slide en fonction de la direction (fade inclus)
                  if (reduce) return child;
                  final beginOffset = Offset(
                      dir > 0
                          ? 0.08
                          : dir < 0
                              ? -0.08
                              : 0.0,
                      0.0);
                  final offsetAnim =
                      Tween<Offset>(begin: beginOffset, end: Offset.zero)
                          .animate(CurvedAnimation(
                              parent: animation, curve: Curves.easeOutCubic));
                  return FadeTransition(
                      opacity: animation,
                      child:
                          SlideTransition(position: offsetAnim, child: child));
                },
                child: KeyedSubtree(key: ValueKey(signature), child: content),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVersesBlock(
    BuildContext context,
    String text,
    TextDirection direction,
    bool showNumbers,
    bool showSeparators,
    bool justify,
    double sidePadding,
    Color? overrideTextColor,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final focus = ref.watch(readerFocusModeProvider);
    final scale = ref.watch(readerTextScaleProvider);
    final lineH = ref.watch(readerLineHeightProvider);
    final fontSize = (16.0 * scale) + (focus ? 2.0 : 0.0);
    final lineHeight = lineH + (focus ? 0.2 : 0.0);
    final style = theme.textTheme.bodyLarge?.copyWith(
      height: lineHeight,
      fontSize: fontSize,
      color: overrideTextColor ?? theme.textTheme.bodyLarge?.color,
    );
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return const SizedBox.shrink();
    }
    final children = <Widget>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      children.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: direction,
        children: [
          if (showNumbers) ...[
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              margin: const EdgeInsetsDirectional.only(end: 8, top: 2),
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${i + 1}',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSecondaryContainer,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
          Expanded(
            child: SelectableText(
              line,
              textDirection: direction,
              textAlign: justify ? TextAlign.justify : TextAlign.start,
              style: style,
            ),
          ),
        ],
      ));
      if (showSeparators && i < lines.length - 1) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Divider(height: 1, thickness: 0.5, color: cs.outlineVariant),
        ));
      } else if (i < lines.length - 1) {
        children.add(const SizedBox(height: 8));
      }
    }
    final reduce = ref.watch(reduceMotionProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sidePadding),
      child: reduce
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: children)
          : StaggeredListAnimation(
              staggerDelay: const Duration(milliseconds: 40),
              children: children),
    );
  }

  Widget _buildVerseIndicators() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.format_list_numbered_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Versets avec numérotation',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineSelection(
      BuildContext context, List<RoutineRow> routines) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModernSectionHeader(
            title: 'Choisir une routine',
            subtitle: '${routines.length} routines disponibles',
          ),
          const SizedBox(height: 16),
          ModernVerticalFlow(
            animated: true,
            children: routines
                .map((routine) => ModernTaskCard(
                      title: routine.nameFr,
                      subtitle:
                          routine.nameAr.isNotEmpty ? routine.nameAr : null,
                      category: _getCategoryFromRoutine(routine),
                      showCheckbox: false,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _selectRoutine(routine);
                      },
                      priority: TaskPriority.medium,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: ModernEmptyState(
        icon: Icons.auto_stories_outlined,
        title: 'Aucune lecture disponible',
        description:
            'Ajoutez des tâches de lecture spirituelle depuis vos routines pour commencer.',
        actionText: 'Voir les routines',
        onAction: () => context.go('/routines'),
        illustration: ScaleAnimation(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: ModernGradients.primary(Theme.of(context).colorScheme),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingControls(
      BuildContext context, bool isPlaying, bool handsFree) {
    final cs = Theme.of(context).colorScheme;
    final compact = ref.watch(readerControlsCompactProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12, vertical: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
              Icons.skip_previous_rounded, () => _previousTask(),
              size: compact ? 20 : 24),
          SizedBox(width: compact ? 8 : 12),
          _buildControlButton(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              () => _togglePlayback(),
              size: 32),
          SizedBox(width: compact ? 8 : 12),
          _buildControlButton(Icons.skip_next_rounded, () => _nextTask(),
              size: compact ? 20 : 24),
          SizedBox(width: compact ? 12 : 16),
          _buildControlButton(
              handsFree ? Icons.touch_app_rounded : Icons.pan_tool_rounded,
              () => _toggleHandsFree(),
              isToggled: handsFree,
              size: compact ? 20 : 24),
          SizedBox(width: compact ? 8 : 12),
          _buildControlButton(
              Icons.settings_rounded, () => _showReaderSettings(context),
              size: compact ? 20 : 24),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon,
    VoidCallback onTap, {
    double size = 24,
    bool isToggled = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isToggled ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isToggled ? ModernColors.primary : Colors.white,
          size: size,
        ),
      ),
    );
  }

  // Helper methods
  IconData _getTaskIcon(TaskRow task) {
    final category = _getCategoryFromTask(task);
    return SpiritualCategories.icons[category] ?? Icons.auto_stories_rounded;
  }

  String _getCategoryFromTask(TaskRow task) {
    final name = (task.notesFr ?? task.category).toLowerCase();
    if (name.contains('prière') || name.contains('prayer')) return 'prayer';
    if (name.contains('coran') || name.contains('quran')) return 'reading';
    if (name.contains('dhikr') || name.contains('ذكر')) return 'dhikr';
    if (name.contains('méditation')) return 'meditation';
    if (name.contains('protection')) return 'protection';
    if (name.contains('gratitude')) return 'gratitude';
    return task.category;
  }

  String _getCategoryFromRoutine(RoutineRow routine) {
    final name = routine.nameFr.toLowerCase();
    if (name.contains('prière') || name.contains('prayer')) return 'prayer';
    if (name.contains('coran') || name.contains('quran')) return 'reading';
    if (name.contains('dhikr') || name.contains('ذكر')) return 'dhikr';
    if (name.contains('méditation')) return 'meditation';
    if (name.contains('protection')) return 'protection';
    if (name.contains('gratitude')) return 'gratitude';
    return 'custom';
  }

  bool _hasVerseIndicators(TaskRow task) {
    // Check if this is a Quran-related task
    return task.type.toLowerCase().contains('surah') ||
        task.type.toLowerCase().contains('verses') ||
        task.category.toLowerCase().contains('coran') ||
        task.category.toLowerCase().contains('quran');
  }

  // Action methods
  void _selectRoutine(RoutineRow routine) async {
    // Navigate to routine tasks and select first task for reading
    context.go('/routines/${routine.id}');

    // Alternatively, you could fetch the first task from this routine
    // For now, show a message about routine selection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Routine "${routine.nameFr}" sélectionnée')),
    );
  }

  void _togglePlayback() {
    final isPlaying = ref.read(readerIsPlayingProvider);
    ref.read(readerIsPlayingProvider.notifier).state = !isPlaying;

    // TODO: Implement TTS playback
    if (!isPlaying) {
      _startTTS();
    } else {
      _stopTTS();
    }
  }

  void _previousTask() {
    _navigateTask(relative: -1);
  }

  void _nextTask() {
    _navigateTask(relative: 1);
  }

  Future<void> _navigateTask({required int relative}) async {
    final current = ref.read(readerCurrentTaskProvider);
    if (current == null) return;
    try {
      final tasks = await ref
          .read(taskDaoProvider)
          .watchByRoutine(current.routineId)
          .first;
      if (tasks.isEmpty) return;
      final idx = tasks.indexWhere((t) => t.id == current.id);
      if (idx == -1) return;
      final nextIdx = idx + relative;
      if (nextIdx < 0 || nextIdx >= tasks.length) {
        HapticFeedback.selectionClick();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(relative < 0 ? 'Début atteint' : 'Fin atteinte')),
        );
        return;
      }
      final nextTask = tasks[nextIdx];
      // Update direction for transition
      ref.read(readerNavDirectionProvider.notifier).state = relative;
      // Update provider (AnimatedSwitcher prendra le relais pour l’animation)
      ref.read(readerCurrentTaskProvider.notifier).state = nextTask;
      HapticFeedback.lightImpact();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Navigation impossible')),
      );
    }
  }

  Future<void> _savePerContentPrefs(String taskId) async {
    final storage = ref.read(secure.userSettingsServiceProvider);
    final focus = ref.read(readerFocusModeProvider);
    final numbers = ref.read(readerShowVerseNumbersProvider);
    final seps = ref.read(readerShowSeparatorsProvider);
    final scale = ref.read(readerTextScaleProvider);
    final lh = ref.read(readerLineHeightProvider);
    final justify = ref.read(readerJustifyProvider);
    final pad = ref.read(readerSidePaddingProvider);
    final themeMode = ref.read(readerThemeModeProvider);
    final key = switch (themeMode) {
      ReaderThemeMode.sepia => 'sepia',
      ReaderThemeMode.paper => 'paper',
      ReaderThemeMode.black => 'black',
      ReaderThemeMode.cream => 'cream',
      _ => 'system',
    };
    final map = {
      'focus': focus,
      'numbers': numbers,
      'separators': seps,
      'scale': scale,
      'lineHeight': lh,
      'justify': justify,
      'sidePadding': pad,
      'theme': key,
    };
    await storage.writeValue('reader_prefs_$taskId', jsonEncode(map));
  }

  Future<void> _clearPerContentPrefs(String taskId) async {
    final storage = ref.read(secure.userSettingsServiceProvider);
    await storage.writeValue('reader_prefs_$taskId', '');
  }

  Future<void> _saveRoutinePrefs(String routineId) async {
    final storage = ref.read(secure.userSettingsServiceProvider);
    final focus = ref.read(readerFocusModeProvider);
    final numbers = ref.read(readerShowVerseNumbersProvider);
    final seps = ref.read(readerShowSeparatorsProvider);
    final scale = ref.read(readerTextScaleProvider);
    final lh = ref.read(readerLineHeightProvider);
    final justify = ref.read(readerJustifyProvider);
    final pad = ref.read(readerSidePaddingProvider);
    final themeMode = ref.read(readerThemeModeProvider);
    final key = switch (themeMode) {
      ReaderThemeMode.sepia => 'sepia',
      ReaderThemeMode.sepiaSoft => 'sepia_soft',
      ReaderThemeMode.paper => 'paper',
      ReaderThemeMode.paperCreamPlus => 'paper_cream_plus',
      ReaderThemeMode.black => 'black',
      ReaderThemeMode.cream => 'cream',
      _ => 'system',
    };
    final map = {
      'focus': focus,
      'numbers': numbers,
      'separators': seps,
      'scale': scale,
      'lineHeight': lh,
      'justify': justify,
      'sidePadding': pad,
      'theme': key,
    };
    await storage.writeValue(
        'reader_prefs_routine_$routineId', jsonEncode(map));
  }

  Future<void> _clearRoutinePrefs(String routineId) async {
    final storage = ref.read(secure.userSettingsServiceProvider);
    await storage.writeValue('reader_prefs_routine_$routineId', '');
  }

  void _toggleHandsFree() {
    final handsFree = ref.read(readerHandsFreeProvider);
    ref.read(readerHandsFreeProvider.notifier).state = !handsFree;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(handsFree
              ? 'Mode mains libres désactivé'
              : 'Mode mains libres activé')),
    );
  }

  void _startTTS() {
    // TODO: Implement TTS start
  }

  void _stopTTS() {
    // TODO: Implement TTS stop
  }

  void _showReaderSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSettingsBottomSheet(),
    );
  }

  Widget _buildSettingsBottomSheet() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Paramètres de lecture',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),

          // Settings options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Mémo par contenu
                Consumer(builder: (context, ref, _) {
                  final task = ref.watch(readerCurrentTaskProvider);
                  final canSave = task != null;
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: canSave
                                  ? () async {
                                      await _savePerContentPrefs(task.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Réglages enregistrés pour ce contenu')),
                                        );
                                      }
                                    }
                                  : null,
                              icon: const Icon(Icons.bookmark_add_outlined),
                              label: const Text('Mémoriser pour ce contenu'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: canSave
                                  ? () async {
                                      final routineId = task.routineId;
                                      await _saveRoutinePrefs(routineId);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Réglages enregistrés pour cette routine')),
                                        );
                                      }
                                    }
                                  : null,
                              icon: const Icon(
                                  Icons.collections_bookmark_outlined),
                              label: const Text('Mémoriser pour la routine'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: canSave
                                  ? () async {
                                      await _clearPerContentPrefs(task.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Préférences de ce contenu effacées')),
                                        );
                                      }
                                    }
                                  : null,
                              icon: const Icon(Icons.bookmark_remove_outlined),
                              label: const Text('Effacer préférences contenu'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextButton.icon(
                              onPressed: canSave
                                  ? () async {
                                      final routineId = task.routineId;
                                      await _clearRoutinePrefs(routineId);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Préférences de cette routine effacées')),
                                        );
                                      }
                                    }
                                  : null,
                              icon: const Icon(Icons.delete_sweep_outlined),
                              label: const Text('Effacer préférences routine'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 12),
                // Reader theme
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Thème de lecture',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Consumer(builder: (context, ref, _) {
                  final mode = ref.watch(readerThemeModeProvider);
                  return SegmentedButton<ReaderThemeMode>(
                    segments: const [
                      ButtonSegment(
                          value: ReaderThemeMode.system,
                          label: Text('Système')),
                      ButtonSegment(
                          value: ReaderThemeMode.sepia, label: Text('Sépia')),
                      ButtonSegment(
                          value: ReaderThemeMode.sepiaSoft,
                          label: Text('Sépia doux')),
                      ButtonSegment(
                          value: ReaderThemeMode.paper, label: Text('Papier')),
                      ButtonSegment(
                          value: ReaderThemeMode.paperCreamPlus,
                          label: Text('Papier crème+')),
                      ButtonSegment(
                          value: ReaderThemeMode.black, label: Text('Noir')),
                      ButtonSegment(
                          value: ReaderThemeMode.cream, label: Text('Crème')),
                    ],
                    selected: {mode},
                    onSelectionChanged: (s) async {
                      final v = s.first;
                      ref.read(readerThemeModeProvider.notifier).state = v;
                      final key = switch (v) {
                        ReaderThemeMode.sepia => 'sepia',
                        ReaderThemeMode.sepiaSoft => 'sepia_soft',
                        ReaderThemeMode.paper => 'paper',
                        ReaderThemeMode.paperCreamPlus => 'paper_cream_plus',
                        ReaderThemeMode.black => 'black',
                        ReaderThemeMode.cream => 'cream',
                        _ => 'system'
                      };
                      await ref
                          .read(secure.userSettingsServiceProvider)
                          .writeValue('reader_theme', key);
                    },
                  );
                }),
                const SizedBox(height: 12),
                // Focus mode
                Consumer(builder: (context, ref, _) {
                  final focus = ref.watch(readerFocusModeProvider);
                  return SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mode concentration'),
                    subtitle: const Text(
                        'Augmente la lisibilité et masque certains éléments'),
                    value: focus,
                    onChanged: (v) =>
                        ref.read(readerFocusModeProvider.notifier).state = v,
                  );
                }),
                const SizedBox(height: 8),
                // Bilingual display toggle
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Affichage du texte',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Consumer(builder: (context, ref, _) {
                  final mode = ref.watch(bilingualDisplayProvider);
                  return SegmentedButton<BilingualDisplay>(
                    segments: const [
                      ButtonSegment(
                          value: BilingualDisplay.frOnly, label: Text('FR')),
                      ButtonSegment(
                          value: BilingualDisplay.arOnly, label: Text('AR')),
                      ButtonSegment(
                          value: BilingualDisplay.both,
                          label: Text('Les deux')),
                    ],
                    selected: {mode},
                    onSelectionChanged: (s) => ref
                        .read(bilingualDisplayProvider.notifier)
                        .state = s.first,
                  );
                }),
                const SizedBox(height: 16),
                // Verse numbers toggle
                Consumer(builder: (context, ref, _) {
                  final v = ref.watch(readerShowVerseNumbersProvider);
                  return SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Numéroter les versets'),
                    value: v,
                    onChanged: (val) async {
                      ref.read(readerShowVerseNumbersProvider.notifier).state =
                          val;
                      await ref
                          .read(secure.userSettingsServiceProvider)
                          .writeValue(
                              'reader_verse_numbers', val ? 'on' : 'off');
                    },
                  );
                }),
                // Separators toggle
                Consumer(builder: (context, ref, _) {
                  final v = ref.watch(readerShowSeparatorsProvider);
                  return SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Séparateurs entre versets'),
                    value: v,
                    onChanged: (val) async {
                      ref.read(readerShowSeparatorsProvider.notifier).state =
                          val;
                      await ref
                          .read(secure.userSettingsServiceProvider)
                          .writeValue('reader_separators', val ? 'on' : 'off');
                    },
                  );
                }),
                // Font size slider
                Consumer(builder: (context, ref, _) {
                  final scale = ref.watch(readerTextScaleProvider);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Taille du texte',
                          style: Theme.of(context).textTheme.titleSmall),
                      Slider(
                        value: scale,
                        min: 0.9,
                        max: 1.4,
                        divisions: 10,
                        label: '${(16 * scale).toStringAsFixed(0)}sp',
                        onChanged: (v) => ref
                            .read(readerTextScaleProvider.notifier)
                            .state = v,
                        onChangeEnd: (v) async {
                          await ref
                              .read(secure.userSettingsServiceProvider)
                              .writeValue(
                                  'reader_text_scale', v.toStringAsFixed(2));
                        },
                      ),
                    ],
                  );
                }),
                // Line height slider
                Consumer(builder: (context, ref, _) {
                  final lh = ref.watch(readerLineHeightProvider);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Espacement des lignes',
                          style: Theme.of(context).textTheme.titleSmall),
                      Slider(
                        value: lh,
                        min: 1.6,
                        max: 2.2,
                        divisions: 12,
                        label: lh.toStringAsFixed(2),
                        onChanged: (v) => ref
                            .read(readerLineHeightProvider.notifier)
                            .state = v,
                        onChangeEnd: (v) async {
                          await ref
                              .read(secure.userSettingsServiceProvider)
                              .writeValue(
                                  'reader_line_height', v.toStringAsFixed(2));
                        },
                      ),
                    ],
                  );
                }),
                // Justify toggle
                Consumer(builder: (context, ref, _) {
                  final j = ref.watch(readerJustifyProvider);
                  return SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Justifier le texte'),
                    value: j,
                    onChanged: (v) async {
                      ref.read(readerJustifyProvider.notifier).state = v;
                      await ref
                          .read(secure.userSettingsServiceProvider)
                          .writeValue('reader_justify', v ? 'on' : 'off');
                    },
                  );
                }),
                // Side padding slider
                Consumer(builder: (context, ref, _) {
                  final pad = ref.watch(readerSidePaddingProvider);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Marge latérale',
                          style: Theme.of(context).textTheme.titleSmall),
                      Slider(
                        value: pad,
                        min: 0,
                        max: 32,
                        divisions: 16,
                        label: '${pad.toStringAsFixed(0)} px',
                        onChanged: (v) => ref
                            .read(readerSidePaddingProvider.notifier)
                            .state = v,
                        onChangeEnd: (v) async {
                          await ref
                              .read(secure.userSettingsServiceProvider)
                              .writeValue(
                                  'reader_side_padding', v.toStringAsFixed(0));
                        },
                      ),
                    ],
                  );
                }),
                // Reset button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      // Reset providers
                      ref.read(readerFocusModeProvider.notifier).state = false;
                      ref.read(readerShowVerseNumbersProvider.notifier).state =
                          false;
                      ref.read(readerShowSeparatorsProvider.notifier).state =
                          true;
                      ref.read(readerTextScaleProvider.notifier).state = 1.0;
                      ref.read(readerLineHeightProvider.notifier).state = 1.8;
                      ref.read(readerJustifyProvider.notifier).state = false;
                      ref.read(readerSidePaddingProvider.notifier).state = 0.0;
                      ref.read(readerThemeModeProvider.notifier).state =
                          ReaderThemeMode.system;
                      // Clear stored prefs
                      final storage =
                          ref.read(secure.userSettingsServiceProvider);
                      await storage.writeValue('reader_focus', 'off');
                      await storage.writeValue('reader_verse_numbers', 'off');
                      await storage.writeValue('reader_separators', 'on');
                      await storage.writeValue('reader_text_scale', '1.00');
                      await storage.writeValue('reader_line_height', '1.80');
                      await storage.writeValue('reader_justify', 'off');
                      await storage.writeValue('reader_side_padding', '0');
                      await storage.writeValue('reader_theme', 'system');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Affichage réinitialisé')),
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Réinitialiser l\'affichage'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.speed_rounded),
            title: const Text('Vitesse de lecture'),
            subtitle: const Text('Normal'),
            onTap: () => Navigator.pop(context),
          ),

          ListTile(
            leading: const Icon(Icons.text_fields_rounded),
            title: const Text('Taille du texte'),
            subtitle: const Text('Moyenne'),
            onTap: () => Navigator.pop(context),
          ),

          ListTile(
            leading: const Icon(Icons.record_voice_over_rounded),
            title: const Text('Voix TTS'),
            subtitle: const Text('Voix par défaut'),
            onTap: () => Navigator.pop(context),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
