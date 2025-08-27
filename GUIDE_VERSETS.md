# 📖 Guide : Comment Ajouter des Versets du Coran

## 🎯 Problème Résolu
L'ajout de versets et sourates dans les tâches a été corrigé. Voici comment procéder :

## 📱 Étapes pour Ajouter des Versets

### 1. **Ouvrir l'Éditeur de Contenu**
- Allez dans une tâche existante ou créez-en une nouvelle
- Appuyez sur "Modifier" ou l'icône d'édition

### 2. **Sélectionner la Source "Versets du Coran"**
⚠️ **IMPORTANT** : Vous devez absolument :
- Choisir l'option **"Versets du Coran"** (icône livre vert) dans les options de source
- **ET** passer à l'onglet **"Arabe"** (AR) en haut de l'écran

```
Sources disponibles :
📝 Manuel (par défaut)
📖 Versets du Coran ← CHOISIR CETTE OPTION
🖼️ OCR Image  
📄 OCR PDF
```

### 3. **Utiliser le Sélecteur de Versets**
Une fois sur l'onglet arabe avec la source "Versets du Coran" sélectionnée :
- Le sélecteur de versets apparaîtra automatiquement
- Vous pouvez sélectionner :
  - **Verset unique** : ex. Sourate 2, Verset 255
  - **Plage de versets** : ex. Sourate 112, Versets 1-4
  - **Versets multiples** : ex. 2:255, 112:1-4, 113:1-5
  - **Sourate complète** : ex. Sourate 112 entière

### 4. **Résultat Attendu**
Les versets seront automatiquement :
- ✅ **Formatés correctement** avec la Basmalah séparée sur sa propre ligne
- ✅ **Numérotés** avec des cercles (1:1, 1:2, etc.)
- ✅ **Ajoutés au texte** de votre tâche

## 🔧 Corrections Appliquées

### Modifications Techniques :
1. **ContentService amélioré** : Détection et formatage correct de la Basmalah
2. **Corpus mis à jour** : 110 sourates reformatées avec retours à la ligne
3. **Cache supprimé** : Forçage de la réimportation des nouvelles données

### Exemple de Résultat :
```
بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ

قُلْ هُوَ ٱللَّهُ أَحَدٌ {{V:1}}
ٱللَّهُ ٱلصَّمَدُ {{V:2}}
لَمْ يَلِدْ وَلَمْ يُولَدْ {{V:3}}
وَلَمْ يَكُن لَّهُۥ كُفُوًا أَحَدٌۢ {{V:4}}
```

## 🚨 Dépannage

Si ça ne marche toujours pas :

1. **Forcez une réimportation** :
   - Allez dans Paramètres > Import du corpus
   - Appuyez sur "Réimporter depuis assets"

2. **Vérifiez la configuration** :
   - Source = "Versets du Coran" 
   - Onglet = "Arabe (AR)"

3. **Relancez l'application** :
   ```bash
   flutter run
   ```

## ✅ Test de Fonctionnement

Pour vérifier que tout fonctionne :
1. Créez une nouvelle tâche
2. Sélectionnez source "Versets du Coran"
3. Passez à l'onglet "Arabe"  
4. Ajoutez la sourate 112 (Al-Ikhlas)
5. Vérifiez que la Basmalah est sur une ligne séparée

La fonctionnalité devrait maintenant être complètement opérationnelle ! 🎉