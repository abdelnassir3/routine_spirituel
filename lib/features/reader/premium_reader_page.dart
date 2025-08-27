import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:spiritual_routines/core/services/progress_service.dart';
import 'package:spiritual_routines/core/services/content_service.dart';
import 'package:spiritual_routines/features/reader/current_progress.dart';
import 'package:spiritual_routines/features/session/session_state.dart';
import 'package:spiritual_routines/features/counter/hands_free_controller.dart';
import 'package:spiritual_routines/features/reader/highlight_controller.dart';
import 'package:spiritual_routines/features/reader/focus_mode.dart';
import 'package:spiritual_routines/features/reader/reading_prefs.dart';
import 'package:spiritual_routines/core/services/audio_tts_flutter.dart';
import 'package:spiritual_routines/core/services/user_settings_service.dart';
import 'package:spiritual_routines/core/services/audio_cloud_tts_service.dart';
import 'package:spiritual_routines/core/services/audio_player_service.dart';
import 'package:spiritual_routines/features/settings/user_settings_service.dart'
    as secure;
import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:drift/drift.dart' as drift;
import 'package:spiritual_routines/core/services/tts_cache_service.dart';
import 'package:spiritual_routines/core/services/task_audio_prefs.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

// Import du nouveau design system
import 'package:spiritual_routines/design_system/advanced_theme.dart';
import 'package:spiritual_routines/design_system/components/premium_card.dart';
import 'package:spiritual_routines/design_system/components/premium_buttons.dart';
import 'package:spiritual_routines/design_system/animations/premium_animations.dart';
import 'package:spiritual_routines/design_system/tokens/colors.dart';
import 'package:spiritual_routines/design_system/tokens/typography.dart';
import 'package:spiritual_routines/design_system/tokens/shadows.dart';

/// Premium Reader Page avec design sophistiqué
/// Interface premium pour la lecture de routines spirituelles
class PremiumReaderPage extends ConsumerStatefulWidget {
  final String sessionId;

  const PremiumReaderPage({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<PremiumReaderPage> createState() => _PremiumReaderPageState();
}

class _PremiumReaderPageState extends ConsumerState<PremiumReaderPage>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _pulseController;

  final bool _showLanguageTabs = true;
  final bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      duration: PremiumAnimations.Durations.normal,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Démarre l'animation de page
    _pageController.forward();

    // Animation de pulsation pour le mode focus
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final currentProgress =
        ref.watch(currentProgressProvider(widget.sessionId));
    final bilingualDisplay = ref.watch(bilingualDisplayProvider);
    final focusMode = ref.watch(focusModeProvider);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      extendBodyBehindAppBar: true,

      // Premium AppBar avec gradient
      appBar: _buildPremiumAppBar(context, colorScheme, isDark),

      body: currentProgress.when(
        data: (progress) => progress != null
            ? _buildPremiumContent(
                context, progress, bilingualDisplay, focusMode, isDark)
            : _buildEmptyState(context, colorScheme),
        loading: () => _buildLoadingState(context),
        error: (error, stack) => _buildErrorState(context, error),
      ),

      // Premium Floating Action Buttons
      floatingActionButton:
          _buildPremiumFABs(context, currentProgress, colorScheme),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

      // Premium Bottom Navigation
      bottomNavigationBar: _buildPremiumBottomBar(context, colorScheme, isDark),
    );
  }

  /// Premium AppBar avec effets visuels sophistiqués
  PreferredSizeWidget _buildPremiumAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,

      // Gradient background
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0A0A0A),
                    const Color(0xFF0A0A0A).withOpacity(0.95),
                    Colors.transparent,
                  ]
                : [
                    const Color(0xFFFAFAFA),
                    const Color(0xFFFAFAFA).withOpacity(0.95),
                    Colors.transparent,
                  ],
          ),
        ),
      ),

      leading: PremiumButtons.icon(
        onPressed: () => context.go('/'),
        icon: Icons.arrow_back_ios_rounded,
        tooltip: 'Retour',
      ),

      title: FadeInAnimation(
        delay: const Duration(milliseconds: 200),
        child: Text(
          'Lecture Spirituelle',
          style: AdvancedTypography.SpecialTextStyles.counterDisplay.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),

      actions: [
        // Bouton de paramètres avec animation
        ScaleAnimation(
          delay: const Duration(milliseconds: 400),
          child: PremiumButtons.icon(
            onPressed: () => _showSettings(context),
            icon: Icons.tune_rounded,
            tooltip: 'Paramètres',
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Contenu principal premium
  Widget _buildPremiumContent(
    BuildContext context,
    ProgressRow progress,
    BilingualDisplay bilingualDisplay,
    bool focusMode,
    bool isDark,
  ) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Header premium avec informations de progression
            _buildPremiumHeader(context, progress, isDark),

            const SizedBox(height: 24),

            // Onglets de langue premium (si affichés)
            if (_showLanguageTabs && !focusMode)
              _buildPremiumLanguageTabs(context, bilingualDisplay),

            if (_showLanguageTabs && !focusMode) const SizedBox(height: 20),

            // Zone de texte principal
            Expanded(
              child: _buildPremiumTextArea(
                context,
                progress,
                bilingualDisplay,
                focusMode,
                isDark,
              ),
            ),

            const SizedBox(height: 20),

            // Contrôles de navigation premium
            _buildPremiumNavigationControls(context, progress, isDark),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Header premium avec informations de progression
  Widget _buildPremiumHeader(
    BuildContext context,
    ProgressRow progress,
    bool isDark,
  ) {
    final taskAsync = ref.watch(taskRowProvider(progress.taskId));

    return taskAsync.when(
      data: (task) => task != null
          ? FadeInAnimation(
              delay: const Duration(milliseconds: 300),
              child: PremiumCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                elevation: 1,
                gradient: isDark
                    ? AdvancedColors.Gradients.cardDark
                    : AdvancedColors.Gradients.cardLight,
                child: Column(
                  children: [
                    // Titre de la tâche
                    Text(
                      task.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),

                    // Barre de progression sophistiquée
                    _buildAdvancedProgressBar(context, progress, task),

                    const SizedBox(height: 12),

                    // Statistiques en temps réel
                    _buildProgressStats(context, progress, task),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
      loading: () => _buildHeaderSkeleton(context),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Barre de progression avancée
  Widget _buildAdvancedProgressBar(
    BuildContext context,
    ProgressRow progress,
    TaskRow task,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentCount = task.targetRepetitions - progress.repetitionsLeft;
    final progressValue = currentCount / task.targetRepetitions;

    return Column(
      children: [
        // Barre de progression avec animation
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: colorScheme.surfaceContainer,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: PremiumAnimations.Durations.normal,
              curve: PremiumAnimations.Curves.easeOut,
              width: MediaQuery.of(context).size.width * progressValue,
              decoration: BoxDecoration(
                gradient: AdvancedColors.Gradients.spiritualPrimary,
                borderRadius: BorderRadius.circular(4),
                boxShadow: AdvancedShadows.Shadows.colored(
                  colorScheme.primary,
                  opacity: 0.3,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Pourcentage avec style premium
        Text(
          '${(progressValue * 100).toInt()}%',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  /// Statistiques de progression
  Widget _buildProgressStats(
    BuildContext context,
    ProgressRow progress,
    TaskRow task,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentCount = task.targetRepetitions - progress.repetitionsLeft;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          context,
          'Complété',
          '$currentCount',
          Icons.check_circle_outline_rounded,
          AdvancedColors.Semantic.success,
        ),
        _buildStatItem(
          context,
          'Restant',
          '${progress.repetitionsLeft}',
          Icons.pending_outlined,
          colorScheme.primary,
        ),
        _buildStatItem(
          context,
          'Total',
          '${task.targetRepetitions}',
          Icons.flag_outlined,
          colorScheme.secondary,
        ),
      ],
    );
  }

  /// Élément de statistique
  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  /// Onglets de langue premium
  Widget _buildPremiumLanguageTabs(
    BuildContext context,
    BilingualDisplay bilingualDisplay,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeInAnimation(
      delay: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildLanguageTab(
                context,
                'العربية',
                bilingualDisplay == BilingualDisplay.arOnly,
                () => ref.read(bilingualDisplayProvider.notifier).state =
                    BilingualDisplay.arOnly,
                Icons.language_rounded,
              ),
            ),
            Expanded(
              child: _buildLanguageTab(
                context,
                'Les Deux',
                bilingualDisplay == BilingualDisplay.both,
                () => ref.read(bilingualDisplayProvider.notifier).state =
                    BilingualDisplay.both,
                Icons.translate_rounded,
              ),
            ),
            Expanded(
              child: _buildLanguageTab(
                context,
                'Français',
                bilingualDisplay == BilingualDisplay.frOnly,
                () => ref.read(bilingualDisplayProvider.notifier).state =
                    BilingualDisplay.frOnly,
                Icons.abc_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Onglet de langue individuel
  Widget _buildLanguageTab(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: PremiumAnimations.Durations.fast,
      curve: PremiumAnimations.Curves.easeOut,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? AdvancedShadows.Shadows.colored(colorScheme.primary, opacity: 0.3)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Zone de texte principale premium
  Widget _buildPremiumTextArea(
    BuildContext context,
    ProgressRow progress,
    BilingualDisplay bilingualDisplay,
    bool focusMode,
    bool isDark,
  ) {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 600),
      child: PremiumCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        elevation: focusMode ? 3 : 1,
        glowColor: focusMode ? Theme.of(context).colorScheme.primary : null,
        gradient: focusMode
            ? (isDark
                ? AdvancedColors.Gradients.cardDark
                : AdvancedColors.Gradients.cardLight)
            : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (focusMode) ...[
                // Indicateur de mode focus
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PulseAnimation(
                      child: Icon(
                        Icons.visibility_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mode Focus',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Contenu textuel avec support RTL et versets
              Expanded(
                child: _buildTextContent(context, progress, bilingualDisplay),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Contenu textuel avec support des versets
  Widget _buildTextContent(
    BuildContext context,
    ProgressRow progress,
    BilingualDisplay bilingualDisplay,
  ) {
    final contentAr = ref.watch(contentProvider((progress.taskId, 'ar')));
    final contentFr = ref.watch(contentProvider((progress.taskId, 'fr')));

    return SingleChildScrollView(
      child: Column(
        children: [
          // Texte arabe
          if (bilingualDisplay != BilingualDisplay.frOnly)
            contentAr.when(
              data: (content) => content?.body?.isNotEmpty == true
                  ? _buildArabicText(context, content!.body!)
                  : const SizedBox.shrink(),
              loading: () => _buildTextSkeleton(context, isArabic: true),
              error: (_, __) => const SizedBox.shrink(),
            ),

          // Espacement entre les langues
          if (bilingualDisplay == BilingualDisplay.both)
            const SizedBox(height: 32),

          // Texte français
          if (bilingualDisplay != BilingualDisplay.arOnly)
            contentFr.when(
              data: (content) => content?.body?.isNotEmpty == true
                  ? _buildFrenchText(context, content!.body!)
                  : const SizedBox.shrink(),
              loading: () => _buildTextSkeleton(context, isArabic: false),
              error: (_, __) => const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  /// Texte arabe avec support des versets
  Widget _buildArabicText(BuildContext context, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isArabicText(text)) {
      return _buildTextWithVerseIndicators(context, text, true);
    }

    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        style: AdvancedTypography.SpecialTextStyles.arabicLarge.copyWith(
          color: colorScheme.onSurface,
          height: 2.0,
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
      ),
    );
  }

  /// Texte français
  Widget _buildFrenchText(BuildContext context, String text) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          height: 1.6,
          fontSize: 18,
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      ),
    );
  }

  /// Détection de texte arabe
  bool _isArabicText(String text) {
    int arabicChars = 0;
    int totalChars = 0;
    for (int i = 0; i < text.length; i++) {
      final char = text.codeUnitAt(i);
      if (char >= 0x0600 && char <= 0x06FF) arabicChars++;
      if (char > 32) totalChars++;
    }
    return totalChars > 0 && (arabicChars / totalChars) > 0.5;
  }

  /// Construction du texte avec indicateurs de versets
  Widget _buildTextWithVerseIndicators(
      BuildContext context, String text, bool isArabic) {
    final List<InlineSpan> spans = [];

    // Pattern pour détecter les versets (exemple: fin de phrase avec ponctuation arabe)
    final versePattern = RegExp(r'[۔۝۞]|\s*\([0-9]+\)\s*');

    int lastMatch = 0;
    int verseNumber = 1;

    for (final match in versePattern.allMatches(text)) {
      // Texte avant le marqueur
      if (match.start > lastMatch) {
        spans.add(TextSpan(
          text: text.substring(lastMatch, match.start),
          style: AdvancedTypography.SpecialTextStyles.arabicLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ));
      }

      // Indicateur de verset
      spans.add(WidgetSpan(
        child: _VerseIndicator(
          surahNumber: 1, // À adapter selon vos données
          verseNumber: verseNumber,
          isArabic: isArabic,
        ),
      ));

      lastMatch = match.end;
      verseNumber++;
    }

    // Texte restant
    if (lastMatch < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatch),
        style: AdvancedTypography.SpecialTextStyles.arabicLarge.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ));
    }

    return SizedBox(
      width: double.infinity,
      child: RichText(
        text: TextSpan(children: spans),
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      ),
    );
  }

  /// Contrôles de navigation premium
  Widget _buildPremiumNavigationControls(
    BuildContext context,
    ProgressRow progress,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeInAnimation(
      delay: const Duration(milliseconds: 800),
      child: PremiumCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        elevation: 1,
        backgroundColor: isDark
            ? colorScheme.surfaceContainer.withOpacity(0.8)
            : colorScheme.surface.withOpacity(0.9),
        child: Row(
          children: [
            // Bouton Précédent
            Expanded(
              child: PremiumButtons.outlined(
                onPressed: () => _goToPrevious(context, progress),
                icon: Icons.arrow_back_ios_rounded,
                size: PremiumButtonSize.medium,
                child: const Text('Précédent'),
              ),
            ),

            const SizedBox(width: 16),

            // Compteur central
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${progress.repetitionsLeft}',
                style: AdvancedTypography.SpecialTextStyles.counterDisplay
                    .copyWith(
                  fontSize: 32,
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Bouton Suivant
            Expanded(
              child: PremiumButtons.primary(
                onPressed: () => _goToNext(context, progress),
                icon: Icons.arrow_forward_ios_rounded,
                size: PremiumButtonSize.medium,
                child: const Text('Suivant'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FABs premium
  Widget _buildPremiumFABs(
    BuildContext context,
    AsyncValue<ProgressRow?> currentProgress,
    ColorScheme colorScheme,
  ) {
    final handsFree = ref.watch(handsFreeControllerProvider);

    return ScaleAnimation(
      delay: const Duration(milliseconds: 1000),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // FAB Mode Focus
          FloatingActionButton(
            heroTag: 'focus',
            onPressed: () => ref.read(focusModeProvider.notifier).toggle(),
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
            child: Icon(
              ref.watch(focusModeProvider)
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
            ),
          ),

          const SizedBox(height: 12),

          // FAB Mode Mains Libres
          FloatingActionButton(
            heroTag: 'handsfree',
            onPressed: handsFree
                ? () => ref.read(handsFreeControllerProvider.notifier).stop()
                : () => ref
                    .read(handsFreeControllerProvider.notifier)
                    .start(widget.sessionId),
            backgroundColor:
                handsFree ? colorScheme.error : colorScheme.primary,
            foregroundColor:
                handsFree ? colorScheme.onError : colorScheme.onPrimary,
            child: handsFree
                ? const Icon(Icons.stop_rounded)
                : const Icon(Icons.play_arrow_rounded),
          ),
        ],
      ),
    );
  }

  /// Bottom bar premium
  Widget _buildPremiumBottomBar(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  Colors.transparent,
                  const Color(0xFF0A0A0A).withOpacity(0.95),
                  const Color(0xFF0A0A0A),
                ]
              : [
                  Colors.transparent,
                  const Color(0xFFFAFAFA).withOpacity(0.95),
                  const Color(0xFFFAFAFA),
                ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomAction(
              context,
              Icons.settings_rounded,
              'Paramètres',
              () => _showSettings(context),
            ),
            _buildBottomAction(
              context,
              Icons.bookmark_rounded,
              'Marquer',
              () => _bookmarkProgress(context),
            ),
            _buildBottomAction(
              context,
              Icons.share_rounded,
              'Partager',
              () => _shareProgress(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Action du bottom bar
  Widget _buildBottomAction(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// États de chargement et d'erreur
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PulseAnimation(
            child: Icon(
              Icons.auto_stories_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          ShimmerAnimation(
            child: Container(
              width: 200,
              height: 20,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune routine en cours',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton(BuildContext context) {
    return ShimmerAnimation(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildTextSkeleton(BuildContext context, {required bool isArabic}) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ShimmerAnimation(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Méthodes d'interaction
  void _goToPrevious(BuildContext context, ProgressRow progress) {
    ref.read(progressServiceProvider).advanceToPrevious(widget.sessionId);
    HapticFeedback.lightImpact();
  }

  void _goToNext(BuildContext context, ProgressRow progress) {
    ref.read(progressServiceProvider).decrementCurrent(widget.sessionId);
    HapticFeedback.lightImpact();
  }

  void _showSettings(BuildContext context) {
    // Implémenter l'affichage des paramètres
  }

  void _bookmarkProgress(BuildContext context) {
    // Implémenter le marque-page
  }

  void _shareProgress(BuildContext context) {
    // Implémenter le partage
  }
}

/// Widget pour indicateur de verset premium
class _VerseIndicator extends StatelessWidget {
  final int surahNumber;
  final int verseNumber;
  final bool isArabic;

  const _VerseIndicator({
    required this.surahNumber,
    required this.verseNumber,
    this.isArabic = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: AdvancedColors.Gradients.spiritualPrimary,
        shape: BoxShape.circle,
        boxShadow: AdvancedShadows.Shadows.colored(
          colorScheme.primary,
          opacity: 0.3,
        ),
      ),
      child: Text(
        '$verseNumber',
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
        textDirection: TextDirection.ltr,
      ),
    );
  }
}
