import 'package:flutter/foundation.dart';
import 'package:spiritual_routines/core/models/task_category.dart';

@immutable
class RoutineSuggestion {
  final String title;
  final String reason;
  const RoutineSuggestion({required this.title, required this.reason});
}

@immutable
class GeneratedContent {
  final String text;
  final String language; // fr|ar
  const GeneratedContent(this.text, {required this.language});
}

@immutable
class Translation {
  final String text;
  const Translation(this.text);
}

@immutable
class Transliteration {
  final String text;
  const Transliteration(this.text);
}

@immutable
class UsageInsights {
  final String summary;
  const UsageInsights(this.summary);
}

@immutable
class OptimizationTips {
  final String summary;
  const OptimizationTips(this.summary);
}

abstract class AIService {
  Future<List<RoutineSuggestion>> suggestRoutines(Map<String, Object?> profile);
  Future<GeneratedContent> generateContent({
    required String theme,
    required TaskCategory category,
    String language = 'fr',
  });
  Future<Translation> translateContent(String text, String target);
  Future<Transliteration> transliterate(String arabicText);
  Future<UsageInsights> analyzeUserPattern();
  Future<OptimizationTips> suggestOptimizations();
}
