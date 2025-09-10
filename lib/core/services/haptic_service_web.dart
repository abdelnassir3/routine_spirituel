import 'package:flutter/foundation.dart';
import 'haptic_service_interface.dart';

/// Factory function pour créer le service Web
HapticServiceInterface createHapticService() => HapticServiceWeb.instance;

/// Implémentation stub du service haptique pour plateforme Web
/// Cette version ne fait aucune vibration mais évite les erreurs
/// Compatible avec tous les navigateurs Web
class HapticServiceWeb implements HapticServiceInterface {
  static HapticServiceWeb? _instance;

  // État simulé pour maintenir la cohérence de l'API
  bool _isEnabled = true;
  HapticIntensity _intensity = HapticIntensity.medium;

  // Singleton
  static HapticServiceWeb get instance {
    _instance ??= HapticServiceWeb._();
    return _instance!;
  }

  HapticServiceWeb._() {
    if (kDebugMode) {
      print('🌐 HapticServiceWeb: Stub initialisé pour plateforme Web');
    }
  }

  @override
  bool get isEnabled => _isEnabled;

  @override
  HapticIntensity get intensity => _intensity;

  @override
  bool get canVibrate => false; // Pas de vibration sur Web

  @override
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    if (kDebugMode) {
      print('🌐 HapticServiceWeb: Feedback haptique ${enabled ? 'activé' : 'désactivé'} (stub)');
    }
  }

  @override
  Future<void> setIntensity(HapticIntensity intensity) async {
    _intensity = intensity;
    if (kDebugMode) {
      print('🌐 HapticServiceWeb: Intensité haptique: ${intensity.name} (stub)');
    }
  }

  // ==================== MÉTHODES DE PRIÈRE ====================
  // Toutes les méthodes retournent immédiatement sans erreur

  @override
  Future<void> prayerStart() async {
    if (kDebugMode) {
      print('🌐 HapticServiceWeb: prayerStart (stub - no vibration)');
    }
  }

  @override
  Future<void> prayerComplete() async {
    if (kDebugMode) {
      print('🌐 HapticServiceWeb: prayerComplete (stub - no vibration)');
    }
  }

  @override
  Future<void> counterTick() async {
    // Pas de log pour éviter le spam - appelé fréquemment
  }

  @override
  Future<void> milestone(int count) async {
    if (kDebugMode) {
      print('🌐 HapticServiceWeb: milestone $count (stub - no vibration)');
    }
  }

  // ==================== MÉTHODES UI ====================

  @override
  Future<void> lightImpact() async {
    // Pas de log pour éviter le spam
  }

  @override
  Future<void> mediumImpact() async {
    // Pas de log pour éviter le spam
  }

  @override
  Future<void> heavyImpact() async {
    // Pas de log pour éviter le spam
  }

  @override
  Future<void> selectionClick() async {
    // Pas de log pour éviter le spam
  }

  // ==================== MÉTHODES GESTURES ====================

  @override
  Future<void> swipeGesture() async {
    // Pas de log pour éviter le spam
  }

  @override
  Future<void> longPress() async {
    // Pas de log pour éviter le spam
  }

  @override
  Future<void> notification() async {
    if (kDebugMode) {
      print('🌐 HapticServiceWeb: notification (stub - no vibration)');
    }
  }

  @override
  Future<void> testHaptic() async {
    if (kDebugMode) {
      print('🌐 HapticServiceWeb: Test haptique (stub - pas de vibration sur Web)');
    }
  }

  @override
  Future<void> customVibration(int milliseconds) async {
    if (kDebugMode) {
      print('🌐 HapticServiceWeb: customVibration ${milliseconds}ms (stub - no vibration)');
    }
  }

  @override
  void dispose() {
    _instance = null;
    if (kDebugMode) {
      print('🌐 HapticServiceWeb: Service libéré');
    }
  }
}