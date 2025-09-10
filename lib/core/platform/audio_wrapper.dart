import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:spiritual_routines/core/platform/platform_service.dart';

/// Wrapper pour l'audio qui fonctionne sur toutes les plateformes
class AudioWrapper {
  final PlatformService _platform = PlatformService.instance;
  final FlutterTts _tts = FlutterTts();
  AudioPlayer? _audioPlayer;

  /// Initialise le service audio de manière cross-platform
  Future<void> initialize() async {
    // Configuration TTS adaptée à la plateforme
    await _configureTTS();

    // Initialiser le player audio
    _audioPlayer = AudioPlayer();

    // Configuration spécifique pour desktop
    if (_platform.isDesktop) {
      await _configureDesktopAudio();
    }

    // Configuration spécifique pour mobile
    if (_platform.isMobile) {
      await _configureMobileAudio();
    }
  }

  /// Configure le TTS selon la plateforme
  Future<void> _configureTTS() async {
    // Configuration de base commune
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(_platform.defaultTTSRate);

    // Configuration spécifique iOS/macOS
    if (_platform.isApple) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback,
          [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker]);
    }

    // Configuration spécifique Android
    if (_platform.isAndroid) {
      await _tts.setQueueMode(1); // MODE_FLUSH
    }

    // Configuration spécifique Desktop
    if (_platform.isDesktop) {
      // Sur desktop, utiliser les voix système par défaut
      final voices = await _tts.getVoices;
      if (voices != null && (voices as List).isNotEmpty) {
        final voicesList = voices as List<dynamic>;
        // Chercher une voix française et arabe
        final frVoice = voicesList.firstWhere(
          (voice) => (voice as Map<String, dynamic>)['locale']?.toString().contains('fr') == true,
          orElse: () => voicesList.first,
        );
        final arVoice = voicesList.firstWhere(
          (voice) => (voice as Map<String, dynamic>)['locale']?.toString().contains('ar') == true,
          orElse: () => voicesList.first,
        );

        debugPrint('Voix FR disponible: ${(frVoice as Map<String, dynamic>)['name']}');
        debugPrint('Voix AR disponible: ${(arVoice as Map<String, dynamic>)['name']}');
      }
    }
  }

  /// Configuration spécifique desktop
  Future<void> _configureDesktopAudio() async {
    // Sur desktop, pas de gestion du focus audio
    // Pas de mode background
    debugPrint('Configuration audio desktop activée');
  }

  /// Configuration spécifique mobile
  Future<void> _configureMobileAudio() async {
    // Sur mobile, gérer le focus audio et le mode background
    if (_platform.needsAudioFocus) {
      // Configuration pour audio_service sur mobile uniquement
      debugPrint('Configuration audio mobile avec focus activée');
    }
  }

  /// Lit du texte avec le TTS
  Future<void> speak(String text, {String? language}) async {
    if (text.isEmpty) return;

    // Déterminer la langue
    final String targetLang = language ?? 'fr';
    if (targetLang == 'ar') {
      await _tts.setLanguage(_platform.defaultTTSLanguageAR);
    } else {
      await _tts.setLanguage(_platform.defaultTTSLanguageFR);
    }

    // Ajustements spécifiques à la plateforme
    if (_platform.isMacOS) {
      // macOS peut avoir besoin d'un délai
      await Future.delayed(const Duration(milliseconds: 100));
    }

    await _tts.speak(text);
  }

  /// Arrête la lecture TTS
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  /// Joue un fichier audio
  Future<void> playAudioFile(String path) async {
    if (_audioPlayer == null) {
      await initialize();
    }

    try {
      if (_platform.isDesktop) {
        // Sur desktop, utiliser le chemin direct
        await _audioPlayer!.setFilePath(path);
      } else {
        // Sur mobile, utiliser l'asset ou le fichier
        if (path.startsWith('assets/')) {
          await _audioPlayer!.setAsset(path);
        } else {
          await _audioPlayer!.setFilePath(path);
        }
      }

      await _audioPlayer!.play();
    } catch (e) {
      debugPrint('Erreur lecture audio: $e');
    }
  }

  /// Pause l'audio
  Future<void> pauseAudio() async {
    await _audioPlayer?.pause();
  }

  /// Reprend l'audio
  Future<void> resumeAudio() async {
    await _audioPlayer?.play();
  }

  /// Arrête l'audio
  Future<void> stopAudio() async {
    await _audioPlayer?.stop();
  }

  /// Nettoie les ressources
  Future<void> dispose() async {
    await _tts.stop();
    await _audioPlayer?.dispose();
    _audioPlayer = null;
  }

  /// Obtient l'état de support du background audio
  bool get supportsBackgroundAudio => _platform.supportsBackgroundAudio;

  /// Message pour les fonctionnalités non supportées
  String getUnsupportedFeatureMessage(String feature) {
    if (feature == 'background_audio' && _platform.isDesktop) {
      return 'La lecture audio en arrière-plan n\'est pas nécessaire sur desktop.\n'
          'L\'application reste active en arrière-plan.';
    }
    return 'Cette fonctionnalité n\'est pas disponible sur ${_platform.isDesktop ? "desktop" : "cette plateforme"}.';
  }
}
