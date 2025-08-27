Voici un backlog JIRA structuré avec Epics, User Stories, critères d’acceptation et priorités. Il couvre l’ergonomie, le design, la technique, l’IA et l’offline-first décrits dans vos PRD.

**Backlog Overview**
- Objectif: livrer un MVP robuste puis itérer sur l’IA et le polissage.
- Cadre: Flutter + Riverpod + go_router + Drift/Isar + Supabase + TTS multi‑provider.
- DoD global: tests verts, perf OK, a11y >90, RTL/LTR OK, logs/metrics, docs courtes, revue design.

**Epic: ONB — Onboarding & Réglages**
- ONB-1 — Onboarding FR/AR + RTL/LTR
  - Description: sélection langue, orientation, thème, polices.
  - AC:
    - Given premier lancement, When je lance l’app, Then je choisis FR/AR et RTL/LTR.
    - Given choix langue, Then toute l’app respecte la direction.
    - Given a11y, Then tailles textes ajustables dans onboarding.
  - Priority: High; Points: 5; Labels: a11y,i18n
- ONB-2 — Choix polices AR/FR et tailles
  - AC: Given réglages, When je change la police ou taille, Then toutes les vues s’adaptent sans redémarrer.
  - Priority: High; Points: 3; Labels: typography
- ONB-3 — Paramètres TTS (voix, vitesse, test audio)
  - AC: Given voix disponible, When je teste, Then un échantillon joue et est mémorisé.
  - Priority: High; Points: 5; Labels: tts
- ONB-4 — Packs hors-ligne (corpus AR/FR)
  - AC: Given téléchargement pack, Then l’app fonctionne sans réseau (lecture texte/tts mis en cache).
  - Priority: High; Points: 8; Labels: offline

**Epic: ROU — Gestion des Routines & Thèmes**
- ROU-1 — CRUD Thèmes avec fréquence
  - AC: créer/modifier/supprimer; fréquence quotidienne/hebdo/mensuelle visible et filtrable.
  - Priority: High; Points: 5
- ROU-2 — CRUD Routines par thème + réorganisation par DnD
  - AC: DnD ordre des tâches persistant; duplication routine.
  - Priority: High; Points: 8
- ROU-3 — Éditeur de tâches (Surate, Versets, Mix, Texte libre)
  - AC: ajouter plusieurs blocs; validation des références; sauvegarde auto.
  - Priority: High; Points: 13
- ROU-4 — Répétitions par défaut appliquées à chaque lancement
  - AC: Given paramètres par défaut, When je lance, Then compteur initialise ces valeurs; modifiable pour sessions futures.
  - Priority: High; Points: 5
- ROU-5 — Catégories et filtres
  - AC: assigner emoji+label; filtrer routines par catégories.
  - Priority: Medium; Points: 5

**Epic: LIB — Bibliothèque & Contenu**
- LIB-1 — Navigateur Coran (sourates/versets, multi-sélection)
  - AC: picker sourate, entrée de plages versets (ex: 2:255, 2:1-5).
  - Priority: High; Points: 8
- LIB-2 — Invocations préchargées + mes notes
  - AC: liste consultable; taggable par catégories; recherche.
  - Priority: Medium; Points: 5
- LIB-3 — Téléchargements hors-ligne (sélectifs + par lot)
  - AC: file d’attente; reprise; ETag; quotas.
  - Priority: High; Points: 8

**Epic: READ — Lecteur Bilingue & Synchronisation**
- READ-1 — Vue lecture AR/FR côte-à-côte/alternée + zoom/plein écran
  - AC: switch d’affichage; zoom pincement; plein écran persistant.
  - Priority: High; Points: 8
- READ-2 — Surlignage synchronisé audio-texte
  - AC: mot/verset en cours surligné; drift corrigé; fallback heuristique si pas de speech marks.
  - Priority: High; Points: 13
- READ-3 — Barre audio (lecture, vitesse, scrubbing)
  - AC: vitesse 0.5–2.0; scrubbing avec mise à jour surlignage.
  - Priority: High; Points: 5
- READ-4 — Gestes et haptique
  - AC: tap −1, double‑tap −5, swipe tâche suivante; haptique distincte à zéro.
  - Priority: Medium; Points: 5

**Epic: CNT — Compteur Intelligent & Mains Libres**
- CNT-1 — Compteur persistant par tâche
  - AC: décrément à chaque validation/lecture; persistance temps réel.
  - Priority: Critical; Points: 8
- CNT-2 — Auto-avance à zéro vers tâche suivante
  - AC: When compteur atteint zéro, Then passage automatique avec feedback.
  - Priority: Critical; Points: 5
- CNT-3 — Mode mains libres
  - AC: décrément sur marqueurs audio; délais configurables; verrouillage écran.
  - Priority: High; Points: 8
- CNT-4 — Raccourcis écouteurs/boutons volume
  - AC: bouton = décrément/pause configurable.
  - Priority: Medium; Points: 3

**Epic: PRS — Persistance & Reprise**
- PRS-1 — Snapshot incrémental session
  - AC: snapshot debouncé <500ms sur changement critique; stockage transactionnel.
  - Priority: Critical; Points: 8
- PRS-2 — Modale de reprise après interruption
  - AC: “Reprendre exactement” vs “Réinitialiser”; détail point/compteur/tâche.
  - Priority: Critical; Points: 5
- PRS-3 — Restauration atomique (UI, audio, compteur)
  - AC: restauration synchronisée sans clignotement; tests de coupure brutale.
  - Priority: Critical; Points: 8

**Epic: OFF — Offline & Sync**
- OFF-1 — Mode hors-ligne complet
  - AC: toutes fonctionnalités clés sans réseau (texte, navigation, compteur, lecture audio TTS pré‑cachée).
  - Priority: Critical; Points: 8
- OFF-2 — Sync Supabase (métadonnées, modèles, sauvegardes)
  - AC: LWW métadonnées; sessions locales par défaut; résolution de conflits simple.
  - Priority: High; Points: 13
- OFF-3 — Cache TTS (clé par texte+voix+vitesse)
  - AC: génération puis réutilisation; LRU; quotas stockage.
  - Priority: High; Points: 5

**Epic: NOT — Notifications & Rappels**
- NOT-1 — Rappels par fréquence thème/routine
  - AC: planification locale; respect DND; répétitions.
  - Priority: Medium; Points: 5
- NOT-2 — Deep‑links vers reprise
  - AC: notification “Reprendre” ouvre la session au bon point.
  - Priority: Medium; Points: 3
- NOT-3 — Sync serveur (pg_cron) pour backup
  - AC: planification cloud optionnelle; idempotence.
  - Priority: Low; Points: 5

**Epic: AI — IA Suggestions & Génération**
- AI-1 — Suggestions de routines personnalisées
  - AC: cartes “Suggestions” avec explication; opt‑in.
  - Priority: Medium; Points: 8
- AI-2 — Génération d’invocations/rappels
  - AC: contenu structuré, langue choisie, révision avant ajout.
  - Priority: Medium; Points: 8
- AI-3 — Traduction/translittération
  - AC: FR/AR cohérents; translit lisible; cache.
  - Priority: Medium; Points: 5
- AI-4 — Insights d’usage
  - AC: recommandations temporelles (meilleures heures/jours), compteur optimal.
  - Priority: Low; Points: 5

**Epic: A11Y — Accessibilité & RTL**
- A11Y-1 — Contrastes et tailles dynamiques
  - AC: score >90; tests dark/light.
  - Priority: High; Points: 3
- A11Y-2 — Lecteur d’écran et ordre focus
  - AC: labels/semantics complets; navigation clavier/assistive.
  - Priority: High; Points: 5
- A11Y-3 — RTL impeccable (miroirs/icônes/gestes)
  - AC: pas d’anomalie visuelle; golden tests RTL.
  - Priority: High; Points: 5

**Epic: SEC — Sécurité & Vie Privée**
- SEC-1 — Chiffrement local (Drift/Isar) + clés sécurisées
  - AC: données chiffrées; clés dans secure storage.
  - Priority: High; Points: 5
- SEC-2 — Opt‑in analytics + anonymisation
  - AC: consentement; bascule off; PII minimale.
  - Priority: Medium; Points: 3
- SEC-3 — Export/Import chiffré des données
  - AC: fichier protégé; restauration fidèle sur nouvel appareil.
  - Priority: Medium; Points: 8

**Epic: OBS — Analytics, Logs, Sentry**
- OBS-1 — Événements clés et funnels
  - AC: démarrage, reprise, complétions, abandon, TTS usage.
  - Priority: Medium; Points: 3
- OBS-2 — Sentry + traces de perf
  - AC: crash rate suivi; alertes P95 latence.
  - Priority: Medium; Points: 3

**Epic: PERF — Performance & Fiabilité**
- PERF-1 — Démarrage <2s et jank <1%
  - AC: profilages; lazy initializations; caches chauds.
  - Priority: High; Points: 5
- PERF-2 — Mémoire <150MB; bundle <35MB
  - AC: audit assets; shrinker; obfuscation; split per ABI.
  - Priority: Medium; Points: 5
- PERF-3 — Gestion audio focus/interruptions
  - AC: appels, écouteurs, autres apps; reprise stable.
  - Priority: High; Points: 5

**Epic: DSN — Design System & Composants**
- DSN-1 — Thème clair/sombre, palette, typo
  - AC: tokens; contrastes validés; thème dynamique.
  - Priority: High; Points: 3
- DSN-2 — Composants: CategoryChip, AudioBar, ReadingPane, CounterChip
  - AC: docs storybook; tests visuels LTR/RTL.
  - Priority: High; Points: 8

**Dépendances clés**
- READ-2 dépend de CNT-1, OFF-3.
- CNT-3 dépend de READ-3 et OFF-3.
- PRS-2/3 dépendent de PRS-1.
- AI-* dépend de OFF-1/2 (cache/sync) et SEC-2 (consentement).
- NOT-2 dépend de PRS-3 (reprise fiable).
- A11Y-3 dépend de DSN-1/2.

**Sprints proposés (MVP → V1)**
- Sprint 1 (Fondations): DSN-1, ONB-1/2, ROU-1, ROU-2, LIB-1 (base), PRS-1, CNT-1.
- Sprint 2 (Core lecture): READ-1, READ-3, ROU-3, ROU-4, ROU-5, OFF-1, OFF-3, A11Y-1/3.
- Sprint 3 (Reprise & mains libres): PRS-2/3, CNT-2/3/4, READ-2, PERF-3, NOT-1/2.
- Sprint 4 (Sync & sécurité): OFF-2, SEC-1/2, OBS-1/2, PERF-1/2, DSN-2.
- Sprint 5 (IA & polish): AI-1/2/3/4, LIB-2/3, NOT-3, SEC-3, améliorations UX.

**Critères de sortie MVP**
- Routines complètes avec tâches mixtes, catégories et rép. par défaut.
- Lecteur bilingue avec compteur persistant, reprise exacte, auto‑avance.
- Hors‑ligne complet, TTS cache, gestuelle et haptique.
- Accessibilité et RTL validés, tests >80%, crash <0.1%.

Voulez-vous que je vous exporte ce backlog en CSV JIRA (colonnes standard: Issue Type, Summary, Description, Acceptance Criteria, Priority, Story Points, Epic Link, Labels) ou que je crée un fichier YAML/CSV dans ce dossier prêt à importer ?

