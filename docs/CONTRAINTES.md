# Contraintes Techniques - Projet Spiritual Routines

## Contraintes de performance
- **Latence UI**: <200ms pour toutes interactions
- **Time to Interactive**: <2 secondes au démarrage à froid
- **Utilisation mémoire**: <150MB en fonctionnement normal
- **Bundle size**: <35MB pour déploiement stores
- **Latence TTS**: <450ms P95 pour synthèse vocale

## Contraintes de sécurité
- **Chiffrement**: AES-256 pour stockage local sensible
- **Authentification**: Biométrique (Face ID/Touch ID/Empreinte) + PIN fallback
- **Logging**: Filtrage automatique PII (email, téléphone, tokens, etc.)
- **Conformité**: OWASP Mobile Top 10, grade minimum B (85/100)
- **Transport**: HTTPS forcé, certificate pinning en production

## Contraintes multilingues
- **Langues supportées**: Français + Arabe avec support RTL/LTR natif
- **Polices**: Noto Naskh Arabic (arabe) + Inter (français/interface)
- **Direction texte**: Auto-détection RTL/LTR avec mirroring icônes
- **Claviers**: Support claviers arabes et français
- **Formatage**: Nombres arabes vs européens selon contexte

## Contraintes plateforme
- **iOS/Android**: Support production complet (95%)
- **macOS**: Beta avec limitations background audio (60%)
- **Web**: Expérimental avec stubs Isar requis (40%)
- **Offline-first**: Fonctionnement complet sans connexion
- **Cache**: 7j/100MB pour TTS, purge automatique

## Contraintes techniques
- **Framework**: Flutter 3.x minimum avec null safety
- **State management**: Riverpod 2.5+ obligatoire
- **Base de données**: Drift (SQL) + Isar (NoSQL) pour persistance
- **Audio**: just_audio + audio_service pour background
- **Tests**: Coverage minimum 60% global, 80% services critiques

## Contraintes serveur
- **VPS Edge-TTS**: 168.231.112.71:8010 (timeout 15s)
- **VPS Coqui**: 168.231.112.71:8001 (timeout 15s)
- **Fallback**: Flutter TTS local si VPS indisponible
- **Circuit breaker**: Désactivation après 5 échecs consécutifs
- **Cache hit**: Objectif 85% pour réduire coûts serveur

## Contraintes UX/UI
- **Material Design 3**: Obligatoire avec thème unifié
- **Accessibilité**: WCAG AA minimum, cibles tactiles e48dp
- **Animations**: d250ms, désactivables pour accessibilité
- **Feedback haptique**: Contextuel avec 3 niveaux d'intensité
- **Mode sombre**: Support automatique système