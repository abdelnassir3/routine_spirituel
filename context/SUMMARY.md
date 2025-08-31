# Résumé Projet - Spiritual Routines (RISAQ)

**Dernière mise à jour: 2025-08-30**

## Vue d'ensemble
• **Application Flutter** de routines spirituelles bilingue français-arabe
• **Cible**: Pratiquants musulmans francophones et arabophones
• **Mission**: Moderniser pratiques spirituelles avec technologie mobile

## Architecture Technique
• **Framework**: Flutter 3.x avec Dart 3.x, null safety strict
• **State Management**: Riverpod 2.5+ obligatoire
• **Persistance**: Drift (SQL) + Isar (NoSQL) pour stockage hybride
• **Audio**: just_audio + audio_service pour background
• **Localisation**: Support RTL/LTR natif avec polices optimisées

## Fonctionnalités Clés
• **Compteur persistant**: Décrémenteur avec haptic feedback et reprise après interruption
• **Lecteur bilingue**: Affichage RTL/LTR simultané avec surlignage audio synchronisé
• **TTS intelligent**: Détection automatique contenu coranique → routage API spécialisée
• **Mode mains-libres**: Auto-avance pour pratique pendant autres activités
• **Mode offline-first**: Fonctionnement complet sans connexion

## Infrastructure Serveur
• **Edge-TTS**: 168.231.112.71:8010 (principal, synthèse FR/AR)
• **Coqui XTTS-v2**: 168.231.112.71:8001 (haute qualité)
• **APIs Quran**: AlQuran.cloud, Everyayah.com (récitations coraniques)
• **Fallback**: Edge-TTS → Coqui → Flutter TTS → Mode silencieux
• **Cache**: 7j/100MB TTS, 30j Quran, objectif hit rate 85%

## Contraintes Performance
• **Latence UI**: <200ms pour toutes interactions
• **Time to Interactive**: <2s au démarrage à froid
• **Utilisation mémoire**: <150MB en fonctionnement
• **Bundle size**: <35MB pour déploiement stores
• **Crash rate**: <0.1% objectif production

## Support Plateformes
• **iOS/Android**: Support production complet (95%)
• **macOS**: Beta avec limitations background audio (60%)
• **Web**: Expérimental avec stubs requis (40%)

## État Actuel & Problème
• **Infrastructure qualité**: ✅ 45 tests, CI/CD déployé, 72 dépendances mises à jour
• **Problème Web actuel**: Boutons "Écouter"/"Mains libres" ne fonctionnent pas
• **Erreur identifiée**: "Unexpected null value" dans UserSettings (drift_schema.g.dart:2471:73)
• **Fix en cours**: Correction mapping user_settings dans drift_web_stub.dart

## Serveurs & APIs
• **Timeout**: 15s par serveur avec circuit breaker (5 échecs)
• **Sécurité**: AES-256 local, HTTPS production, pas de secrets en dur
• **Environnement**: HTTP dev autorisé, HTTPS obligatoire production