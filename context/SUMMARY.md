# RÉSUMÉ PROJET - Spiritual Routines (RISAQ)

**Dernière mise à jour: 2025-08-31 - PERSISTANCE RÉSOLUE**

## Vue d'ensemble
• **Application Flutter** bilingue français-arabe pour routines spirituelles musulmanes  
• **Architecture**: Drift + Isar persistance, Riverpod state management, offline-first  
• **Public**: Pratiquants musulmans francophones et arabophones  
• **Status**: Problème persistance routines **COMPLÈTEMENT RÉSOLU** (2025-08-31)  

## Fonctionnalités Core
• **Compteur persistant** avec feedback haptique et reprise après interruption  
• **Lecteur bilingue** RTL/LTR avec surlignage audio synchronisé  
• **TTS hybride** Edge-TTS/Coqui avec détection automatique contenu coranique  
• **Mode mains-libres** auto-avance pendant pratique  
• **Catégorisation** par thèmes (louange, protection, pardon)  

## Architecture Technique
• **Framework**: Flutter 3.x + Dart null safety, Riverpod 2.5+  
• **Persistance**: Drift (SQL) + Isar (NoSQL) + WebStub pour tests Web  
• **Audio**: just_audio + audio_service, background support  
• **Multilingue**: Support RTL/LTR natif, polices Noto Arabic + Inter  
• **Web**: Expérimental (40%) avec WebStub fonctionnel  

## Serveurs & API
• **Edge-TTS**: 168.231.112.71:8010 (principal, synthèse FR/AR)  
• **Coqui XTTS**: 168.231.112.71:8001 (haute qualité, backup)  
• **Quran APIs**: AlQuran.cloud + fallbacks pour récitations  
• **Circuit breaker**: 5 échecs → fallback Flutter TTS local  
• **Cache**: 7j/100MB TTS, 30j Quran, hit rate objectif 85%  

## Performance & Qualité
• **KPI**: TTI <2s, latence UI <200ms, crash rate <0.1%  
• **Tests**: 45+ tests unitaires créés, coverage 60% minimum  
• **Sécurité**: OWASP Grade B, AES-256, authentification biométrique  
• **Bundle**: <35MB, mémoire <150MB  

## RÉSOLUTION MAJEURE (2025-08-31)
• **Problème persistance RÉSOLU**: WebInitializer corrigé - tous champs obligatoires fournis  
• **Corrections**: TasksCompanion, ThemesCompanion, RoutinesCompanion avec Value() wrappers  
• **Providers dynamiques**: ModernHomePage utilise StreamBuilder au lieu données codées  
• **Service reset**: DatabaseResetService complet dans settings  
• **Interface adaptée**: Gestion états vides quand aucune routine  
• **Résultat**: ✅ Routine par défaut créée automatiquement sans erreur  

## État Infrastructure
• **CI/CD**: GitHub Actions lint → test → build → deploy  
• **Scripts**: lint.sh, test.sh déployés et testés  
• **Dépendances**: 72 packages mis à jour, js package forcé v0.7.2  
• **Design system**: colors.dart, typography.dart, shadows.dart réparés