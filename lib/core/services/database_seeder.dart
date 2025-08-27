import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/data/seed_data.dart';
import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';
import 'package:spiritual_routines/core/persistence/isar_collections.dart';
import 'package:spiritual_routines/core/services/content_service.dart';
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
    
    print('🌱 Initialisation de la base de données avec les données de base...');
    
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
        for (int routineIndex = 0; routineIndex < routines.length; routineIndex++) {
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
              category: drift.Value(taskData['category'].toString().split('.').last),
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
      
      await markAsSeeded();
      print('✅ Base de données initialisée avec succès !');
      print('📊 ${SeedData.themes.length} thèmes créés');
      print('📿 ${SeedData.themes.fold(0, (sum, t) => sum + (t['routines'] as List).length)} routines créées');
      print('📖 ${SeedData.standaloneInvocations.length} invocations individuelles ajoutées');
      
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
  
  String _genId() => DateTime.now().microsecondsSinceEpoch.toString();
}

/// Provider pour le service de seed
final databaseSeederProvider = Provider((ref) => DatabaseSeeder(ref));