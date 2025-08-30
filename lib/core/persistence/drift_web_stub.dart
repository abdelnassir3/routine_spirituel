import 'package:drift/drift.dart';

/// Base de données stub améliorée pour le web avec stockage en mémoire
/// Implémente QueryExecutor sans utiliser sql.js
class WebStubExecutor extends QueryExecutor {
  // Stockage en mémoire pour chaque table (statique pour persister entre instances)
  static final Map<String, List<Map<String, dynamic>>> _tables = {
    'themes': [],
    'routines': [],
    'tasks': [],
    'sessions': [],
    'session_completions': [],
    'user_settings': [],
    'aya_verses': [],
  };
  
  // Compteur pour générer des IDs uniques - utilise un compteur simple pour éviter l'overflow DateTime
  static int _idCounter = 1000;
  
  static int _generateId() {
    return ++_idCounter;
  }
  
  // Helper pour parser le nom de la table depuis une requête SQL
  String? _extractTableName(String sql) {
    final upperSql = sql.toUpperCase().replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ');
    
    if (upperSql.contains('INSERT INTO')) {
      final match = RegExp(r'INSERT INTO\s+["`]?(\w+)["`]?', caseSensitive: false).firstMatch(sql);
      return match?.group(1)?.toLowerCase();
    } else if (upperSql.contains('SELECT')) {
      final match = RegExp(r'FROM\s+["`]?(\w+)["`]?', caseSensitive: false).firstMatch(sql);
      return match?.group(1)?.toLowerCase();
    } else if (upperSql.contains('UPDATE')) {
      final match = RegExp(r'UPDATE\s+["`]?(\w+)["`]?', caseSensitive: false).firstMatch(sql);
      return match?.group(1)?.toLowerCase();
    } else if (upperSql.contains('DELETE FROM')) {
      final match = RegExp(r'DELETE FROM\s+["`]?(\w+)["`]?', caseSensitive: false).firstMatch(sql);
      return match?.group(1)?.toLowerCase();
    }
    return null;
  }
  
  // Helper pour extraire les colonnes depuis une requête INSERT
  List<String> _extractInsertColumns(String sql) {
    // Pattern: INSERT INTO table (col1, col2, ...) VALUES
    final match = RegExp(r'INSERT INTO\s+\w+\s*\(([^)]+)\)', caseSensitive: false).firstMatch(sql);
    if (match != null) {
      final columnsStr = match.group(1)!;
      return columnsStr
          .split(',')
          .map((col) => col.trim().replaceAll(RegExp(r'["`]'), ''))
          .toList();
    }
    return [];
  }
  
  // Helper pour créer un Map depuis les valeurs avec colonnes
  Map<String, dynamic> _createRecordWithColumns(String tableName, List<String> columns, List<Object?> args) {
    final record = <String, dynamic>{};
    
    // Mapper les colonnes aux valeurs
    for (int i = 0; i < columns.length && i < args.length; i++) {
      record[columns[i]] = args[i];
    }
    
    // S'assurer qu'il y a un ID
    if (!record.containsKey('id') || record['id'] == null) {
      record['id'] = _generateId().toString();
    }
    
    // Ajouter les champs obligatoires selon la table
    if (tableName == 'sessions') {
      // Ajouter les champs requis pour la table sessions avec milliseconds
      record['started_at'] ??= DateTime.now().millisecondsSinceEpoch;
      record['ended_at'] ??= null;
      record['snapshot_ref'] ??= null;
    }
    
    // Ajouter les timestamps si non présents avec milliseconds
    record['created_at'] ??= DateTime.now().millisecondsSinceEpoch;
    record['updated_at'] ??= DateTime.now().millisecondsSinceEpoch;
    
    // Log pour déboguer
    print('📝 WebStub: Created record for $tableName: $record');
    
    return record;
  }
  
  @override
  TransactionExecutor beginTransaction() {
    return _WebStubTransaction(this);
  }
  
  @override
  QueryExecutor beginExclusive() {
    return this;
  }

  @override
  Future<bool> ensureOpen(QueryExecutorUser user) async {
    print('🔓 WebStub: Database opened');
    return true;
  }

  @override
  Future<void> runBatched(BatchedStatements statements) async {
    print('📦 WebStub: Running ${statements.statements.length} batched statements');
    for (final stmt in statements.statements) {
      await runCustom(stmt, []);
    }
  }

  @override
  Future<void> runCustom(String statement, [List<Object?>? args]) async {
    // Log la requête pour déboguer
    print('🔧 WebStub: Custom SQL: ${statement.substring(0, statement.length.clamp(0, 100))}...');
    
    // Traiter les CREATE TABLE et autres DDL
    if (statement.toUpperCase().contains('CREATE TABLE')) {
      // Ignorer silencieusement les CREATE TABLE
      return;
    }
    
    // Si c'est un PRAGMA ou autre commande système, ignorer
    if (statement.toUpperCase().startsWith('PRAGMA')) {
      return;
    }
  }

  @override
  Future<int> runDelete(String statement, List<Object?> args) async {
    print('🗑️ WebStub: DELETE query: $statement with args: $args');
    
    final tableName = _extractTableName(statement);
    if (tableName != null && _tables.containsKey(tableName)) {
      final beforeCount = _tables[tableName]!.length;
      
      // Si on a un WHERE id = ?, supprimer par ID
      if (statement.contains('WHERE') && statement.contains('id') && args.isNotEmpty) {
        final idToDelete = args[0]?.toString();
        _tables[tableName]!.removeWhere((row) => 
          row['id']?.toString() == idToDelete
        );
      }
      
      final deletedCount = beforeCount - _tables[tableName]!.length;
      print('🗑️ WebStub: Deleted $deletedCount records from $tableName');
      return deletedCount;
    }
    return 0;
  }

  @override
  Future<int> runInsert(String statement, List<Object?> args) async {
    print('➕ WebStub: INSERT query: $statement');
    print('➕ WebStub: INSERT args: $args');
    
    final tableName = _extractTableName(statement);
    if (tableName != null && _tables.containsKey(tableName)) {
      // Extraire les colonnes depuis la requête
      final columns = _extractInsertColumns(statement);
      
      Map<String, dynamic> record;
      if (columns.isNotEmpty) {
        // Utiliser les colonnes extraites
        record = _createRecordWithColumns(tableName, columns, args);
      } else {
        // Fallback sur l'ancienne méthode si pas de colonnes trouvées
        print('⚠️ WebStub: No columns found in INSERT, using positional mapping');
        record = _createRecordPositional(tableName, args);
      }
      
      _tables[tableName]!.add(record);
      print('✅ WebStub: Inserted into $tableName. Total records: ${_tables[tableName]!.length}');
      
      // Retourner l'ID comme int
      final id = record['id'];
      if (id is String) {
        return int.tryParse(id) ?? _generateId();
      }
      return id as int? ?? _generateId();
    }
    
    print('❌ WebStub: Table $tableName not found!');
    return _generateId();
  }
  
  // Méthode de fallback pour le mapping positionnel
  Map<String, dynamic> _createRecordPositional(String tableName, List<Object?> args) {
    final record = <String, dynamic>{};
    
    // Assigner un ID
    if (args.isNotEmpty && args[0] != null) {
      record['id'] = args[0];
    } else {
      record['id'] = _generateId().toString();
    }
    
    // Mapper selon la table (amélioré)
    if (tableName == 'routines') {
      if (args.length > 1) record['theme_id'] = args[1];
      if (args.length > 2) record['name_fr'] = args[2];
      if (args.length > 3) record['name_ar'] = args[3];
      if (args.length > 4) record['order_index'] = args[4];
      if (args.length > 5) record['is_active'] = args[5];
      if (args.length > 6) record['created_at'] = args[6];
      if (args.length > 7) record['updated_at'] = args[7];
      if (args.length > 8) record['metadata'] = args[8];
    } else if (tableName == 'tasks') {
      if (args.length > 1) record['routine_id'] = args[1];
      if (args.length > 2) record['type'] = args[2];
      if (args.length > 3) record['category'] = args[3];
      if (args.length > 4) record['default_reps'] = args[4];
      if (args.length > 5) record['content_id'] = args[5];
      if (args.length > 6) record['notes_fr'] = args[6];
      if (args.length > 7) record['notes_ar'] = args[7];
      if (args.length > 8) record['order_index'] = args[8];
      if (args.length > 9) record['audio_settings'] = args[9];
      if (args.length > 10) record['display_settings'] = args[10];
    } else if (tableName == 'themes') {
      if (args.length > 1) record['name_fr'] = args[1];
      if (args.length > 2) record['name_ar'] = args[2];
      if (args.length > 3) record['frequency'] = args[3];
      if (args.length > 4) record['created_at'] = args[4];
      if (args.length > 5) record['metadata'] = args[5];
    } else if (tableName == 'sessions') {
      if (args.length > 1) record['routine_id'] = args[1];
      if (args.length > 2) record['state'] = args[2];
      // Ajouter le timestamp started_at requis par le schéma Drift avec milliseconds
      record['started_at'] = DateTime.now().millisecondsSinceEpoch;
      // ended_at est nullable donc pas requis
      record['ended_at'] = null;
      // snapshot_ref est nullable donc pas requis  
      record['snapshot_ref'] = null;
    }
    
    // Timestamps par défaut avec milliseconds
    record['created_at'] ??= DateTime.now().millisecondsSinceEpoch;
    record['updated_at'] ??= DateTime.now().millisecondsSinceEpoch;
    
    return record;
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(String statement, List<Object?> args) async {
    print('🔍 WebStub: SELECT query: ${statement.substring(0, statement.length.clamp(0, 100))}...');
    print('🔍 WebStub: SELECT args: $args');
    
    final tableName = _extractTableName(statement);
    if (tableName != null && _tables.containsKey(tableName)) {
      var results = List<Map<String, Object?>>.from(_tables[tableName]!);
      
      // Filtrer par ID si WHERE id = ?
      if (statement.contains('WHERE') && statement.contains('"id" = ?')) {
        final searchId = args.isNotEmpty ? args[0]?.toString() : null;
        print('🔍 WebStub: Filtering by id = $searchId');
        results = results.where((row) {
          final rowId = row['id']?.toString();
          return rowId == searchId;
        }).toList();
      }
      // Alternative: WHERE id = ? sans guillemets
      else if (statement.contains('WHERE') && statement.contains('id = ?') && args.isNotEmpty) {
        final searchId = args[0]?.toString();
        print('🔍 WebStub: Filtering by id = $searchId');
        results = results.where((row) {
          final rowId = row['id']?.toString();
          return rowId == searchId;
        }).toList();
      }
      
      // Filtrer par routine_id si présent
      if (statement.contains('routine_id') && args.isNotEmpty) {
        // Trouver l'index de routine_id dans les arguments
        final routineId = args.firstWhere((arg) => arg != null, orElse: () => null);
        if (routineId != null) {
          print('🔍 WebStub: Filtering by routine_id = $routineId');
          results = results.where((row) => 
            row['routine_id']?.toString() == routineId.toString()
          ).toList();
        }
      }
      
      print('📊 WebStub: Found ${results.length} records in $tableName');
      return results;
    }
    
    print('❌ WebStub: Table $tableName not found!');
    return [];
  }

  @override
  Future<int> runUpdate(String statement, List<Object?> args) async {
    print('🔄 WebStub: UPDATE query: $statement with args: $args');
    
    final tableName = _extractTableName(statement);
    if (tableName != null && _tables.containsKey(tableName)) {
      var updateCount = 0;
      
      // Parser SET clause pour extraire les champs à mettre à jour
      final setMatch = RegExp(r'SET\s+(.+?)\s+WHERE', caseSensitive: false).firstMatch(statement);
      if (setMatch != null) {
        final setClause = setMatch.group(1)!;
        final updates = <String, Object?>{};
        
        // Parser les champs (simple parsing)
        final fields = setClause.split(',');
        for (int i = 0; i < fields.length && i < args.length - 1; i++) {
          final field = fields[i].trim().replaceAll(RegExp(r'["`]|\s*=\s*\?'), '');
          updates[field] = args[i];
        }
        
        // L'ID est le dernier argument
        final id = args.isNotEmpty ? args.last : null;
        
        // Mettre à jour les enregistrements
        for (var row in _tables[tableName]!) {
          if (row['id']?.toString() == id?.toString()) {
            // Appliquer les mises à jour
            updates.forEach((key, value) {
              row[key] = value;
            });
            row['updated_at'] = DateTime.now().millisecondsSinceEpoch;
            updateCount++;
            print('✅ WebStub: Updated record $id in $tableName');
          }
        }
      }
      
      return updateCount;
    }
    return 0;
  }

  @override
  Future<void> close() async {
    print('🔒 WebStub: Database closed (data preserved in memory)');
    // Ne pas effacer les tables car elles sont statiques et partagées
  }

  @override
  SqlDialect get dialect => SqlDialect.sqlite;
  
  // Méthode utilitaire pour déboguer l'état des tables
  static void debugPrintTables() {
    print('📊 === WebStub Database State ===');
    _tables.forEach((tableName, records) {
      print('Table $tableName: ${records.length} records');
      for (var record in records) {
        print('  - ${record['id']}: ${record}');
      }
    });
    print('================================');
  }
}

class _WebStubTransaction extends QueryExecutor implements TransactionExecutor {
  final WebStubExecutor _parent;

  _WebStubTransaction(this._parent);

  @override
  TransactionExecutor beginTransaction() => this;
  
  @override
  QueryExecutor beginExclusive() => this;
  
  @override
  bool get supportsNestedTransactions => false;

  @override
  Future<bool> ensureOpen(QueryExecutorUser user) => _parent.ensureOpen(user);

  @override
  Future<void> runBatched(BatchedStatements statements) => _parent.runBatched(statements);

  @override
  Future<void> runCustom(String statement, [List<Object?>? args]) => 
      _parent.runCustom(statement, args);

  @override
  Future<int> runDelete(String statement, List<Object?> args) => 
      _parent.runDelete(statement, args);

  @override
  Future<int> runInsert(String statement, List<Object?> args) => 
      _parent.runInsert(statement, args);

  @override
  Future<List<Map<String, Object?>>> runSelect(String statement, List<Object?> args) => 
      _parent.runSelect(statement, args);

  @override
  Future<int> runUpdate(String statement, List<Object?> args) => 
      _parent.runUpdate(statement, args);

  @override
  Future<void> close() async {}

  @override
  SqlDialect get dialect => _parent.dialect;

  @override
  Future<void> rollback() async {
    print('⏪ WebStub: Transaction rollback (no-op in stub)');
  }

  @override
  Future<void> send() async {
    print('✉️ WebStub: Transaction commit (no-op in stub)');
  }
}

/// Ouvre une connexion avec le stub web
LazyDatabase openStubConnection() {
  return LazyDatabase(() async {
    print('🚀 WebStub: Opening database connection');
    return DatabaseConnection(WebStubExecutor());
  });
}