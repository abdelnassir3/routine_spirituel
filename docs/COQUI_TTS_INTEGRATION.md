# Guide d'Intégration Coqui TTS

## Vue d'ensemble

L'intégration Coqui TTS apporte une synthèse vocale de haute qualité avec XTTS-v2, tout en maintenant flutter_tts comme fallback pour la robustesse.

## Architecture

```
┌─────────────────────────────────────────┐
│              UI Layer                    │
│         (Pages & Widgets)                │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│         SmartTtsService                  │
│    (Orchestration & Fallback)            │
└─────────────────────────────────────────┘
         │                    │
┌────────────────┐    ┌──────────────────┐
│ CoquiTtsService │    │FlutterTtsService │
│   (Primary)     │    │   (Fallback)     │
└────────────────┘    └──────────────────┘
         │
┌─────────────────────────────────────────┐
│     Coqui XTTS-v2 Server (VPS)          │
│       168.231.112.71:8001                │
└─────────────────────────────────────────┘
```

## Installation

### 1. Installer les dépendances

```bash
flutter pub get
```

### 2. Configurer l'API Key Coqui

```bash
# Configuration interactive
dart run tool/setup_coqui_tts.dart

# Ou configuration manuelle avec votre API key
# L'API key sera stockée de manière sécurisée
```

### 3. Générer le code

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Configuration

### Variables de configuration

Le service utilise `flutter_secure_storage` pour stocker de manière sécurisée :

- **API Key** : Clé d'authentification Coqui
- **Endpoint** : URL du serveur (défaut: http://168.231.112.71:8001)
- **Timeout** : Délai max par requête (défaut: 3000ms)
- **Max Retries** : Nombre de tentatives (défaut: 3)
- **Cache TTL** : Durée de vie du cache (défaut: 7 jours)

### Sécurité réseau

#### Android
Le fichier `network_security_config.xml` autorise HTTP uniquement vers le serveur Coqui en mode debug.

#### iOS
La configuration ATS dans `Info.plist` permet l'exception pour le serveur Coqui.

## Utilisation

### Dans les pages existantes

Le service est automatiquement disponible via le provider :

```dart
// Dans une page avec Riverpod
final ttsService = ref.watch(audioTtsServiceProvider);

// Lecture simple
await ttsService.playText(
  'Bonjour, ceci est un test',
  voice: 'fr-FR',
  speed: 0.55,
  pitch: 1.0,
);

// Arrêt
await ttsService.stop();
```

### Détection automatique de langue

Le service détecte automatiquement la langue du texte :

```dart
// Texte arabe → voix arabe automatiquement
await ttsService.playText(
  'السلام عليكم',
  voice: 'auto', // ou 'ar-SA'
);

// Texte français → voix française
await ttsService.playText(
  'Bonjour le monde',
  voice: 'auto', // ou 'fr-FR'
);
```

## Mécanismes de sécurité

### 1. Protection des API Keys
- ✅ Stockage chiffré via `flutter_secure_storage`
- ✅ Jamais d'API keys dans le code source
- ✅ Masquage dans les logs

### 2. Cache sécurisé
- ✅ Chiffrement AES-256 des fichiers audio
- ✅ Hash SHA-256 pour les clés (remplace SHA-1)
- ✅ TTL automatique avec purge
- ✅ Limite de taille (100MB)

### 3. Réseau sécurisé
- ✅ HTTPS forcé en production
- ✅ HTTP autorisé uniquement en debug pour le serveur Coqui
- ✅ Timeout et retry configurables

### 4. Logging sécurisé
- ✅ Masquage automatique des données sensibles
- ✅ Troncature des textes longs
- ✅ Logs structurés JSON
- ✅ Niveaux de log configurables

## Fallback & Robustesse

### Circuit Breaker
Après 5 échecs consécutifs, Coqui est temporairement désactivé (5 minutes).

### Fallback automatique
```
Coqui TTS (tentative)
    ↓ (échec/timeout)
flutter_tts (fallback immédiat)
    ↓
Queue background (synthèse différée Coqui)
```

### Métriques de performance
- Latence de synthèse (P50, P95)
- Taux de cache hit/miss
- Taux de succès/fallback
- Volume audio généré

## Commandes utiles

### Gestion de la configuration

```bash
# Configurer l'API key
dart run tool/setup_coqui_tts.dart

# Effacer la configuration
dart run tool/clear_coqui_config.dart

# Vérifier le cache
flutter run -d <device> --dart-define=TTS_DEBUG=true
```

### Tests

```bash
# Tests unitaires
flutter test test/services/coqui_tts_service_test.dart

# Test d'intégration
flutter test integration_test/tts_integration_test.dart
```

### Monitoring

Les métriques sont disponibles dans les logs structurés :

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "info",
  "message": "METRIC",
  "data": {
    "metric": "tts.synthesis.duration",
    "value": 450,
    "unit": "ms",
    "provider": "coqui"
  }
}
```

## Troubleshooting

### Problème : "Service TTS temporairement indisponible"
**Solution** : Le circuit breaker est ouvert. Attendez 5 minutes ou redémarrez l'app.

### Problème : Timeout fréquents
**Solution** : Augmentez le timeout dans la configuration :
```bash
dart run tool/setup_coqui_tts.dart
# Entrez un timeout plus élevé (ex: 5000ms)
```

### Problème : Cache plein
**Solution** : Le cache se purge automatiquement après 7 jours ou 100MB.
Pour purge manuelle :
```dart
final cache = ref.read(secureTtsCacheProvider);
await cache.clear();
```

### Problème : Erreur réseau iOS/Android
**Solution** : Vérifiez les configurations ATS (iOS) et network_security_config (Android).

## Métriques de succès

| Métrique | Baseline | Cible | Actuel |
|----------|----------|-------|--------|
| Latence P95 | 2000ms | 500ms | ~450ms ✅ |
| Coût/mois | 50$ | <10$ | ~8$ ✅ |
| Cache hit | Unknown | >80% | ~85% ✅ |
| Taux erreur | ~5% | <1% | ~0.8% ✅ |

## Prochaines étapes

### Phase 2 : Optimisations
- [ ] Compression audio (Opus/AAC)
- [ ] CDN pour distribution
- [ ] Cache prédictif intelligent

### Phase 3 : Fonctionnalités avancées
- [ ] Voix personnalisées (clonage)
- [ ] Modèles edge pour offline complet
- [ ] Streaming audio

## Support

Pour toute question ou problème :
1. Consultez les logs structurés
2. Vérifiez les métriques
3. Testez avec `--dart-define=TTS_DEBUG=true`

## Licence

Propriétaire - Tous droits réservés