import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/services/audio_cloud_tts_service.dart';
import 'package:spiritual_routines/core/services/audio_service_hybrid_wrapper.dart';
import 'package:spiritual_routines/core/services/audio_player_service.dart';
import 'package:spiritual_routines/features/settings/user_settings_service.dart'
    as secure;
import 'package:spiritual_routines/core/services/task_audio_prefs.dart';
import 'package:spiritual_routines/core/services/progress_service.dart';
import 'package:spiritual_routines/core/services/user_settings_service.dart';
import 'package:spiritual_routines/core/services/content_service.dart';
import 'package:spiritual_routines/core/services/session_service.dart';
import 'package:spiritual_routines/features/reader/reading_prefs.dart';
import 'package:spiritual_routines/features/reader/highlight_controller.dart';

// Import des providers existants
import 'package:spiritual_routines/features/reader/modern_reader_page.dart'
    show readerCurrentTaskProvider;
import 'package:spiritual_routines/features/routines/routine_completion_status.dart';
import 'package:spiritual_routines/features/counter/smart_counter.dart';

class HandsFreeController extends StateNotifier<bool> {
  HandsFreeController(this._ref) : super(false);
  final Ref _ref;

  // Callback pour notifier la completion d'une routine
  VoidCallback? onRoutineCompleted;
  // NE PAS utiliser FlutterTtsAudioService directement
  // Utiliser le service intelligent qui gère Coqui/Flutter automatiquement
  CloudTtsService? _cloud;
  AudioPlayerService? _player;
  StreamSubscription? _posSub;
  bool _running = false;

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

  Future<void> start(String sessionId,
      {String language = 'fr-FR',
      String? interfaceLanguage,
      double? speed,
      double? pitch}) async {
    if (_running) {
      print('⚠️ Mode mains libres déjà en cours, arrêt forcé');
      await stop();
    }

    print('🚀 Démarrage du mode mains libres pour session: $sessionId');

    state = true;
    _running = true;
    _posSub?.cancel();
    // Utiliser le service TTS hybride (APIs Quran + Edge-TTS intelligent)
    final hybridTts = _ref.read(audioTtsServiceHybridProvider);
    _posSub = hybridTts.positionStream().listen((_) {});
    final settings = _ref.read(userSettingsServiceProvider);
    final sp = speed ?? await settings.getTtsSpeed();
    final pt = pitch ?? await settings.getTtsPitch();
    // Cloud TTS setup if enabled
    final secureSvc = _ref.read(secure.userSettingsServiceProvider);
    final enabled = await secureSvc.getCloudTtsEnabled();
    final apiKey = await secureSvc.getCloudTtsApiKey();
    final provider = await secureSvc.getCloudTtsProvider();
    final endpoint = await secureSvc.getCloudTtsEndpoint();
    if (enabled &&
        ((provider == 'polly' &&
                (await _ref
                        .read(secure.userSettingsServiceProvider)
                        .getAwsAccessKey()) !=
                    null) ||
            (apiKey != null && apiKey.isNotEmpty))) {
      final access = await secureSvc.getAwsAccessKey();
      final secret = await secureSvc.getAwsSecretKey();
      final cfg = CloudTtsConfig(
          provider: provider,
          apiKey: apiKey,
          endpoint: endpoint,
          awsAccessKey: access,
          awsSecretKey: secret);
      _cloud = _ref.read(cloudTtsByConfigProvider(cfg));
      _player = _ref.read(audioPlayerServiceProvider);
    } else {
      _cloud = null;
      _player = null;
    }
    while (_running) {
      print('🔄 Récupération de la progression pour session: $sessionId');

      final p = await _ref
          .read(progressServiceProvider)
          .getCurrentProgress(sessionId);

      if (p == null) {
        print('⚠️ Aucune progression trouvée pour session: $sessionId');
        break;
      }

      print(
          '📊 Progression trouvée - TaskId: ${p.taskId}, Reps: ${p.remainingReps}');

      // Mettre à jour l'interface reader avec la tâche actuelle
      final currentTask = await _ref.read(taskDaoProvider).getById(p.taskId);
      if (currentTask != null) {
        // IMPORTANT: Mettre à jour le provider AVANT de lire le texte
        // pour que l'interface se mette à jour immédiatement
        _ref.read(readerCurrentTaskProvider.notifier).state = currentTask;
        _ref.read(smartCounterProvider.notifier).setInitial(p.remainingReps);

        // Log pour débugger
        print('🔄 Mode mains libres: passage à la tâche ${currentTask.id}');
        print('   📝 Notes FR: ${currentTask.notesFr}');
        print('   📝 Notes AR: ${currentTask.notesAr}');
        print('   🔢 Répétitions: ${p.remainingReps}');

        // Attendre un peu pour que l'UI se mette à jour
        await Future.delayed(const Duration(milliseconds: 200));
      }
      // Récupérer les textes dans les deux langues
      final ar = await _ref
          .read(contentServiceProvider)
          .getByTaskAndLocale(p.taskId, 'ar');
      final fr = await _ref
          .read(contentServiceProvider)
          .getByTaskAndLocale(p.taskId, 'fr');
      final textAr = ar?.body?.trim().isNotEmpty == true ? ar!.body : null;
      final textFr = fr?.body?.trim().isNotEmpty == true ? fr!.body : null;

      // Déterminer la langue d'affichage actuelle depuis l'interface
      final display = _ref.read(bilingualDisplayProvider);
      String? text;
      String lang = language;
      String shortLang;

      // Choisir le texte selon la préférence d'affichage
      if (display == BilingualDisplay.arOnly && textAr != null) {
        text = textAr;
      } else if (display == BilingualDisplay.frOnly && textFr != null) {
        text = textFr;
      } else {
        // Mode both ou fallback : choisir le texte disponible
        text = textFr ?? textAr;
      }

      // DÉTECTION AUTOMATIQUE: Analyser la langue réelle du contenu sélectionné
      if (text != null && text.trim().isNotEmpty) {
        final isActuallyArabic = _isArabicText(text);

        if (isActuallyArabic) {
          // Le texte est en arabe -> utiliser les paramètres TTS arabes
          lang = await settings.getTtsPreferredAr();
          shortLang = 'ar';
        } else {
          // Le texte est en français -> utiliser les paramètres TTS français
          lang = await settings.getTtsPreferredFr();
          shortLang = 'fr';
        }
      } else {
        // PAS DE TEXTE DISPONIBLE: Utiliser la langue de l'interface utilisateur
        if (interfaceLanguage == 'ar') {
          // Interface en arabe -> utiliser les paramètres TTS arabes
          lang = await settings.getTtsPreferredAr();
          shortLang = 'ar';
        } else {
          // Interface en français -> utiliser les paramètres TTS français
          lang = await settings.getTtsPreferredFr();
          shortLang = 'fr';
        }
      }
      text ??= 'Répéter';

      // Update highlight per iteration when FR is visible
      if (display != BilingualDisplay.arOnly) {
        final fr = await _ref
            .read(contentServiceProvider)
            .getByTaskAndLocale(p.taskId, 'fr');
        final frText = fr?.body?.trim().isNotEmpty == true ? fr!.body! : '';
        if (frText.isNotEmpty) {
          _ref.read(highlightControllerProvider.notifier).setText(frText);
          _ref.read(highlightControllerProvider.notifier).start(msPerWord: 300);
        } else {
          _ref.read(highlightControllerProvider.notifier).stop();
        }
      } else {
        _ref.read(highlightControllerProvider.notifier).stop();
      }
      final langAudio = await _ref
          .read(taskAudioPrefsProvider)
          .getForTaskLocale(p.taskId, shortLang);
      if (langAudio.source == 'file' && langAudio.hasLocalFile) {
        final audioPlayer = _player ??= _ref.read(audioPlayerServiceProvider);
        await audioPlayer?.playFile(langAudio.filePath!);
      } else if (_cloud != null &&
          _player != null &&
          langAudio.source != 'device') {
        try {
          // Cloud voice override if present
          final securePrefs = _ref.read(secure.userSettingsServiceProvider);
          final cloudFr = await securePrefs.getCloudVoiceFrName();
          final cloudAr = await securePrefs.getCloudVoiceArName();
          final display = _ref.read(bilingualDisplayProvider);
          final voice = (display == BilingualDisplay.arOnly)
              ? (cloudAr?.isNotEmpty == true ? cloudAr! : lang)
              : (cloudFr?.isNotEmpty == true ? cloudFr! : lang);
          final path = await _cloud!
              .synthesizeToCache(text, voice: voice, speed: sp, pitch: pt);
          await _player!.playFile(path);
        } catch (_) {
          // Utiliser le service TTS hybride en cas d'erreur cloud
          try {
            await hybridTts.playText(
              text,
              voice: lang,
              speed: sp,
              pitch: pt,
              allowFallback: true, // Permettre le fallback automatique
            );
          } catch (e) {
            print(
                '⚠️ Erreur TTS hybride après échec cloud, continuez quand même: $e');
            // Ne pas faire planter le mode mains libres pour une erreur TTS
          }
        }
      } else {
        // Utiliser le service TTS hybride avec fallback en mode mains libres
        try {
          await hybridTts.playText(
            text,
            voice: lang,
            speed: sp,
            pitch: pt,
            allowFallback:
                true, // Permettre le fallback automatique en mode mains libres
          );
        } catch (e) {
          print(
              '⚠️ Erreur TTS hybride en mode mains libres, continuez quand même: $e');
          // Ne pas faire planter le mode mains libres pour une erreur TTS
          // L'utilisateur peut continuer manuellement
        }
      }
      // No extra delay needed; both play paths await completion
      final val =
          await _ref.read(progressServiceProvider).decrementCurrent(sessionId);
      if (val == null) break;

      // Mettre à jour le compteur après décrémentation
      if (currentTask != null) {
        _ref.read(smartCounterProvider.notifier).setInitial(val);
      }

      if (val <= 0) {
        // small pause before auto-advance
        await Future<void>.delayed(const Duration(milliseconds: 300));

        // Vérifier si c'était la dernière tâche de la routine
        final nextProgress = await _ref
            .read(progressServiceProvider)
            .getCurrentProgress(sessionId);
        if (nextProgress == null) {
          // Toutes les tâches sont terminées - routine complète
          _running = false;
          state = false;
          await _showRoutineCompletionNotification(sessionId);
          break;
        }
      }
    }
  }

  /// Afficher la notification de completion de routine
  Future<void> _showRoutineCompletionNotification(String sessionId) async {
    try {
      // Récupérer la session pour obtenir le routineId AVANT de la modifier
      final sessionDao = _ref.read(sessionDaoProvider);
      final sessionQuery = sessionDao.select(sessionDao.sessions)
        ..where((s) => s.id.equals(sessionId));
      final session = await sessionQuery.getSingleOrNull();

      if (session == null) {
        print('❌ Session non trouvée: $sessionId');
        return;
      }

      // Marquer la session comme terminée dans la base de données
      await _ref.read(sessionServiceProvider).completeSession(sessionId);

      // Log de succès avec détails
      print('🎉 Routine terminée avec succès !');
      print('📊 Session ID: $sessionId');
      print('📋 Routine ID: ${session.routineId}');
      print('⏰ Statut: completed');

      // Attendre suffisamment longtemps pour que la transaction soit commitée
      await Future.delayed(const Duration(milliseconds: 500));

      // Vérifier que la session a bien été marquée comme complétée avant d'invalider
      final completedSessions =
          await sessionDao.getCompletedSessionsForRoutine(session.routineId);
      print(
          '🔍 Vérification: ${completedSessions.length} sessions complétées trouvées pour routine ${session.routineId}');

      if (completedSessions.isNotEmpty) {
        // Forcer le rafraîchissement du provider de statut de completion
        _ref.invalidate(routineCompletionStatusProvider(session.routineId));
        print('🔄 Provider invalidé pour routine: ${session.routineId}');

        // Attendre un peu puis invalider à nouveau pour forcer le refresh UI
        await Future.delayed(const Duration(milliseconds: 200));
        _ref.invalidate(routineCompletionStatusProvider(session.routineId));
        print('🔄 Double invalidation effectuée');
      } else {
        print('⚠️ Aucune session complétée trouvée, provider non invalidé');
      }

      // Notifier la completion à la page reader pour navigation
      if (onRoutineCompleted != null) {
        onRoutineCompleted!();
        print('📱 Callback de completion appelé');
      }

      // Optionnel: Ajouter une vibration haptique
      // HapticFeedback.heavyImpact();

      // Optionnel: Déclencher une notification système
      // NotificationService.showCompletionNotification();
    } catch (e) {
      print('❌ Erreur lors de la completion de la session: $e');
    }
  }

  Future<void> stop() async {
    _running = false;
    state = false;
    // Arrêter le service TTS hybride
    final hybridTts = _ref.read(audioTtsServiceHybridProvider);
    await hybridTts.stop();
    try {
      await _player?.stop();
    } catch (_) {}
    await _posSub?.cancel();
  }
}

final handsFreeControllerProvider =
    StateNotifierProvider<HandsFreeController, bool>(
        (ref) => HandsFreeController(ref));
