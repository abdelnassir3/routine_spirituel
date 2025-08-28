import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_settings_service.dart';

/// Service pour réinitialiser la vitesse TTS à une valeur normale
class TtsSpeedReset {
  static const double DEFAULT_SPEED = 0.9; // Vitesse normale

  /// Réinitialise la vitesse TTS si elle est trop lente
  static Future<void> ensureNormalSpeed(WidgetRef ref) async {
    final settings = ref.read(userSettingsServiceProvider);

    // Récupérer la vitesse actuelle
    final currentSpeed = await settings.getTtsSpeed();

    // Si la vitesse est inférieure à 0.8 (trop lente), la réinitialiser
    if (currentSpeed < 0.8) {
      print(
          '🔧 Réinitialisation de la vitesse TTS: $currentSpeed → $DEFAULT_SPEED');
      await settings.setTtsSpeed(DEFAULT_SPEED);
    } else {
      print('✅ Vitesse TTS correcte: $currentSpeed');
    }
  }

  /// Force la réinitialisation de la vitesse
  static Future<void> forceResetSpeed(WidgetRef ref) async {
    final settings = ref.read(userSettingsServiceProvider);
    print('🔧 Réinitialisation forcée de la vitesse TTS à $DEFAULT_SPEED');
    await settings.setTtsSpeed(DEFAULT_SPEED);
  }
}
