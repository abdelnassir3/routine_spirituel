# RISAQ - Résumé du Projet

**Dernière mise à jour: 2025-09-09 - OPTIMISATIONS FINALISÉES**

## 🎯 Vue d'ensemble
• **Application Flutter** de routines spirituelles bilingue FR/AR pour pratiquants musulmans
• **Architecture** : Drift + Isar persistance, Riverpod state management, offline-first
• **Mission** : Moderniser pratiques spirituelles quotidiennes avec technologie mobile
• **Cible** : Pratiquants musulmans francophones et arabophones

## 📱 Fonctionnalités principales
• **Compteur persistant** : Décrément avec haptic feedback, reprise après interruption
• **Lecteur bilingue** : RTL/LTR simultané avec surlignage audio synchronisé
• **TTS intelligent** : Détection coranique → routage API spécialisée (Edge-TTS/Coqui/Flutter)
• **Mode mains-libres** : Auto-avance pour pratique pendant autres activités
• **Catégorisation** : Thèmes (louange, protection, pardon)

## ⚡ Performances cibles
• **Latence UI** : <200ms | **TTI** : <2s | **Mémoire** : <150MB | **Bundle** : <35MB
• **Rétention D30** : >50% | **Session** : >10min | **Crash rate** : <0.1%
• **Tests coverage** : 60% min (45+ tests créés)

## 🔧 Stack technique
• **Framework** : Flutter 3.x + Dart (null safety)
• **State** : Riverpod 2.5+ | **DB** : Drift + Isar | **Audio** : just_audio + audio_service
• **Plateformes** : iOS/Android (95%), macOS beta (60%), Web expérimental (40%)

## 🌐 Infrastructure serveurs
• **Edge-TTS** : 168.231.112.71:8010 (principal, ~8€/mois)
• **Coqui XTTS** : 168.231.112.71:8001 (haute qualité, backup)
• **APIs Quran** : AlQuran.cloud, Everyayah.com (contenu coranique)
• **Fallback** : Flutter TTS local → Mode silencieux

## 🔒 Sécurité
• **Chiffrement** : AES-256 | **Auth** : Biométrique + PIN
• **Conformité** : OWASP Grade B | **Transport** : HTTPS + certificate pinning

## ✅ État actuel (Sept 2025)
• **Infrastructure qualité** : CI/CD, scripts lint/test/build déployés
• **72 dépendances** mises à jour, design system réparé
• **Optimisations récentes** : Erreurs providers, ParentDataWidget, overflow, requêtes DB, service worker
• **Status** : Application stable, prête pour tests utilisateurs