import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/features/session/session_state.dart';
import 'package:spiritual_routines/core/services/user_settings_service.dart';
import 'package:spiritual_routines/core/services/hybrid_audio_service.dart';
import 'package:spiritual_routines/features/reader/reading_prefs.dart';

// Stub classes pour éviter les erreurs de compilation
enum HandsFreeStatus { idle, starting, playing, paused, error }

class HandsFreeState {
  final HandsFreeStatus status;
  final String? error;
  
  const HandsFreeState({required this.status, this.error});
  
  HandsFreeState.idle() : status = HandsFreeStatus.idle, error = null;
  
  bool get isActive => status != HandsFreeStatus.idle;
  bool get isPlaying => status == HandsFreeStatus.playing;
  
  HandsFreeState copyWith({HandsFreeStatus? status, String? error}) {
    return HandsFreeState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

class AudioTaskPrefs {
  final double speed;
  final double pitch;
  
  const AudioTaskPrefs({this.speed = 1.0, this.pitch = 0.0});
}

final taskAudioPrefsProvider = Provider<TaskAudioPrefs>((ref) => TaskAudioPrefs());

class TaskAudioPrefs {
  Future<AudioTaskPrefs> getForTaskLocale(int taskId, String locale) async {
    return const AudioTaskPrefs();
  }
}

final highlightControllerProvider = StateNotifierProvider<HighlightController, void>((ref) {
  return HighlightController();
});

class HighlightController extends StateNotifier<void> {
  HighlightController() : super(null);
  
  void highlightCurrent(int index, Duration duration) {}
  void stop() {}
}

// Classe temporaire pour simuler un item
class MockCurrentItem {
  String? get contentAr => 'الحمد لله';
  String? get contentFr => 'Louange à Allah';
}

final handsFreeControllerProvider = StateNotifierProvider.family<
    HandsFreeController, HandsFreeState, int>((ref, taskId) {
  return HandsFreeController(ref, taskId);
});

class HandsFreeController extends StateNotifier<HandsFreeState> {
  final Ref _ref;
  final int taskId;
  Timer? _timer;
  Timer? _delayTimer;

  HandsFreeController(this._ref, this.taskId) : super(HandsFreeState.idle());

  Future<void> startHandsFree() async {
    if (state.isActive) return;

    try {
      // TODO: Vérifier l'état de la session
      // final sessionState = _ref.read(sessionStateProvider);
      // if (!sessionState.hasValidTask()) {
      //   debugPrint('❌ Session non valide pour le mode mains libres');
      //   return;
      // }
      debugPrint('✅ Démarrage du mode mains libres (simulation)');

      state = state.copyWith(
        status: HandsFreeStatus.starting,
        error: null,
      );

      // Démarrer le mode
      await _startRepeatedPlayback();
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors du démarrage du mode mains libres: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        status: HandsFreeStatus.error,
        error: 'Erreur lors du démarrage: ${e.toString()}',
      );
    }
  }

  Future<void> stopHandsFree() async {
    try {
      _timer?.cancel();
      _delayTimer?.cancel();

      // Arrêter l'audio
      final hybridTts = _ref.read(hybridAudioServiceProvider);
      await hybridTts.stop();

      // Arrêter la surbrillance
      _ref.read(highlightControllerProvider.notifier).stop();

      state = HandsFreeState.idle();
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'arrêt du mode mains libres: $e');
      state = state.copyWith(
        status: HandsFreeStatus.error,
        error: 'Erreur lors de l\'arrêt: ${e.toString()}',
      );
    }
  }

  void pause() {
    if (!state.isPlaying) return;

    _timer?.cancel();
    _delayTimer?.cancel();

    state = state.copyWith(
      status: HandsFreeStatus.paused,
    );
  }

  Future<void> resume() async {
    if (state.status != HandsFreeStatus.paused) return;

    state = state.copyWith(
      status: HandsFreeStatus.playing,
    );

    await _startRepeatedPlayback();
  }

  Future<void> _startRepeatedPlayback() async {
    try {
      state = state.copyWith(status: HandsFreeStatus.playing);
      await _playCurrentIteration();
    } catch (e) {
      debugPrint('❌ Erreur dans _startRepeatedPlayback: $e');
      state = state.copyWith(
        status: HandsFreeStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> _playCurrentIteration() async {
    if (!state.isPlaying) return;

    try {
      // Simuler une progression pour éviter les erreurs
      final currentItem = _getCurrentMockItem();

      // PRÉPARATION AUDIO INTELLIGENTE
      final settings = _ref.read(userSettingsServiceProvider);
      // TODO: implémenter getLanguage ou utiliser une valeur par défaut
      const interfaceLanguage = 'fr'; // Valeur par défaut
      final display = BilingualDisplay.both; // Valeur par défaut

      String? text;
      String? textAr = currentItem.contentAr;
      String? textFr = currentItem.contentFr;
      String lang;
      String shortLang;
      bool isActuallyArabic = false; // Déclaré au début pour être disponible partout

      // Choisir le texte selon la préférence d'affichage
      text = textFr ?? textAr ?? 'تسبيح الله'; // Fallback vers un texte par défaut

      // DÉTECTION AUTOMATIQUE: Analyser la langue réelle du contenu sélectionné
      if (text != null && text.trim().isNotEmpty) {
        isActuallyArabic = _isArabicText(text);

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

      // Simulation de surbrillance
      _ref.read(highlightControllerProvider.notifier).highlightCurrent(0, Duration(seconds: 2));
      // TOUJOURS utiliser le service TTS hybride pour une meilleure consistency
      // Le service hybride gère déjà le routing coranique vs normal automatiquement
      final audioPrefs = TaskAudioPrefs();
      final langAudio = await audioPrefs.getForTaskLocale(taskId, shortLang);
          
      try {
        print('🎤 DEBUG: Mode mains libres - démarrage playText');
        print('  - Texte: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
        print('  - Langue: $lang');
        print('  - Vitesse: ${langAudio.speed}');
        print('  - Is Arabic: $isActuallyArabic');
        
        final hybridTts = _ref.read(hybridAudioServiceProvider);
        await hybridTts.playText(
          text,
          voice: lang,
          speed: langAudio.speed,
          pitch: langAudio.pitch,
          allowFallback: true, // Le service hybride gère les fallbacks intelligemment
        );
        
        print('✅ DEBUG: Mode mains libres - playText complété');

      } catch (e) {
        debugPrint('❌ Erreur lors de la lecture TTS: $e');
        // Continuer malgré l'erreur pour ne pas interrompre le mode mains libres
      }

      if (!state.isPlaying) return;

      // Attendre avant la prochaine répétition
      final delay = 3000; // 3 secondes par défaut
      _delayTimer = Timer(Duration(milliseconds: delay), () {
        if (state.isPlaying) {
          _playCurrentIteration();
        }
      });

    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de la lecture: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        status: HandsFreeStatus.error,
        error: 'Erreur lors de la lecture: ${e.toString()}',
      );
    }
  }

  bool _isArabicText(String text) {
    if (text.trim().isEmpty) return false;
    
    // Compter les caractères arabes
    int arabicCount = 0;
    int totalLetters = 0;
    
    for (int i = 0; i < text.length; i++) {
      final codeUnit = text.codeUnitAt(i);
      
      // Vérifier si c'est une lettre (pas de ponctuation, espaces, etc.)
      if ((codeUnit >= 0x0041 && codeUnit <= 0x005A) || // A-Z
          (codeUnit >= 0x0061 && codeUnit <= 0x007A) || // a-z
          (codeUnit >= 0x0600 && codeUnit <= 0x06FF) || // Arabic block
          (codeUnit >= 0x0750 && codeUnit <= 0x077F) || // Arabic Supplement
          (codeUnit >= 0x08A0 && codeUnit <= 0x08FF)) { // Arabic Extended-A
        totalLetters++;
        
        // Vérifier si c'est un caractère arabe
        if ((codeUnit >= 0x0600 && codeUnit <= 0x06FF) || // Arabic block
            (codeUnit >= 0x0750 && codeUnit <= 0x077F) || // Arabic Supplement
            (codeUnit >= 0x08A0 && codeUnit <= 0x08FF)) { // Arabic Extended-A
          arabicCount++;
        }
      }
    }
    
    if (totalLetters == 0) return false;
    
    // Si plus de 50% des lettres sont arabes, considérer comme texte arabe
    return (arabicCount / totalLetters) > 0.5;
  }
  
  // Méthode temporaire pour simuler un item
  dynamic _getCurrentMockItem() {
    return MockCurrentItem();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _delayTimer?.cancel();
    super.dispose();
  }
}