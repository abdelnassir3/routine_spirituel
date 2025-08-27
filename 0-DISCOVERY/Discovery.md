# Discovery Pack — Routines Spirituelles
**Phase 0 — DISCOVERY | Analyse complète**

## 1. Intent Produit

### Problème
Les pratiquants musulmans manquent d'un outil numérique moderne pour maintenir et suivre leurs routines spirituelles quotidiennes (dhikr, invocations, récitation), particulièrement en contexte bilingue français-arabe.

### Proposition de Valeur
Application mobile **offline-first** offrant :
- Compteur spirituel persistant avec reprise exacte après interruption
- Audio TTS bilingue (FR/AR) avec synchronisation texte
- Mode mains-libres pour pratique pendant activités
- Catégorisation intuitive des invocations par thème

### Publics Cibles (Personas)
1. **Pratiquant régulier** : Suit des routines quotidiennes établies
2. **Débutant** : Découvre et apprend les invocations progressivement  
3. **Parent éducateur** : Transmet les pratiques aux enfants
4. **Voyageur** : Maintient sa pratique sans connexion

### Contexte d'Usage
- **Domicile** : Sessions matinales/nocturnes (PRD_App_Routines_Spirituelles_AI.md:303-305)
- **Transport** : Mode mains-libres pendant déplacements
- **Travail** : Pauses spirituelles courtes
- **Voyage** : Mode hors-ligne complet

## 2. Objectifs & KPI

### Objectifs Mesurables
- **Rétention D30** : >50% (PRD:354)
- **Session Duration** : >10 min (PRD:333)
- **Routine Completion** : >75% (PRD:335)
- **App Start Time** : <2s (PRD:340)
- **Crash Rate** : <0.1% (PRD:310)

### KPI Techniques (CLAUDE.md:142-145)
- **TTI** : <2 secondes
- **Latence UI** : <200ms
- **Memory** : <150MB
- **Bundle** : <35MB

## 3. Portée Fonctionnelle

### Features Principales
1. **Gestion des Routines** (lib/features/routines/)
   - CRUD thèmes avec fréquence (daily/weekly/monthly)
   - Éditeur de routine avec blocs composites
   - Catégorisation par type (louange, protection, pardon)

2. **Compteur Intelligent** (lib/features/counter/smart_counter.dart)
   - Décrément avec feedback haptique
   - Persistance automatique toutes les 5s
   - Mode mains-libres avec auto-avance

3. **Lecteur Avancé** (lib/features/reader/)
   - Vue bilingue RTL/LTR adaptative
   - Synchronisation audio-texte avec surlignage
   - Mode focus et préférences de lecture

4. **Audio/TTS** (lib/core/services/audio_tts_service.dart)
   - TTS multi-langue FR/AR
   - Queue audio avec priorités
   - Cache local pour mode offline

5. **Persistance** (lib/core/persistence/)
   - Double système Drift (SQL) + Isar (NoSQL)
   - Sauvegarde automatique de session
   - Récupération après interruption

### Parcours Utilisateur Principal
```
Splash → Home → Sélection Routine → Lecture/Compteur → Tâche Suivante → Completion
                           ↓
                    Reprise Session (si interruption)
```

## 4. Non-Fonctionnel

### Performance
- **Architecture** : Clean Architecture avec Repository Pattern (CLAUDE.md:42-48)
- **State Management** : Riverpod 2.x avec AsyncValue
- **Optimisations** : Code splitting, lazy loading, caching agressif

### Accessibilité (a11y)
- **Screen Reader** : Support complet
- **RTL/LTR** : Directionality widgets pour arabe (CLAUDE.md:68-70)
- **Contrast** : WCAG 2.1 AA minimum
- **Reduce Motion** : Option dans settings (main.dart:42)

### Internationalisation (i18n)
- **Langues** : FR (défaut), AR
- **Localisation** : ARB files avec flutter_localizations (lib/l10n/)
- **Polices** : Inter (FR), NotoNaskhArabic (AR) (pubspec.yaml:71-80)

### Offline
- **Corpus Coran** : JSON local dans assets/corpus/ (README.md:32-37)
- **Cache TTS** : Audio stocké avec flutter_secure_storage
- **Sync différée** : Queue pour mode online

### Sécurité
- **Storage** : flutter_secure_storage pour données sensibles
- **Chiffrement** : AES-256 prévu pour Drift/Isar
- **Permissions** : Camera, Audio, Storage (README.md:47-59)

### Confidentialité
- **Analytics** : Anonymisées, opt-out disponible
- **Data** : Local-first, pas de cloud obligatoire
- **RGPD** : Conformité prévue

## 5. Architecture Snapshot

### Stack Technique
```yaml
Frontend:
  Framework: Flutter 3.x (Dart 3.3+)
  State: Riverpod 2.5.1
  Navigation: go_router 14.2.0
  UI: Material Design 3 avec thème custom
  
Persistance:
  SQL: Drift 2.17.0 + sqlite3
  NoSQL: Isar 3.1.0
  Secure: flutter_secure_storage 9.2.2
  
Audio:
  Player: just_audio 0.9.39
  Service: audio_service 0.18.13
  TTS: flutter_tts 3.8.3
  
Services:
  HTTP: dio 5.5.0
  OCR: google_mlkit_text_recognition
  PDF: native_pdf_renderer
```

### Patterns Architecturaux
1. **Clean Architecture** : Séparation UI/Business/Data (lib/core/, lib/features/)
2. **Repository Pattern** : Abstraction accès données (lib/core/repositories/)
3. **Service Layer** : Services singleton transverses (lib/core/services/)
4. **Provider Pattern** : Riverpod pour injection de dépendances

### Organisation Code
```
lib/
├── app/           # Router (router.dart), Config
├── core/          
│   ├── models/    # Modèles métier (routine_models.dart, task_category.dart)
│   ├── persistence/ # Drift schemas, Isar collections
│   ├── services/  # 20+ services (AI, Audio, OCR, Session...)
├── features/      
│   ├── counter/   # Smart counter avec hands-free
│   ├── home/      # Dashboard moderne
│   ├── reader/    # 6 variantes de lecteur
│   ├── routines/  # CRUD et éditeur
│   ├── session/   # État global session
│   ├── settings/  # Paramètres et cache
│   └── splash/    # Écran animé
├── design_system/ # Tokens, composants, thèmes
└── l10n/         # Localisation FR/AR
```

### Intégrations Prévues
- **Supabase** : Auth, Storage, Realtime (PRD:26-29)
- **OpenAI/Claude** : Suggestions IA (PRD:178-179)
- **Firebase** : Analytics, Crashlytics
- **Google Cloud TTS** : Voix premium

## 6. Contraintes

### Plateformes Cibles
- **iOS** : 12.0+ (pubspec.yaml)
- **Android** : API 21+ (Android 5.0)
- **Web** : Support partiel (drift_web.dart existe)
- **macOS** : Support expérimental

### Budgets Techniques
- **Bundle Size** : <35MB contrainte stricte
- **Memory** : <150MB en usage normal
- **Storage** : ~100MB pour corpus complet
- **Network** : Mode offline obligatoire

### Dépendances Critiques
- **flutter_tts** : Qualité variable selon OS/langue
- **Isar** : Migration complexe si changement
- **MLKit** : OCR limité pour arabe

## 7. Risques & Hypothèses

### Risques Identifiés
1. **TTS Arabe** : Qualité variable → Multi-provider prévu (PRD:322)
2. **RTL Complexity** : Bugs visuels → Tests screenshots prévus
3. **Battery Drain** : Audio continu → Wake locks optimisés
4. **Data Loss** : Interruptions → Triple backup strategy

### Hypothèses
- Utilisateurs acceptent permissions audio/storage
- Corpus Coran peut être packagé <50MB
- Performance Flutter suffisante pour 60fps

## 8. Questions Ouvertes

### Priorité Haute
1. **Authentification** : Obligatoire ou optionnelle au lancement ?
2. **Sync Cloud** : Supabase dès v1 ou différé ?
3. **Corpus** : Sources officielles validées pour Coran ?

### Priorité Moyenne
4. **Monétisation** : Freemium ? Ads ? Premium features ?
5. **IA** : Intégration GPT-4 pour suggestions dès v1 ?
6. **Notifications** : Rappels de prière intégrés ?

## 9. Preuves Code

### État Actuel
- **47 pages/screens** identifiés (Grep class.*Page)
- **95+ fichiers Dart** dans lib/
- **20+ services** implémentés
- **6 variantes** du reader (modern, premium, enhanced...)
- **Double persistance** Drift + Isar fonctionnelle
- **Thème Material 3** avec 3 systèmes (theme.dart, inspired_theme.dart, advanced_theme.dart)

### Points d'Attention
- **Duplication** : 3 systèmes de thème coexistent
- **Incohérence** : Mix ancien/nouveau design (home_page.dart vs modern_home_page.dart)
- **Dead Code** : Fichiers .backup, stubs non utilisés
- **Complexité** : 6 implémentations du reader

## 10. Recommandations Immédiates

1. **Consolidation Design System** : Unifier les 3 thèmes
2. **Cleanup Code** : Supprimer doublons/variantes
3. **Validation Corpus** : Sourcer données officielles
4. **Tests E2E** : Couvrir parcours critiques
5. **Documentation API** : Manque specs services