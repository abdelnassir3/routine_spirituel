# QA Checklist UI/UX — Routines Spirituelles

## Scénarios
- Modes: clair/sombre; Palettes: modern/elegant/ocean; Langues: FR/AR.
- Plateformes: iOS + Android (simu/device) — tailles d’écran S/M/L.

## Accueil
- [ ] Header lisible (titre/sous‑titre) sur dégradé; ombre perçue.
- [ ] Stats/CTA suivent la palette; labels secondaires lisibles.

## Routines
- [ ] Chips filtres: cibles ≥ 48dp; sélection lisible (fond/texte en primary/onPrimary).
- [ ] Rows/cards: bordures `outlineVariant`, fonds `surface`; pas de gris codés.

## Reader
- [ ] Thèmes lecture: Système/Sépia/Sépia doux/Papier/Papier crème+/Noir/Crème — fond/texte corrects.
- [ ] Bilingue: FR/AR/Les deux — direction RTL/LTR OK; numérotation/séparateurs.
- [ ] Sliders taille/interligne, justification, marges latérales — effet immédiat + persistance.
- [ ] Mode “concentration”: header masqué, taille/interligne +; lisibilité optimale.
- [ ] Navigation Précédent/Suivant: animation directionnelle (slide+fade), haptique; bornes protégées.
- [ ] Réinitialiser l’affichage: remet toutes les préférences (focus, numéros, sep, sliders, justif, marges, thème).
- [ ] Mémoriser par contenu: Enregistrer/effacer les préférences pour la tâche courante.

## Réglages
- [ ] Bascule clair/sombre persistée.
- [ ] Sélecteur de palette (swatches) appliqué globalement.
- [ ] Snackbars lisibles (clair/sombre).

## Navigation & Composants
- [ ] BottomNav: fond `surface`, sélection en `primary`, non‑sélectionné `onSurfaceVariant`.
- [ ] FAB: gradient `primary/secondary`, ombre cohérente.
- [ ] Inputs/ListTiles: tokens `colorScheme`; focus/erreur visibles.

## Performances & Stabilité
- [ ] Transitions Reader fluides; pas de jank lors des sliders.
- [ ] Aucun crash lors des changements rapides de paramètres.
