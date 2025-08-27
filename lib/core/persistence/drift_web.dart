import 'package:drift/drift.dart';
import 'package:drift/web.dart';

/// Ouvre une connexion Drift pour le web
LazyDatabase openConnection() {
  return LazyDatabase(() async {
    // Utilise une base de données IndexedDB pour le web
    return WebDatabase('spiritual_routines_db');
  });
}