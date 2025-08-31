import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';
import 'package:drift/drift.dart' show Value;

/// Initialiseur Web pour pré-remplir les tables essentielles
/// Garantit que les données critiques existent pour éviter les erreurs null
class WebInitializer {
  static bool _initialized = false;
  
  /// Initialise les données essentielles pour le Web
  static Future<void> initialize(WidgetRef ref) async {
    // Éviter les initialisations multiples
    if (_initialized) return;
    
    try {
      print('🚀 WebInitializer: Starting initialization...');
      
      // 1. Initialiser les UserSettings par défaut
      await _initializeUserSettings(ref);
      
      // 2. Créer un thème par défaut si nécessaire
      await _initializeDefaultTheme(ref);
      
      // 3. Créer une routine par défaut si nécessaire
      await _initializeDefaultRoutine(ref);
      
      _initialized = true;
      print('✅ WebInitializer: Initialization complete');
    } catch (e) {
      print('❌ WebInitializer: Error during initialization: $e');
      // Ne pas bloquer l'application même si l'initialisation échoue
    }
  }
  
  /// Initialise les UserSettings avec des valeurs par défaut
  static Future<void> _initializeUserSettings(WidgetRef ref) async {
    try {
      final dao = ref.read(userSettingsDaoProvider);
      
      // Vérifier si les settings existent déjà
      try {
        final existing = await dao.getById('local');
        if (existing != null) {
          print('✓ UserSettings already exist');
          return;
        }
      } catch (e) {
        print('⚠️ Error checking UserSettings: $e');
      }
      
      // Créer les settings par défaut
      await dao.upsert(UserSettingsCompanion.insert(
        id: 'local',
      ));
      
      print('✓ UserSettings initialized with defaults');
    } catch (e) {
      print('❌ Failed to initialize UserSettings: $e');
    }
  }
  
  /// Crée un thème par défaut
  static Future<void> _initializeDefaultTheme(WidgetRef ref) async {
    try {
      final dao = ref.read(themeDaoProvider);
      
      // Vérifier si des thèmes existent
      try {
        final themes = await dao.watchAll().first;
        if (themes.isNotEmpty) {
          print('✓ Themes already exist: ${themes.length}');
          return;
        }
      } catch (e) {
        print('⚠️ Error checking themes: $e');
      }
      
      // Créer un thème par défaut
      await dao.upsertTheme(ThemesCompanion.insert(
        id: 'default-theme',
        nameFr: 'Lecture spirituelle',
        nameAr: 'القراءة الروحية',
        frequency: 'daily',
      ));
      
      print('✓ Default theme created');
    } catch (e) {
      print('❌ Failed to create default theme: $e');
    }
  }
  
  /// Crée une routine par défaut
  static Future<void> _initializeDefaultRoutine(WidgetRef ref) async {
    try {
      final routineDao = ref.read(routineDaoProvider);
      final taskDao = ref.read(taskDaoProvider);
      
      // Vérifier si des routines existent
      try {
        final routines = await routineDao.watchAll().first;
        if (routines.isNotEmpty) {
          print('✓ Routines already exist: ${routines.length}');
          return;
        }
      } catch (e) {
        print('⚠️ Error checking routines: $e');
      }
      
      // S'assurer qu'un thème existe
      final themes = await ref.read(themeDaoProvider).watchAll().first;
      final themeId = themes.isNotEmpty ? themes.first.id : 'default-theme';
      
      // Créer une routine par défaut
      final routineId = 'default-routine';
      await routineDao.upsertRoutine(RoutinesCompanion.insert(
        id: routineId,
        themeId: themeId,
        nameFr: 'Ma routine quotidienne',
        nameAr: 'روتيني اليومي',
      ));
      
      // Créer une tâche exemple avec Value pour les champs optionnels
      await taskDao.upsertTask(TasksCompanion(
        id: Value('default-task'),
        routineId: Value(routineId),
        type: const Value('text'),
        category: const Value('dhikr'),
        defaultReps: const Value(33),
        notesFr: const Value('Subhan Allah'),
        notesAr: const Value('سبحان الله'),
        orderIndex: const Value(0),
      ));
      
      print('✓ Default routine and task created');
    } catch (e) {
      print('❌ Failed to create default routine: $e');
    }
  }
  
  /// Réinitialise l'état (utile pour les tests)
  static void reset() {
    _initialized = false;
  }
}