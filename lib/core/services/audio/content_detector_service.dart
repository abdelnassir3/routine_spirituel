import 'dart:async';
import '../quran_content_detector.dart';

/// Types de contenu pour le routage audio
enum ContentType {
  quranicVerse,     // Verset coranique → APIs Quran
  islamicDua,       // Invocation islamique → APIs Quran  
  arabicText,       // Texte arabe non-coranique → Edge-TTS
  frenchText,       // Texte français → Edge-TTS
  mixedLanguage     // Contenu mixte → Edge-TTS
}

/// Service intelligent pour détecter le type de contenu audio
class ContentDetectorService {

  /// Analyse le contenu et détermine le type approprié
  static Future<ContentType> analyzeContent(String text) async {
    final cleanText = text.trim();
    
    // 1. Détection des marqueurs de versets {{V:sourate:verset}}
    if (_hasVerseMarkers(cleanText)) {
      return ContentType.quranicVerse;
    }
    
    // 2. **NOUVEAU**: Détection coranique avancée avec QuranContentDetector
    try {
      final detection = await QuranContentDetector.detectQuranContent(cleanText);
      if (detection.isQuranic && detection.confidence > 0.8) {
        return ContentType.quranicVerse;
      }
    } catch (e) {
      // Si la détection échoue, continuer avec les autres méthodes
      print('⚠️ Erreur détection coranique: $e');
    }
    
    // 3. Détection des invocations islamiques par mots-clés
    if (_isIslamicDua(cleanText)) {
      return ContentType.islamicDua;
    }
    
    // 4. Détection de langue basée sur les caractères
    final languageRatio = _calculateLanguageRatio(cleanText);
    
    if (languageRatio.arabic > 0.8) {
      return ContentType.arabicText;
    } else if (languageRatio.french > 0.8) {
      return ContentType.frenchText;
    } else {
      return ContentType.mixedLanguage;
    }
  }
  
  /// Extrait les références de versets du texte
  static List<VerseReference> extractVerseReferences(String text) {
    final references = <VerseReference>[];
    final regex = RegExp(r'\{\{V:(\d+):(\d+)\}\}');
    
    for (final match in regex.allMatches(text)) {
      final surah = int.parse(match.group(1)!);
      final verse = int.parse(match.group(2)!);
      references.add(VerseReference(surah: surah, verse: verse));
    }
    
    return references;
  }
  
  /// Nettoie le texte des marqueurs pour l'affichage
  static String cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\{\{V:\d+:\d+\}\}'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
  
  /// Calcule le ratio de langues dans le texte (méthode publique)
  static LanguageRatio calculateLanguageRatio(String text) {
    return _calculateLanguageRatio(text);
  }
  
  // Méthodes privées de détection
  static bool _hasVerseMarkers(String text) {
    return RegExp(r'\{\{V:\d+:\d+\}\}').hasMatch(text);
  }
  
  static bool _isIslamicDua(String text) {
    final islamicKeywords = [
      'بسم الله', 'الحمد لله', 'سبحان الله', 'الله أكبر', 'لا إله إلا الله',
      'أستغفر الله', 'حسبنا الله', 'ما شاء الله', 'بارك الله',
      'اللهم صل', 'رب اغفر', 'ربنا آتنا', 'اللهم اهدنا'
    ];
    
    return islamicKeywords.any((keyword) => text.contains(keyword));
  }
  
  static LanguageRatio _calculateLanguageRatio(String text) {
    int arabicChars = 0;
    int frenchChars = 0;
    int totalChars = 0;
    
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (RegExp(r'[a-zA-ZÀ-ÿ]').hasMatch(char)) {
        frenchChars++;
        totalChars++;
      } else if (RegExp(r'[\u0600-\u06FF\u0750-\u077F]').hasMatch(char)) {
        arabicChars++;
        totalChars++;
      }
    }
    
    if (totalChars == 0) return LanguageRatio(arabic: 0.0, french: 0.0);
    
    return LanguageRatio(
      arabic: arabicChars / totalChars,
      french: frenchChars / totalChars,
    );
  }
}

/// Référence de verset coranique
class VerseReference {
  final int surah;
  final int verse;
  
  const VerseReference({required this.surah, required this.verse});
  
  @override
  String toString() => 'Sourate $surah, Verset $verse';
}

/// Ratio de langues dans le texte
class LanguageRatio {
  final double arabic;
  final double french;
  
  const LanguageRatio({required this.arabic, required this.french});
}