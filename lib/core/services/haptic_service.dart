import 'package:flutter/foundation.dart';
import 'haptic_service_interface.dart';
// Imports conditionnels avec factory functions
import 'haptic_service_io.dart' if (dart.library.html) 'haptic_service_web.dart' as platform;

/// Service de retour haptique unifié pour toutes les plateformes
/// 
/// Architecture :
/// - Mobile/Desktop : Utilise haptic_service_io.dart avec packages natifs
/// - Web : Utilise haptic_service_web.dart avec stubs (pas de vibration)
/// 
/// Fournit des vibrations et retours tactiles contextuels pour :
/// - Actions de prière (début, fin, milestones)
/// - Interactions UI (boutons, swipes)
/// - Notifications et alertes
/// - Feedback de progression
class HapticService implements HapticServiceInterface {
  static HapticService? _instance;
  static HapticServiceInterface? _platformService;

  // Singleton
  static HapticService get instance {
    _instance ??= HapticService._();
    return _instance!;
  }

  HapticService._() {
    _initializePlatformService();
  }

  void _initializePlatformService() {
    try {
      _platformService = _createPlatformService();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ HapticService: Erreur initialisation plateforme: $e');
      }
      // Fallback silencieux
    }
  }

  /// Factory method compilé conditionnellement
  HapticServiceInterface _createPlatformService() {
    return platform.createHapticService();
  }

  // ===== Configuration =====

  @override
  bool get isEnabled => _platformService?.isEnabled ?? false;

  @override
  HapticIntensity get intensity => _platformService?.intensity ?? HapticIntensity.medium;

  @override
  bool get canVibrate => _platformService?.canVibrate ?? false;

  @override
  Future<void> setEnabled(bool enabled) async {
    await _platformService?.setEnabled(enabled);
  }

  @override
  Future<void> setIntensity(HapticIntensity intensity) async {
    await _platformService?.setIntensity(intensity);
  }

  // ===== Méthodes de prière =====

  @override
  Future<void> prayerStart() async {
    await _platformService?.prayerStart();
  }

  @override
  Future<void> prayerComplete() async {
    await _platformService?.prayerComplete();
  }

  @override
  Future<void> counterTick() async {
    await _platformService?.counterTick();
  }

  @override
  Future<void> milestone(int count) async {
    await _platformService?.milestone(count);
  }

  // ===== Méthodes UI =====

  @override
  Future<void> lightImpact() async {
    await _platformService?.lightImpact();
  }

  @override
  Future<void> mediumImpact() async {
    await _platformService?.mediumImpact();
  }

  @override
  Future<void> heavyImpact() async {
    await _platformService?.heavyImpact();
  }

  @override
  Future<void> selectionClick() async {
    await _platformService?.selectionClick();
  }

  // ===== Méthodes additionnelles pour compatibilité =====

  Future<void> lightTap() async {
    await lightImpact();
  }

  Future<void> selection() async {
    await selectionClick();
  }

  Future<void> impact() async {
    await mediumImpact();
  }

  Future<void> success() async {
    await prayerComplete();
  }

  Future<void> error() async {
    await heavyImpact();
  }

  // ===== Méthodes gestures =====

  @override
  Future<void> swipeGesture() async {
    await _platformService?.swipeGesture();
  }

  @override
  Future<void> longPress() async {
    await _platformService?.longPress();
  }

  @override
  Future<void> notification() async {
    await _platformService?.notification();
  }

  @override
  Future<void> customVibration(int milliseconds) async {
    await _platformService?.customVibration(milliseconds);
  }

  // ===== Test et nettoyage =====

  @override
  Future<void> testHaptic() async {
    await _platformService?.testHaptic();
  }

  @override
  void dispose() {
    _platformService?.dispose();
  }
}
