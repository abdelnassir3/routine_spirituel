import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/adapters/adapters.dart';

/// Provider exposant l'adaptateur haptique cross‑plateforme.
/// - Mobile (iOS/Android): implémentation réelle via HapticService.
/// - Web/Desktop: stub no‑op sécurisé (aucune vibration, pas d'erreur).
final hapticAdapterProvider = Provider<HapticAdapter>((ref) {
  return AdapterFactories.haptic;
});
