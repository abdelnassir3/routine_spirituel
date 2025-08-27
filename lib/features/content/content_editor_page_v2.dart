import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/services/content_service.dart';
import 'package:spiritual_routines/core/services/diacritizer_service.dart';
import 'package:spiritual_routines/core/services/diacritizer_provider.dart';
import 'package:spiritual_routines/core/services/ocr_service.dart';
import 'package:spiritual_routines/core/services/transcription_service.dart';
import 'package:spiritual_routines/core/services/ocr_mlkit.dart';
import 'package:spiritual_routines/features/content/quran_verse_selector.dart';
import 'package:spiritual_routines/design_system/components/buttons.dart';
import 'package:spiritual_routines/design_system/components/cards.dart';
import 'package:spiritual_routines/design_system/components/states.dart';
import 'package:spiritual_routines/design_system/tokens/spacing.dart';
import 'package:file_picker/file_picker.dart';

/// Content Editor Page with Material 3 Design
class ContentEditorPageV2 extends ConsumerStatefulWidget {
  final String taskId;
  const ContentEditorPageV2({super.key, required this.taskId});

  @override
  ConsumerState<ContentEditorPageV2> createState() =>
      _ContentEditorPageV2State();
}

class _ContentEditorPageV2State extends ConsumerState<ContentEditorPageV2> {
  // Language selection
  String _selectedLanguage = 'fr';

  // Content source
  String _source = 'manual';

  // Text controllers
  final _rawCtrlFR = TextEditingController();
  final _correctedCtrlFR = TextEditingController();
  final _rawCtrlAR = TextEditingController();
  final _correctedCtrlAR = TextEditingController();
  final _diacritizedCtrlAR = TextEditingController();

  // Loading states
  bool _isLoading = false;
  bool _busyImport = false;
  bool _busyDiacritize = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    _rawCtrlFR.dispose();
    _correctedCtrlFR.dispose();
    _rawCtrlAR.dispose();
    _correctedCtrlAR.dispose();
    _diacritizedCtrlAR.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    setState(() => _isLoading = true);

    final svc = ref.read(contentServiceProvider);
    final fr = await svc.getEditingBodies(widget.taskId, 'fr');
    final ar = await svc.getEditingBodies(widget.taskId, 'ar');

    if (!mounted) return;

    setState(() {
      _rawCtrlFR.text = fr.$1 ?? '';
      _correctedCtrlFR.text = fr.$2 ?? '';
      _rawCtrlAR.text = ar.$1 ?? '';
      _correctedCtrlAR.text = ar.$2 ?? '';
      _diacritizedCtrlAR.text = ar.$3 ?? '';
      _isLoading = false;
    });
  }

  Future<void> _importFromOCR() async {
    setState(() => _busyImport = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        final text = await OCRService.extractText(result.files.single.path!);

        if (mounted) {
          final controller =
              _selectedLanguage == 'fr' ? _rawCtrlFR : _rawCtrlAR;
          controller.text = text;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Texte extrait avec succès'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'extraction: $e'),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busyImport = false);
      }
    }
  }

  Future<void> _diacritizeArabic() async {
    if (_correctedCtrlAR.text.isEmpty) return;

    setState(() => _busyDiacritize = true);

    try {
      final service = ref.read(diacritizerServiceProvider);
      final diacritized = await service.diacritize(_correctedCtrlAR.text);

      if (mounted) {
        _diacritizedCtrlAR.text = diacritized;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Texte diacritisé avec succès'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de diacritisation: $e'),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busyDiacritize = false);
      }
    }
  }

  Future<void> _saveContent() async {
    final svc = ref.read(contentServiceProvider);

    // Save French content
    await svc.updateRaw(
      taskId: widget.taskId,
      locale: 'fr',
      raw: _rawCtrlFR.text,
    );
    await svc.updateCorrected(
      taskId: widget.taskId,
      locale: 'fr',
      corrected: _correctedCtrlFR.text,
    );

    // Save Arabic content
    await svc.updateRaw(
      taskId: widget.taskId,
      locale: 'ar',
      raw: _rawCtrlAR.text,
    );
    await svc.updateCorrected(
      taskId: widget.taskId,
      locale: 'ar',
      corrected: _correctedCtrlAR.text,
    );
    await svc.updateDiacritized(
      taskId: widget.taskId,
      locale: 'ar',
      diacritized: _diacritizedCtrlAR.text,
    );

    // Validate and finalize
    await svc.validateAndFinalize(
      taskId: widget.taskId,
      locale: _selectedLanguage,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contenu enregistré avec succès'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isRTL = _selectedLanguage == 'ar';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Éditeur de contenu'),
        elevation: 0,
        actions: [
          // Language selector as segmented button
          Padding(
            padding: const EdgeInsets.only(right: Spacing.lg),
            child: M3SegmentedButton<String>(
              selected: _selectedLanguage,
              options: const [
                SegmentedButtonOption(value: 'fr', label: 'FR'),
                SegmentedButtonOption(value: 'ar', label: 'AR'),
              ],
              onSelectionChanged: (value) {
                setState(() => _selectedLanguage = value);
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const M3LoadingIndicator(label: 'Chargement du contenu...')
          : AnimatedSwitcher(
              duration: AnimDurations.medium,
              child: _buildLanguageContent(),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildLanguageContent() {
    final isArabic = _selectedLanguage == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: ListView(
        key: ValueKey(_selectedLanguage),
        padding: const EdgeInsets.all(Spacing.pagePadding),
        children: [
          // Source selection card
          M3FilledCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Source du contenu',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: Spacing.md),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: [
                    ChoiceChip(
                      label: const Text('Manuel'),
                      selected: _source == 'manual',
                      onSelected: (selected) {
                        setState(() => _source = 'manual');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('OCR'),
                      selected: _source == 'ocr',
                      onSelected: (selected) {
                        setState(() => _source = 'ocr');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Audio'),
                      selected: _source == 'audio',
                      onSelected: (selected) {
                        setState(() => _source = 'audio');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Coran'),
                      selected: _source == 'quran',
                      onSelected: (selected) {
                        setState(() => _source = 'quran');
                      },
                    ),
                  ],
                ),
                if (_source == 'ocr' || _source == 'audio') ...[
                  const SizedBox(height: Spacing.lg),
                  M3TonalButton(
                    onPressed: _busyImport ? null : _importFromOCR,
                    icon: Icons.upload_file_rounded,
                    isLoading: _busyImport,
                    child: Text(
                        _source == 'ocr' ? 'Importer image' : 'Importer audio'),
                  ),
                ] else if (_source == 'quran') ...[
                  const SizedBox(height: Spacing.lg),
                  M3TonalButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.75,
                          minChildSize: 0.5,
                          maxChildSize: 0.95,
                          expand: false,
                          builder: (context, scrollController) {
                            return QuranVerseSelector(
                              onVersesSelected: (verses) {
                                final controller =
                                    isArabic ? _rawCtrlAR : _rawCtrlFR;
                                controller.text = verses;
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      );
                    },
                    icon: Icons.book_rounded,
                    child: const Text('Sélectionner des versets'),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: Spacing.lg),

          // Content editing section
          if (isArabic) ...[
            _buildArabicEditors(),
          ] else ...[
            _buildFrenchEditors(),
          ],
        ],
      ),
    );
  }

  Widget _buildFrenchEditors() {
    return Column(
      children: [
        // Raw text
        M3OutlinedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.text_fields_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    'Texte brut',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              TextField(
                controller: _rawCtrlFR,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Entrez ou importez le texte original...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: Spacing.lg),

        // Corrected text
        M3OutlinedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    'Texte corrigé',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              TextField(
                controller: _correctedCtrlFR,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Texte après correction et mise en forme...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArabicEditors() {
    return Column(
      children: [
        // Raw Arabic text
        M3OutlinedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.text_fields_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    'النص الخام',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              TextField(
                controller: _rawCtrlAR,
                maxLines: 6,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  hintText: 'أدخل أو استورد النص الأصلي...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: Spacing.lg),

        // Corrected Arabic text
        M3OutlinedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    'النص المصحح',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              TextField(
                controller: _correctedCtrlAR,
                maxLines: 6,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  hintText: 'النص بعد التصحيح والتنسيق...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: Spacing.lg),

        // Diacritized Arabic text
        M3OutlinedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    'النص مع التشكيل',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  M3TonalButton(
                    onPressed: _busyDiacritize ? null : _diacritizeArabic,
                    isLoading: _busyDiacritize,
                    child: const Text('تشكيل'),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              TextField(
                controller: _diacritizedCtrlAR,
                maxLines: 6,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'النص مع الحركات...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.pagePadding),
          child: Row(
            children: [
              M3TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              const Spacer(),
              M3FilledButton(
                onPressed: _saveContent,
                icon: Icons.check_rounded,
                child: const Text('Valider et enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
