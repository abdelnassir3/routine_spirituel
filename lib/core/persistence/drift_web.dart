import 'package:drift/drift.dart';
import 'drift_web_stub.dart';

/// Ouvre une connexion Drift pour le web
/// Utilise un stub pour éviter complètement sql.js
LazyDatabase openConnection() {
  // Utiliser notre stub qui ne dépend pas de sql.js
  return openStubConnection();
}
