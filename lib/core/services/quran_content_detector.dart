import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

/// Service pour détecter si un texte est un verset coranique
/// Compare le texte avec le corpus Coran local
class QuranContentDetector {
  static Map<String, QuranVerse>? _quranIndex;
  static bool _isInitialized = false;

  /// Initialise l'index du Coran depuis les assets
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Charger le corpus Coran complet depuis les assets
      final String jsonString =
          await rootBundle.loadString('assets/corpus/quran_full.json');
      final List<dynamic> quranData = jsonDecode(jsonString);

      _quranIndex = {};

      for (final verse in quranData) {
        if (verse is Map<String, dynamic>) {
          final quranVerse = QuranVerse(
            surah: (verse['surah'] as int?) ?? 0,
            ayah: (verse['ayah'] as int?) ?? 0,
            textAr: (verse['textAr'] as String?) ?? '',
            textFr: (verse['textFr'] as String?) ?? '',
          );

          // Indexer par le texte arabe nettoyé
          final cleanArabicText = _cleanArabicText(quranVerse.textAr);
          if (cleanArabicText.isNotEmpty) {
            _quranIndex![cleanArabicText] = quranVerse;
          }
        }
      }

      _isInitialized = true;
      print(
          '✅ QuranContentDetector initialisé avec ${_quranIndex!.length} versets');

      if (_quranIndex!.length < 6000) {
        print(
            '⚠️ ATTENTION: Nombre de versets insuffisant (attendu: 6236, reçu: ${_quranIndex!.length})');
      } else {
        print(
            '📖 Corpus Coran complet chargé (${_quranIndex!.length}/6236 versets)');
      }
    } catch (e) {
      print('❌ Erreur initialisation QuranContentDetector: $e');
      print(
          '💡 Vérification: assets/corpus/quran_full.json existe et est accessible');
      _quranIndex = {};
      _isInitialized = true;
    }
  }

  /// Alias pour detectQuranContent - méthode attendue par les tests
  static Future<QuranDetectionResult> detectContent(String text) async {
    return detectQuranContent(text);
  }

  /// Détecte si un texte est un verset coranique
  static Future<QuranDetectionResult> detectQuranContent(String text) async {
    await initialize();

    if (_quranIndex == null || text.trim().isEmpty) {
      return QuranDetectionResult(
        isQuranic: false,
        confidence: 0.0,
      );
    }

    final cleanedText = _cleanArabicText(text);

    // 1. Recherche exacte
    if (_quranIndex!.containsKey(cleanedText)) {
      final verse = _quranIndex![cleanedText]!;
      return QuranDetectionResult(
        isQuranic: true,
        confidence: 1.0,
        verse: verse,
        matchType: MatchType.exact,
      );
    }

    // 2. Recherche de correspondance partielle (pour les textes tronqués ou modifiés)
    final partialMatches = <QuranVerse>[];
    double bestConfidence = 0.0;
    QuranVerse? bestMatch;

    for (final entry in _quranIndex!.entries) {
      final similarity = _calculateTextSimilarity(cleanedText, entry.key);

      if (similarity > 0.85) {
        // Seuil de confiance élevé
        partialMatches.add(entry.value);
        if (similarity > bestConfidence) {
          bestConfidence = similarity;
          bestMatch = entry.value;
        }
      }
    }

    if (bestMatch != null && bestConfidence > 0.85) {
      return QuranDetectionResult(
        isQuranic: true,
        confidence: bestConfidence,
        verse: bestMatch,
        matchType: MatchType.partial,
        partialMatches: partialMatches,
      );
    }

    // 3. Vérifier si le texte contient des motifs coraniques typiques
    final linguisticConfidence = _analyzeArabicLinguisticFeatures(text);

    return QuranDetectionResult(
      isQuranic: linguisticConfidence > 0.7,
      confidence: linguisticConfidence,
      matchType: MatchType.linguistic,
    );
  }

  /// Nettoie le texte arabe pour la comparaison
  static String _cleanArabicText(String text) {
    return text
        // Supprimer les diacritiques arabes
        .replaceAll(RegExp(r'[\u064B-\u0652\u0670\u0640]'), '')
        // Supprimer les espaces multiples et trim
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        // Supprimer les marqueurs de versets s'ils existent
        .replaceAll(RegExp(r'\{\{V:\d+(?::\d+)?\}\}'), '')
        .trim();
  }

  /// Calcule la similarité entre deux textes arabes
  static double _calculateTextSimilarity(String text1, String text2) {
    if (text1 == text2) return 1.0;
    if (text1.isEmpty || text2.isEmpty) return 0.0;

    // Algorithme de distance de Levenshtein normalisée
    final words1 = text1.split(' ').where((w) => w.isNotEmpty).toList();
    final words2 = text2.split(' ').where((w) => w.isNotEmpty).toList();

    if (words1.isEmpty || words2.isEmpty) return 0.0;

    // Calculer le pourcentage de mots communs
    int commonWords = 0;
    for (final word1 in words1) {
      if (words2.contains(word1)) {
        commonWords++;
      }
    }

    final similarity1 = commonWords / words1.length;
    final similarity2 = commonWords / words2.length;

    // Retourner la moyenne des deux similarités
    return (similarity1 + similarity2) / 2;
  }

  /// Analyse les caractéristiques linguistiques arabes pour détecter un style coranique
  static double _analyzeArabicLinguisticFeatures(String text) {
    if (text.trim().isEmpty) return 0.0;

    double confidence = 0.0;

    // Motifs coraniques typiques
    final quranKeywords = [
      'اللَّهِ', 'الله', // Allah
      'الرَّحْمَٰنِ', 'الرحمن', // Rahman
      'الرَّحِيمِ', 'الرحيم', // Rahim
      'بِسْمِ', 'باسم', // Bismillah
      'يَا أَيُّهَا', 'يأيها', // Ya ayyuha
      'وَالَّذِينَ', 'والذين', // Wa alladhina
      'إِنَّ', 'إن', // Inna
      'قَالَ', 'قال', // Qala
    ];

    final arabicWords = text.split(' ').where((w) => w.isNotEmpty).toList();
    int keywordMatches = 0;

    for (final word in arabicWords) {
      final cleanWord = _cleanArabicText(word);
      for (final keyword in quranKeywords) {
        if (cleanWord.contains(_cleanArabicText(keyword))) {
          keywordMatches++;
          break;
        }
      }
    }

    if (arabicWords.isNotEmpty) {
      confidence += (keywordMatches / arabicWords.length) * 0.5;
    }

    // Structure des phrases coraniques
    if (text.contains('بِسْمِ اللَّهِ') || text.contains('باسم الله')) {
      confidence += 0.3; // Basmala
    }

    if (text.contains('يَا أَيُّهَا') || text.contains('يأيها')) {
      confidence += 0.2; // Appel typique du Coran
    }

    return confidence.clamp(0.0, 1.0);
  }

  /// Récupère les informations d'un verset par sourate et ayah
  static Future<QuranVerse?> getVerseInfo(int surah, int ayah) async {
    await initialize();

    if (_quranIndex != null) {
      for (final verse in _quranIndex!.values) {
        if (verse.surah == surah && verse.ayah == ayah) {
          return verse;
        }
      }
    }

    return null;
  }

  /// Recherche des versets par texte partiel
  static Future<List<QuranVerse>> searchVerses(String partialText) async {
    await initialize();

    if (_quranIndex == null || partialText.trim().isEmpty) {
      return [];
    }

    final results = <QuranVerse>[];
    final cleanedSearch = _cleanArabicText(partialText);

    for (final entry in _quranIndex!.entries) {
      if (entry.key.contains(cleanedSearch) ||
          _calculateTextSimilarity(cleanedSearch, entry.key) > 0.7) {
        results.add(entry.value);
      }
    }

    return results;
  }
}

/// Résultat de la détection de contenu coranique
class QuranDetectionResult {
  final bool isQuranic;
  final double confidence;
  final QuranVerse? verse;
  final MatchType matchType;
  final List<QuranVerse>? partialMatches;

  /// Alias pour isQuranic - compatibilité tests
  bool get isQuranVerse => isQuranic;

  QuranDetectionResult({
    required this.isQuranic,
    required this.confidence,
    this.verse,
    this.matchType = MatchType.none,
    this.partialMatches,
  });

  @override
  String toString() {
    return 'QuranDetectionResult(isQuranic: $isQuranic, confidence: $confidence, '
        'matchType: $matchType, verse: ${verse?.toString()})';
  }
}

/// Types de correspondance
enum MatchType {
  none, // Aucune correspondance
  exact, // Correspondance exacte
  partial, // Correspondance partielle
  linguistic // Basé sur l'analyse linguistique
}

/// Modèle pour un verset du Coran
class QuranVerse {
  final int surah;
  final int ayah;
  final String textAr;
  final String textFr;

  QuranVerse({
    required this.surah,
    required this.ayah,
    required this.textAr,
    required this.textFr,
  });

  @override
  String toString() {
    return 'QuranVerse(surah: $surah, ayah: $ayah, textAr: "${textAr.substring(0, textAr.length > 30 ? 30 : textAr.length)}...")';
  }

  /// Identifiant unique du verset
  String get verseId => '$surah:$ayah';

  /// Texte complet avec référence
  String get fullReference => 'Sourate $surah, Verset $ayah';
}

/// Provider Riverpod pour QuranContentDetector
final quranContentDetectorProvider = Provider<QuranContentDetector>((ref) {
  return QuranContentDetector();
});
