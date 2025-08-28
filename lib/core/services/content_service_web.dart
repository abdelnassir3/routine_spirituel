import 'package:flutter_riverpod/flutter_riverpod.dart';

// Service stub pour le web - utilise uniquement Drift
class ContentService {
  ContentService(this._ref);
  final Ref _ref;

  Future<dynamic> getByTaskAndLocale(String taskId, String locale) async {
    // Sur le web, retourner null ou utiliser Drift
    return null;
  }

  Future<String?> buildTextFromRefs(String refs, String locale) async {
    // Implémentation simplifiée pour le web
    return null;
  }

  Future<(String?, String?)> getBuiltTextsForTask(String taskId) async {
    return (null, null);
  }

  Future<void> putContent({
    required String taskId,
    required String locale,
    required String kind,
    String? title,
    String? body,
  }) async {
    // Stocker dans Drift au lieu d'Isar
  }

  Future<void> setSource({
    required String taskId,
    required String locale,
    required String source,
  }) async {
    // Stocker dans Drift
  }

  Future<void> updateRaw({
    required String taskId,
    required String locale,
    required String raw,
  }) async {
    // Stocker dans Drift
  }

  Future<void> updateCorrected({
    required String taskId,
    required String locale,
    required String corrected,
  }) async {
    // Stocker dans Drift
  }

  Future<void> updateDiacritized({
    required String taskId,
    required String locale,
    required String diacritized,
  }) async {
    // Stocker dans Drift
  }

  Future<void> validateAndFinalize({
    required String taskId,
    required String locale,
  }) async {
    // Valider dans Drift
  }

  Future<(String?, String?, String?)> getEditingBodies(
      String taskId, String locale) async {
    return (null, null, null);
  }

  Future<void> saveTaskContent(dynamic content) async {
    // Sauvegarder dans Drift
  }

  Future<void> saveContent(dynamic content) => saveTaskContent(content);
}

final contentServiceProvider =
    Provider<ContentService>((ref) => ContentService(ref));
