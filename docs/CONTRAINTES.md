# Contraintes Techniques - Projet Spiritual Routines

## Contraintes de performance
- **Latence UI**: <200ms pour toutes interactions
- **Time to Interactive**: <2 secondes au d�marrage � froid
- **Utilisation m�moire**: <150MB en fonctionnement normal
- **Bundle size**: <35MB pour d�ploiement stores
- **Latence TTS**: <450ms P95 pour synth�se vocale

## Contraintes de s�curit�
- **Chiffrement**: AES-256 pour stockage local sensible
- **Authentification**: Biom�trique (Face ID/Touch ID/Empreinte) + PIN fallback
- **Logging**: Filtrage automatique PII (email, t�l�phone, tokens, etc.)
- **Conformit�**: OWASP Mobile Top 10, grade minimum B (85/100)
- **Transport**: HTTPS forc�, certificate pinning en production

## Contraintes multilingues
- **Langues support�es**: Fran�ais + Arabe avec support RTL/LTR natif
- **Polices**: Noto Naskh Arabic (arabe) + Inter (fran�ais/interface)
- **Direction texte**: Auto-d�tection RTL/LTR avec mirroring ic�nes
- **Claviers**: Support claviers arabes et fran�ais
- **Formatage**: Nombres arabes vs europ�ens selon contexte

## Contraintes plateforme
- **iOS/Android**: Support production complet (95%)
- **macOS**: Beta avec limitations background audio (60%)
- **Web**: Exp�rimental avec stubs Isar requis (40%)
- **Offline-first**: Fonctionnement complet sans connexion
- **Cache**: 7j/100MB pour TTS, purge automatique

## Contraintes techniques
- **Framework**: Flutter 3.x minimum avec null safety
- **State management**: Riverpod 2.5+ obligatoire
- **Base de donn�es**: Drift (SQL) + Isar (NoSQL) pour persistance
- **Audio**: just_audio + audio_service pour background
- **Tests**: Coverage minimum 60% global, 80% services critiques

## Contraintes serveur
- **VPS Edge-TTS**: 168.231.112.71:8010 (timeout 15s)
- **VPS Coqui**: 168.231.112.71:8001 (timeout 15s)
- **Fallback**: Flutter TTS local si VPS indisponible
- **Circuit breaker**: D�sactivation apr�s 5 �checs cons�cutifs
- **Cache hit**: Objectif 85% pour r�duire co�ts serveur

## Contraintes UX/UI
- **Material Design 3**: Obligatoire avec th�me unifi�
- **Accessibilit�**: WCAG AA minimum, cibles tactiles e48dp
- **Animations**: d250ms, d�sactivables pour accessibilit�
- **Feedback haptique**: Contextuel avec 3 niveaux d'intensit�
- **Mode sombre**: Support automatique syst�me