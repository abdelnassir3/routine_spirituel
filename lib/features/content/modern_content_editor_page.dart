import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Imports du design system
import 'package:spiritual_routines/design_system/components/modern_navigation.dart';

// Services
import 'package:spiritual_routines/core/services/content_service.dart';
import 'package:spiritual_routines/core/services/diacritizer_provider.dart';
import 'package:spiritual_routines/core/services/ocr_service.dart';
import 'package:spiritual_routines/core/services/transcription_service.dart';
import 'package:spiritual_routines/core/services/ocr_provider.dart';
import 'package:spiritual_routines/core/services/ocr_service.dart';
import 'package:spiritual_routines/core/services/user_settings_service.dart';
import 'package:spiritual_routines/core/services/ocr_tesseract.dart';
import 'package:spiritual_routines/core/services/ocr_mlkit.dart';
import 'package:spiritual_routines/core/services/task_audio_prefs.dart';
import 'package:spiritual_routines/core/services/audio_player_service.dart';

import 'package:spiritual_routines/features/content/quran_verse_selector.dart';
import 'package:spiritual_routines/core/platform/media_picker_wrapper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class ModernContentEditorPage extends ConsumerStatefulWidget {
  final String taskId;
  const ModernContentEditorPage({super.key, required this.taskId});

  @override
  ConsumerState<ModernContentEditorPage> createState() =>
      _ModernContentEditorPageState();
}

class _ModernContentEditorPageState
    extends ConsumerState<ModernContentEditorPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _source = 'manual';
  final _rawCtrlFR = TextEditingController();
  final _correctedCtrlFR = TextEditingController();
  final _rawCtrlAR = TextEditingController();
  final _correctedCtrlAR = TextEditingController();
  final _diacritizedCtrlAR = TextEditingController();
  bool _busyImport = false;
  bool _busyDiacritize = false;
  String _ocrEngine = 'auto';
  String? _lastImportedTitle;
  int _pdfPageLimit = 5;
  final Map<String, String> _audioSourceByLocale = {
    'fr': 'coqui',
    'ar': 'coqui'
  };
  final Map<String, String?> _audioFileByLocale = {'fr': null, 'ar': null};

  // États d'animation et d'interaction
  final GlobalKey _audioSectionKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadExisting();
  }

  @override
  void dispose() {
    _rawCtrlFR.dispose();
    _correctedCtrlFR.dispose();
    _rawCtrlAR.dispose();
    _correctedCtrlAR.dispose();
    _diacritizedCtrlAR.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    try {
      // Charger les textes existants
      final svc = ref.read(contentServiceProvider);
      final fr = await svc.getEditingBodies(widget.taskId, 'fr');
      final ar = await svc.getEditingBodies(widget.taskId, 'ar');

      if (mounted) {
        setState(() {
          _rawCtrlFR.text = fr.$1 ?? '';
          _correctedCtrlFR.text = fr.$2 ?? '';
          _rawCtrlAR.text = ar.$1 ?? '';
          _correctedCtrlAR.text = ar.$2 ?? '';
          _diacritizedCtrlAR.text = ar.$3 ?? '';
        });
      }

      // Charger les préférences audio
      final frAudio = await ref
          .read(taskAudioPrefsProvider)
          .getForTaskLocale(widget.taskId, 'fr');
      final arAudio = await ref
          .read(taskAudioPrefsProvider)
          .getForTaskLocale(widget.taskId, 'ar');

      if (mounted) {
        setState(() {
          _audioSourceByLocale['fr'] = frAudio.source;
          _audioFileByLocale['fr'] = frAudio.filePath;
          _audioSourceByLocale['ar'] = arAudio.source;
          _audioFileByLocale['ar'] = arAudio.filePath;
        });
      }

      // Charger préférence OCR
      final engine = await ref.read(userSettingsServiceProvider).getOcrEngine();
      final limit =
          await ref.read(userSettingsServiceProvider).getOcrPdfPageLimit();
      if (mounted)
        setState(() {
          _ocrEngine = engine;
          _pdfPageLimit = limit;
        });
    } catch (e) {
      debugPrint('Erreur lors du chargement: $e');
    }
  }

  String _getAudioSourceLabel(String source) {
    switch (source) {
      case 'device':
        return 'TTS générique';
      case 'cloud':
        return 'Voix neurale';
      case 'file':
        return 'Fichier audio';
      default:
        return source;
    }
  }

  IconData _getAudioIcon(String source) {
    switch (source) {
      case 'device':
        return Icons.phone_android_rounded;
      case 'cloud':
        return Icons.cloud_rounded;
      case 'file':
        return Icons.audio_file_rounded;
      default:
        return Icons.volume_up_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Header moderne avec gradient
            SliverToBoxAdapter(
              child: _buildModernHeader(context),
            ),

            // Contenu principal
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: _buildContentEditor(context),
              ),
            ),
          ],
        ),
      ),

      // Navigation moderne
      bottomNavigationBar: ModernBottomNavigation(
        currentIndex: 1, // Routines tab actif
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/routines');
              break;
            case 2:
              context.go('/reader');
              break;
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

  Widget _buildModernHeader(BuildContext context) {
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
              // Barre de navigation supérieure
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
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Titre et sous-titre
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Édition de contenu',
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
                          'Personnalisez votre contenu spirituel',
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

                  // Actions uniformisées
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
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
                          onPressed: _saveAudioSettings,
                          icon: const Icon(
                            Icons.audiotrack_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
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
                          onPressed: _saveContent,
                          icon: const Icon(
                            Icons.save_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
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

  Widget _buildContentEditor(BuildContext context) {
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
        children: [
          // En-tête avec tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
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
                    Icons.edit_note_rounded,
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
                        'Contenu de la tâche',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Éditez le texte en français et arabe',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TabBar moderne
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              tabs: const [
                Tab(text: 'Français'),
                Tab(text: 'العربية'),
              ],
            ),
          ),

          // TabBarView avec hauteur flexible
          SizedBox(
            height: MediaQuery.of(context).size.height *
                0.7, // 70% de la hauteur de l'écran
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  child: _buildLanguageEditor('fr'),
                ),
                SingleChildScrollView(
                  child: _buildLanguageEditor('ar'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLanguageEditor(String language) {
    final theme = Theme.of(context);
    final isArabic = language == 'ar';
    final rawCtrl = isArabic ? _rawCtrlAR : _rawCtrlFR;
    final correctedCtrl = isArabic ? _correctedCtrlAR : _correctedCtrlFR;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // Section audio ultra-moderne
          _buildModernAudioSection(language),
          const SizedBox(height: 12),

          // Section source avec design époustouflant
          _buildSourceSelector(language),
          const SizedBox(height: 12),

          // Sélecteur de moteur OCR
          if (_source == 'image_ocr' || _source == 'pdf_ocr') ...[
            _buildOcrEngineSelector(),
            const SizedBox(height: 12),
            if (_source == 'pdf_ocr') _buildPdfLimitSelector(),
            const SizedBox(height: 12),
          ],

          // Sélecteur de versets Coran si nécessaire
          if (_source == 'quran_verses' && isArabic) ...[
            _buildQuranSelector(language),
            const SizedBox(height: 12),
          ],

          // Section d'import avec animations
          if (_source != 'quran_verses') _buildImportSection(language),

          const SizedBox(height: 12),

          // Champs de texte avec design époustouflant
          _buildTextFields(language),
        ],
      ),
    );
  }

  // Nouvelle section audio ultra-moderne
  Widget _buildModernAudioSection(String language) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentSource = _audioSourceByLocale[language]!;
    final hasFile = _audioFileByLocale[language] != null;

    return Container(
      key: language == 'fr' ? _audioSectionKey : null,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withOpacity(0.4),
            cs.primaryContainer.withOpacity(0.1),
            cs.secondaryContainer.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showModernAudioOptions(language),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Icône animée
                Hero(
                  tag: 'audio_icon_$language',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.primary,
                          cs.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getAudioIcon(currentSource),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                // Informations audio
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configuration Audio',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getAudioSourceLabel(currentSource),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      if (hasFile && currentSource == 'file') ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.audiotrack_rounded,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                p.basename(_audioFileByLocale[language]!),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Actions rapides
                Column(
                  children: [
                    if (hasFile && currentSource == 'file')
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () => _playAudioFile(language),
                          icon: const Icon(
                            Icons.play_circle_fill_rounded,
                            color: Colors.green,
                            size: 28,
                          ),
                          tooltip: 'Écouter',
                        ),
                      ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () => _showModernAudioOptions(language),
                        icon: Icon(
                          Icons.settings_rounded,
                          color: cs.onSurfaceVariant,
                          size: 20,
                        ),
                        tooltip: 'Configurer',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Section de sélection de source moderne
  Widget _buildSourceSelector(String language) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withOpacity(0.1),
                        cs.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.source_rounded,
                    color: cs.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Source du contenu',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildModernSourceChip(
                    label: 'Saisie manuelle',
                    icon: Icons.keyboard_rounded,
                    value: 'manual',
                    gradient: [cs.secondary, cs.secondary.withOpacity(0.8)],
                    maxWidth: constraints.maxWidth,
                  ),
                  if (language == 'ar')
                    _buildModernSourceChip(
                      label: 'Versets Coran',
                      icon: Icons.menu_book_rounded,
                      value: 'quran_verses',
                      gradient: [Colors.green, Colors.green.withOpacity(0.8)],
                      maxWidth: constraints.maxWidth,
                    ),
                  _buildModernSourceChip(
                    label: 'Image OCR',
                    icon: Icons.image_rounded,
                    value: 'image_ocr',
                    gradient: [Colors.orange, Colors.orange.withOpacity(0.8)],
                    maxWidth: constraints.maxWidth,
                  ),
                  _buildModernSourceChip(
                    label: 'PDF OCR',
                    icon: Icons.picture_as_pdf_rounded,
                    value: 'pdf_ocr',
                    gradient: [Colors.red, Colors.red.withOpacity(0.8)],
                    maxWidth: constraints.maxWidth,
                  ),
                  _buildModernSourceChip(
                    label: 'Audio → Texte',
                    icon: Icons.mic_rounded,
                    value: 'audio_transcription',
                    gradient: [Colors.purple, Colors.purple.withOpacity(0.8)],
                    maxWidth: constraints.maxWidth,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sélecteur de moteur OCR (Auto/MLKit/Tesseract/Stub)
  Widget _buildOcrEngineSelector() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget chip(String label, String value) {
      final selected = _ocrEngine == value;
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (v) async {
          if (!v) return;
          setState(() => _ocrEngine = value);
          await ref.read(userSettingsServiceProvider).setOcrEngine(value);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Moteur OCR: $label'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: cs.primary),
              const SizedBox(width: 8),
              Text('Moteur OCR',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              chip('Auto', 'auto'),
              chip('MLKit', 'mlkit'),
              chip('Vision (macOS)', 'vision'),
              chip('Tesseract', 'tesseract'),
              chip('Stub', 'stub'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPdfLimitSelector() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final List<int> presets = [1, 3, 5, 10];
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.picture_as_pdf_rounded, color: cs.primary),
              const SizedBox(width: 8),
              Text('Pages PDF maximum',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('$_pdfPageLimit', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: presets
                .map((n) => ChoiceChip(
                      label: Text('$n'),
                      selected: _pdfPageLimit == n,
                      onSelected: (v) async {
                        if (!v) return;
                        setState(() => _pdfPageLimit = n);
                        await ref
                            .read(userSettingsServiceProvider)
                            .setOcrPdfPageLimit(n);
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // Chip de source moderne avec gradient
  Widget _buildModernSourceChip({
    required String label,
    required IconData icon,
    required String value,
    required List<Color> gradient,
    required double maxWidth,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isSelected = _source == value;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: (maxWidth - 16) / 2, // 2 colonnes avec espacement
        minWidth: 120,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: gradient) : null,
          color:
              isSelected ? null : cs.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? gradient[0].withOpacity(0.3)
                : cs.outlineVariant.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _source = value),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected ? Colors.white : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : cs.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
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

  void _saveAudioSettings() async {
    final theme = Theme.of(context);

    try {
      // Sauvegarder les préférences audio
      await ref.read(taskAudioPrefsProvider).setForTaskLocale(
            widget.taskId,
            'fr',
            TaskLangAudio(
                source: _audioSourceByLocale['fr']!,
                filePath: _audioFileByLocale['fr']),
          );
      await ref.read(taskAudioPrefsProvider).setForTaskLocale(
            widget.taskId,
            'ar',
            TaskLangAudio(
                source: _audioSourceByLocale['ar']!,
                filePath: _audioFileByLocale['ar']),
          );

      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.audiotrack_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Préférences audio sauvegardées',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: theme.colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde audio: $e'),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _saveContent() async {
    final theme = Theme.of(context);

    // Animation de feedback
    HapticFeedback.mediumImpact();

    try {
      final contentSvc = ref.read(contentServiceProvider);

      // Assurer que les sources sont définies AVANT les updates
      await contentSvc.setSource(
        taskId: widget.taskId,
        locale: 'fr',
        source: _source,
      );
      await contentSvc.setSource(
        taskId: widget.taskId,
        locale: 'ar',
        source: _source,
      );

      // Sauvegarder tous les champs
      await contentSvc.updateRaw(
        taskId: widget.taskId,
        locale: 'fr',
        raw: _rawCtrlFR.text,
      );
      await contentSvc.updateCorrected(
        taskId: widget.taskId,
        locale: 'fr',
        corrected: _correctedCtrlFR.text,
      );
      await contentSvc.updateRaw(
        taskId: widget.taskId,
        locale: 'ar',
        raw: _rawCtrlAR.text,
      );
      await contentSvc.updateCorrected(
        taskId: widget.taskId,
        locale: 'ar',
        corrected: _correctedCtrlAR.text,
      );
      await contentSvc.updateDiacritized(
        taskId: widget.taskId,
        locale: 'ar',
        diacritized: _diacritizedCtrlAR.text,
      );

      // Note: Les préférences audio sont sauvegardées séparément via le bouton audio
      // pour éviter les problèmes de dépendances de base de données

      // Finaliser et valider le contenu (CRITIQUE pour créer l'entité complète)
      await contentSvc.validateAndFinalize(
        taskId: widget.taskId,
        locale: _tabController.index == 0 ? 'fr' : 'ar',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Contenu sauvegardé avec succès',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Erreur de sauvegarde: $e',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _diacritizeText() async {
    if (_correctedCtrlAR.text.trim().isEmpty) return;

    setState(() => _busyDiacritize = true);
    try {
      final diacritizer = await ref.read(diacritizerProvider.future);
      final result = await diacritizer.diacritize(_correctedCtrlAR.text.trim());
      if (mounted) {
        _diacritizedCtrlAR.text = result;
        _correctedCtrlAR.text = result;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de vocalisation: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busyDiacritize = false);
    }
  }

  void _showQuranSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => QuranVerseSelector(
        locale: 'ar', // Pour le Coran, on utilise l'arabe
        onVersesSelected: (versesText, versesRefs) {
          // Ajouter les versets sélectionnés au texte arabe
          final currentText = _correctedCtrlAR.text;
          final newText =
              currentText.isEmpty ? versesText : '$currentText\n\n$versesText';

          _correctedCtrlAR.text = newText;

          // Fermer le modal
          Navigator.pop(context);

          // Afficher un message de confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Versets ajoutés au texte arabe')),
          );
        },
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void _importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        if (mounted) {
          _correctedCtrlFR.text = content;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fichier importé avec succès')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'importation: $e')),
        );
      }
    }
  }

  // Sélecteur de versets Coran intégré
  Widget _buildQuranSelector(String language) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: QuranVerseSelector(
          locale: language,
          onVersesSelected: (versesText, versesRefs) async {
            print('🔧 DEBUG EDITOR: onVersesSelected appelé');
            print('🔧 DEBUG EDITOR: versesText length: ${versesText.length}');
            print('🔧 DEBUG EDITOR: versesRefs: $versesRefs');
            print('🔧 DEBUG EDITOR: versesText COMPLET: "$versesText"');

            final content = ref.read(contentServiceProvider);

            // Mettre à jour les contrôleurs de texte
            setState(() {
              print('🔧 DEBUG EDITOR: Mise à jour des contrôleurs');
              _rawCtrlAR.text = versesText;
              if (_correctedCtrlAR.text.isEmpty) {
                _correctedCtrlAR.text = versesText;
              }
            });

            // Sauvegarder dans la base de données
            await content.setSource(
                taskId: widget.taskId,
                locale: language,
                source: 'quran_verses');
            await content.updateRaw(
                taskId: widget.taskId, locale: language, raw: versesText);
            await content.updateCorrected(
              taskId: widget.taskId,
              locale: language,
              corrected: _correctedCtrlAR.text,
            );

            // Ajouter les références comme métadonnées
            await content.putContent(
              taskId: widget.taskId,
              locale: language,
              kind: 'verses',
              title: versesRefs,
              body: versesText,
            );

            // Feedback utilisateur
            if (mounted) {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Versets ajoutés avec succès'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // Section d'import avec animations
  Widget _buildImportSection(String language) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isArabic = language == 'ar';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.tertiaryContainer.withOpacity(0.3),
            cs.tertiaryContainer.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.tertiary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primary,
                      cs.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _busyImport ? null : () => _performImport(language),
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: _busyImport
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    'Importation...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getImportIcon(),
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    _getImportLabel(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _busyImport
                      ? null
                      : () => _importFromManualPath(language),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_open_rounded,
                            color: cs.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text('Chemin...',
                            style: TextStyle(color: cs.onSurface)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (isArabic) ...[
              const SizedBox(width: 16),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.secondary,
                      cs.secondary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cs.secondary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _busyDiacritize ? null : () => _diacritizeText(),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Center(
                        child: _busyDiacritize
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Vocalisation...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Vocaliser',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Champs de texte époustouflants
  Widget _buildTextFields(String language) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isArabic = language == 'ar';
    final rawCtrl = isArabic ? _rawCtrlAR : _rawCtrlFR;
    final correctedCtrl = isArabic ? _correctedCtrlAR : _correctedCtrlFR;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Champ texte brut
        _buildModernTextField(
          controller: rawCtrl,
          title: 'Texte brut (OCR/Transcription)',
          subtitle: 'Texte importé automatiquement',
          icon: Icons.raw_on_rounded,
          iconColor: Colors.orange,
          isArabic: isArabic,
          maxLines: 6,
          onChanged: (value) {
            ref.read(contentServiceProvider).updateRaw(
                  taskId: widget.taskId,
                  locale: language,
                  raw: value,
                );
          },
        ),

        const SizedBox(height: 20),

        // Champ texte corrigé
        _buildModernTextField(
          controller: correctedCtrl,
          title: 'Texte corrigé',
          subtitle: 'Version finale pour la lecture',
          icon: Icons.edit_rounded,
          iconColor: Colors.blue,
          isArabic: isArabic,
          maxLines: 8,
          onChanged: (value) {
            ref.read(contentServiceProvider).updateCorrected(
                  taskId: widget.taskId,
                  locale: language,
                  corrected: value,
                );
          },
        ),

        if (isArabic) ...[
          const SizedBox(height: 20),

          // Champ texte vocalisé
          _buildModernTextField(
            controller: _diacritizedCtrlAR,
            title: 'Avec voyelles (Tashkīl)',
            subtitle: 'Texte arabe avec diacritiques',
            icon: Icons.auto_awesome_rounded,
            iconColor: Colors.purple,
            isArabic: true,
            maxLines: 8,
            onChanged: (value) {
              ref.read(contentServiceProvider).updateDiacritized(
                    taskId: widget.taskId,
                    locale: 'ar',
                    diacritized: value,
                  );
            },
          ),
        ],
      ],
    );
  }

  // Champ de texte moderne avec design époustouflant
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isArabic,
    required int maxLines,
    required ValueChanged<String> onChanged,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface,
            cs.surfaceContainerHighest.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du champ
          Container(
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Champ de texte avec support des marqueurs de versets
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildTextFieldWithVerseSupport(
              controller: controller,
              maxLines: maxLines,
              isArabic: isArabic,
              iconColor: iconColor,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget combiné qui supporte l'édition ET l'affichage des marqueurs de versets
  Widget _buildTextFieldWithVerseSupport({
    required TextEditingController controller,
    required int maxLines,
    required bool isArabic,
    required Color iconColor,
    required ValueChanged<String> onChanged,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Vérifier si le texte contient des marqueurs de versets
    final hasVerseMarkers =
        controller.text.contains(RegExp(r'\{\{V:\d+(?::\d+)?\}\}'));

    print('🔧 DEBUG: _buildTextFieldWithVerseSupport appelé');
    print('🔧 DEBUG: controller.text.length = ${controller.text.length}');
    print('🔧 DEBUG: hasVerseMarkers = $hasVerseMarkers');
    if (controller.text.isNotEmpty) {
      print(
          '🔧 DEBUG: Premier 100 caractères: ${controller.text.substring(0, controller.text.length > 100 ? 100 : controller.text.length)}');
    }

    if (hasVerseMarkers) {
      // Mode affichage avec marqueurs transformés en cercles
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: cs.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(16),
          color: cs.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affichage formaté avec cercles de versets
            _buildTextWithVerseNumbers(
              controller.text,
              theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: isArabic ? 'NotoNaskhArabic' : 'Inter',
                    fontSize: 16,
                    height: 1.6,
                    color: cs.onSurface,
                  ) ??
                  const TextStyle(),
              isArabic,
              false, // pas de justification
            ),
            const SizedBox(height: 16),
            // Bouton pour passer en mode édition
            TextButton.icon(
              onPressed: () => _showEditDialog(controller, isArabic, onChanged),
              icon: const Icon(Icons.edit),
              label: Text(isArabic ? 'تعديل النص' : 'Modifier le texte'),
            ),
          ],
        ),
      );
    } else {
      // Mode édition standard
      return TextField(
        controller: controller,
        maxLines: maxLines,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: isArabic ? 'NotoNaskhArabic' : 'Inter',
          fontSize: 16,
          height: 1.6,
          color: cs.onSurface,
        ),
        decoration: InputDecoration(
          hintText: isArabic
              ? 'اكتب النص باللغة العربية هنا...'
              : 'Saisissez le texte français ici...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: cs.outline.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: cs.outline.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: iconColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: cs.surface,
          contentPadding: const EdgeInsets.all(16),
          hintStyle: TextStyle(
            color: cs.onSurfaceVariant.withOpacity(0.6),
            fontFamily: isArabic ? 'NotoNaskhArabic' : 'Inter',
          ),
        ),
        onChanged: onChanged,
      );
    }
  }

  /// Dialog pour éditer le texte avec marqueurs
  void _showEditDialog(TextEditingController controller, bool isArabic,
      ValueChanged<String> onChanged) {
    final editController = TextEditingController(text: controller.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'تعديل النص' : 'Modifier le texte'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: TextField(
            controller: editController,
            maxLines: null,
            expands: true,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isArabic ? 'إلغاء' : 'Annuler'),
          ),
          FilledButton(
            onPressed: () {
              controller.text = editController.text;
              onChanged(editController.text);
              setState(() {}); // Rafraîchir l'affichage
              Navigator.of(context).pop();
            },
            child: Text(isArabic ? 'حفظ' : 'Sauvegarder'),
          ),
        ],
      ),
    );
  }

  /// Crée un cercle avec le numéro de verset (copié de reading_session_page.dart)
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

  /// Convertit le texte avec marqueurs en RichText avec cercles de verset (copié de reading_session_page.dart)
  Widget _buildTextWithVerseNumbers(
      String text, TextStyle style, bool isArabic, bool justify) {
    // Support pour les deux formats : {{V:verset}} et {{V:sourate:verset}}
    final versePattern = RegExp(r'\{\{V:(\d+)(?::(\d+))?\}\}');
    final matches = versePattern.allMatches(text);

    final spans = <InlineSpan>[];
    int lastIndex = 0;

    for (final match in versePattern.allMatches(text)) {
      // Ajouter le texte avant le marqueur
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: style,
        ));
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

    // Ajouter le texte restant
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: style,
      ));
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      textAlign: justify
          ? TextAlign.justify
          : (isArabic ? TextAlign.right : TextAlign.left),
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
    );
  }

  // Méthodes utilitaires pour l'import
  IconData _getImportIcon() {
    switch (_source) {
      case 'image_ocr':
        return Icons.image_rounded;
      case 'pdf_ocr':
        return Icons.picture_as_pdf_rounded;
      case 'audio_transcription':
        return Icons.mic_rounded;
      default:
        return Icons.upload_file_rounded;
    }
  }

  String _getImportLabel() {
    switch (_source) {
      case 'image_ocr':
        return 'Importer Image';
      case 'pdf_ocr':
        return 'Importer PDF';
      case 'audio_transcription':
        return 'Importer Audio';
      default:
        return 'Importer Fichier';
    }
  }

  Future<void> _performImport(String language) async {
    final isArabic = language == 'ar';
    final content = ref.read(contentServiceProvider);
    final rawCtrl = isArabic ? _rawCtrlAR : _rawCtrlFR;
    final correctedCtrl = isArabic ? _correctedCtrlAR : _correctedCtrlFR;

    setState(() => _busyImport = true);
    HapticFeedback.mediumImpact();

    try {
      await content.setSource(
        taskId: widget.taskId,
        locale: language,
        source: _source,
      );

      String text = '';

      switch (_source) {
        case 'image_ocr':
          text = await _importFromImage(isArabic);
          break;
        case 'pdf_ocr':
          text = await _importFromPdf(isArabic);
          break;
        case 'audio_transcription':
          text = await _importFromAudio(isArabic);
          break;
        default:
          text = await _importFromTextFile();
      }

      if (text.isNotEmpty && mounted) {
        await _applyImportedText(language: language, text: text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Erreur d\'importation: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busyImport = false);
    }
  }

  Future<void> _applyImportedText({
    required String language,
    required String text,
  }) async {
    final isArabic = language == 'ar';
    final content = ref.read(contentServiceProvider);
    final rawCtrl = isArabic ? _rawCtrlAR : _rawCtrlFR;
    final correctedCtrl = isArabic ? _correctedCtrlAR : _correctedCtrlFR;

    final newRaw = rawCtrl.text.isEmpty ? text : '${rawCtrl.text}\n\n$text';
    final newCorrected =
        correctedCtrl.text.isEmpty ? text : '${correctedCtrl.text}\n\n$text';
    if (mounted) {
      setState(() {
        rawCtrl.text = newRaw;
        correctedCtrl.text = newCorrected;
      });
    }
    await content.updateRaw(
        taskId: widget.taskId, locale: language, raw: newRaw);
    await content.updateCorrected(
        taskId: widget.taskId, locale: language, corrected: newCorrected);

    final kind = _source == 'image_ocr'
        ? 'ocr_image'
        : _source == 'pdf_ocr'
            ? 'ocr_pdf'
            : _source;
    await content.putContent(
      taskId: widget.taskId,
      locale: language,
      kind: kind,
      title: _lastImportedTitle,
      body: text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Import terminé avec succès'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<String> _importFromImage(bool isArabic) async {
    // SOLUTION TEMPORAIRE POUR SIMULATEUR iOS
    // Le simulateur iOS a des problèmes avec l'accès natif aux photos

    // Afficher d'abord un choix entre méthodes de sélection
    final String? method = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚨 Simulateur iOS détecté'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Le simulateur iOS peut figer lors de l\'accès aux photos. Choisissez une méthode alternative :',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.folder_open, color: Colors.orange),
              title: const Text('Sélecteur de fichiers'),
              subtitle: const Text('Alternative qui fonctionne sur simulateur'),
              onTap: () => Navigator.pop(context, 'file_picker'),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Chemin manuel'),
              subtitle: const Text('Entrer le chemin d\'une image'),
              onTap: () => Navigator.pop(context, 'manual_path'),
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.green),
              title: const Text('Image de test'),
              subtitle: const Text('Utiliser une image pré-configurée'),
              onTap: () => Navigator.pop(context, 'test_image'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (method == null) return '';

    try {
      String? imagePath;

      switch (method) {
        case 'file_picker':
          // Utiliser FilePicker comme fallback
          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: false,
          );
          if (result?.files.single.path != null) {
            imagePath = result!.files.single.path!;
            _lastImportedTitle = p.basename(imagePath);
          }
          break;

        case 'manual_path':
          // Permettre la saisie manuelle du chemin
          final controller = TextEditingController();
          final path = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Chemin de l\'image'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Entrez le chemin complet vers votre image :'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: '/path/to/your/image.png',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, controller.text.trim()),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          if (path != null && path.isNotEmpty) {
            imagePath = path;
            _lastImportedTitle = p.basename(imagePath);
          }
          break;

        case 'test_image':
          // Utiliser l'image de test créée précédemment
          final testImages = [
            '/Users/mac/Documents/Projet_sprit/assets/test_images/test_french_ocr.png',
            '/Users/mac/Documents/Projet_sprit/assets/test_images/test_arabic_ocr.png',
            '/Users/mac/Documents/Projet_sprit/assets/test_images/simple_arabic_ocr.png',
          ];

          final selectedImage = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Choisir une image de test'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.text_fields),
                    title: const Text('Texte français'),
                    subtitle: const Text('Texte simple français'),
                    onTap: () => Navigator.pop(context, testImages[0]),
                  ),
                  ListTile(
                    leading: const Text('عر', style: TextStyle(fontSize: 18)),
                    title: const Text('Texte arabe (complexe)'),
                    subtitle: const Text('Coran - calligraphie complexe'),
                    onTap: () => Navigator.pop(context, testImages[1]),
                  ),
                  ListTile(
                    leading: const Text('عر',
                        style: TextStyle(fontSize: 18, color: Colors.green)),
                    title: const Text('Texte arabe (simple)'),
                    subtitle: const Text('Invocations - texte simple et clair'),
                    onTap: () => Navigator.pop(context, testImages[2]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
              ],
            ),
          );

          if (selectedImage != null) {
            imagePath = selectedImage;
            _lastImportedTitle = p.basename(imagePath);
          }
          break;
      }

      if (imagePath != null) {
        return await _recognizeImageAuto(imagePath, isArabic: isArabic);
      }

      return '';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return '';
    }
  }

  Future<String> _importFromPdf(bool isArabic) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null ||
        result.files.isEmpty ||
        result.files.single.path == null) {
      return '';
    }
    final path = result.files.single.path!;
    _lastImportedTitle = p.basename(path);
    return await _renderPdfAndRecognize(path,
        isArabic: isArabic, maxPages: _pdfPageLimit);
  }

  Future<String> _recognizeImageAuto(String imagePath,
      {required bool isArabic}) async {
    // Prefer engine based on platform and selected language for best results
    try {
      final engine = _ocrEngine;

      // Debug information
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '🔍 OCR Debug: ${isArabic ? "Arabe" : "Français"} - ${kIsWeb ? "Web" : Platform.operatingSystem} - Engine: $engine'),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Note: Tesseract logic removed. OCR provider handles service selection automatically.
      // iOS uses MacosVisionOcrService with improved Arabic support
      // Android can use MlkitOcrService or TesseractOcrService based on user preference

      // Otherwise, use provider-selected engine
      final ocr = await ref.read(ocrProvider.future);

      // Debug OCR service info
      if (mounted) {
        final serviceName = ocr.runtimeType.toString();
        final platformInfo = kIsWeb ? "Web" : Platform.operatingSystem;
        final languageInfo = isArabic ? "Arabe" : "Français";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '🔧 $serviceName sur $platformInfo - $languageInfo - ${p.basename(imagePath)}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.blueGrey,
          ),
        );
      }

      final text =
          await ocr.recognizeImage(imagePath, language: isArabic ? 'ar' : 'fr');

      // Debug result
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '📊 OCR Résultat: ${text.isEmpty ? "VIDE" : "${text.length} caractères"}'),
            backgroundColor: text.isEmpty ? Colors.red : Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      if (mounted && ocr is StubOcrService) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'OCR (stub) utilisé: résultat indicatif. Activez Vision/Tesseract dans Réglages.')),
        );
      }

      return text;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur OCR: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return '';
    }
  }

  Future<String> _renderPdfAndRecognize(String pdfPath,
      {required bool isArabic, required int maxPages}) async {
    try {
      final doc = await PdfDocument.openFile(pdfPath);
      final pageCount = await doc.pagesCount;
      final buffer = StringBuffer();
      for (int i = 1; i <= pageCount && i <= maxPages; i++) {
        final page = await doc.getPage(i);
        final pageImage =
            await page.render(width: page.width, height: page.height);
        await page.close();
        if (pageImage == null) continue;
        final temp = await _writeTempPng(pageImage.bytes);
        final text = await _recognizeImageAuto(temp.path, isArabic: isArabic);
        if (text.isNotEmpty) buffer.writeln(text);
      }
      return buffer.toString();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur OCR PDF: $e')));
      }
      return '';
    }
  }

  Future<File> _writeTempPng(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file =
        File('${dir.path}/ocr_${DateTime.now().microsecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _importFromManualPath(String language) async {
    final cs = Theme.of(context).colorScheme;
    final ctrl = TextEditingController();
    final isArabic = language == 'ar';
    final ocr = await ref.read(ocrProvider.future);

    // Show choice between file picker and manual path
    final bool useFilePicker = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Importer un fichier'),
            content: const Text(
                'Voulez-vous parcourir vos fichiers ou saisir un chemin manuellement ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Chemin manuel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Parcourir'),
              ),
            ],
          ),
        ) ??
        false;

    String? path;

    if (useFilePicker) {
      // Use appropriate picker for the source
      if (_source == 'image_ocr') {
        try {
          final picker = MediaPickerWrapper();
          final file = await picker.pickImage(source: ImageSource.gallery);
          if (file != null) {
            path = file.path;
          }
        } catch (e) {
          // Fallback to FilePicker if MediaPickerWrapper fails
          final result =
              await FilePicker.platform.pickFiles(type: FileType.image);
          if (result?.files.isNotEmpty == true &&
              result!.files.single.path != null) {
            path = result.files.single.path!;
          }
        }
      } else {
        // For PDF or other files, use FilePicker
        final result = await FilePicker.platform.pickFiles(
          type: _source == 'pdf_ocr' ? FileType.custom : FileType.any,
          allowedExtensions: _source == 'pdf_ocr' ? ['pdf'] : null,
        );
        if (result?.files.isNotEmpty == true &&
            result!.files.single.path != null) {
          path = result.files.single.path!;
        }
      }
    } else {
      // Manual path input
      path = await showDialog<String?>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Chemin du fichier'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
                hintText: '/Chemin/vers/fichier.png ou .pdf'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: const Text('Annuler')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                child: const Text('Importer')),
          ],
        ),
      );
    }
    if (path == null || path.isEmpty) return;

    try {
      _lastImportedTitle = p.basename(path);
      final lower = path.toLowerCase();
      String text;
      if (_source == 'pdf_ocr' || lower.endsWith('.pdf')) {
        text = await ocr.recognizePdf(path, language: isArabic ? 'ar' : 'fr');
      } else {
        text = await ocr.recognizeImage(path, language: isArabic ? 'ar' : 'fr');
      }
      if (text.isNotEmpty) {
        await _applyImportedText(language: language, text: text);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text(
                  'Aucun texte détecté (le moteur OCR sélectionné ne supporte peut-être pas cette langue).'),
              backgroundColor: cs.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: cs.error),
        );
      }
    }
  }

  Future<String> _importFromAudio(bool isArabic) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav', 'mp3', 'm4a'],
    );
    if (result == null ||
        result.files.isEmpty ||
        result.files.single.path == null) {
      return '';
    }

    final path = result.files.single.path!;
    return await StubTranscriptionService().transcribeAudio(
      path,
      language: isArabic ? 'ar' : 'fr',
    );
  }

  Future<String> _importFromTextFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'doc', 'docx'],
    );
    if (result == null ||
        result.files.isEmpty ||
        result.files.single.path == null) {
      return '';
    }

    final file = File(result.files.single.path!);
    return await file.readAsString();
  }

  // Options audio modernes
  void _showModernAudioOptions(String language) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.surface,
              cs.surfaceContainerHighest.withOpacity(0.8),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // Titre avec Hero
              Hero(
                tag: 'audio_title_$language',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
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
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.audio_file_rounded,
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
                              'Options Audio',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            Text(
                              'Configuration pour ${language == 'fr' ? 'Français' : 'العربية'}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Options audio
              _buildModernAudioOption(
                context: context,
                language: language,
                value: 'coqui',
                icon: Icons.record_voice_over_rounded,
                title: 'Coqui TTS',
                subtitle: 'Voix naturelle haute qualité',
                gradient: [Colors.teal, Colors.teal.withOpacity(0.8)],
              ),

              _buildModernAudioOption(
                context: context,
                language: language,
                value: 'device',
                icon: Icons.phone_android_rounded,
                title: 'TTS Générique',
                subtitle: 'Synthèse vocale de l\'appareil',
                gradient: [Colors.blue, Colors.blue.withOpacity(0.8)],
              ),

              _buildModernAudioOption(
                context: context,
                language: language,
                value: 'cloud',
                icon: Icons.cloud_rounded,
                title: 'Voix Neurale',
                subtitle: 'Modèle Cloud haute qualité',
                gradient: [Colors.purple, Colors.purple.withOpacity(0.8)],
              ),

              _buildModernAudioOption(
                context: context,
                language: language,
                value: 'file',
                icon: Icons.audio_file_rounded,
                title: 'Fichier Audio',
                subtitle: _audioFileByLocale[language] != null
                    ? p.basename(_audioFileByLocale[language]!)
                    : 'Importer un fichier audio',
                gradient: [Colors.orange, Colors.orange.withOpacity(0.8)],
                onFilePick: () => _pickAudioFile(language),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAudioOption({
    required BuildContext context,
    required String language,
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    VoidCallback? onFilePick,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isSelected = _audioSourceByLocale[language] == value;
    final hasFile = _audioFileByLocale[language] != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        gradient: isSelected ? LinearGradient(colors: gradient) : null,
        color: isSelected ? null : cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? gradient[0].withOpacity(0.3)
              : cs.outlineVariant.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: gradient[0].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (value == 'file' && onFilePick != null) {
              Navigator.pop(context);
              onFilePick();
            } else {
              setState(() => _audioSourceByLocale[language] = value);
              Navigator.pop(context);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                          )
                        : LinearGradient(
                            colors: gradient
                                .map((c) => c.withOpacity(0.1))
                                .toList()),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : gradient[0],
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions pour fichier audio
                if (value == 'file' &&
                    hasFile &&
                    _audioSourceByLocale[language] == 'file') ...[
                  Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => _playAudioFile(language),
                      icon: Icon(
                        Icons.play_circle_fill_rounded,
                        color: isSelected ? Colors.white : Colors.green,
                        size: 28,
                      ),
                      tooltip: 'Écouter',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() => _audioFileByLocale[language] = null);
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.delete_rounded,
                        color: isSelected ? Colors.white : Colors.red,
                        size: 24,
                      ),
                      tooltip: 'Supprimer',
                    ),
                  ),
                ] else if (isSelected) ...[
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAudioFile(String language) async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'wav', 'aac'],
      );

      if (picked == null ||
          picked.files.isEmpty ||
          picked.files.single.path == null) {
        return;
      }

      final src = picked.files.single.path!;
      final dir = await getApplicationSupportDirectory();
      final dstDir = Directory(p.join(dir.path, 'task-audio'));

      if (!await dstDir.exists()) {
        await dstDir.create(recursive: true);
      }

      final ext = p.extension(src);
      final dst = p.join(dstDir.path, '${widget.taskId}_$language$ext');
      await File(src).copy(dst);

      setState(() {
        _audioSourceByLocale[language] = 'file';
        _audioFileByLocale[language] = dst;
      });

      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.audiotrack_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Fichier audio importé avec succès'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Erreur d\'importation: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _playAudioFile(String language) async {
    final filePath = _audioFileByLocale[language];
    if (filePath != null) {
      try {
        await ref.read(audioPlayerServiceProvider).playFile(filePath);
        HapticFeedback.lightImpact();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur de lecture: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
