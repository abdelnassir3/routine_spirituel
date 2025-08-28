# Brief Projet - Spiritual Routines (RISAQ)

**Dernière mise à jour: 2025-08-27 14:30**

## Vue d'ensemble
Application Flutter de routines spirituelles bilingue français-arabe avec fonctionnalités avancées de compteur intelligent, synthèse vocale hybride Edge-TTS/Coqui/Flutter, et mode offline-first complet.

## Objectifs produit
- **Mission**: Moderniser les pratiques spirituelles quotidiennes avec technologie mobile
- **Vision**: App de r�f�rence pour routines spirituelles avec IA et accessibilit�
- **Cible**: Pratiquants musulmans francophones et arabophones

## Fonctionnalit�s core
- **Compteur persistant**: D�cr�ment avec haptic feedback, reprise apr�s interruption
- **Lecteur bilingue**: Affichage RTL/LTR simultan� avec surlignage audio synchronis�
- **TTS intelligent**: D�tection automatique contenu coranique � routage API sp�cialis�e
- **Mode mains-libres**: Auto-avance pour pratique pendant autres activit�s
- **Cat�gorisation**: Organisation par th�me (louange, protection, pardon, etc.)

## Diff�renciation
- Architecture audio hybride (APIs Quran + TTS synth�se)
- Support RTL/LTR natif avec polices optimis�es
- Persistance multi-niveau (Drift + Isar + cache s�curis�)
- S�curit� OWASP Grade B avec authentification biom�trique
- Fonctionnement offline complet avec synchronisation

## KPI cibles
- **Rétention D30**: >50%
- **Session moyenne**: >10min
- **Taux complétion routine**: >75%
- **Crash rate**: <0.1%
- **Performance**: TTI <2s, latence UI <200ms
- **Coverage tests**: 60% minimum (actuellement 45+ tests créés, couverture améliorée)
- **Code qualité**: Infrastructure qualité déployée, 72 dépendances mises à jour

## État Projet
- ✅ Audit qualité terminé (Août 2025) - 45 tests unitaires créés, infrastructure CI/CD déployée, dépendances modernisées