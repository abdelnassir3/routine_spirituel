import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/services/content_service.dart';
import 'package:spiritual_routines/core/services/diacritizer_service.dart';
import 'package:spiritual_routines/core/services/diacritizer_provider.dart';
import 'package:spiritual_routines/core/services/ocr_service.dart';
import 'package:spiritual_routines/core/services/transcription_service.dart';
import 'package:spiritual_routines/core/services/ocr_mlkit.dart';
import 'package:spiritual_routines/features/content/quran_verse_selector.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:spiritual_routines/core/services/task_audio_prefs.dart';
import 'package:spiritual_routines/core/services/audio_player_service.dart';

class ContentEditorPage extends ConsumerStatefulWidget {
  final String taskId;
  const ContentEditorPage({super.key, required this.taskId});

  @override
  ConsumerState<ContentEditorPage> createState() => _ContentEditorPageState();
}

class _ContentEditorPageState extends ConsumerState<ContentEditorPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _source = 'manual';
  final _rawCtrlFR = TextEditingController();
  final _correctedCtrlFR = TextEditingController();
  final _rawCtrlAR = TextEditingController();
  final _correctedCtrlAR = TextEditingController();
  final _diacritizedCtrlAR = TextEditingController();
  bool _busyImport = false;
  bool _busyDiacritize = false;
  final Map<String, String> _audioSourceByLocale = {
    'fr': 'device',
    'ar': 'device'
  };
  final Map<String, String?> _audioFileByLocale = {'fr': null, 'ar': null};

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadExisting();
  }

  @override
  void dispose() {
    _rawCtrlFR.dispose();
    _correctedCtrlFR.dispose();
    _rawCtrlAR.dispose();
    _correctedCtrlAR.dispose();
    _diacritizedCtrlAR.dispose();
    _tab.dispose();
    super.dispose();
  }

  String _getAudioSourceLabel(String source) {
    switch (source) {
      case 'device':
        return 'TTS appareil';
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

  void _showAudioOptionsSheet(BuildContext context, String locale) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.audio_file_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Options audio',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildAudioOption(
                context: context,
                value: 'device',
                currentValue: _audioSourceByLocale[locale]!,
                icon: Icons.phone_android_rounded,
                title: 'TTS générique',
                subtitle: 'Synthèse vocale de l\'appareil',
                onTap: () {
                  setState(() => _audioSourceByLocale[locale] = 'device');
                  Navigator.pop(context);
                },
              ),
              _buildAudioOption(
                context: context,
                value: 'cloud',
                currentValue: _audioSourceByLocale[locale]!,
                icon: Icons.cloud_rounded,
                title: 'Voix neurale',
                subtitle: 'Modèle Cloud haute qualité',
                onTap: () {
                  setState(() => _audioSourceByLocale[locale] = 'cloud');
                  Navigator.pop(context);
                },
              ),
              _buildAudioOption(
                context: context,
                value: 'file',
                currentValue: _audioSourceByLocale[locale]!,
                icon: Icons.audio_file_rounded,
                title: 'Fichier audio',
                subtitle: _audioFileByLocale[locale] != null
                    ? p.basename(_audioFileByLocale[locale]!)
                    : 'Importer un fichier audio',
                onTap: () async {
                  Navigator.pop(context);
                  final picked = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['mp3', 'm4a', 'wav', 'aac'],
                  );
                  if (picked == null ||
                      picked.files.isEmpty ||
                      picked.files.single.path == null) return;
                  final src = picked.files.single.path!;
                  final dir = await getApplicationSupportDirectory();
                  final dstDir = Directory(p.join(dir.path, 'task-audio'));
                  if (!await dstDir.exists())
                    await dstDir.create(recursive: true);
                  final ext = p.extension(src);
                  final dst =
                      p.join(dstDir.path, '${widget.taskId}_$locale$ext');
                  await File(src).copy(dst);
                  setState(() {
                    _audioSourceByLocale[locale] = 'file';
                    _audioFileByLocale[locale] = dst;
                  });
                },
                trailing: _audioFileByLocale[locale] != null &&
                        _audioSourceByLocale[locale] == 'file'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.play_arrow_rounded,
                                color: theme.colorScheme.primary),
                            onPressed: () async {
                              final file = _audioFileByLocale[locale]!;
                              await ref
                                  .read(audioPlayerServiceProvider)
                                  .playFile(file);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.clear_rounded,
                                color: theme.colorScheme.error),
                            onPressed: () {
                              setState(() => _audioFileByLocale[locale] = null);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      )
                    : null,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioOption({
    required BuildContext context,
    required String value,
    required String currentValue,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final isSelected = value == currentValue;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 1.5,
              )
            : null,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? theme.colorScheme.primary : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: trailing ??
            (isSelected
                ? Icon(
                    Icons.check_circle_rounded,
                    color: theme.colorScheme.primary,
                  )
                : null),
      ),
    );
  }

  Widget _buildSourceChip({
    required String label,
    required IconData icon,
    required String value,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: selected
            ? LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              )
            : null,
        color: selected
            ? null
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelected(true),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactRadioOption({
    required String value,
    required String groupValue,
    required String label,
    required IconData icon,
    required ValueChanged<String?> onChanged,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withOpacity(0.5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadExisting() async {
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
    });
    // Load audio settings
    final frAudio = await ref
        .read(taskAudioPrefsProvider)
        .getForTaskLocale(widget.taskId, 'fr');
    final arAudio = await ref
        .read(taskAudioPrefsProvider)
        .getForTaskLocale(widget.taskId, 'ar');
    if (!mounted) return;
    setState(() {
      _audioSourceByLocale['fr'] = frAudio.source;
      _audioFileByLocale['fr'] = frAudio.filePath;
      _audioSourceByLocale['ar'] = arAudio.source;
      _audioFileByLocale['ar'] = arAudio.filePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
                theme.colorScheme.secondary.withOpacity(0.6),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        title: const Text(
          'Éditeur de contenu',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Français'),
                Tab(text: 'العربية'),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.95),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 120),
            child: TabBarView(
              controller: _tab,
              children: [
                _buildLang('fr'),
                _buildLang('ar'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
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
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Réglages audio enregistrés'),
                backgroundColor: theme.colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.save_rounded, color: Colors.white),
          label: const Text(
            'Sauver audio',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        borderRadius: BorderRadius.circular(24),
                        child: Center(
                          child: Text(
                            'Annuler',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final svc = ref.read(contentServiceProvider);
                          await svc.validateAndFinalize(
                            taskId: widget.taskId,
                            locale: _tab.index == 0 ? 'fr' : 'ar',
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Contenu validé avec succès'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                          Navigator.of(context).maybePop();
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Valider le contenu',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLang(String locale) {
    final isAr = locale == 'ar';
    final rawCtrl = isAr ? _rawCtrlAR : _rawCtrlFR;
    final correctedCtrl = isAr ? _correctedCtrlAR : _correctedCtrlFR;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section Audio ultra-compacte avec design moderne
        Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer.withOpacity(0.3),
                theme.colorScheme.primaryContainer.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showAudioOptionsSheet(context, locale),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getAudioIcon(_audioSourceByLocale[locale]!),
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Audio',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            _getAudioSourceLabel(_audioSourceByLocale[locale]!),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_audioFileByLocale[locale] != null &&
                        _audioSourceByLocale[locale] == 'file')
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.audiotrack_rounded,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Fichier',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color:
                          theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Section source avec design moderne
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.source_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Source du contenu',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSourceChip(
                    label: 'Saisie',
                    icon: Icons.keyboard_rounded,
                    value: 'manual',
                    selected: _source == 'manual',
                    onSelected: (_) => setState(() => _source = 'manual'),
                  ),
                  _buildSourceChip(
                    label: 'Versets Coran',
                    icon: Icons.menu_book_rounded,
                    value: 'quran_verses',
                    selected: _source == 'quran_verses',
                    onSelected: (_) => setState(() => _source = 'quran_verses'),
                  ),
                  _buildSourceChip(
                    label: 'Image OCR',
                    icon: Icons.image_rounded,
                    value: 'image_ocr',
                    selected: _source == 'image_ocr',
                    onSelected: (_) => setState(() => _source = 'image_ocr'),
                  ),
                  _buildSourceChip(
                    label: 'PDF OCR',
                    icon: Icons.picture_as_pdf_rounded,
                    value: 'pdf_ocr',
                    selected: _source == 'pdf_ocr',
                    onSelected: (_) => setState(() => _source = 'pdf_ocr'),
                  ),
                  _buildSourceChip(
                    label: 'Audio → Texte',
                    icon: Icons.mic_rounded,
                    value: 'audio_transcription',
                    selected: _source == 'audio_transcription',
                    onSelected: (_) =>
                        setState(() => _source = 'audio_transcription'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Afficher le sélecteur de versets si la source est 'quran_verses'
        if (_source == 'quran_verses') ...[
          QuranVerseSelector(
            locale: locale,
            onVersesSelected: (versesText, versesRefs) async {
              // Mettre à jour les contrôleurs de texte
              setState(() {
                rawCtrl.text = versesText;
                if (correctedCtrl.text.isEmpty) {
                  correctedCtrl.text = versesText;
                }
              });

              // Sauvegarder dans la base de données
              final content = ref.read(contentServiceProvider);
              await content.setSource(
                  taskId: widget.taskId,
                  locale: locale,
                  source: 'quran_verses');
              await content.updateRaw(
                  taskId: widget.taskId, locale: locale, raw: versesText);
              await content.updateCorrected(
                taskId: widget.taskId,
                locale: locale,
                corrected: correctedCtrl.text,
              );

              // Ajouter les références comme métadonnées
              await content.putContent(
                taskId: widget.taskId,
                locale: locale,
                kind: 'verses',
                title: versesRefs,
                body: versesText,
              );
            },
          ),
          const SizedBox(height: 12),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: _busyImport
                      ? null
                      : () async {
                          final content = ref.read(contentServiceProvider);
                          setState(() => _busyImport = true);
                          await content.setSource(
                              taskId: widget.taskId,
                              locale: locale,
                              source: _source);

                          String text = '';
                          if (_source == 'image_ocr') {
                            final picked = await FilePicker.platform
                                .pickFiles(type: FileType.image);
                            if (picked == null ||
                                picked.files.isEmpty ||
                                picked.files.single.path == null) {
                              return;
                            }
                            final path = picked.files.single.path!;
                            try {
                              text = await MlkitOcrService().recognizeImage(
                                  path,
                                  language: isAr ? 'ar' : 'fr');
                            } catch (_) {
                              text = await StubOcrService().recognizeImage(path,
                                  language: isAr ? 'ar' : 'fr');
                            }
                          } else if (_source == 'pdf_ocr') {
                            final picked = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf'],
                            );
                            if (picked == null ||
                                picked.files.isEmpty ||
                                picked.files.single.path == null) {
                              return;
                            }
                            final path = picked.files.single.path!;
                            try {
                              text = await MlkitOcrService().recognizePdf(path,
                                  language: isAr ? 'ar' : 'fr');
                            } catch (_) {
                              text = await StubOcrService().recognizePdf(path,
                                  language: isAr ? 'ar' : 'fr');
                            }
                          } else if (_source == 'audio_transcription') {
                            final picked = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['wav', 'mp3', 'm4a'],
                            );
                            if (picked == null ||
                                picked.files.isEmpty ||
                                picked.files.single.path == null) {
                              return;
                            }
                            final path = picked.files.single.path!;
                            text = await StubTranscriptionService()
                                .transcribeAudio(path,
                                    language: isAr ? 'ar' : 'fr');
                          }

                          setState(() {
                            rawCtrl.text = text;
                            if (correctedCtrl.text.isEmpty) {
                              correctedCtrl.text = text;
                            }
                          });
                          await content.updateRaw(
                              taskId: widget.taskId, locale: locale, raw: text);
                          await content.updateCorrected(
                            taskId: widget.taskId,
                            locale: locale,
                            corrected: correctedCtrl.text,
                          );
                          setState(() => _busyImport = false);
                        },
                  child: _busyImport
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 8),
                            Text('En cours…'),
                          ],
                        )
                      : const Text('Importer/Reconnaître'),
                ),
              ),
              const SizedBox(width: 8),
              if (isAr)
                Expanded(
                  child: FilledButton(
                    onPressed: _busyDiacritize
                        ? null
                        : () async {
                            final diacritizer =
                                await ref.read(diacritizerProvider.future);
                            setState(() => _busyDiacritize = true);
                            final diacritized = await diacritizer
                                .diacritize(correctedCtrl.text);
                            setState(
                                () => _diacritizedCtrlAR.text = diacritized);
                            await ref
                                .read(contentServiceProvider)
                                .updateDiacritized(
                                  taskId: widget.taskId,
                                  locale: 'ar',
                                  diacritized: diacritized,
                                );
                            setState(() => _busyDiacritize = false);
                          },
                    child: _busyDiacritize
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                              SizedBox(width: 8),
                              Text('Diacritisation…'),
                            ],
                          )
                        : const Text('Diacritiser (AR)'),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Text('Brut (OCR/Transcription)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        TextField(
          controller: rawCtrl,
          maxLines: 6,
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: (v) => ref
              .read(contentServiceProvider)
              .updateRaw(taskId: widget.taskId, locale: locale, raw: v),
        ),
        const SizedBox(height: 12),
        Text('Corrigé', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        TextField(
          controller: correctedCtrl,
          maxLines: 8,
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: (v) => ref.read(contentServiceProvider).updateCorrected(
                taskId: widget.taskId,
                locale: locale,
                corrected: v,
              ),
        ),
        if (isAr) ...[
          const SizedBox(height: 12),
          Text('Avec voyelles (tashkīl)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          TextField(
            controller: _diacritizedCtrlAR,
            maxLines: 8,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            onChanged: (v) => ref
                .read(contentServiceProvider)
                .updateDiacritized(
                    taskId: widget.taskId, locale: 'ar', diacritized: v),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
