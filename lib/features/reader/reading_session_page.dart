import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';
import 'package:spiritual_routines/core/services/content_service.dart';
import 'package:spiritual_routines/core/services/session_service.dart';
import 'package:spiritual_routines/features/counter/smart_counter.dart';
import 'package:spiritual_routines/features/reader/current_progress.dart';
import 'package:spiritual_routines/features/session/session_state.dart';
import 'package:spiritual_routines/features/counter/hands_free_controller.dart';
import 'package:spiritual_routines/features/reader/reading_prefs.dart';
import 'package:spiritual_routines/design_system/inspired_theme.dart';
import 'package:spiritual_routines/core/services/audio_tts_flutter.dart';
import 'package:spiritual_routines/core/services/smart_tts_service.dart';
import 'package:spiritual_routines/core/services/user_settings_service.dart';
import 'package:spiritual_routines/core/services/progress_service.dart';
import 'package:spiritual_routines/core/services/task_audio_prefs.dart';
import 'package:spiritual_routines/core/services/tts_config_service.dart';
import 'package:spiritual_routines/features/reader/modern_reader_page.dart'
    show
        readerCurrentTaskProvider,
        readerProgressProvider,
        readerLanguageProvider;
import 'package:spiritual_routines/features/reader/enhanced_modern_reader_page.dart'
    show
        enhancedReaderThemeModeProvider,
        enhancedReaderFocusModeProvider,
        enhancedReaderSidePaddingProvider,
        enhancedReaderTextScaleProvider,
        enhancedReaderLineHeightProvider,
        enhancedReaderJustifyProvider,
        EnhancedReaderThemeMode;
import 'package:spiritual_routines/features/reader/reading_prefs.dart'
    show bilingualDisplayProvider, BilingualDisplay;
import 'package:go_router/go_router.dart';

/// Page dédiée à la session de lecture active
class ReadingSessionPage extends ConsumerStatefulWidget {
  final String sessionId;
  final TaskRow task;

  const ReadingSessionPage({
    super.key,
    required this.sessionId,
    required this.task,
  });

  @override
  ConsumerState<ReadingSessionPage> createState() => _ReadingSessionPageState();
}

class _ReadingSessionPageState extends ConsumerState<ReadingSessionPage> {
  // Cache de la tâche pour éviter les incohérences - utiliser le provider en mode mains libres
  TaskRow get _currentTask {
    // En mode mains libres, utiliser le provider qui est mis à jour dynamiquement
    final handsFreeMode = ref.watch(handsFreeControllerProvider);
    if (handsFreeMode) {
      // Écouter les changements du provider global
      final globalTask = ref.watch(readerCurrentTaskProvider);
      return globalTask ?? widget.task;
    }
    // En mode normal, utiliser la tâche passée en paramètre
    return widget.task;
  }

  // État de chargement de l'audio
  bool _isLoadingAudio = false;
  String _loadingMessage = '';
  int _currentSegment = 0;
  int _totalSegments = 0;

  @override
  void initState() {
    super.initState();
    // Initialiser le compteur avec la tâche passée en paramètre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(smartCounterProvider.notifier)
          .setInitial(widget.task.defaultReps);
      // Utiliser widget.task directement pour l'initialisation
    });
  }

  @override
  void dispose() {
    // Arrêter tous les audios de manière sécurisée
    _safeStopAllAudio();
    super.dispose();
  }

  // Méthode sécurisée pour arrêter les audios sans utiliser ref après dispose
  void _safeStopAllAudio() {
    try {
      // Utiliser les providers de manière sécurisée
      Future.microtask(() async {
        try {
          final tts = ref.read(audioTtsServiceProvider);
          await tts.stop();
        } catch (_) {}

        try {
          if (ref.read(handsFreeControllerProvider)) {
            ref.read(handsFreeControllerProvider.notifier).stop();
          }
        } catch (_) {}
      });
    } catch (_) {
      // Ignorer silencieusement les erreurs
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentProgressAsync =
        ref.watch(currentProgressProvider(widget.sessionId));
    final counterState = ref.watch(smartCounterProvider);
    final handsFreeMode = ref.watch(handsFreeControllerProvider);
    final language = ref.watch(readerLanguageProvider);
    final bilingualDisplay = ref.watch(bilingualDisplayProvider);
    // En mode mains libres, écouter les changements du provider global
    // Cela forcera la reconstruction de l'interface quand la tâche change
    final currentTask =
        _currentTask; // Ceci utilise le getter qui surveille le provider
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final readerTheme = ref.watch(enhancedReaderThemeModeProvider);
    final focusMode = ref.watch(enhancedReaderFocusModeProvider);
    final sidePadding = ref.watch(enhancedReaderSidePaddingProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // Header avec progression - uniformisé
          Container(
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
                            onPressed: _endSession,
                            icon: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Colors.white,
                              size: 20, // 🎯 Uniformisé à 20px
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Bouton de paramètres avancés
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
                            onPressed: () =>
                                _showEnhancedSettingsBottomSheet(context),
                            icon: const Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 20, // 🎯 Uniformisé à 20px
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Zone de texte optimisée
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Titre principal uniformisé
                              Text(
                                _currentTask.notesFr?.isNotEmpty == true
                                    ? _currentTask.notesFr!
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
                                'Étape 1/1',
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

                        const SizedBox(width: 16),
                        // Compteur restant uniformisé
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.95),
                                Colors.white.withOpacity(0.85),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Restant: ${counterState.remaining}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenu principal scrollable
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // Contrôles de texte rapides
                  _buildQuickTextControls(context),

                  // Contenu principal de lecture
                  Expanded(
                    child: _buildSessionTextContent(context, language),
                  ),

                  // Contrôles de session
                  _buildSessionControls(
                      context, counterState, handsFreeMode, language),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Contrôles de texte rapides identiques à l'original
  Widget _buildQuickTextControls(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = ref.watch(enhancedReaderTextScaleProvider);
    final focusMode = ref.watch(enhancedReaderFocusModeProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Mode focus (bouton œil)
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

  Widget _buildTextSizeButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: enabled ? theme.colorScheme.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: enabled ? onTap : null,
        icon: Icon(
          icon,
          size: 14,
          color: enabled
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withOpacity(0.3),
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Contenu textuel pour session active
  Widget _buildSessionTextContent(BuildContext context, String language) {
    // Lire les préférences de style
    final textScale = ref.watch(enhancedReaderTextScaleProvider);
    final lineHeight = ref.watch(enhancedReaderLineHeightProvider);
    final justify = ref.watch(enhancedReaderJustifyProvider);
    final sidePadding = ref.watch(enhancedReaderSidePaddingProvider);
    final readerTheme = ref.watch(enhancedReaderThemeModeProvider);
    final focusMode = ref.watch(enhancedReaderFocusModeProvider);
    final theme = Theme.of(context);

    // Log pour déboguer
    // print('📖 DEBUG: _buildSessionTextContent - _currentTask.id: ${_currentTask.id}');
    // print('📖 DEBUG: _buildSessionTextContent - _currentTask.category: ${_currentTask.category}');

    return FutureBuilder<(String?, String?)>(
      // IMPORTANT: Utiliser une clé unique basée sur l'ID de la tâche
      // pour forcer la reconstruction quand la tâche change
      key: ValueKey(_currentTask.id),
      future: ref
          .read(contentServiceProvider)
          .getBuiltTextsForTask(_currentTask.id),
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
                ],
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          margin: EdgeInsets.all(focusMode ? 10 : 20),
          padding: EdgeInsets.symmetric(
            horizontal: 24 + sidePadding,
            vertical: focusMode ? 16 : 24,
          ),
          decoration: BoxDecoration(
            color: _getReaderThemeBackgroundColor(readerTheme, theme),
            borderRadius: BorderRadius.circular(focusMode ? 12 : 20),
            boxShadow: focusMode
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
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
                              '${_currentTask.defaultReps}x répétitions',
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

                // Contenu textuel avec support des numéros de verset
                () {
                  final textStyle = theme.textTheme.bodyLarge?.copyWith(
                    fontFamily: isArabic ? 'NotoNaskhArabic' : 'Inter',
                    fontSize: isArabic ? (24 * textScale) : (18 * textScale),
                    height: isArabic ? lineHeight : 1.6,
                    letterSpacing: isArabic ? 0 : 0.2,
                    fontWeight: isArabic ? FontWeight.w500 : FontWeight.w400,
                    color: _getReaderThemeTextColor(readerTheme, theme),
                  );

                  // Vérifier si le texte contient des marqueurs de verset
                  final hasVerseMarkers =
                      currentText.contains(RegExp(r'\{\{V:\d+(?::\d+)?\}\}'));

                  // Debug: Afficher le texte et les marqueurs
                  // DEBUG: currentText = $currentText
                  // DEBUG: hasVerseMarkers = $hasVerseMarkers

                  if (hasVerseMarkers) {
                    // Utiliser l'affichage avec cercles de verset
                    // DEBUG: Utilisation des cercles de verset
                    return _buildTextWithVerseNumbers(
                        currentText, textStyle!, isArabic, justify);
                  } else {
                    // Affichage normal sans numéros de verset
                    // DEBUG: Affichage normal sans cercles
                    return SelectableText(
                      currentText,
                      style: textStyle,
                      textAlign: justify
                          ? TextAlign.justify
                          : (isArabic ? TextAlign.right : TextAlign.left),
                      textDirection:
                          isArabic ? TextDirection.rtl : TextDirection.ltr,
                    );
                  }
                }(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Section contrôles de session
  Widget _buildSessionControls(BuildContext context, CounterState counterState,
      bool handsFreeMode, String language) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Compteur central
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bouton moins
                    _buildCounterButton(
                      icon: Icons.remove,
                      onTap: counterState.remaining > 0
                          ? () => ref
                              .read(smartCounterProvider.notifier)
                              .decrementWithFeedback(HapticType.light)
                          : null,
                    ),

                    const SizedBox(width: 24),

                    // Affichage du compteur
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${counterState.remaining}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 24),

                    // Bouton plus
                    _buildCounterButton(
                      icon: Icons.add,
                      onTap: () => ref
                          .read(smartCounterProvider.notifier)
                          .setInitial(counterState.remaining + 1),
                    ),
                  ],
                ),
              ),

              // Actions minimales
              _buildMinimalActions(context, handsFreeMode, language),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Icon(
            icon,
            color: onTap != null
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalActions(
      BuildContext context, bool handsFreeMode, String language) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Contrôle de vitesse TTS
        FutureBuilder<double>(
          future: ref.read(userSettingsServiceProvider).getTtsSpeed(),
          builder: (context, snapshot) {
            final currentSpeed = snapshot.data ?? 0.9;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.speed_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vitesse',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(currentSpeed * 100).toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 16),
                      activeTrackColor: theme.colorScheme.primary,
                      inactiveTrackColor:
                          theme.colorScheme.surfaceContainerHighest,
                      thumbColor: theme.colorScheme.primary,
                      overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: currentSpeed,
                      min: 0.5,
                      max: 1.5,
                      divisions: 20,
                      onChanged: (value) async {
                        await ref
                            .read(userSettingsServiceProvider)
                            .setTtsSpeed(value);
                        // Force le rebuild du widget
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Première ligne d'actions
        Row(
          children: [
            // Écouter
            Expanded(
              child: _isLoadingAudio
                  ? Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _loadingMessage,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_totalSegments > 1)
                                    Text(
                                      'Segment $_currentSegment/$_totalSegments',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.7),
                                        fontSize: 10,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _buildMinimalButton(
                      icon: Icons.volume_up_rounded,
                      label: 'Écouter',
                      onPressed: () => _playCurrentText(),
                      isPrimary: false,
                    ),
            ),

            const SizedBox(width: 12),

            // Mains libres
            Expanded(
              child: _buildMinimalButton(
                icon: handsFreeMode
                    ? Icons.stop_rounded
                    : Icons.play_arrow_rounded,
                label: handsFreeMode ? 'Arrêter' : 'Mains libres',
                onPressed: () {
                  if (handsFreeMode) {
                    ref.read(handsFreeControllerProvider.notifier).stop();
                  } else {
                    ref
                        .read(handsFreeControllerProvider.notifier)
                        .start(widget.sessionId, interfaceLanguage: language);
                  }
                },
                isPrimary: true,
                isActive: handsFreeMode,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Deuxième ligne d'actions
        Row(
          children: [
            // Précédent
            Expanded(
              child: _buildMinimalButton(
                icon: Icons.skip_previous_rounded,
                label: 'Précédent',
                onPressed: () => _goToPrevious(),
                isPrimary: false,
              ),
            ),

            const SizedBox(width: 12),

            // Suivant
            Expanded(
              child: _buildMinimalButton(
                icon: Icons.skip_next_rounded,
                label: 'Suivant',
                onPressed: () => _goToNext(),
                isPrimary: false,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Troisième ligne d'actions
        Row(
          children: [
            // Arrêter
            Expanded(
              child: _buildMinimalButton(
                icon: Icons.stop_rounded,
                label: 'Arrêter',
                onPressed: _endSession,
                isPrimary: false,
              ),
            ),

            const SizedBox(width: 12),

            // Terminer
            Expanded(
              child: _buildMinimalButton(
                icon: Icons.check_rounded,
                label: 'Terminer',
                onPressed: _completeSession,
                isPrimary: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMinimalButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isPrimary = false,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    final backgroundColor = isActive
        ? theme.colorScheme.primary
        : isPrimary
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.colorScheme.surfaceContainerHighest;
    final foregroundColor = isActive || isPrimary
        ? (isActive ? Colors.white : theme.colorScheme.primary)
        : theme.colorScheme.onSurface;

    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: foregroundColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Actions

  /// Afficher un message à l'utilisateur
  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// Ajuster la taille du texte
  Future<void> _adjustTextScale(double delta) async {
    final current = ref.read(enhancedReaderTextScaleProvider);
    final newScale = (current + delta).clamp(0.8, 1.6);
    ref.read(enhancedReaderTextScaleProvider.notifier).state = newScale;

    // Feedback haptique
    HapticFeedback.selectionClick();

    // Sauvegarder la préférence
    try {
      // TODO: Implémenter la sauvegarde des préférences
      // final settingsService = ref.read(userSettingsServiceProvider);
      // await settingsService.writeValue('enhanced_reader_text_scale', newScale.toString());
    } catch (e) {
      // Ignore silently - not critical
    }
  }

  /// Aller à la tâche précédente (sans navigation de page)
  Future<void> _goToPrevious() async {
    try {
      print('🔍 DEBUG: _goToPrevious appelé');

      // Récupérer toutes les tâches de la routine courante
      final tasks = await ref
          .read(taskDaoProvider)
          .watchByRoutine(_currentTask.routineId)
          .first;
      print('🔍 DEBUG: ${tasks.length} tâches trouvées dans la routine');

      if (tasks.length <= 1) {
        _showMessage('Pas de tâche précédente disponible');
        return;
      }

      // Utiliser directement _currentTask au lieu du provider global
      final currentTask = _currentTask;
      print('🔍 DEBUG: Tâche courante ID = ${currentTask.id}');

      // Trouver l'index de la tâche actuelle
      final currentIndex =
          tasks.indexWhere((task) => task.id == currentTask.id);
      print('🔍 DEBUG: Index courant = $currentIndex');

      if (currentIndex <= 0) {
        _showMessage('Vous êtes déjà à la première tâche');
        return;
      }

      // Naviguer vers la tâche précédente
      final previousTask = tasks[currentIndex - 1];
      print('🔍 DEBUG: Navigation vers tâche ${previousTask.id}');

      // Naviguer vers une nouvelle instance de la page avec la nouvelle tâche
      if (mounted) {
        context.pushReplacement(
          '/session/${widget.sessionId}/task/${previousTask.id}',
        );
      }

      HapticFeedback.lightImpact();
    } catch (e) {
      print('❌ DEBUG: Erreur _goToPrevious: $e');
      _showMessage('Erreur lors de la navigation: $e');
    }
  }

  /// Aller à la tâche suivante (sans navigation de page)
  Future<void> _goToNext() async {
    try {
      print('🔍 DEBUG: _goToNext appelé');

      // Récupérer toutes les tâches de la routine courante
      final tasks = await ref
          .read(taskDaoProvider)
          .watchByRoutine(_currentTask.routineId)
          .first;
      print('🔍 DEBUG: ${tasks.length} tâches trouvées dans la routine');

      if (tasks.length <= 1) {
        _showMessage('Pas de tâche suivante disponible');
        return;
      }

      // Utiliser directement _currentTask au lieu du provider global
      final currentTask = _currentTask;
      print('🔍 DEBUG: Tâche courante ID = ${currentTask.id}');

      // Trouver l'index de la tâche actuelle
      final currentIndex =
          tasks.indexWhere((task) => task.id == currentTask.id);
      print('🔍 DEBUG: Index courant = $currentIndex');
      if (currentIndex >= tasks.length - 1) {
        _showMessage('Vous êtes déjà à la dernière tâche');
        return;
      }

      // Naviguer vers la tâche suivante
      final nextTask = tasks[currentIndex + 1];
      print('🔍 DEBUG: Navigation vers tâche ${nextTask.id}');

      // Naviguer vers une nouvelle instance de la page avec la nouvelle tâche
      if (mounted) {
        context.pushReplacement(
          '/session/${widget.sessionId}/task/${nextTask.id}',
        );
      }

      HapticFeedback.lightImpact();
    } catch (e) {
      print('❌ DEBUG: Erreur _goToNext: $e');
      _showMessage('Erreur lors de la navigation: $e');
    }
  }

  /// Détection automatique du texte arabe
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

  /// CRITIQUE: Arrêter tous les audios (TTS direct et mode mains libres)
  Future<void> _stopAllAudio() async {
    try {
      // Vérifier que le widget est encore monté
      if (!mounted) {
        return;
      }

      print('🛑 DEBUG: Arrêt de tous les audios');

      // 1. Arrêter le mode mains libres si actif
      try {
        final handsFreeController =
            ref.read(handsFreeControllerProvider.notifier);
        await handsFreeController.stop();
        print('🛑 DEBUG: Mode mains libres arrêté');
      } catch (e) {
        print('⚠️ DEBUG: Erreur arrêt mains libres: $e');
      }

      // 2. Arrêter le TTS direct si actif (plusieurs fois pour être sûr)
      try {
        final tts = ref.read(audioTtsServiceProvider);
        await tts.stop();
        await Future.delayed(Duration(milliseconds: 100));
        await tts.stop(); // Double stop pour être sûr
        print('🛑 DEBUG: TTS arrêté');
      } catch (e) {
        print('⚠️ DEBUG: Erreur arrêt TTS: $e');
      }

      // 3. NE PAS invalider les providers car cela recrée le service SANS Coqui
      // Les services sont déjà configurés correctement au démarrage
      print('🛑 DEBUG: Services audio conservés (pas de réinitialisation)');
    } catch (e) {
      print('❌ DEBUG: Erreur globale _stopAllAudio: $e');
      // Ignorer silencieusement les erreurs
    }
  }

  /// Lire le texte actuel
  Future<void> _playCurrentText() async {
    try {
      // Afficher l'indicateur de chargement
      setState(() {
        _isLoadingAudio = true;
        _loadingMessage = 'Préparation de l\'audio...';
      });

      // IMPORTANT: Arrêter tout audio en cours avant de lire le nouveau texte
      await _stopAllAudio();

      // Attendre un peu pour s'assurer que l'audio est bien arrêté
      await Future.delayed(Duration(milliseconds: 500));

      // Utiliser directement _currentTask pour être sûr d'avoir la bonne tâche
      final interfaceLanguage = ref.read(readerLanguageProvider);

      print('🎧 DEBUG: _playCurrentText appelé pour tâche ${_currentTask.id}');
      print('🎧 DEBUG: Catégorie de la tâche: ${_currentTask.category}');

      // Vérifier la configuration audio pour cette tâche
      final audioPrefs = await ref
          .read(taskAudioPrefsProvider)
          .getForTaskLocale(_currentTask.id, interfaceLanguage);
      print(
          '🎧 DEBUG: Configuration audio pour tâche ${_currentTask.id}: source=${audioPrefs.source}');

      // Vérifier la configuration TTS et audio de la tâche
      final ttsConfig = await ref.read(ttsConfigProvider.future);
      print('🎧 DEBUG: Configuration TTS:');
      print('  - Provider configuré: ${ttsConfig.preferredProvider}');
      print('  - Source audio tâche: ${audioPrefs.source}');
      print('  - API Key présente: ${ttsConfig.coquiApiKey.isNotEmpty}');
      print('  - API Key longueur: ${ttsConfig.coquiApiKey.length}');
      print('  - Endpoint: ${ttsConfig.coquiEndpoint}');

      // Vérifier que le service SmartTTS est bien configuré
      final smartTts = ref.read(audioTtsServiceProvider);
      print('🎧 DEBUG: Service TTS actuel: ${smartTts.runtimeType}');

      // Si c'est un fichier audio personnalisé, ne pas utiliser TTS
      if (audioPrefs.source == 'file' && audioPrefs.hasLocalFile) {
        _showMessage('Lecture de fichier audio personnalisé non implémentée');
        return;
      }

      // Récupérer le contenu textuel des deux langues POUR _currentTask
      final (textFr, textAr) = await ref
          .read(contentServiceProvider)
          .getBuiltTextsForTask(_currentTask.id);
      print(
          '🎧 DEBUG: Récupération texte pour _currentTask.id: ${_currentTask.id}');
      print('🎧 DEBUG: _currentTask.category: ${_currentTask.category}');
      print(
          '🎧 DEBUG: Texte FR récupéré: ${textFr?.substring(0, textFr.length > 50 ? 50 : textFr.length) ?? "null"}...');
      print(
          '🎧 DEBUG: Texte AR récupéré: ${textAr?.substring(0, textAr.length > 50 ? 50 : textAr.length) ?? "null"}...');

      // Déterminer quel texte utiliser selon l'interface
      final currentText = interfaceLanguage == 'ar' ? textAr : textFr;

      if (currentText == null || currentText.trim().isEmpty) {
        _showMessage('Aucun contenu à lire');
        return;
      }

      // DÉTECTION AUTOMATIQUE: Analyser le contenu réel du texte
      final isActuallyArabic = _isArabicText(currentText);

      // Récupérer la vitesse configurée par l'utilisateur
      final userSettings = ref.read(userSettingsServiceProvider);
      final configuredSpeed = await userSettings.getTtsSpeed();

      // Utiliser le service TTS configuré (SmartTtsService avec Coqui)
      final tts = ref.read(audioTtsServiceProvider);
      final languageCode = isActuallyArabic ? 'ar' : 'fr';

      print(
          '🎧 DEBUG: Lecture avec langue: $languageCode, vitesse: $configuredSpeed');
      print(
          '🎧 DEBUG: Texte complet à lire: ${currentText.substring(0, currentText.length > 100 ? 100 : currentText.length)}...');

      print('🎧 DEBUG: Appel playText avec:');
      print(
          '  - Texte: ${currentText.substring(0, currentText.length > 100 ? 100 : currentText.length)}...');
      print('  - Langue: $languageCode');
      print('  - Vitesse: $configuredSpeed');
      print('  - Longueur du texte: ${currentText.length} caractères');

      // Mettre à jour le message de chargement
      setState(() {
        _loadingMessage = 'Synthèse vocale en cours...';
      });

      // Lancer la lecture avec gestion d'erreur améliorée
      try {
        await tts.playText(
          currentText,
          voice: languageCode,
          speed: configuredSpeed,
          pitch: 1.0,
        );

        _showMessage('🆗 Lecture terminée');
      } catch (playError) {
        print('❌ Erreur lors de la lecture TTS: $playError');
        _showMessage('❌ Erreur de lecture: ${playError.toString()}');
        rethrow;
      }

      _showMessage(
          '🔊 Lecture ${isActuallyArabic ? 'arabe' : 'française'} démarrée');

      // Feedback haptique
      HapticFeedback.selectionClick();
    } catch (e) {
      print('❌ DEBUG: Erreur lecture: $e');
      _showMessage('Erreur lors de la lecture: $e');
    } finally {
      // Masquer l'indicateur de chargement
      setState(() {
        _isLoadingAudio = false;
        _loadingMessage = '';
      });
    }
  }

  /// Détecter si un texte est en arabe

  /// Terminer la session avec succès
  Future<void> _completeSession() async {
    try {
      // ARRÊTER LE TTS ET MODE MAINS LIBRES
      await _stopAllAudio();

      // Marquer la session comme terminée avec succès
      final sessionService = ref.read(sessionServiceProvider);
      await sessionService.completeSession(widget.sessionId);

      // Marquer le progress comme terminé
      ref.read(progressServiceProvider).completeCurrent(widget.sessionId);

      // Retourner à la page précédente
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      print('❌ Erreur lors de la completion de session: $e');
      // Retourner quand même à la page précédente
      if (mounted) {
        context.pop();
      }
    }
  }

  /// Terminer la session (préserver pour reprise)
  Future<void> _endSession() async {
    try {
      // ARRÊTER LE TTS ET MODE MAINS LIBRES
      await _stopAllAudio();

      // Arrêter la session en préservant le progress pour reprise
      final sessionService = ref.read(sessionServiceProvider);
      await sessionService.stopSession(widget.sessionId);

      // Réinitialiser l'état et retourner à la page précédente
      ref.read(smartCounterProvider.notifier).setInitial(0);

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      print('❌ Erreur lors de l\'arrêt de session: $e');
      // Retourner quand même à la page précédente
      if (mounted) {
        context.pop();
      }
    }
  }

  /// Afficher les paramètres avancés
  void _showEnhancedSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EnhancedSettingsBottomSheet(),
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildThemeSelector() {
    final theme = Theme.of(context);
    final currentTheme = ref.watch(enhancedReaderThemeModeProvider);

    final themes = [
      {'name': 'Système', 'value': EnhancedReaderThemeMode.system},
      {'name': 'Sepia', 'value': EnhancedReaderThemeMode.sepia},
      {'name': 'Papier', 'value': EnhancedReaderThemeMode.paper},
      {'name': 'Noir', 'value': EnhancedReaderThemeMode.black},
      {'name': 'Crème', 'value': EnhancedReaderThemeMode.cream},
      {'name': 'Sépia doux', 'value': EnhancedReaderThemeMode.sepiaSoft},
      {'name': 'Papier+', 'value': EnhancedReaderThemeMode.paperCreamPlus},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: themes.map((themeData) {
        final isSelected = currentTheme == themeData['value'];
        return GestureDetector(
          onTap: () {
            ref.read(enhancedReaderThemeModeProvider.notifier).state =
                themeData['value'] as EnhancedReaderThemeMode;
          },
          child: Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  themeData['name'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextCustomization() {
    final theme = Theme.of(context);
    final textScale = ref.watch(enhancedReaderTextScaleProvider);
    final lineHeight = ref.watch(enhancedReaderLineHeightProvider);
    final sidePadding = ref.watch(enhancedReaderSidePaddingProvider);
    final justify = ref.watch(enhancedReaderJustifyProvider);

    return Column(
      children: [
        // Taille du texte
        _buildSliderSetting(
          label: 'Taille du texte',
          value: textScale,
          min: 0.8,
          max: 1.6,
          divisions: 8,
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
          min: 1.0,
          max: 2.5,
          divisions: 15,
          displayValue: '${lineHeight.toStringAsFixed(1)}x',
          onChanged: (value) {
            ref.read(enhancedReaderLineHeightProvider.notifier).state = value;
          },
        ),

        const SizedBox(height: 16),

        // Espacement latéral
        _buildSliderSetting(
          label: 'Espacement latéral',
          value: sidePadding,
          min: 0.0,
          max: 40.0,
          divisions: 8,
          displayValue: '${sidePadding.round()}px',
          onChanged: (value) {
            ref.read(enhancedReaderSidePaddingProvider.notifier).state = value;
          },
        ),

        const SizedBox(height: 16),

        // Justifier le texte
        _buildSwitchSetting(
          label: 'Justifier le texte',
          subtitle: 'Alignement justifié',
          value: justify,
          onChanged: (value) {
            ref.read(enhancedReaderJustifyProvider.notifier).state = value;
          },
        ),
      ],
    );
  }

  Widget _buildInterfaceSettings() {
    final focusMode = ref.watch(enhancedReaderFocusModeProvider);

    return Column(
      children: [
        _buildSwitchSetting(
          label: 'Mode focus',
          subtitle: 'Masquer les distractions',
          value: focusMode,
          onChanged: (value) {
            ref.read(enhancedReaderFocusModeProvider.notifier).state = value;
          },
        ),
      ],
    );
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayValue,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSwitchSetting({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Obtenir la couleur de fond pour un thème de lecteur
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
      String text, TextStyle style, bool isArabic, bool justify) {
    // DEBUG: Texte à parser: ${text.substring(0, text.length > 100 ? 100 : text.length)}...

    // Support pour les deux formats : {{V:verset}} et {{V:sourate:verset}}
    final versePattern = RegExp(r'\{\{V:(\d+)(?::(\d+))?\}\}');
    final matches = versePattern.allMatches(text);
    // DEBUG: Nombre de marqueurs trouvés: ${matches.length}

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

      // DEBUG: Marqueur trouvé: ${match.group(0)}, group1: $group1, group2: $group2

      String verseReference;
      if (group2 != null) {
        // Format {{V:sourate:verset}}
        verseReference = '$group1:$group2';
        // DEBUG: Format sourate:verset détecté: $verseReference
      } else {
        // Format ancien {{V:verset}} - pour compatibilité
        verseReference = group1 ?? '';
        // DEBUG: Format verset seul détecté: $verseReference
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
      textAlign: justify
          ? TextAlign.justify
          : (isArabic ? TextAlign.right : TextAlign.left),
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
    );
  }
}

/// Widget séparé pour le modal de paramètres avec gestion d'état réactive
class EnhancedSettingsBottomSheet extends ConsumerWidget {
  const EnhancedSettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    context: context,
                    title: 'Thèmes de lecture',
                    icon: Icons.palette_rounded,
                    child: _buildThemeSelector(context, ref),
                  ),

                  const SizedBox(height: 24),

                  // Section Texte
                  _buildSettingSection(
                    context: context,
                    title: 'Personnalisation du texte',
                    icon: Icons.text_fields_rounded,
                    child: _buildTextCustomization(context, ref),
                  ),

                  const SizedBox(height: 24),

                  // Section Interface
                  _buildSettingSection(
                    context: context,
                    title: 'Interface',
                    icon: Icons.settings_rounded,
                    child: _buildInterfaceSettings(context, ref),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection({
    required BuildContext context,
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

  Widget _buildThemeSelector(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentTheme = ref.watch(enhancedReaderThemeModeProvider);

    final themes = [
      {'name': 'Système', 'value': EnhancedReaderThemeMode.system},
      {'name': 'Sepia', 'value': EnhancedReaderThemeMode.sepia},
      {'name': 'Papier', 'value': EnhancedReaderThemeMode.paper},
      {'name': 'Noir', 'value': EnhancedReaderThemeMode.black},
      {'name': 'Crème', 'value': EnhancedReaderThemeMode.cream},
      {'name': 'Sépia doux', 'value': EnhancedReaderThemeMode.sepiaSoft},
      {'name': 'Papier+', 'value': EnhancedReaderThemeMode.paperCreamPlus},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: themes.map((themeData) {
        final themeMode = themeData['value'] as EnhancedReaderThemeMode;
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
                  themeData['name'] as String,
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
  }

  Widget _buildTextCustomization(BuildContext context, WidgetRef ref) {
    final textScale = ref.watch(enhancedReaderTextScaleProvider);
    final lineHeight = ref.watch(enhancedReaderLineHeightProvider);
    final sidePadding = ref.watch(enhancedReaderSidePaddingProvider);
    final justify = ref.watch(enhancedReaderJustifyProvider);

    return Column(
      children: [
        // Taille du texte
        _buildSliderSetting(
          context: context,
          label: 'Taille du texte',
          value: textScale,
          min: 0.8,
          max: 1.6,
          divisions: 8,
          displayValue: '${(textScale * 100).round()}%',
          onChanged: (value) {
            ref.read(enhancedReaderTextScaleProvider.notifier).state = value;
            HapticFeedback.selectionClick();
          },
        ),

        const SizedBox(height: 16),

        // Hauteur de ligne
        _buildSliderSetting(
          context: context,
          label: 'Hauteur de ligne',
          value: lineHeight,
          min: 1.0,
          max: 2.5,
          divisions: 15,
          displayValue: '${lineHeight.toStringAsFixed(1)}x',
          onChanged: (value) {
            ref.read(enhancedReaderLineHeightProvider.notifier).state = value;
            HapticFeedback.selectionClick();
          },
        ),

        const SizedBox(height: 16),

        // Espacement latéral
        _buildSliderSetting(
          context: context,
          label: 'Espacement latéral',
          value: sidePadding,
          min: 0.0,
          max: 40.0,
          divisions: 8,
          displayValue: '${sidePadding.round()}px',
          onChanged: (value) {
            ref.read(enhancedReaderSidePaddingProvider.notifier).state = value;
            HapticFeedback.selectionClick();
          },
        ),

        const SizedBox(height: 16),

        // Justifier le texte
        _buildSwitchSetting(
          context: context,
          label: 'Justifier le texte',
          subtitle: 'Alignement justifié',
          value: justify,
          onChanged: (value) {
            ref.read(enhancedReaderJustifyProvider.notifier).state = value;
            HapticFeedback.selectionClick();
          },
        ),
      ],
    );
  }

  Widget _buildInterfaceSettings(BuildContext context, WidgetRef ref) {
    final focusMode = ref.watch(enhancedReaderFocusModeProvider);

    return Column(
      children: [
        _buildSwitchSetting(
          context: context,
          label: 'Mode focus',
          subtitle: 'Masquer les distractions',
          value: focusMode,
          onChanged: (value) {
            ref.read(enhancedReaderFocusModeProvider.notifier).state = value;
            HapticFeedback.lightImpact();
          },
        ),
      ],
    );
  }

  Widget _buildSliderSetting({
    required BuildContext context,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayValue,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSwitchSetting({
    required BuildContext context,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Obtenir la couleur de fond pour un thème de lecteur
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
}
