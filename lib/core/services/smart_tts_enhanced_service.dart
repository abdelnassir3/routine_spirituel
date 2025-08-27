import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_player_service.dart';
import 'audio_tts_service.dart';
import 'audio/hybrid_audio_service.dart';
import 'audio/content_detector_service.dart';

/// Service TTS intelligent amélioré avec support hybride
class SmartTtsEnhancedService {
  final AudioPlayerService _audioPlayer;
  final AudioTtsService? _classicTtsService;
  bool _isEnabled = true;
  
  SmartTtsEnhancedService(this._audioPlayer, {AudioTtsService? classicTtsService})
      : _classicTtsService = classicTtsService;
  
  /// Lit le texte avec le système hybride intelligent
  Future<void> playTextHybrid(
    String text, {
    String language = 'auto',
    double speed = 1.0,
    double pitch = 1.0,
    HybridAudioSettings? settings,
  }) async {
    try {
      if (!_isEnabled) {
        debugPrint('⚠️ TTS désactivé');
        return;
      }
      
      debugPrint('🎵 SmartTTS Hybride: Début lecture');
      debugPrint('📝 Texte: ${text.substring(0, text.length.clamp(0, 100))}...');
      
      // 1. Analyser le contenu
      final analysis = await HybridAudioService.analyzeContentDetails(text);
      debugPrint('📊 Analyse: $analysis');
      
      // 2. Générer l'audio approprié
      final audioBytes = await HybridAudioService.generateAudio(
        text,
        language: language,
        speed: speed,
        pitch: pitch,
        settings: settings,
      );
      
      if (audioBytes != null) {
        // 3. Lire l'audio généré
        await _audioPlayer.playFromBytes(audioBytes);
        debugPrint('✅ Lecture hybride démarrée: ${audioBytes.length} bytes');
      } else {
        debugPrint('❌ Échec génération audio hybride');
        // Fallback vers le système TTS classique
        await _fallbackToClassicTts(text, language, speed, pitch);
      }
      
    } catch (e) {
      debugPrint('❌ Erreur SmartTTS Hybride: $e');
      await _fallbackToClassicTts(text, language, speed, pitch);
    }
  }
  
  /// Fallback vers le système TTS classique
  Future<void> _fallbackToClassicTts(
    String text,
    String language,
    double speed,
    double pitch,
  ) async {
    debugPrint('🔄 Fallback vers TTS classique');
    
    try {
      // Utiliser l'AudioPlayerService pour jouer le texte via le système existant
      // Convertir language en voice pour l'API existante
      String voice;
      switch (language.toLowerCase()) {
        case 'fr':
        case 'fr-fr':
          voice = 'fr-FR-DeniseNeural';
          break;
        case 'ar':
        case 'ar-sa':
          voice = 'ar-SA-HamedNeural';
          break;
        case 'en':
        case 'en-us':
          voice = 'en-US-AriaNeural';
          break;
        default:
          voice = 'fr-FR-DeniseNeural';
      }
      
      // Utiliser le service TTS classique si disponible
      if (_classicTtsService != null) {
        debugPrint('💬 Utilisation du SmartTtsService classique avec voix: $voice');
        await _classicTtsService!.playText(
          text,
          voice: voice,
          speed: speed,
          pitch: pitch,
        );
      } else {
        debugPrint('⚠️ Aucun service TTS classique disponible pour le fallback');
      }
      
    } catch (e) {
      debugPrint('❌ Erreur dans le fallback TTS classique: $e');
    }
  }
  
  /// Analyse le contenu sans lire l'audio
  Future<ContentAnalysis> analyzeContent(String text) async {
    return await HybridAudioService.analyzeContentDetails(text);
  }
  
  /// Active/désactive le service
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    debugPrint('🎵 SmartTTS Hybride ${enabled ? 'activé' : 'désactivé'}');
  }
  
  /// Arrête la lecture en cours
  Future<void> stop() async {
    await _audioPlayer.stop();
  }
  
  /// Pause la lecture
  Future<void> pause() async {
    await _audioPlayer.pause();
  }
  
  /// Reprend la lecture
  Future<void> resume() async {
    await _audioPlayer.resume();
  }
  
  /// Obtient la position actuelle
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  
  /// Obtient le statut de lecture
  Stream<bool> get isPlayingStream => _audioPlayer.isPlayingStream;
}

/// Provider pour le service TTS hybride amélioré
final smartTtsEnhancedProvider = Provider<SmartTtsEnhancedService>((ref) {
  final audioPlayer = ref.read(audioPlayerServiceProvider);
  final classicTts = ref.read(audioTtsServiceProvider);
  return SmartTtsEnhancedService(audioPlayer, classicTtsService: classicTts);
});

/// Extension pour faciliter l'utilisation
extension SmartTtsEnhancedExtension on SmartTtsEnhancedService {
  
  /// Lit automatiquement selon le contenu détecté
  Future<void> playAuto(String text, {double speed = 1.0}) async {
    await playTextHybrid(
      text,
      language: 'auto',
      speed: speed,
      settings: HybridAudioSettings.defaultSettings(),
    );
  }
  
  /// Lit avec la meilleure qualité disponible
  Future<void> playHighQuality(String text, {double speed = 1.0}) async {
    await playTextHybrid(
      text,
      language: 'auto',
      speed: speed,
      settings: HybridAudioSettings.highQuality(),
    );
  }
  
  /// Prévisualise l'analyse de contenu
  String previewContentType(String text) {
    final analysis = analyzeContent(text);
    
    switch (analysis.contentType) {
      case ContentType.quranicVerse:
        return '🕌 Verset coranique (${analysis.verses.length} versets)';
      case ContentType.islamicDua:
        return '🤲 Invocation islamique';
      case ContentType.arabicText:
        return '🗣️ Texte arabe (${(analysis.languageRatio.arabic * 100).round()}% AR)';
      case ContentType.frenchText:
        return '🇫🇷 Texte français (${(analysis.languageRatio.french * 100).round()}% FR)';
      case ContentType.mixedLanguage:
        return '🌍 Contenu mixte (${(analysis.languageRatio.arabic * 100).round()}% AR, ${(analysis.languageRatio.french * 100).round()}% FR)';
    }
  }
}