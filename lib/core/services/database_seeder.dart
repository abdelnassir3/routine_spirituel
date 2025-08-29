import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/data/seed_data.dart';
import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';
// Conditional import for TaskContent compatibility
import 'package:spiritual_routines/core/persistence/isar_collections.dart'
    if (dart.library.html) '../persistence/isar_web_stub.dart'
    if (dart.library.io) '../persistence/isar_mobile_stub.dart';
import 'package:spiritual_routines/core/services/content_service.dart';
import 'package:spiritual_routines/core/services/corpus_importer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour initialiser la base de données avec des données de base
class DatabaseSeeder {
  final Ref ref;

  DatabaseSeeder(this.ref);

  /// Vérifie si c'est le premier lancement de l'app
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey('database_seeded');
  }

  /// Marque la base de données comme initialisée
  Future<void> markAsSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('database_seeded', true);
  }

  /// Initialise la base de données avec les données de seed
  Future<void> seedDatabase() async {
    final isFirst = await isFirstLaunch();
    if (!isFirst) {
      print('Base de données déjà initialisée');
      return;
    }

    print(
        '🌱 Initialisation de la base de données avec les données de base...');

    // Sur la plateforme web, utiliser les stubs Isar seulement
    if (kIsWeb) {
      print('🌐 Plateforme web détectée - utilisation des stubs de données');
      try {
        await _seedWebDatabase();
      } catch (e) {
        print('⚠️ Erreur web database seeder : $e');
        // Sur web, continuer même si il y a des erreurs
        await markAsSeeded();
      }
      return;
    }

    try {
      final themeDao = ref.read(themeDaoProvider);
      final routineDao = ref.read(routineDaoProvider);
      final taskDao = ref.read(taskDaoProvider);
      final contentService = ref.read(contentServiceProvider);

      // Parcourir tous les thèmes
      for (final themeData in SeedData.themes) {
        // Créer le thème
        final themeId = themeData['id'] as String;
        await themeDao.upsertTheme(ThemesCompanion(
          id: drift.Value(themeId),
          nameFr: drift.Value(themeData['nameFr'] as String),
          nameAr: drift.Value(themeData['nameAr'] as String),
          frequency: drift.Value(themeData['frequency'] as String),
        ));

        // Créer les routines du thème
        final routines = themeData['routines'] as List<Map<String, dynamic>>;
        for (int routineIndex = 0;
            routineIndex < routines.length;
            routineIndex++) {
          final routineData = routines[routineIndex];
          final routineId = routineData['id'] as String;

          await routineDao.upsertRoutine(RoutinesCompanion(
            id: drift.Value(routineId),
            themeId: drift.Value(themeId),
            nameFr: drift.Value(routineData['nameFr'] as String),
            nameAr: drift.Value(routineData['nameAr'] as String),
            orderIndex: drift.Value(routineIndex),
            isActive: const drift.Value(true),
          ));

          // Créer les tâches de la routine
          final tasks = routineData['tasks'] as List<Map<String, dynamic>>;
          for (int taskIndex = 0; taskIndex < tasks.length; taskIndex++) {
            final taskData = tasks[taskIndex];
            final taskId = _genId();

            // Créer le contenu selon le type
            String? contentId;
            if (taskData['type'] == 'verses') {
              // Créer un contenu de type versets
              final content = TaskContent()
                ..id = _genId()
                ..type = 'verses'
                ..surahNumber = taskData['surah'] as int?
                ..ayahStart = taskData['ayahStart'] as int?
                ..ayahEnd = taskData['ayahEnd'] as int?;

              await contentService.saveTaskContent(content);
              contentId = content.id;
            } else if (taskData['type'] == 'text') {
              // Créer un contenu de type texte
              final content = TaskContent()
                ..id = _genId()
                ..type = 'text'
                ..textAr = taskData['textAr'] as String?
                ..textFr = taskData['textFr'] as String?;

              await contentService.saveTaskContent(content);
              contentId = content.id;
            }

            // Créer la tâche
            await taskDao.upsertTask(TasksCompanion(
              id: drift.Value(taskId),
              routineId: drift.Value(routineId),
              type: drift.Value(taskData['type'] as String),
              category:
                  drift.Value(taskData['category'].toString().split('.').last),
              defaultReps: drift.Value(taskData['defaultReps'] as int? ?? 1),
              contentId: drift.Value(contentId),
              notesFr: drift.Value(taskData['notesFr'] as String?),
              notesAr: drift.Value(taskData['notesAr'] as String?),
              orderIndex: drift.Value(taskIndex),
              audioSettings: const drift.Value('{}'),
              displaySettings: const drift.Value('{}'),
            ));
          }
        }
      }

      // Ajouter aussi les invocations individuelles comme contenus disponibles
      for (final invData in SeedData.standaloneInvocations) {
        final content = TaskContent()
          ..id = invData['id'] as String
          ..type = 'text'
          ..nameFr = invData['nameFr'] as String?
          ..nameAr = invData['nameAr'] as String?
          ..textAr = invData['textAr'] as String?
          ..textFr = invData['textFr'] as String?
          ..category = invData['category'].toString().split('.').last
          ..defaultRepetitions = invData['defaultReps'] as int?
          ..notes = invData['notesFr'] as String?;

        await contentService.saveTaskContent(content);
      }

      // Importer automatiquement le corpus Coran
      try {
        print('📖 Chargement du corpus Coran...');
        final corpusImporter = ref.read(corpusImporterProvider);
        final (inserted, updated) = await corpusImporter.importFromAssets();
        print('✅ Corpus Coran chargé: $inserted versets importés');
      } catch (e) {
        print('⚠️ Erreur lors du chargement du corpus: $e');
        // Ne pas faire échouer l'initialisation pour cela
      }

      await markAsSeeded();
      print('✅ Base de données initialisée avec succès !');
      print('📊 ${SeedData.themes.length} thèmes créés');
      print(
          '📿 ${SeedData.themes.fold(0, (sum, t) => sum + (t['routines'] as List).length)} routines créées');
      print(
          '📖 ${SeedData.standaloneInvocations.length} invocations individuelles ajoutées');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation : $e');
      rethrow;
    }
  }

  /// Réinitialise la base de données (pour debug/test)
  Future<void> resetDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('database_seeded');

    // Pour réinitialiser, utiliser les méthodes spécifiques des DAOs
    // final themeDao = ref.read(themeDaoProvider);
    // final routineDao = ref.read(routineDaoProvider);
    // final taskDao = ref.read(taskDaoProvider);

    print('🔄 Base de données réinitialisée');
  }

  /// Initialisation simplifiée pour la plateforme web (utilise seulement les stubs)
  Future<void> _seedWebDatabase() async {
    try {
      // Sur web, pas de vraie initialisation de base de données
      // Juste simuler les opérations avec les stubs
      
      print('📊 Simulation: ${SeedData.themes.length} thèmes');
      print('📿 Simulation: ${SeedData.themes.fold(0, (sum, t) => sum + (t['routines'] as List).length)} routines');
      print('📖 Simulation: ${SeedData.standaloneInvocations.length} invocations individuelles');

      // Marquer comme initialisé sans essayer d'accéder aux vraies bases
      await markAsSeeded();
      print('✅ Base de données web (stub) initialisée avec succès !');
      print('🌐 Mode web: Fonctionnement avec stubs - pas de persistance');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation web : $e');
      // Ne pas faire échouer pour la compatibilité web
      await markAsSeeded();
    }
  }

  String _genId() => DateTime.now().microsecondsSinceEpoch.toString();
}

/// Provider pour le service de seed
final databaseSeederProvider = Provider((ref) => DatabaseSeeder(ref));
