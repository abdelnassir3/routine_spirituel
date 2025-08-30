/// Export conditionnel pour l'adaptateur Haptic
/// - Mobile (iOS/Android) : utilise le HapticService existant
/// - Web : utilise un stub no-op pour éviter les erreurs
export 'haptic_mobile.dart' if (dart.library.html) 'haptic_web.dart';
