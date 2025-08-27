# Changelog UI/UX — Routines Spirituelles

Objectif: unifier le thème, améliorer l’accessibilité/contrastes, et peaufiner l’expérience Lecteur.

## Thème & Palettes
- Unification du thème (Material 3) et suppression du thème legacy.
- Palettes dynamiques persistées (modern, elegant, ocean) avec prévisualisation.
- Gradients pilotés par la palette (headers, FAB, CTA) et tokens `colorScheme` généralisés.
- Snackbars harmonisées (inverseSurface/onInverseSurface) pour meilleure lisibilité.

## Accessibilité & Contrastes
- Cibles tactiles ≥ 48dp (nav/back/chips filtres routines; autres cas revus).
- Headers sur dégradés: ombres de texte discrètes pour titres/sous‑titres.
- Icônes/labels secondaires: `onSurfaceVariant`; bordures: `outlineVariant`.
- Cartes (cardTheme) sur `surface`; inputs/listTiles/bottomNav alignés sur `colorScheme`.

## Navigation & Composants
- Bottom navigation: sélection icône/label et puce d’icône en `primary`.
- FAB: gradient enrichi (mix `primary`/`secondary`).
- CTA/Stats/TimeDisplay par défaut sur `primary`; fallbacks catégorie sur `theme.colorScheme.primary`.

## Lecteur (Reader)
- Contenu réel (FR/AR), affichage bilingue (FR/AR/Les deux), direction RTL/LTR.
- Numérotation/séparateurs optionnels; mode “concentration”.
- Réglages de lisibilité: taille/interligne, justification, marges latérales.
- Thèmes de lecture: Système, Sépia, Papier, Noir (OLED).
- Thèmes de lecture additionnels: Crème, Sépia doux, Papier crème+.
- Accessibilité: option "Réduire les animations" (Reader et transitions liées), persistée.
- Lecteur: mémorisation par contenu (enregistrer/effacer les réglages pour une tâche).
- Animations: stagger par verset + transition directionnelle (slide+fade) pour Précédent/Suivant.
- Navigation Précédent/Suivant opérationnelle (ordre de routine), haptique léger, bornes protégées.
- Persistance et bouton “Réinitialiser l’affichage”.

## Divers
- Nettoyage de couleurs codées (blancs/greys) au profit des tokens M3.
- Renommage de providers pour éviter collisions; suppression du fichier legacy.

---
Ce lot pose une base solide et cohérente visuellement, avec une lecture confortable et personnalisable. Les prochains incréments possibles: micro‑animations supplémentaires, thèmes de lecture additionnels, mémorisation des préférences par contenu.
