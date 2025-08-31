import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';

/// Service pour réinitialiser complètement la base de données
class DatabaseResetService {
  final Ref _ref;

  const DatabaseResetService(this._ref);

  /// Réinitialise complètement toutes les données de l'application
  Future<ResetResult> resetAll() async {
    try {
      if (kDebugMode) {
        print('🔄 Début de la réinitialisation de la base de données...');
      }

      int deletedItems = 0;

      // 1. Supprimer tous les snapshots
      final snapshotDao = _ref.read(snapshotDaoProvider);
      // Les snapshots n'ont pas de méthode deleteAll, on va les supprimer via la base
      final db = _ref.read(appDatabaseProvider);
      final snapshotsDeleted = await (db.delete(db.snapshots)).go();
      deletedItems += snapshotsDeleted;
      if (kDebugMode) print('✅ $snapshotsDeleted snapshots supprimés');

      // 2. Supprimer tous les progrès de tâches
      final progressDao = _ref.read(progressDaoProvider);
      final progressDeleted = await (db.delete(db.taskProgress)).go();
      deletedItems += progressDeleted;
      if (kDebugMode) print('✅ $progressDeleted progrès de tâches supprimés');

      // 3. Supprimer toutes les sessions
      final sessionDao = _ref.read(sessionDaoProvider);
      final sessionsDeleted = await (db.delete(db.sessions)).go();
      deletedItems += sessionsDeleted;
      if (kDebugMode) print('✅ $sessionsDeleted sessions supprimées');

      // 4. Supprimer toutes les tâches
      final taskDao = _ref.read(taskDaoProvider);
      final tasksDeleted = await (db.delete(db.tasks)).go();
      deletedItems += tasksDeleted;
      if (kDebugMode) print('✅ $tasksDeleted tâches supprimées');

      // 5. Supprimer toutes les routines
      final routineDao = _ref.read(routineDaoProvider);
      final routinesDeleted = await (db.delete(db.routines)).go();
      deletedItems += routinesDeleted;
      if (kDebugMode) print('✅ $routinesDeleted routines supprimées');

      // 6. Supprimer tous les thèmes
      final themeDao = _ref.read(themeDaoProvider);
      final themesDeleted = await (db.delete(db.themes)).go();
      deletedItems += themesDeleted;
      if (kDebugMode) print('✅ $themesDeleted thèmes supprimés');

      // Note: On garde les UserSettings pour préserver les préférences utilisateur
      
      if (kDebugMode) {
        print('🎉 Réinitialisation terminée : $deletedItems éléments supprimés');
      }

      return ResetResult.success(deletedItems);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Erreur lors de la réinitialisation: $e');
        print('Stack trace: $stackTrace');
      }
      return ResetResult.error(e.toString());
    }
  }

  /// Réinitialise uniquement les routines (garde les sessions et préférences)
  Future<ResetResult> resetRoutinesOnly() async {
    try {
      if (kDebugMode) {
        print('🔄 Réinitialisation des routines uniquement...');
      }

      final db = _ref.read(appDatabaseProvider);
      int deletedItems = 0;

      // Supprimer les tâches d'abord (contrainte de clé étrangère)
      final tasksDeleted = await (db.delete(db.tasks)).go();
      deletedItems += tasksDeleted;

      // Puis les routines
      final routinesDeleted = await (db.delete(db.routines)).go();
      deletedItems += routinesDeleted;

      // Enfin les thèmes
      final themesDeleted = await (db.delete(db.themes)).go();
      deletedItems += themesDeleted;

      if (kDebugMode) {
        print('✅ Routines réinitialisées : $deletedItems éléments supprimés');
      }

      return ResetResult.success(deletedItems);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la réinitialisation des routines: $e');
      }
      return ResetResult.error(e.toString());
    }
  }

  /// Réinitialise uniquement les sessions (garde les routines)
  Future<ResetResult> resetSessionsOnly() async {
    try {
      if (kDebugMode) {
        print('🔄 Réinitialisation des sessions uniquement...');
      }

      final db = _ref.read(appDatabaseProvider);
      int deletedItems = 0;

      // Supprimer les snapshots d'abord
      final snapshotsDeleted = await (db.delete(db.snapshots)).go();
      deletedItems += snapshotsDeleted;

      // Puis les progrès de tâches
      final progressDeleted = await (db.delete(db.taskProgress)).go();
      deletedItems += progressDeleted;

      // Enfin les sessions
      final sessionsDeleted = await (db.delete(db.sessions)).go();
      deletedItems += sessionsDeleted;

      if (kDebugMode) {
        print('✅ Sessions réinitialisées : $deletedItems éléments supprimés');
      }

      return ResetResult.success(deletedItems);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la réinitialisation des sessions: $e');
      }
      return ResetResult.error(e.toString());
    }
  }
}

/// Résultat d'une opération de réinitialisation
class ResetResult {
  final bool success;
  final int? deletedCount;
  final String? errorMessage;

  const ResetResult._({
    required this.success,
    this.deletedCount,
    this.errorMessage,
  });

  factory ResetResult.success(int deletedCount) => ResetResult._(
        success: true,
        deletedCount: deletedCount,
      );

  factory ResetResult.error(String error) => ResetResult._(
        success: false,
        errorMessage: error,
      );
}

/// Provider pour le service de réinitialisation
final databaseResetServiceProvider = Provider<DatabaseResetService>((ref) {
  return DatabaseResetService(ref);
});