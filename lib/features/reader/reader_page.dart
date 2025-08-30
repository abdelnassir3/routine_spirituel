import 'package:flutter/material.dart';
import 'dart:io' show Platform if (dart.library.html) 'package:spiritual_routines/core/platform/platform_stub.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:spiritual_routines/core/providers/haptic_provider.dart';
import 'package:spiritual_routines/core/services/progress_service.dart';
import 'package:spiritual_routines/core/services/content_service.dart';
import 'package:spiritual_routines/features/reader/current_progress.dart';
import 'package:spiritual_routines/features/session/session_state.dart';
import 'package:spiritual_routines/features/counter/hands_free_controller.dart';
import 'package:spiritual_routines/features/reader/highlight_controller.dart';
import 'package:spiritual_routines/features/reader/focus_mode.dart';
import 'package:spiritual_routines/features/reader/reading_prefs.dart';
import 'package:spiritual_routines/core/services/audio_tts_flutter.dart';
import 'package:spiritual_routines/core/services/smart_tts_service.dart';
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

/// Enum pour les choix de langue lors du pré-cache
enum _Scope { fr, ar, both }

/// Widget pour afficher un indicateur de fin de verset (numéro sourate/verset)
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
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        child: Text(
          '$verseNumber',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 9,
          ),
          textDirection: TextDirection.ltr, // Toujours LTR pour les numéros
        ),
      ),
    );
  }
}

/// Traite le texte arabe pour y insérer les indicateurs de verset
String _processArabicTextWithVerseIndicators(
    String text, List<({int surah, int ayah})> verses) {
  if (verses.isEmpty) return text;

  String processedText = text.trim();

  // Si on a plusieurs versets, on essaie de les distribuer dans le texte
  if (verses.length > 1) {
    final sentences = _splitIntoSentences(processedText);
    if (sentences.length >= verses.length) {
      // Distribuer les indicateurs après chaque phrase logique
      String result = '';
      for (int i = 0; i < sentences.length; i++) {
        result += sentences[i];
        if (i < verses.length) {
          final verse = verses[i];
          result += ' \uE000${verse.surah}:${verse.ayah}\uE001 ';
        }
      }
      return result.trim();
    }
  }

  // Cas simple : ajouter tous les indicateurs à la fin
  for (final verse in verses) {
    processedText += ' \uE000${verse.surah}:${verse.ayah}\uE001';
  }

  return processedText;
}

/// Divise le texte en phrases logiques (basé sur les points et patterns arabes)
List<String> _splitIntoSentences(String text) {
  // Diviser par les caractères de fin de phrase arabes et points
  final sentences =
      text.split(RegExp(r'[.。؟!]')).where((s) => s.trim().isNotEmpty).toList();

  // Si pas de séparateurs, diviser par des mots-clés arabes courants de transition
  if (sentences.length <= 1) {
    // Diviser par des patterns courants dans le Coran
    final parts = text
        .split(RegExp(r'\s+(وَ|ثُمَّ|فَ|إِنَّ|وَإِنَّ)\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (parts.length > 1) return parts;
  }

  return sentences.isNotEmpty ? sentences : [text];
}

/// Convertit un texte avec marqueurs en une liste de widgets avec indicateurs
List<InlineSpan> _buildTextWithVerseIndicators(
    String text, TextStyle? baseStyle, BuildContext context,
    {bool isArabic = true}) {
  final List<InlineSpan> spans = [];
  final RegExp versePattern = RegExp(r'\uE000(\d+):(\d+)\uE001');

  int lastIndex = 0;
  for (final match in versePattern.allMatches(text)) {
    // Ajouter le texte avant l'indicateur
    if (match.start > lastIndex) {
      spans.add(TextSpan(
        text: text.substring(lastIndex, match.start),
        style: baseStyle,
      ));
    }

    // Ajouter l'indicateur de verset
    final surahNum = int.parse(match.group(1)!);
    final verseNum = int.parse(match.group(2)!);

    spans.add(WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: _VerseIndicator(
        surahNumber: surahNum,
        verseNumber: verseNum,
        isArabic: isArabic,
      ),
    ));

    lastIndex = match.end;
  }

  // Ajouter le texte restant
  if (lastIndex < text.length) {
    spans.add(TextSpan(
      text: text.substring(lastIndex),
      style: baseStyle,
    ));
  }

  return spans;
}

class ReaderPage extends ConsumerWidget {
  const ReaderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = ref.watch(currentSessionIdProvider);
    final focus = ref.watch(focusModeProvider);
    // Initialize display preference from DB once
    ref.listen(readingDisplayPrefProvider, (prev, next) {
      next.whenData((mode) {
        final current = ref.read(bilingualDisplayProvider);
        if (current != mode) {
          ref.read(bilingualDisplayProvider.notifier).state = mode;
        }
      });
    });
    // Auto pre-cache on session start (background)
    Future.microtask(() async {
      final sid = sessionId;
      if (sid == null) return;
      final secureSvc = ref.read(secure.userSettingsServiceProvider);
      final auto = await secureSvc.getAutoPrecacheEnabled();
      if (!auto) return;
      // avoid repeating per session by flagging
      final doneKey = 'precache_done_$sid';
      final already = await secureSvc.readValue(doneKey);
      if (already == 'done') return;
      final cloudOn = await secureSvc.getCloudTtsEnabled();
      if (!cloudOn) return;
      final provider = await secureSvc.getCloudTtsProvider();
      final endpoint = await secureSvc.getCloudTtsEndpoint();
      final apiKey = await secureSvc.getCloudTtsApiKey();
      final access = await secureSvc.getAwsAccessKey();
      final secret = await secureSvc.getAwsSecretKey();
      final canCloud = (provider == 'polly')
          ? (access != null &&
              access.isNotEmpty &&
              secret != null &&
              secret.isNotEmpty &&
              endpoint != null &&
              endpoint.isNotEmpty)
          : (apiKey != null && apiKey.isNotEmpty);
      if (!canCloud) return;
      // Build items according to scope
      final settings = ref.read(userSettingsServiceProvider);
      final frVoice = (await secureSvc.getCloudVoiceFrName()) ??
          await settings.getTtsPreferredFr();
      final arVoice = (await secureSvc.getCloudVoiceArName()) ??
          await settings.getTtsPreferredAr();
      final speed = await settings.getTtsSpeed();
      final pitch = await settings.getTtsPitch();
      final cfg = CloudTtsConfig(
          provider: provider,
          apiKey: apiKey,
          endpoint: endpoint,
          awsAccessKey: access,
          awsSecretKey: secret);
      final cloud = ref.read(cloudTtsByConfigProvider(cfg));
      final content = ref.read(contentServiceProvider);
      final sessionDao = ref.read(sessionDaoProvider);
      final taskDao = ref.read(taskDaoProvider);
      final session = await sessionDao.getById(sid);
      if (session == null) return;
      final tasks = await (taskDao.select(taskDao.tasks)
            ..where((t) => t.routineId.equals(session.routineId))
            ..orderBy([(t) => drift.OrderingTerm.asc(t.orderIndex)]))
          .get();
      final items = <({String text, String voice})>[];
      final seen = <String>{};
      final scope =
          await secureSvc.getAutoPrecacheScope(); // 'fr' | 'ar' | 'both'
      for (final t in tasks) {
        final pair = await content.getBuiltTextsForTask(t.id);
        final ar = pair.$1?.trim();
        final fr = pair.$2?.trim();
        if (fr != null && fr.isNotEmpty && (scope == 'fr' || scope == 'both')) {
          final k = 'fr|$fr|$frVoice|$speed|$pitch';
          if (seen.add(k)) items.add((text: fr, voice: frVoice));
        }
        if (ar != null && ar.isNotEmpty && (scope == 'ar' || scope == 'both')) {
          final k = 'ar|$ar|$arVoice|$speed|$pitch';
          if (seen.add(k)) items.add((text: ar, voice: arVoice));
        }
      }
      if (items.isEmpty) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pré‑cache auto démarré…')),
        );
      }
      for (final it in items) {
        try {
          await cloud.synthesizeToCache(it.text,
              voice: it.voice, speed: speed, pitch: pitch);
        } catch (_) {}
      }
      await secureSvc.writeValue(doneKey, 'done');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Pré‑cache auto terminé (${items.length} fichiers)')),
        );
      }
    });

    return Scaffold(
      appBar: focus
          ? null
          : AppBar(
              title: const Text('Lecteur'),
              actions: [
                Consumer(builder: (context, ref, _) {
                  final mode = ref.watch(bilingualDisplayProvider);
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: SegmentedButton<BilingualDisplay>(
                      segments: const [
                        ButtonSegment(
                          value: BilingualDisplay.arOnly,
                          label: Text('AR', style: TextStyle(fontSize: 12)),
                        ),
                        ButtonSegment(
                          value: BilingualDisplay.both,
                          label: Text('AR+FR', style: TextStyle(fontSize: 11)),
                        ),
                        ButtonSegment(
                          value: BilingualDisplay.frOnly,
                          label: Text('FR', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                      selected: {mode},
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4)),
                        minimumSize: WidgetStateProperty.all(const Size(0, 32)),
                      ),
                      onSelectionChanged: (sel) async {
                        final m = sel.first;
                        ref.read(bilingualDisplayProvider.notifier).state = m;
                        await ref
                            .read(userSettingsServiceProvider)
                            .setDisplayPreference(m);
                      },
                    ),
                  );
                }),
                IconButton(
                  icon: const Icon(Icons.center_focus_strong_rounded),
                  tooltip: 'Mode focus',
                  onPressed: () =>
                      ref.read(focusModeProvider.notifier).state = true,
                ),
                IconButton(
                  icon: const Icon(Icons.cloud_download_rounded),
                  tooltip: 'Pré‑cacher la session (TTS Cloud)',
                  onPressed: () async {
                    final sessionId = ref.read(currentSessionIdProvider);
                    if (sessionId == null) return;
                    final secureSvc =
                        ref.read(secure.userSettingsServiceProvider);
                    final enabled = await secureSvc.getCloudTtsEnabled();
                    final provider = await secureSvc.getCloudTtsProvider();
                    final endpoint = await secureSvc.getCloudTtsEndpoint();
                    final apiKey = await secureSvc.getCloudTtsApiKey();
                    final awsAccess = await secureSvc.getAwsAccessKey();
                    final awsSecret = await secureSvc.getAwsSecretKey();
                    final canCloud = enabled &&
                        ((provider == 'polly' &&
                                awsAccess != null &&
                                awsAccess.isNotEmpty &&
                                awsSecret != null &&
                                awsSecret.isNotEmpty &&
                                endpoint != null &&
                                endpoint.isNotEmpty) ||
                            (provider != 'polly' &&
                                apiKey != null &&
                                apiKey.isNotEmpty));
                    if (!canCloud) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Activez le TTS Cloud et renseignez les identifiants')),
                        );
                      }
                      return;
                    }

                    final user = ref.read(userSettingsServiceProvider);
                    final frVoice = await user.getTtsPreferredFr();
                    final arVoice = await user.getTtsPreferredAr();
                    final speed = await user.getTtsSpeed();
                    final pitch = await user.getTtsPitch();
                    final cfg = CloudTtsConfig(
                        provider: provider,
                        apiKey: apiKey,
                        endpoint: endpoint,
                        awsAccessKey: awsAccess,
                        awsSecretKey: awsSecret);
                    final cloud = ref.read(cloudTtsByConfigProvider(cfg));
                    final content = ref.read(contentServiceProvider);
                    final sessionDao = ref.read(sessionDaoProvider);
                    final taskDao = ref.read(taskDaoProvider);
                    final session = await sessionDao.getById(sessionId);
                    if (session == null) return;
                    final tasks = await (taskDao.select(taskDao.tasks)
                          ..where((t) => t.routineId.equals(session.routineId))
                          ..orderBy(
                              [(t) => drift.OrderingTerm.asc(t.orderIndex)]))
                        .get();

                    // Ask scope
                    _Scope? scope = _Scope.both;
                    if (!context.mounted) return;
                    scope = await showDialog<_Scope>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Pré‑cache — langue'),
                        content:
                            const Text('Choisissez la langue à pré‑cacher'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(ctx).pop(_Scope.fr),
                              child: const Text('FR seulement')),
                          TextButton(
                              onPressed: () => Navigator.of(ctx).pop(_Scope.ar),
                              child: const Text('AR seulement')),
                          FilledButton(
                              onPressed: () =>
                                  Navigator.of(ctx).pop(_Scope.both),
                              child: const Text('AR + FR')),
                        ],
                      ),
                    );
                    scope ??= _Scope.both;

                    final items = <({
                      String text,
                      String voice,
                      String lang,
                      String taskId
                    })>[];
                    final seen = <String>{};
                    for (final t in tasks) {
                      final pair = await content.getBuiltTextsForTask(t.id);
                      final ar = pair.$1?.trim();
                      final fr = pair.$2?.trim();
                      if (fr != null &&
                          fr.isNotEmpty &&
                          (scope == _Scope.fr || scope == _Scope.both)) {
                        final k = 'fr|$fr|$frVoice|$speed|$pitch';
                        if (seen.add(k))
                          items.add((
                            text: fr,
                            voice: frVoice,
                            lang: 'fr',
                            taskId: t.id
                          ));
                      }
                      if (ar != null &&
                          ar.isNotEmpty &&
                          (scope == _Scope.ar || scope == _Scope.both)) {
                        final k = 'ar|$ar|$arVoice|$speed|$pitch';
                        if (seen.add(k))
                          items.add((
                            text: ar,
                            voice: arVoice,
                            lang: 'ar',
                            taskId: t.id
                          ));
                      }
                    }

                    if (items.isEmpty) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Rien à pré‑cacher pour cette session')),
                        );
                      }
                      return;
                    }

                    bool cancelled = false;
                    int done = 0;
                    final total = items.length;
                    if (!context.mounted) return;
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) {
                        Future.microtask(() async {
                          for (final it in items) {
                            if (cancelled) break;
                            try {
                              final path = await cloud.synthesizeToCache(
                                  it.text,
                                  voice: it.voice,
                                  speed: speed,
                                  pitch: pitch);
                              // Record manifest
                              final digest = await ref
                                  .read(ttsCacheServiceProvider)
                                  .computeDigest(
                                    provider: provider,
                                    voice: it.voice,
                                    speed: speed,
                                    pitch: pitch,
                                    text: it.text,
                                  );
                              final bytes = await File(path).length();
                              await ref
                                  .read(ttsCacheServiceProvider)
                                  .recordEntry(
                                    digest: digest,
                                    routineId: session.routineId,
                                    taskId: it.taskId,
                                    lang: it.lang,
                                    sizeBytes: bytes,
                                  );
                            } catch (_) {}
                            done++;
                            if (ctx.mounted) (ctx as Element).markNeedsBuild();
                          }
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        });
                        return StatefulBuilder(
                          builder: (context, setState) {
                            final progress = done / total;
                            return AlertDialog(
                              title: const Text('Pré‑cache TTS en cours'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                      value: progress.clamp(0.0, 1.0)),
                                  const SizedBox(height: 12),
                                  Text('$done / $total'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    cancelled = true;
                                  },
                                  child: const Text('Annuler'),
                                )
                              ],
                            );
                          },
                        );
                      },
                    );
                    if (context.mounted && !cancelled) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Pré‑cache terminé ($done fichiers)')),
                      );
                    }
                  },
                ),
                PopupMenuButton<String>(
                  tooltip: 'Options cache',
                  onSelected: (v) async {
                    if (v == 'clear_routine') {
                      final sessionId = ref.read(currentSessionIdProvider);
                      if (sessionId == null) return;
                      final session =
                          await ref.read(sessionDaoProvider).getById(sessionId);
                      if (session == null) return;
                      final stats = await ref
                          .read(ttsCacheServiceProvider)
                          .statsForRoutine(session.routineId);
                      if (!context.mounted) return;
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title:
                              const Text('Nettoyer le cache de la routine ?'),
                          content: Text(
                              'Supprimer ${stats.$1} fichiers (~${(stats.$2 / (1024 * 1024)).toStringAsFixed(2)} Mo) liés à cette routine.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Annuler')),
                            FilledButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Supprimer')),
                          ],
                        ),
                      );
                      if (confirm != true) return;
                      final removed = await ref
                          .read(ttsCacheServiceProvider)
                          .clearRoutine(session.routineId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Cache routine nettoyé ($removed fichiers)')),
                        );
                      }
                    }
                  },
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(
                        value: 'clear_routine',
                        child: Text('Vider le cache de cette routine')),
                  ],
                ),
              ],
            ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (sessionId == null)
                    const Text('Aucune session active')
                  else ...[
                    const Expanded(child: _ReadingPane()),
                    if (!focus) ...[
                      const SizedBox(height: 6),
                      _StepIndicator(sessionId: sessionId),
                      const SizedBox(height: 4),
                      _CounterBar(sessionId: sessionId),
                      const SizedBox(height: 6),
                      _StopAndCompleteBar(sessionId: sessionId),
                    ],
                  ],
                ],
              ),
            ),
          ),
          if (focus)
            Positioned(
              right: 16,
              top: 28,
              child: SafeArea(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_fullscreen_rounded),
                        onPressed: () =>
                            ref.read(focusModeProvider.notifier).state = false,
                        tooltip: 'Quitter',
                      ),
                      Consumer(builder: (context, ref, _) {
                        final mode = ref.watch(bilingualDisplayProvider);
                        return PopupMenuButton<BilingualDisplay>(
                          initialValue: mode,
                          icon: const Icon(Icons.view_day_rounded),
                          tooltip: 'Affichage',
                          onSelected: (m) async {
                            ref.read(bilingualDisplayProvider.notifier).state =
                                m;
                            await ref
                                .read(userSettingsServiceProvider)
                                .setDisplayPreference(m);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: BilingualDisplay.both,
                                child: Text('AR + FR')),
                            PopupMenuItem(
                                value: BilingualDisplay.arOnly,
                                child: Text('AR seul')),
                            PopupMenuItem(
                                value: BilingualDisplay.frOnly,
                                child: Text('FR seul')),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReadingPane extends ConsumerWidget {
  const _ReadingPane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = ref.watch(currentSessionIdProvider);
    final current = sessionId == null
        ? null
        : ref.watch(currentProgressProvider(sessionId));
    return current == null
        ? const SizedBox.shrink()
        : current.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Erreur de chargement')),
            data: (p) {
              if (p == null)
                return const Center(child: Text('Aucune tâche en cours'));

              // Récupérer le contenu de la tâche pour afficher le titre
              final contentTitle = ref.watch(_contentTitleProvider(p.taskId));
              final content = ref.watch(_contentForTaskProvider(p.taskId));
              final highlight = ref.watch(highlightControllerProvider);

              return Column(
                children: [
                  // Titre de la tâche
                  contentTitle.when(
                    data: (title) => title != null && title.isNotEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tâche en cours',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // Contenu des textes
                  Expanded(
                    child: content.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) =>
                          const Center(child: Text('Contenu indisponible')),
                      data: (pair) {
                        final arText = pair.$1 ?? '';
                        final frText = pair.$2 ?? '';
                        final mode = ref.watch(bilingualDisplayProvider);
                        final Widget arBox =
                            _TextBox(title: 'AR', text: arText, isArabic: true);
                        final Widget frBox = _HighlightBox(
                            title: 'FR', text: frText, index: highlight.index);
                        switch (mode) {
                          case BilingualDisplay.arOnly:
                            return arBox;
                          case BilingualDisplay.frOnly:
                            return frBox;
                          case BilingualDisplay.both:
                          default:
                            return Row(
                              children: [
                                Expanded(child: arBox),
                                const SizedBox(width: 12),
                                Expanded(child: frBox),
                              ],
                            );
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          );
  }
}

class _TextBox extends StatelessWidget {
  final String title;
  final String text;
  final bool isArabic;
  const _TextBox(
      {required this.title, required this.text, this.isArabic = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textStyle = isArabic
        ? theme.textTheme.bodyLarge?.copyWith(
            fontSize: 20,
            height: 1.8,
            fontFamily: 'NotoNaskhArabic',
          )
        : theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            height: 1.6,
          );
    final dir = isArabic ? TextDirection.rtl : TextDirection.ltr;
    final align = isArabic ? TextAlign.right : TextAlign.left;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isArabic
              ? colorScheme.primary.withOpacity(0.2)
              : colorScheme.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Header avec titre et indicateur de langue
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isArabic
                  ? colorScheme.primaryContainer.withOpacity(0.3)
                  : colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  isArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isArabic) ...[
                  Icon(
                    Icons.translate_rounded,
                    size: 20,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isArabic
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSecondaryContainer,
                  ),
                  textDirection: dir,
                ),
                if (isArabic) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.translate_rounded,
                    size: 20,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ],
              ],
            ),
          ),
          // Contenu du texte
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Directionality(
                  textDirection: dir,
                  child: _buildTextContent(
                      context, text, textStyle, align, isArabic),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, String text,
      TextStyle? textStyle, TextAlign align, bool isArabic) {
    // Détection automatique des versets dans le texte arabe
    if (isArabic && text.isNotEmpty) {
      // Debug: afficher les infos sur le texte
      print(
          'DEBUG: Texte arabe détecté, longueur: ${text.length}, isArabic: $isArabic');

      // Essayer de détecter s'il s'agit d'un texte coranique avec des numéros de verset
      // Pour une détection plus robuste, on pourrait analyser le contenu ou utiliser des métadonnées
      final List<({int surah, int ayah})> detectedVerses =
          _detectVersesInText(text);

      print('DEBUG: Versets détectés: ${detectedVerses.length}');
      for (final verse in detectedVerses) {
        print('DEBUG: Verset ${verse.surah}:${verse.ayah}');
      }

      if (detectedVerses.isNotEmpty) {
        final processedText =
            _processArabicTextWithVerseIndicators(text, detectedVerses);
        print(
            'DEBUG: Texte traité: ${processedText.substring(0, math.min(100, processedText.length))}...');
        final spans = _buildTextWithVerseIndicators(
            processedText, textStyle, context,
            isArabic: isArabic);
        print('DEBUG: Nombre de spans: ${spans.length}');

        return RichText(
          textAlign: align,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          text: TextSpan(children: spans),
        );
      } else {
        print('DEBUG: Aucun verset détecté, retour au SelectableText');
      }
    } else {
      print(
          'DEBUG: Pas de texte arabe détecté (isArabic: $isArabic, text.isEmpty: ${text.isEmpty})');
    }

    // Fallback vers SelectableText pour le contenu non-coranique
    return SelectableText(
      text,
      textAlign: align,
      style: textStyle,
    );
  }

  /// Détecte automatiquement les versets dans un texte (version simplifiée)
  /// Pour une version complète, il faudrait analyser le contenu ou utiliser des métadonnées de la tâche
  List<({int surah, int ayah})> _detectVersesInText(String text) {
    // Version simplifiée: pour la démonstration, on va créer des versets factices
    // En réalité, cette information devrait venir des métadonnées de la tâche ou d'une analyse du contenu

    // Si le texte contient certains versets célèbres, on peut les identifier
    if (text.contains('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ')) {
      return [(surah: 1, ayah: 1)]; // Al-Fatiha verset 1
    }
    if (text.contains('ذَٰلِكَ الْكِتَابُ لَا رَيْبَ') ||
        text.contains('ذلك الكتاب لا ريب')) {
      return [(surah: 2, ayah: 2)]; // Al-Baqarah verset 2
    }
    if (text.contains('اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ')) {
      return [(surah: 2, ayah: 255)]; // Ayat al-Kursi
    }

    // Mode de démonstration : détection automatique pour TOUT texte arabe
    if (text.trim().isNotEmpty && _isArabicText(text)) {
      // Pour les versets multiples, on peut analyser la longueur du texte
      final wordCount =
          text.split(' ').where((w) => w.trim().isNotEmpty).length;
      if (wordCount > 50) {
        // Texte long, probablement plusieurs versets
        return [
          (surah: 2, ayah: 2),
          (surah: 2, ayah: 3),
          (surah: 2, ayah: 4),
          (surah: 2, ayah: 5),
        ];
      } else if (wordCount > 20) {
        // Texte moyen, probablement 1-2 versets
        return [
          (surah: 2, ayah: 2),
          (surah: 2, ayah: 3),
        ];
      } else if (wordCount > 5) {
        // Texte court, probablement 1 verset
        return [(surah: 2, ayah: 2)];
      }
    }

    // Pour une implémentation complète, il faudrait:
    // 1. Avoir accès aux métadonnées de la tâche (surahNumber, ayahStart, ayahEnd)
    // 2. Ou analyser le texte pour détecter des patterns de fin de verset
    // 3. Ou utiliser une base de données de correspondance texte -> verset

    return []; // Pas de versets détectés
  }

  /// Vérifie si un texte contient principalement de l'arabe
  bool _isArabicText(String text) {
    // Compter les caractères arabes
    int arabicChars = 0;
    int totalChars = 0;

    for (int i = 0; i < text.length; i++) {
      final char = text.codeUnitAt(i);
      if (char >= 0x0600 && char <= 0x06FF) {
        // Plage de caractères arabes
        arabicChars++;
      }
      if (char > 32) {
        // Ignorer les espaces et caractères de contrôle
        totalChars++;
      }
    }

    // Si plus de 50% des caractères sont arabes, considérer comme texte arabe
    return totalChars > 0 && (arabicChars / totalChars) > 0.5;
  }
}

class _HighlightBox extends StatelessWidget {
  final String title;
  final String text;
  final int index;
  const _HighlightBox(
      {required this.title, required this.text, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = text.replaceAll(RegExp(r"\s+"), ' ').trim().split(' ');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec titre et indicateur de progression
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.translate_rounded,
                  size: 20,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                const Spacer(),
                if (index >= 0 && tokens.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${index + 1} / ${tokens.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Contenu avec surlignage
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: [
                    for (int i = 0; i < tokens.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: i == index
                              ? colorScheme.primaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: i == index
                              ? Border.all(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  width: 1,
                                )
                              : null,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        child: Text(
                          tokens[i],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            height: 1.4,
                            fontWeight: i == index
                                ? FontWeight.w500
                                : FontWeight.normal,
                            color: i == index
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurface,
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends ConsumerWidget {
  final String sessionId;
  const _StepIndicator({required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionRowProvider(sessionId));
    return sessionAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (session) {
        if (session == null) return const SizedBox.shrink();
        final tasksAsync = ref.watch(tasksByRoutineProvider(session.routineId));
        final progAsync = ref.watch(progressListProvider(sessionId));
        if (tasksAsync.isLoading || progAsync.isLoading) {
          return const SizedBox.shrink();
        }
        final tasks = tasksAsync.value ?? const [];
        final progress = progAsync.value ?? const [];
        if (tasks.isEmpty) return const SizedBox.shrink();
        final map = {for (final p in progress) p.taskId: p};
        int currentIndex = -1;
        for (int i = 0; i < tasks.length; i++) {
          final p = map[tasks[i].id];
          if (p != null && p.remainingReps > 0) {
            currentIndex = i;
            break;
          }
        }
        final done = currentIndex == -1;
        if (done) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded),
                    SizedBox(width: 8),
                    Expanded(child: Text('Session terminée')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/routines'),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Routines'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          await ref
                              .read(progressServiceProvider)
                              .resetSession(sessionId);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Recommencer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        final total = tasks.length;
        final step = currentIndex + 1;
        final remaining = (currentIndex >= 0)
            ? (map[tasks[currentIndex].id]?.remainingReps ?? 0)
            : 0;
        final value = total == 0 ? 0.0 : step / total;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Étape $step/$total',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(value: value, minHeight: 8),
                  ),
                ),
                const SizedBox(width: 8),
                if (currentIndex >= 0) Chip(label: Text('Restant: $remaining')),
              ],
            ),
          ],
        );
      },
    );
  }
}

final _contentForTaskProvider =
    FutureProvider.family<(String?, String?), String>((ref, taskId) async {
  final svc = ref.read(contentServiceProvider);
  return svc.getBuiltTextsForTask(taskId);
});

final _contentTitleProvider =
    FutureProvider.family<String?, String>((ref, taskId) async {
  final svc = ref.read(contentServiceProvider);
  // Essayons d'abord en français, puis en arabe
  final frContent = await svc.getByTaskAndLocale(taskId, 'fr');
  if (frContent?.title != null && frContent!.title!.isNotEmpty) {
    return frContent.title;
  }
  final arContent = await svc.getByTaskAndLocale(taskId, 'ar');
  if (arContent?.title != null && arContent!.title!.isNotEmpty) {
    return arContent.title;
  }
  // Si pas de titre, utiliser l'ID de la tâche comme fallback
  return 'Tâche $taskId';
});

class _CounterBar extends ConsumerWidget {
  final String sessionId;
  const _CounterBar({required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentProgressProvider(sessionId));
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Compteur avec boutons + et -
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton décrémenter
                IconButton.filled(
                  onPressed: current.maybeWhen(
                    data: (p) => p == null || p.remainingReps <= 0
                        ? null
                        : () async {
                            final val = await ref
                                .read(progressServiceProvider)
                                .decrementCurrent(sessionId);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              final msg = (val == null)
                                  ? 'Étape mise à jour'
                                  : (val > 0
                                      ? 'Reste: $val'
                                      : 'Étape terminée ✓');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(msg)),
                              );
                              if (val == null) {
                                ref.hapticSelection();
                              } else if (val > 0) {
                                ref.hapticLightTap();
                              } else {
                                ref.hapticImpact();
                              }
                            }
                          },
                    orElse: () => null,
                  ),
                  icon: const Icon(Icons.remove),
                  tooltip: 'Décrémenter',
                ),
                const SizedBox(width: 12),
                // Affichage du compteur
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: current.when(
                    data: (p) => Text(
                      p == null ? '0' : '${p.remainingReps}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    loading: () => Text(
                      '...',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                    ),
                    error: (_, __) => Text(
                      '!',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: colorScheme.error,
                              ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Bouton incrémenter (pour corriger si besoin)
                IconButton.outlined(
                  onPressed: current.maybeWhen(
                    data: (p) => p == null
                        ? null
                        : () async {
                            final val = await ref
                                .read(progressServiceProvider)
                                .incrementCurrent(sessionId);
                            ref.hapticLightTap();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(val == null
                                        ? 'Étape mise à jour'
                                        : 'Reste: $val')),
                              );
                            }
                          },
                    orElse: () => null,
                  ),
                  icon: const Icon(Icons.add),
                  tooltip: 'Incrémenter',
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            // Boutons audio
            Row(
              children: [
                Expanded(
                  child: Consumer(builder: (context, ref, _) {
                    return FutureBuilder<bool>(
                      future: () async {
                        final mode = ref.read(bilingualDisplayProvider);
                        final settings = ref.read(userSettingsServiceProvider);
                        final current = await ref
                            .read(currentProgressProvider(sessionId).future);
                        if (current == null) return false;
                        final pair = await ref
                            .read(contentServiceProvider)
                            .getBuiltTextsForTask(current.taskId);
                        String? text;
                        String lang;
                        if (mode == BilingualDisplay.arOnly) {
                          text = pair.$1; // AR
                          lang = await settings.getTtsPreferredAr();
                          if (text == null || text.trim().isEmpty) {
                            text = pair.$2; // fallback FR
                            lang = await settings.getTtsPreferredFr();
                          }
                        } else {
                          text = pair.$2; // FR
                          lang = await settings.getTtsPreferredFr();
                          if (text == null || text.trim().isEmpty) {
                            text = pair.$1; // fallback AR
                            lang = await settings.getTtsPreferredAr();
                          }
                        }
                        if (text == null || text.trim().isEmpty) return false;
                        final speed = await settings.getTtsSpeed();
                        final pitch = await settings.getTtsPitch();
                        final localSecure =
                            ref.read(secure.userSettingsServiceProvider);
                        final cloudEnabled =
                            await localSecure.getCloudTtsEnabled();
                        if (!cloudEnabled) return false;
                        final provider =
                            await localSecure.getCloudTtsProvider();
                        final endpoint =
                            await localSecure.getCloudTtsEndpoint();
                        final apiKey = await localSecure.getCloudTtsApiKey();
                        final awsAccess = await localSecure.getAwsAccessKey();
                        final awsSecret = await localSecure.getAwsSecretKey();
                        final canCloud = (provider == 'polly')
                            ? (awsAccess != null &&
                                awsAccess.isNotEmpty &&
                                awsSecret != null &&
                                awsSecret.isNotEmpty &&
                                endpoint != null &&
                                endpoint.isNotEmpty)
                            : (apiKey != null && apiKey.isNotEmpty);
                        if (!canCloud) return false;
                        final cloudFr = await localSecure.getCloudVoiceFrName();
                        final cloudAr = await localSecure.getCloudVoiceArName();
                        final cloudVoice = (mode == BilingualDisplay.arOnly)
                            ? (cloudAr?.isNotEmpty == true ? cloudAr! : lang)
                            : (cloudFr?.isNotEmpty == true ? cloudFr! : lang);
                        return ref.read(ttsCacheServiceProvider).existsFor(
                              provider: provider,
                              voice: cloudVoice,
                              speed: speed,
                              pitch: pitch,
                              text: text,
                            );
                      }(),
                      builder: (context, snap) {
                        final cached = snap.data == true;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton.icon(
                              icon: Icon(cached
                                  ? Icons.library_music_rounded
                                  : Icons.volume_up_rounded),
                              label:
                                  Text(cached ? 'Écouter (cache)' : 'Écouter'),
                              onPressed: () async {
                                // One-shot playback of current passage (no decrement)
                                final tts = ref.read(audioTtsServiceProvider);
                                final mode = ref.read(bilingualDisplayProvider);
                                final settings =
                                    ref.read(userSettingsServiceProvider);
                                final current = await ref.read(
                                    currentProgressProvider(sessionId).future);
                                if (current == null) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Session terminée')),
                                    );
                                  }
                                  return;
                                }
                                final pair = await ref
                                    .read(contentServiceProvider)
                                    .getBuiltTextsForTask(current.taskId);
                                // Prefer FR unless AR-only mode is selected
                                String? text;
                                String lang;
                                String shortLang; // 'fr' or 'ar'
                                if (mode == BilingualDisplay.arOnly) {
                                  text = pair.$1; // AR
                                  lang = await settings.getTtsPreferredAr();
                                  shortLang = 'ar';
                                  if (text == null || text.trim().isEmpty) {
                                    text = pair.$2; // fallback FR
                                    lang = await settings.getTtsPreferredFr();
                                    shortLang = 'fr';
                                  }
                                } else {
                                  text = pair.$2; // FR
                                  lang = await settings.getTtsPreferredFr();
                                  shortLang = 'fr';
                                  if (text == null || text.trim().isEmpty) {
                                    text = pair.$1; // fallback AR
                                    lang = await settings.getTtsPreferredAr();
                                    shortLang = 'ar';
                                  }
                                }
                                if (text == null || text.trim().isEmpty) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Contenu introuvable pour ce passage')),
                                    );
                                  }
                                  return;
                                }
                                await tts.stop(); // stop any ongoing utterance
                                // Check per-task audio settings (per-lang)
                                final taskAudio = await ref
                                    .read(taskAudioPrefsProvider)
                                    .getForTaskLocale(
                                        current.taskId, shortLang);
                                if (taskAudio.source == 'file' &&
                                    taskAudio.hasLocalFile) {
                                  await ref
                                      .read(audioPlayerServiceProvider)
                                      .playFile(taskAudio.filePath!);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Lecture du fichier associé…')),
                                    );
                                  }
                                  return;
                                }
                                final speed = await settings.getTtsSpeed();
                                final pitch = await settings.getTtsPitch();
                                final localSecure = ref
                                    .read(secure.userSettingsServiceProvider);
                                final cloudEnabled =
                                    await localSecure.getCloudTtsEnabled();
                                final provider =
                                    await localSecure.getCloudTtsProvider();
                                final endpoint =
                                    await localSecure.getCloudTtsEndpoint();
                                final apiKey =
                                    await localSecure.getCloudTtsApiKey();
                                final awsAccess =
                                    await localSecure.getAwsAccessKey();
                                final awsSecret =
                                    await localSecure.getAwsSecretKey();
                                // Cloud-specific voice overrides
                                final cloudFr =
                                    await localSecure.getCloudVoiceFrName();
                                final cloudAr =
                                    await localSecure.getCloudVoiceArName();
                                final cloudVoice =
                                    (mode == BilingualDisplay.arOnly)
                                        ? (cloudAr?.isNotEmpty == true
                                            ? cloudAr!
                                            : lang)
                                        : (cloudFr?.isNotEmpty == true
                                            ? cloudFr!
                                            : lang);
                                // Per-task override: enforce device or cloud
                                final forcedDevice =
                                    taskAudio.source == 'device';
                                final forcedCloud = taskAudio.source == 'cloud';
                                final canCloud = !forcedDevice &&
                                    cloudEnabled &&
                                    ((provider == 'polly' &&
                                            awsAccess != null &&
                                            awsAccess.isNotEmpty &&
                                            awsSecret != null &&
                                            awsSecret.isNotEmpty &&
                                            endpoint != null &&
                                            endpoint.isNotEmpty) ||
                                        (provider != 'polly' &&
                                            apiKey != null &&
                                            apiKey.isNotEmpty));
                                bool wasCached = false;
                                if (canCloud || forcedCloud) {
                                  try {
                                    final cfg = CloudTtsConfig(
                                        provider: provider,
                                        apiKey: apiKey,
                                        endpoint: endpoint,
                                        awsAccessKey: awsAccess,
                                        awsSecretKey: awsSecret);
                                    final svc =
                                        ref.read(cloudTtsByConfigProvider(cfg));
                                    wasCached = await ref
                                        .read(ttsCacheServiceProvider)
                                        .existsFor(
                                          provider: provider,
                                          voice: cloudVoice,
                                          speed: speed,
                                          pitch: pitch,
                                          text: text,
                                        );
                                    final path = await svc.synthesizeToCache(
                                        text,
                                        voice: cloudVoice,
                                        speed: speed,
                                        pitch: pitch);
                                    await ref
                                        .read(audioPlayerServiceProvider)
                                        .playFile(path);
                                    // Record entry to manifest
                                    final digest = await ref
                                        .read(ttsCacheServiceProvider)
                                        .computeDigest(
                                          provider: provider,
                                          voice: cloudVoice,
                                          speed: speed,
                                          pitch: pitch,
                                          text: text,
                                        );
                                    final bytes = await File(path).length();
                                    // Determine routine from session
                                    final session = await ref
                                        .read(sessionDaoProvider)
                                        .getById(sessionId);
                                    final routineId = session?.routineId ?? '';
                                    await ref
                                        .read(ttsCacheServiceProvider)
                                        .recordEntry(
                                          digest: digest,
                                          routineId: routineId,
                                          taskId: current.taskId,
                                          lang:
                                              (mode == BilingualDisplay.arOnly)
                                                  ? 'ar'
                                                  : 'fr',
                                          sizeBytes: bytes,
                                        );
                                  } catch (_) {
                                    await tts.playText(text,
                                        voice: lang,
                                        speed: speed,
                                        pitch: pitch);
                                  }
                                } else {
                                  await tts.playText(text,
                                      voice: lang, speed: speed, pitch: pitch);
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(wasCached
                                            ? 'Lecture du passage (cache)…'
                                            : 'Lecture du passage…')),
                                  );
                                }
                              },
                            ),
                            if (cached) ...[
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    child: Text('Cache',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                          fontSize: 11,
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    icon: Consumer(builder: (context, ref, _) {
                      final running = ref.watch(handsFreeControllerProvider);
                      return Icon(running
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded);
                    }),
                    label: Consumer(builder: (context, ref, _) {
                      final running = ref.watch(handsFreeControllerProvider);
                      return Text(running ? 'Pause' : 'Mains libres');
                    }),
                    onPressed: () async {
                      final running = ref.read(handsFreeControllerProvider);
                      if (!running) {
                        // Choose TTS language from display preference
                        final mode = ref.read(bilingualDisplayProvider);
                        final settings = ref.read(userSettingsServiceProvider);
                        final ttsLang = mode == BilingualDisplay.arOnly
                            ? await settings.getTtsPreferredAr()
                            : await settings.getTtsPreferredFr();
                        final ttsSpeed = await settings.getTtsSpeed();
                        final ttsPitch = await settings.getTtsPitch();
                        // Prepare highlight from built FR text
                        final current = await ref
                            .read(currentProgressProvider(sessionId).future);
                        if (current != null) {
                          final pair = await ref
                              .read(contentServiceProvider)
                              .getBuiltTextsForTask(current.taskId);
                          final frText = pair.$2;
                          if (frText != null && frText.trim().isNotEmpty) {
                            ref
                                .read(highlightControllerProvider.notifier)
                                .setText(frText);
                            ref
                                .read(highlightControllerProvider.notifier)
                                .start(msPerWord: 300);
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Session terminée')),
                            );
                          }
                          return;
                        }
                        await ref
                            .read(handsFreeControllerProvider.notifier)
                            .start(sessionId,
                                language: ttsLang,
                                speed: ttsSpeed,
                                pitch: ttsPitch);
                        ref.hapticLightTap();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Mode mains libres activé')),
                          );
                        }
                      } else {
                        await ref
                            .read(handsFreeControllerProvider.notifier)
                            .stop();
                        ref.read(highlightControllerProvider.notifier).stop();
                        ref.hapticSelection();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Mode mains libres arrêté')),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StopAndCompleteBar extends ConsumerWidget {
  final String sessionId;
  const _StopAndCompleteBar({required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentProgressProvider(sessionId));
    final hasCurrent = current.maybeWhen(
      data: (p) => p != null,
      orElse: () => false,
    );

    // Vérifier s'il y a une étape précédente disponible
    final sessionAsync = ref.watch(sessionRowProvider(sessionId));
    final tasksAsync = sessionAsync.maybeWhen(
      data: (session) => session != null
          ? ref.watch(tasksByRoutineProvider(session.routineId))
          : null,
      orElse: () => null,
    );

    final canGoPrevious = current.maybeWhen(
      data: (p) {
        if (p == null) return false;
        // On peut revenir en arrière si on n'est pas à la première tâche
        final tasks = tasksAsync?.value ?? [];
        final currentIndex = tasks.indexWhere((t) => t.id == p.taskId);
        return currentIndex > 0;
      },
      orElse: () => false,
    );

    return Column(
      children: [
        // Ligne 1: Navigation entre étapes
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Bouton Étape précédente
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: canGoPrevious
                        ? () async {
                            await ref
                                .read(progressServiceProvider)
                                .advanceToPrevious(sessionId);
                            ref.hapticLightTap();
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Précédent'),
                  ),
                ),
                const SizedBox(width: 8),
                // Bouton Étape suivante
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: hasCurrent
                        ? () async {
                            await ref
                                .read(progressServiceProvider)
                                .advanceToNext(sessionId);
                            ref.hapticLightTap();
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Suivant'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Ligne 2: Actions sur la tâche
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Bouton Stop lecture
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Stop one-shot TTS and hands-free if any
                      await ref.read(audioTtsServiceProvider).stop();
                      final running = ref.read(handsFreeControllerProvider);
                      if (running) {
                        await ref
                            .read(handsFreeControllerProvider.notifier)
                            .stop();
                      }
                      ref.read(highlightControllerProvider.notifier).stop();
                      ref.hapticSelection();
                    },
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text('Arrêter'),
                  ),
                ),
                const SizedBox(width: 8),
                // Bouton Terminer cette tâche
                Expanded(
                  child: FilledButton.icon(
                    onPressed: hasCurrent
                        ? () async {
                            await ref
                                .read(progressServiceProvider)
                                .completeCurrent(sessionId);
                            ref.hapticImpact();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Tâche terminée ✓')),
                              );
                            }
                          }
                        : null,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Terminer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
