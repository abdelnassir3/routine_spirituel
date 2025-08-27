# Fonctionnalité : Ajout de Versets du Coran

## Vue d'ensemble

Cette fonctionnalité permet aux utilisateurs d'ajouter des versets du Coran dans l'éditeur de contenu de l'application. Elle offre une interface intuitive pour sélectionner des versets selon différents modes.

## Modes de sélection disponibles

### 1. Verset unique
- Sélectionnez une sourate spécifique
- Entrez le numéro du verset désiré
- Exemple : Sourate 2, Verset 255 (Ayat al-Kursi)

### 2. Plage de versets
- Sélectionnez une sourate
- Définissez un verset de début et un verset de fin
- Exemple : Sourate 1, Versets 1-7 (Al-Fatiha complète)

### 3. Versets mixtes
- Permet de sélectionner des versets de différentes sourates
- Format : `sourate:verset` ou `sourate:début-fin`
- Exemples : 
  - `2:255` (un seul verset)
  - `112:1-4` (plage de versets)
  - `2:255, 112:1-4, 1:1-7` (combinaison)

### 4. Sourate complète
- Sélectionnez une ou plusieurs sourates entières
- Tous les versets de la sourate seront ajoutés

## Utilisation dans l'application

### Accès à la fonctionnalité

1. Ouvrez l'éditeur de contenu d'une tâche
2. Sélectionnez "Versets Coran" parmi les sources disponibles
3. Le widget `QuranVerseSelector` s'affiche

### Étapes pour ajouter des versets

1. **Choisir le mode** : Cliquez sur l'un des 4 chips de sélection
2. **Configurer la sélection** : 
   - Pour verset unique/plage : utilisez les dropdowns et champs texte
   - Pour versets mixtes : entrez les références au format requis
   - Pour sourate complète : cochez les sourates désirées dans la liste
3. **Ajouter** : Cliquez sur "Ajouter les versets"
4. **Résultat** : Les versets sont automatiquement ajoutés dans les champs de texte

## Architecture technique

### Composants principaux

#### QuranVerseSelector
- Widget principal pour la sélection des versets
- Gère les 4 modes de sélection
- Communique avec `QuranCorpusService` pour récupérer les versets

#### QuranCorpusService
- Service singleton pour accéder au corpus Coran
- Charge les données depuis `assets/corpus/quran_full.json`
- Fournit des méthodes pour récupérer des versets par référence

#### ContentEditorPage
- Intègre le `QuranVerseSelector` comme source de contenu
- Sauvegarde les versets sélectionnés dans la base de données

### Structure des données

#### Corpus Coran (`quran_full.json`)
```json
[
  {
    "surah": 1,
    "ayah": 1,
    "textAr": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
    "textFr": "Au nom d'Allah, le Tout Miséricordieux, le Très Miséricordieux."
  }
]
```

#### Métadonnées des sourates (`surahs_metadata.json`)
```json
{
  "number": 1,
  "name": "سُورَةُ ٱلْفَاتِحَةِ",
  "frenchName": "Al-Fatiha (L'ouverture)",
  "numberOfAyahs": 7,
  "revelationType": "Meccan"
}
```

## Avantages de la fonctionnalité

1. **Flexibilité** : 4 modes différents pour s'adapter à tous les besoins
2. **Simplicité** : Interface intuitive avec feedback visuel
3. **Performance** : Corpus stocké localement, pas besoin de connexion
4. **Bilingue** : Support français et arabe
5. **Précision** : 6236 versets disponibles avec traduction française

## Tests

Le widget est testé via `test/quran_verse_selector_test.dart` qui vérifie :
- L'affichage des 4 modes de sélection
- Le changement de mode
- La présence du bouton d'ajout

## Améliorations futures possibles

1. **Recherche** : Ajouter une barre de recherche pour trouver des versets par mots-clés
2. **Favoris** : Permettre de marquer des versets/sourates favoris
3. **Thèmes** : Grouper les versets par thèmes (patience, gratitude, etc.)
4. **Audio** : Intégration de récitations audio
5. **Tafsir** : Ajouter des explications/commentaires des versets