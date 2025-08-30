/// Export conditionnel pour l'adaptateur de stockage sécurisé
/// - Mobile (iOS/Android) : utilise flutter_secure_storage + SharedPreferences
/// - Web : utilise localStorage avec chiffrement basique
export 'storage_mobile.dart' if (dart.library.html) 'storage_web.dart';
