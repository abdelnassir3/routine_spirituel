/// Façade unifiée pour tous les adaptateurs multi-plateforme
/// Simplifie l'import et l'usage des adaptateurs dans l'application

// Adaptateurs principaux
export 'haptic_adapter.dart';
export 'tts_adapter.dart';
export 'storage_adapter.dart';

// Implémentations conditionnelles
export 'haptic.dart';
export 'tts.dart';
export 'storage.dart';
// Share
export 'share_adapter.dart';
export 'share.dart';

// Factories
export 'adapter_factories.dart';
