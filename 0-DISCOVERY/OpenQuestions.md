# Questions Ouvertes — Points de Décision
**Questions prioritaires nécessitant clarification pour avancer**

## 🔴 Priorité CRITIQUE (Bloquantes)

### 1. Source du Corpus Coranique
**Context** : assets/corpus/ attend des fichiers JSON mais aucun présent
**Impact** : Feature core non fonctionnelle sans données
**Questions** :
- Quelle source officielle/validée utiliser pour le texte arabe ?
- Quelle traduction française privilégier (Hamidullah, autres) ?
- Format exact attendu : combined ou séparé ? Métadonnées incluses ?
**Décision requise** : Immédiate pour débloquer développement

### 2. État du Code - Consolidation ou Refonte ?
**Context** : 6 variantes du reader, 3 systèmes de thème, doublons multiples
**Impact** : Dette technique majeure, maintenance difficile
**Questions** :
- Consolider les variantes existantes ou repartir sur une base clean ?
- Quelle variante du reader garder (modern, premium, enhanced) ?
- Quel système de thème privilégier (theme.dart, inspired_theme, advanced_theme) ?
**Décision requise** : Avant tout nouveau développement

### 3. Architecture State Management
**Context** : Riverpod utilisé mais patterns inconsistants
**Impact** : Scalabilité et testabilité du code
**Questions** :
- Pattern officiel : AsyncNotifier ou StateNotifier ?
- Providers globaux ou feature-scoped ?
- Migration vers Riverpod Generator pour type-safety ?
**Décision requise** : Pour guidelines développement

## 🟡 Priorité HAUTE (v1.0)

### 4. Authentification & Comptes Utilisateurs
**Context** : Supabase mentionné mais non implémenté
**Impact** : Sync multi-device, personnalisation
**Questions** :
- Auth obligatoire ou mode anonyme au lancement ?
- OAuth providers : Google, Apple, email/password ?
- Données à synchroniser : tout ou seulement préférences ?
**Timeline** : Décision pour v1.0 ou différer v1.5 ?

### 5. Stratégie Audio/TTS
**Context** : flutter_tts qualité variable, surtout en arabe
**Impact** : UX critique pour feature principale
**Questions** :
- Intégrer Cloud TTS (Google/Amazon) dès v1.0 ?
- Voix pré-enregistrées pour invocations communes ?
- Budget pour API cloud TTS ?
**Options** : Local only vs Hybrid vs Cloud-first

### 6. Monétisation
**Context** : Aucune stratégie définie
**Impact** : Architecture des features premium
**Questions** :
- Modèle : Gratuit, Freemium, Paid, Ads ?
- Features premium : Thèmes, voix, statistiques avancées ?
- Prix cible et marchés prioritaires ?
**Timeline** : Architecture à prévoir même si activation ultérieure

## 🟢 Priorité MOYENNE (v1.5+)

### 7. Features IA
**Context** : ai_service.dart stub présent, PRD mentionne GPT-4/Claude
**Impact** : Différenciation produit
**Questions** :
- Suggestions de routines personnalisées : priorité ?
- Génération de du'a contextuels : pertinent ?
- Budget API et privacy concerns ?
**Faisabilité** : POC avant intégration complète

### 8. Notifications & Rappels
**Context** : Permission handler présent mais pas de logique notification
**Impact** : Engagement et rétention
**Questions** :
- Rappels de prière (horaires) : dans scope ?
- Notifications motivationnelles : fréquence ?
- Intégration calendrier système ?
**Complexité** : iOS/Android différences significatives

### 9. Mode Famille/Éducation
**Context** : Persona "parent éducateur" identifié
**Impact** : Nouveau segment utilisateur
**Questions** :
- Comptes enfants avec contrôle parental ?
- Gamification pour apprentissage ?
- Contenu adapté par âge ?
**Effort** : Feature set complet additionnel

### 10. Analytics & Insights
**Context** : Firebase mentionné mais non configuré
**Impact** : Compréhension usage et optimisation
**Questions** :
- Métriques prioritaires à tracker ?
- Dashboard utilisateur avec statistiques ?
- Respect RGPD et privacy : opt-in/opt-out ?
**Outils** : Firebase vs Mixpanel vs Custom

## 🔵 Priorité BASSE (v2.0+)

### 11. Support Desktop Complet
**Context** : Windows/Linux à 20% seulement
**Questions** :
- Vraie demande utilisateur ou nice-to-have ?
- Effort vs ROI pour ces plateformes ?
- Maintenance long terme ?

### 12. Mode Communautaire
**Context** : Partage de routines entre utilisateurs
**Questions** :
- Modération du contenu partagé ?
- Système de rating/review ?
- Aspects légaux et religieux ?

### 13. Intégrations Tierces
**Context** : Apple Health, Google Fit, calendriers
**Questions** :
- Pertinence pour app spirituelle ?
- Complexité vs valeur ajoutée ?
- Privacy implications ?

## Actions Requises

### Immédiat (Sprint 0)
1. **Workshop Produit** : Trancher questions critiques 1-3
2. **Audit Code** : Décider consolidation vs refonte
3. **Source Corpus** : Identifier et valider source données

### Court Terme (Sprint 1-2)
4. **Roadmap v1.0** : Prioriser features 4-6
5. **POC TTS** : Tester solutions cloud
6. **Architecture Review** : Figer patterns state management

### Moyen Terme (v1.0+)
7. **User Research** : Valider hypothèses features 7-10
8. **A/B Tests** : Expérimenter options monétisation
9. **Community Feedback** : Beta test pour priorités v2.0

## Recommandation Finale

**Approche proposée** : 
1. MVP minimal (iOS/Android only) avec corpus local
2. Itérations rapides basées sur feedback utilisateur
3. Features avancées (IA, cloud) en v1.5+ si traction

**Risques si non traité** :
- Développement bloqué sans corpus
- Dette technique ingérable avec code dupliqué
- Perte de focus avec trop de features non validées