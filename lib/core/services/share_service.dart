import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spiritual_routines/core/adapters/share.dart';
import 'package:spiritual_routines/core/adapters/share_adapter.dart';
import '../utils/app_logger.dart';
import 'analytics_service.dart';

/// Service de partage social des statistiques
///
/// Permet de créer et partager des cartes visuelles des accomplissements
/// spirituels sur les réseaux sociaux
class ShareService {
  static ShareService? _instance;

  // Services
  final AnalyticsService _analyticsService = AnalyticsService.instance;

  // Configuration
  static const String _shareFolder = 'spiritual_routines_shares';
  static const Size _defaultCardSize =
      Size(1080, 1080); // Format carré Instagram
  static const Size _storySize = Size(1080, 1920); // Format story

  // Singleton
  static ShareService get instance {
    _instance ??= ShareService._();
    return _instance!;
  }

  ShareService._();

  // ===== Création de cartes visuelles =====

  /// Créer une carte de streak
  Future<ShareCard> createStreakCard({
    required StreakData streak,
    ShareCardStyle style = ShareCardStyle.modern,
    String? customMessage,
  }) async {
    try {
      AppLogger.logDebugInfo('Creating streak card', {
        'currentStreak': streak.currentStreak,
        'style': style.name,
      });

      // Créer le widget de la carte
      final widget = _StreakCardWidget(
        streak: streak,
        style: style,
        message: customMessage,
      );

      // Convertir en image
      final imageBytes = await _widgetToImage(widget, _defaultCardSize);

      // Sauvegarder l'image
      final fileName = 'streak_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await _saveImageToFile(fileName, imageBytes);

      // Générer le message de partage
      final shareMessage = customMessage ??
          '🔥 ${streak.currentStreak} jours de pratique spirituelle consécutive !\n'
              '#RoutinesSpirituelle #Streak #Motivation';

      AppLogger.logUserAction('streak_card_created', {
        'streak': streak.currentStreak,
      });

      return ShareCard(
        imagePath: file.path,
        message: shareMessage,
        type: ShareCardType.streak,
      );
    } catch (e) {
      AppLogger.logError('Failed to create streak card', e);
      rethrow;
    }
  }

  /// Créer une carte de milestone
  Future<ShareCard> createMilestoneCard({
    required Milestone milestone,
    ShareCardStyle style = ShareCardStyle.modern,
    String? customMessage,
  }) async {
    try {
      AppLogger.logDebugInfo('Creating milestone card', {
        'milestone': milestone.value,
        'type': milestone.type,
      });

      // Créer le widget de la carte
      final widget = _MilestoneCardWidget(
        milestone: milestone,
        style: style,
        message: customMessage,
      );

      // Convertir en image
      final imageBytes = await _widgetToImage(widget, _defaultCardSize);

      // Sauvegarder l'image
      final fileName = 'milestone_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await _saveImageToFile(fileName, imageBytes);

      // Générer le message de partage
      final shareMessage = customMessage ??
          '🏆 J\'ai atteint ${_formatMilestoneValue(milestone.value)} ${milestone.type} !\n'
              '${milestone.description}\n'
              '#Accomplissement #RoutinesSpirituelle #Milestone';

      AppLogger.logUserAction('milestone_card_created', {
        'milestone': milestone.value,
        'type': milestone.type,
      });

      return ShareCard(
        imagePath: file.path,
        message: shareMessage,
        type: ShareCardType.milestone,
      );
    } catch (e) {
      AppLogger.logError('Failed to create milestone card', e);
      rethrow;
    }
  }

  /// Créer une carte de statistiques mensuelles
  Future<ShareCard> createMonthlyStatsCard({
    required MonthlyMetrics metrics,
    ShareCardStyle style = ShareCardStyle.modern,
    String? customMessage,
  }) async {
    try {
      AppLogger.logDebugInfo('Creating monthly stats card');

      // Créer le widget de la carte
      final widget = _MonthlyStatsCardWidget(
        metrics: metrics,
        style: style,
        message: customMessage,
      );

      // Convertir en image
      final imageBytes = await _widgetToImage(widget, _defaultCardSize);

      // Sauvegarder l'image
      final fileName = 'monthly_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await _saveImageToFile(fileName, imageBytes);

      // Générer le message de partage
      final progressText = metrics.progressionPercent > 0
          ? '📈 +${metrics.progressionPercent}% vs mois dernier'
          : '';

      final shareMessage = customMessage ??
          '📊 Mes statistiques du mois :\n'
              '• ${metrics.totalRepetitions} répétitions\n'
              '• ${metrics.totalSessions} sessions complétées\n'
              '• ${metrics.activeDays} jours actifs\n'
              '$progressText\n'
              '#StatsSpirituelle #Progression #Motivation';

      AppLogger.logUserAction('monthly_card_created', {
        'repetitions': metrics.totalRepetitions,
        'sessions': metrics.totalSessions,
      });

      return ShareCard(
        imagePath: file.path,
        message: shareMessage,
        type: ShareCardType.monthlyStats,
      );
    } catch (e) {
      AppLogger.logError('Failed to create monthly stats card', e);
      rethrow;
    }
  }

  /// Créer une story de progression
  Future<ShareCard> createProgressStory({
    required List<ChartData> progressData,
    required String title,
    ShareCardStyle style = ShareCardStyle.story,
    String? customMessage,
  }) async {
    try {
      AppLogger.logDebugInfo('Creating progress story');

      // Créer le widget de la story
      final widget = _ProgressStoryWidget(
        progressData: progressData,
        title: title,
        style: style,
      );

      // Convertir en image (format story)
      final imageBytes = await _widgetToImage(widget, _storySize);

      // Sauvegarder l'image
      final fileName = 'story_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await _saveImageToFile(fileName, imageBytes);

      // Générer le message de partage
      final shareMessage = customMessage ??
          '📈 Ma progression spirituelle\n'
              '#ProgressionSpirituelle #Motivation #Story';

      AppLogger.logUserAction('progress_story_created');

      return ShareCard(
        imagePath: file.path,
        message: shareMessage,
        type: ShareCardType.story,
      );
    } catch (e) {
      AppLogger.logError('Failed to create progress story', e);
      rethrow;
    }
  }

  // ===== Partage =====

  /// Partager une carte
  Future<bool> shareCard(ShareCard card) async {
    try {
      final share = getShareAdapter();
      await share.shareFiles([card.imagePath], text: card.message);

      AppLogger.logUserAction('card_shared', {
        'type': card.type.name,
      });

      return true;
    } catch (e) {
      AppLogger.logError('Failed to share card', e);
      return false;
    }
  }

  /// Partager du texte simple
  Future<bool> shareText({
    required String text,
    String? subject,
  }) async {
    try {
      final share = getShareAdapter();
      await share.shareText(text, subject: subject);

      AppLogger.logUserAction('text_shared');

      return true;
    } catch (e) {
      AppLogger.logError('Failed to share text', e);
      return false;
    }
  }

  /// Partager un lien d'invitation
  Future<bool> shareInviteLink() async {
    const appStoreLink = 'https://apps.apple.com/app/spiritual-routines';
    const playStoreLink =
        'https://play.google.com/store/apps/details?id=com.spiritual.routines';

    final message = '🕌 Rejoins-moi sur Spiritual Routines !\n\n'
        'Une app pour maintenir tes routines spirituelles avec :\n'
        '• Compteur de dhikr intelligent\n'
        '• Suivi de progression\n'
        '• Rappels personnalisés\n'
        '• Mode hors-ligne complet\n\n'
        'Télécharger sur iOS: $appStoreLink\n'
        'Télécharger sur Android: $playStoreLink';

    return shareText(
      text: message,
      subject: 'Invitation - Spiritual Routines',
    );
  }

  // ===== Templates prédéfinis =====

  /// Obtenir les messages de partage prédéfinis
  List<ShareTemplate> getShareTemplates() {
    return [
      ShareTemplate(
        id: 'daily_achievement',
        title: 'Accomplissement du jour',
        message: '✅ Session de prière complétée aujourd\'hui !\n'
            'Chaque jour compte dans le voyage spirituel.\n'
            '#RoutineQuotidienne #Spiritualité',
        icon: Icons.check_circle,
      ),
      ShareTemplate(
        id: 'weekly_summary',
        title: 'Résumé hebdomadaire',
        message: '📊 Une semaine de pratique spirituelle accomplie !\n'
            'La constance est la clé du succès.\n'
            '#BilanHebdomadaire #Persévérance',
        icon: Icons.calendar_today,
      ),
      ShareTemplate(
        id: 'motivation',
        title: 'Message de motivation',
        message: '💪 La pratique spirituelle renforce l\'âme.\n'
            'Continuons ensemble sur ce chemin !\n'
            '#Motivation #Ensemble',
        icon: Icons.favorite,
      ),
      ShareTemplate(
        id: 'gratitude',
        title: 'Gratitude',
        message: '🙏 Reconnaissant pour cette opportunité de pratique.\n'
            'Chaque répétition est une bénédiction.\n'
            '#Gratitude #Bénédiction',
        icon: Icons.volunteer_activism,
      ),
      ShareTemplate(
        id: 'invite_friends',
        title: 'Inviter des amis',
        message: '👥 Pratiquons ensemble !\n'
            'Rejoins-moi sur Spiritual Routines pour maintenir nos routines spirituelles.\n'
            '#Communauté #Ensemble',
        icon: Icons.group,
      ),
    ];
  }

  // ===== Helpers =====

  /// Convertir un widget en image
  Future<Uint8List> _widgetToImage(Widget widget, Size size) async {
    final repaintBoundary = RenderRepaintBoundary();
    final renderView = ui.PlatformDispatcher.instance.views.first;

    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    final renderObjectToWidgetElement = RenderObjectToWidgetAdapter(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          width: size.width,
          height: size.height,
          child: widget,
        ),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(renderObjectToWidgetElement);
    buildOwner.finalizeTree();

    pipelineOwner.rootNode = repaintBoundary;
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final image = await repaintBoundary.toImage(
      pixelRatio: renderView.devicePixelRatio,
    );

    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return byteData!.buffer.asUint8List();
  }

  /// Sauvegarder une image dans un fichier
  Future<File> _saveImageToFile(String fileName, Uint8List imageBytes) async {
    final directory = await _getShareDirectory();
    final file = File('${directory.path}/$fileName');
    return await file.writeAsBytes(imageBytes);
  }

  /// Obtenir le répertoire de partage
  Future<Directory> _getShareDirectory() async {
    final directory = await getTemporaryDirectory();
    final shareDir = Directory('${directory.path}/$_shareFolder');

    if (!await shareDir.exists()) {
      await shareDir.create(recursive: true);
    }

    return shareDir;
  }

  /// Formater la valeur d'un milestone
  String _formatMilestoneValue(int value) {
    if (value < 1000) {
      return value.toString();
    } else if (value < 1000000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    } else {
      return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M';
    }
  }

  /// Nettoyer les anciennes images
  Future<void> cleanOldShares() async {
    try {
      final directory = await _getShareDirectory();

      await for (final entity in directory.list()) {
        if (entity is File) {
          await entity.delete();
        }
      }

      AppLogger.logDebugInfo('Cleaned old share images');
    } catch (e) {
      AppLogger.logError('Failed to clean old shares', e);
    }
  }
}

// ===== Widgets pour les cartes =====

/// Widget de carte de streak
class _StreakCardWidget extends StatelessWidget {
  final StreakData streak;
  final ShareCardStyle style;
  final String? message;

  const _StreakCardWidget({
    required this.streak,
    required this.style,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 1080,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade400,
            Colors.deepOrange.shade600,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Pattern de fond
          Positioned.fill(
            child: CustomPaint(
              painter: _PatternPainter(),
            ),
          ),

          // Contenu
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône de flamme
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Nombre de jours
                Text(
                  '${streak.currentStreak}',
                  style: const TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1,
                  ),
                ),

                // Label
                Text(
                  'JOURS',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 4,
                  ),
                ),

                const SizedBox(height: 60),

                // Record
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Record : ${streak.longestStreak} jours',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Message personnalisé
                if (message != null) ...[
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Logo/watermark
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Spiritual Routines',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de carte de milestone
class _MilestoneCardWidget extends StatelessWidget {
  final Milestone milestone;
  final ShareCardStyle style;
  final String? message;

  const _MilestoneCardWidget({
    required this.milestone,
    required this.style,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForMilestone(milestone);

    return Container(
      width: 1080,
      height: 1080,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.8),
            color,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Pattern de fond
          Positioned.fill(
            child: CustomPaint(
              painter: _PatternPainter(),
            ),
          ),

          // Contenu
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Valeur
                Text(
                  _formatValue(milestone.value),
                  style: const TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1,
                  ),
                ),

                // Type
                Text(
                  milestone.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 40),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: Text(
                    milestone.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Badge de rareté
                const SizedBox(height: 40),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    _getRarityLabel(milestone.value),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Logo/watermark
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Spiritual Routines',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForMilestone(Milestone milestone) {
    if (milestone.value >= 1000000) {
      return Colors.purple;
    } else if (milestone.value >= 100000) {
      return Colors.amber;
    } else if (milestone.value >= 10000) {
      return Colors.orange;
    } else if (milestone.value >= 1000) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  String _formatValue(int value) {
    if (value < 1000) {
      return value.toString();
    } else if (value < 1000000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    } else {
      return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M';
    }
  }

  String _getRarityLabel(int value) {
    if (value >= 1000000) {
      return 'LÉGENDAIRE';
    } else if (value >= 100000) {
      return 'ÉPIQUE';
    } else if (value >= 10000) {
      return 'RARE';
    } else if (value >= 1000) {
      return 'SPÉCIAL';
    } else {
      return 'COMMUN';
    }
  }
}

/// Widget de carte de statistiques mensuelles
class _MonthlyStatsCardWidget extends StatelessWidget {
  final MonthlyMetrics metrics;
  final ShareCardStyle style;
  final String? message;

  const _MonthlyStatsCardWidget({
    required this.metrics,
    required this.style,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 1080,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Pattern de fond
          Positioned.fill(
            child: CustomPaint(
              painter: _PatternPainter(),
            ),
          ),

          // Contenu
          Padding(
            padding: const EdgeInsets.all(80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Titre
                const Text(
                  'STATISTIQUES DU MOIS',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 60),

                // Stats principales
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatColumn(
                      value: '${metrics.totalRepetitions}',
                      label: 'RÉPÉTITIONS',
                    ),
                    _StatColumn(
                      value: '${metrics.totalSessions}',
                      label: 'SESSIONS',
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatColumn(
                      value: '${metrics.activeDays}',
                      label: 'JOURS ACTIFS',
                    ),
                    _StatColumn(
                      value:
                          '${(metrics.totalDuration / 3600).toStringAsFixed(1)}h',
                      label: 'TEMPS TOTAL',
                    ),
                  ],
                ),

                // Progression
                if (metrics.progressionPercent != 0) ...[
                  const SizedBox(height: 60),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          metrics.progressionPercent > 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${metrics.progressionPercent > 0 ? '+' : ''}${metrics.progressionPercent}%',
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'vs mois dernier',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Logo/watermark
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Spiritual Routines',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Colonne de statistique
class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

/// Widget de story de progression
class _ProgressStoryWidget extends StatelessWidget {
  final List<ChartData> progressData;
  final String title;
  final ShareCardStyle style;

  const _ProgressStoryWidget({
    required this.progressData,
    required this.title,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 1920,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(60),
          child: Column(
            children: [
              const SizedBox(height: 100),

              // Titre
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 100),

              // Graphique
              Container(
                height: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomPaint(
                  painter: _SimpleChartPainter(
                    data: progressData,
                    color: Colors.white,
                  ),
                  child: Container(),
                ),
              ),

              const SizedBox(height: 80),

              // Stats résumées
              _buildStatsSummary(),

              const Spacer(),

              // Call to action
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.touch_app,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Swipe up pour en savoir plus',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Logo
              Text(
                'Spiritual Routines',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    final total = progressData.fold<double>(
      0,
      (sum, data) => sum + data.value,
    );
    final average = total / progressData.length;
    final max = progressData.map((d) => d.value).reduce(
          (a, b) => a > b ? a : b,
        );

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildStatRow('Total', total.round().toString()),
          const SizedBox(height: 16),
          _buildStatRow('Moyenne', average.round().toString()),
          const SizedBox(height: 16),
          _buildStatRow('Maximum', max.round().toString()),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Painter pour les patterns de fond
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Dessiner des cercles en pattern
    const spacing = 80.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(
          Offset(x, y),
          20,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter pour graphique simple
class _SimpleChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Color color;

  _SimpleChartPainter({
    required this.data,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final xStep = size.width / (data.length - 1).clamp(1, double.infinity);

    for (int i = 0; i < data.length; i++) {
      final x = i * xStep;
      final normalizedValue = data[i].value / maxValue;
      final y = size.height -
          (normalizedValue * size.height * 0.8) -
          size.height * 0.1;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Point
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }

    // Fermer le chemin de remplissage
    if (data.isNotEmpty) {
      fillPath.lineTo((data.length - 1) * xStep, size.height);
      fillPath.close();
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ===== Modèles =====

/// Styles de cartes
enum ShareCardStyle {
  modern,
  classic,
  minimal,
  story,
}

/// Types de cartes
enum ShareCardType {
  streak,
  milestone,
  monthlyStats,
  weeklyStats,
  story,
  custom,
}

/// Carte de partage
class ShareCard {
  final String imagePath;
  final String message;
  final ShareCardType type;

  ShareCard({
    required this.imagePath,
    required this.message,
    required this.type,
  });
}

/// Template de partage
class ShareTemplate {
  final String id;
  final String title;
  final String message;
  final IconData icon;

  ShareTemplate({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
  });
}
