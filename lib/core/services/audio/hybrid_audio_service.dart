import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'content_detector_service.dart';
import 'quranic_audio_service.dart';
import 'edge_tts_service.dart';
import '../text/farasa_diacritization_service.dart';
import '../quran_content_detector.dart';

/// Service hybride intelligent qui route l'audio selon le type de contenu
class HybridAudioService {
  /// Génère l'audio approprié selon le type de contenu détecté
  static Future<Uint8List?> generateAudio(
    String text, {
    String language = 'auto',
    double speed = 1.0,
    double pitch = 1.0,
    HybridAudioSettings? settings,
  }) async {
    try {
      final audioSettings = settings ?? HybridAudioSettings.defaultSettings();

      // 1. Analyser le type de contenu
      final contentType = await ContentDetectorService.analyzeContent(text);
      final cleanText = ContentDetectorService.cleanText(text);

      debugPrint('🎵 HybridAudio: Type détecté = $contentType');
      debugPrint('🎵 Texte nettoyé: ${cleanText.length} chars');

      // 2. Router vers le service approprié
      switch (contentType) {
        case ContentType.quranicVerse:
          return await _generateQuranicAudio(text, audioSettings);

        case ContentType.islamicDua:
          return await _generateIslamicDuaAudio(cleanText, audioSettings);

        case ContentType.arabicText:
          return await _generateArabicTtsAudio(
              cleanText, speed, pitch, audioSettings);

        case ContentType.frenchText:
          return await _generateFrenchTtsAudio(
              cleanText, speed, pitch, audioSettings);

        case ContentType.mixedLanguage:
          return await _generateMixedLanguageAudio(
              cleanText, speed, pitch, audioSettings);
      }
    } catch (e) {
      debugPrint('❌ Erreur HybridAudioService: $e');
      return null;
    }
  }

  /// Génère l'audio pour les versets coraniques
  static Future<Uint8List?> _generateQuranicAudio(
    String text,
    HybridAudioSettings settings,
  ) async {
    debugPrint('🕌 Génération audio coranique...');

    // Utiliser QuranContentDetector pour obtenir les vraies références
    try {
      final detection = await QuranContentDetector.detectQuranContent(text);

      if (detection.isQuranic && detection.verse != null) {
        // Utiliser le verset détecté
        final quranVerse = detection.verse!;
        final verse =
            VerseReference(surah: quranVerse.surah, verse: quranVerse.ayah);

        debugPrint(
            '🕌 Verset détecté: Sourate ${quranVerse.surah}, Ayah ${quranVerse.ayah}');

        // Générer l'audio avec les APIs Quran
        return await QuranicAudioService.getVerseAudio(
          verse,
          provider: settings.quranicProvider,
          reciter: settings.preferredReciter,
        );
      }
    } catch (e) {
      debugPrint('⚠️ Erreur détection QuranContentDetector: $e');
    }

    // Fallback: vérifier les marqueurs manuels comme avant
    final verses = ContentDetectorService.extractVerseReferences(text);

    if (verses.isEmpty) {
      debugPrint('⚠️ Aucun verset détecté, fallback vers TTS arabe');
      final cleanText = ContentDetectorService.cleanText(text);
      return await EdgeTtsService.synthesizeText(
        cleanText,
        language: 'ar-SA',
        voice: EdgeTtsVoice.arabicHamed,
      );
    }

    // Pour un seul verset
    if (verses.length == 1) {
      return await QuranicAudioService.getVerseAudio(
        verses.first,
        provider: settings.quranicProvider,
        reciter: settings.preferredReciter,
      );
    }

    // Pour plusieurs versets - concaténation (à implémenter)
    return await _concatenateVerseAudios(verses, settings);
  }

  /// Génère l'audio pour les invocations islamiques
  static Future<Uint8List?> _generateIslamicDuaAudio(
    String text,
    HybridAudioSettings settings,
  ) async {
    debugPrint('🤲 Génération audio invocation...');

    // Améliorer la prononciation avec Farasa
    String diacritizedText = text;
    if (settings.enableDiacritization) {
      debugPrint('🔤 Application diacritisation Farasa...');
      diacritizedText =
          await FarasaDiacritizationService.diacritizeIfNeeded(text);
      debugPrint(
          '📝 Texte diacritisé: ${diacritizedText.substring(0, diacritizedText.length.clamp(0, 50))}...');
    }

    // Stratégie hybride : essayer Quran API puis fallback Edge-TTS
    if (settings.useQuranicApiForDuas) {
      // TODO: Rechercher dans une base de dados de duas avec audio
      // Pour l'instant, utiliser Edge-TTS avec voix arabe de qualité
    }

    return await EdgeTtsService.synthesizeText(
      diacritizedText,
      language: 'ar-SA',
      voice: EdgeTtsVoice.arabicHamed,
    );
  }

  /// Génère l'audio TTS pour le texte arabe non-coranique
  static Future<Uint8List?> _generateArabicTtsAudio(
    String text,
    double speed,
    double pitch,
    HybridAudioSettings settings,
  ) async {
    debugPrint('🗣️ Génération TTS arabe...');

    // Améliorer la prononciation avec Farasa pour le texte arabe
    String diacritizedText = text;
    if (settings.enableDiacritization) {
      debugPrint('🔤 Application diacritisation Farasa pour texte arabe...');
      diacritizedText =
          await FarasaDiacritizationService.diacritizeIfNeeded(text);
      debugPrint(
          '📝 Texte arabe diacritisé: ${diacritizedText.substring(0, diacritizedText.length.clamp(0, 50))}...');
    }

    return await EdgeTtsService.synthesizeText(
      diacritizedText,
      language: 'ar-SA',
      voice: settings.arabicVoice,
      rate: speed,
      pitch: pitch,
    );
  }

  /// Génère l'audio TTS pour le texte français
  static Future<Uint8List?> _generateFrenchTtsAudio(
    String text,
    double speed,
    double pitch,
    HybridAudioSettings settings,
  ) async {
    debugPrint('🇫🇷 Génération TTS français...');

    return await EdgeTtsService.synthesizeText(
      text,
      language: 'fr-FR',
      voice: settings.frenchVoice,
      rate: speed,
      pitch: pitch,
    );
  }

  /// Génère l'audio pour contenu multilingue
  static Future<Uint8List?> _generateMixedLanguageAudio(
    String text,
    double speed,
    double pitch,
    HybridAudioSettings settings,
  ) async {
    debugPrint('🌍 Génération TTS multilingue...');

    // Stratégie : détecter la langue dominante et utiliser la voix appropriée
    final languageRatio = ContentDetectorService.calculateLanguageRatio(text);

    if (languageRatio.arabic > languageRatio.french) {
      // Diacritiser la partie arabe si activé
      String processedText = text;
      if (settings.enableDiacritization) {
        debugPrint('🔤 Diacritisation contenu mixte (partie arabe)...');
        processedText =
            await FarasaDiacritizationService.diacritizeIfNeeded(text);
      }
      return await EdgeTtsService.synthesizeText(
        processedText,
        language: 'ar-SA',
        voice: settings.arabicVoice,
        rate: speed,
        pitch: pitch,
      );
    } else {
      return await _generateFrenchTtsAudio(text, speed, pitch, settings);
    }
  }

  /// Concatène l'audio de plusieurs versets
  static Future<Uint8List?> _concatenateVerseAudios(
    List<VerseReference> verses,
    HybridAudioSettings settings,
  ) async {
    // TODO: Implémenter la concaténation audio
    // Pour l'instant, retourner le premier verset
    if (verses.isNotEmpty) {
      return await QuranicAudioService.getVerseAudio(
        verses.first,
        provider: settings.quranicProvider,
        reciter: settings.preferredReciter,
      );
    }
    return null;
  }

  /// Obtient des informations sur le contenu analysé
  static Future<ContentAnalysis> analyzeContentDetails(String text) async {
    final contentType = await ContentDetectorService.analyzeContent(text);
    final verses = ContentDetectorService.extractVerseReferences(text);
    final languageRatio = ContentDetectorService.calculateLanguageRatio(text);
    final cleanText = ContentDetectorService.cleanText(text);

    return ContentAnalysis(
      contentType: contentType,
      verses: verses,
      languageRatio: languageRatio,
      cleanText: cleanText,
      originalText: text,
    );
  }
}

/// Paramètres de configuration pour l'audio hybride
class HybridAudioSettings {
  final QuranicAudioProvider quranicProvider;
  final String preferredReciter;
  final EdgeTtsVoice arabicVoice;
  final EdgeTtsVoice frenchVoice;
  final bool useQuranicApiForDuas;
  final bool enableAudioCaching;
  final bool enableDiacritization;

  const HybridAudioSettings({
    this.quranicProvider = QuranicAudioProvider.alQuran,
    this.preferredReciter = 'ar.sudais',
    this.arabicVoice = EdgeTtsVoice.arabicHamed,
    this.frenchVoice = EdgeTtsVoice.frenchDenise,
    this.useQuranicApiForDuas = true,
    this.enableAudioCaching = true,
    this.enableDiacritization = true,
  });

  factory HybridAudioSettings.defaultSettings() {
    return const HybridAudioSettings();
  }

  factory HybridAudioSettings.highQuality() {
    return const HybridAudioSettings(
      quranicProvider: QuranicAudioProvider.alQuran,
      preferredReciter: 'ar.sudais',
      arabicVoice: EdgeTtsVoice.arabicZariyah,
      frenchVoice: EdgeTtsVoice.frenchHenri,
      enableDiacritization: true, // Activé par défaut pour haute qualité
    );
  }

  /// Paramètres optimisés pour performance (sans diacritisation)
  factory HybridAudioSettings.performance() {
    return const HybridAudioSettings(
      quranicProvider: QuranicAudioProvider.alQuran,
      preferredReciter: 'Alafasy_128kbps',
      arabicVoice: EdgeTtsVoice.arabicHamed,
      frenchVoice: EdgeTtsVoice.frenchDenise,
      enableDiacritization: false, // Désactivé pour performance
      enableAudioCaching: true,
    );
  }
}

/// Analyse détaillée du contenu
class ContentAnalysis {
  final ContentType contentType;
  final List<VerseReference> verses;
  final LanguageRatio languageRatio;
  final String cleanText;
  final String originalText;

  const ContentAnalysis({
    required this.contentType,
    required this.verses,
    required this.languageRatio,
    required this.cleanText,
    required this.originalText,
  });

  @override
  String toString() {
    return 'ContentAnalysis('
        'type: $contentType, '
        'verses: ${verses.length}, '
        'arabic: ${(languageRatio.arabic * 100).toStringAsFixed(1)}%, '
        'french: ${(languageRatio.french * 100).toStringAsFixed(1)}%'
        ')';
  }
}
