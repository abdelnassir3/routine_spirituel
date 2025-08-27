# 🧪 Guide de Test OCR - Solutions pour Simulateur iOS

## ⚡ Solution Immédiate

L'application a été modifiée pour contourner le problème de gel du simulateur iOS.

### 🎯 Nouvelle Fonctionnalité

Quand vous cliquez sur **"Image OCR"** puis **"Importer Image"**, vous verrez maintenant :

**🚨 Simulateur iOS détecté**
- **Sélecteur de fichiers** 📁 - Alternative qui fonctionne sur simulateur
- **Chemin manuel** ✏️ - Entrer le chemin d'une image
- **Image de test** 🖼️ - Utiliser une image pré-configurée

## 📋 Instructions de Test

### Méthode 1 : Image de Test (Recommandée)
1. Cliquez sur "Image OCR"
2. Sélectionnez **"Image de test"**
3. Choisissez "Texte français" ou "Texte arabe"
4. L'OCR s'exécutera automatiquement

### Méthode 2 : Sélecteur de Fichiers
1. Cliquez sur "Image OCR"
2. Sélectionnez **"Sélecteur de fichiers"**
3. Naviguez vers une image sur votre Mac
4. Sélectionnez l'image et testez l'OCR

### Méthode 3 : Chemin Manuel
1. Cliquez sur "Image OCR"
2. Sélectionnez **"Chemin manuel"**
3. Entrez un chemin vers une image :
   ```
   /Users/mac/Documents/Projet_sprit/assets/test_images/test_french_ocr.png
   ```

## 🖼️ Images de Test Disponibles

Dans `/Users/mac/Documents/Projet_sprit/assets/test_images/` :
- `test_french_ocr.png` - Texte français pour OCR
- `test_arabic_ocr.png` - Texte arabe pour OCR

## 🚀 Lancement du Test

```bash
flutter run -d "iPhone 16 Plus"
```

## ✅ Résultats Attendus

- ✅ Plus de gel de l'interface
- ✅ Accès aux images via méthodes alternatives
- ✅ OCR fonctionnel sur les images sélectionnées
- ✅ Texte extrait affiché dans l'éditeur

## 🔧 En Cas de Problème

Si vous rencontrez encore des problèmes :

```bash
# Nettoyage complet
flutter clean
flutter pub get
flutter run -d "iPhone 16 Plus"
```

## 📱 Test sur Appareil Réel

Pour tester sur un iPhone physique :
```bash
flutter run -d [ID_DEVICE]
```

Sur appareil réel, l'accès natif aux photos fonctionnera normalement.

---

**Note** : Cette solution est spécialement conçue pour contourner les limitations du simulateur iOS. Sur un appareil réel, l'interface native iOS pour les photos fonctionnera parfaitement.