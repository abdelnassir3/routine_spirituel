#!/bin/bash

echo "📱 Configuration des images de test pour OCR"

# Créer des images de test depuis les HTML
cd /Users/mac/Documents/Projet_sprit/assets/test_images

# Générer les captures d'écran
echo "📸 Génération des images de test..."

# Ouvrir et capturer le texte français
open test_ocr_french.html
sleep 2
screencapture -x -t png test_french_ocr.png

# Ouvrir et capturer le texte arabe  
open test_ocr_arabic.html
sleep 2
screencapture -x -t png test_arabic_ocr.png

echo "✅ Images de test créées !"
echo ""
echo "🔄 Pour importer dans le simulateur iOS :"
echo "1. Assurez-vous que le simulateur est ouvert"
echo "2. Ouvrez l'app Photos dans le simulateur"
echo "3. Glissez-déposez les fichiers .png depuis le Finder"
echo ""
echo "📍 Emplacement des images :"
echo "   $(pwd)"
echo ""
echo "🚀 Dans votre app Flutter :"
echo "1. Allez dans l'éditeur de contenu"
echo "2. Appuyez sur le bouton + (FloatingActionButton)"
echo "3. Sélectionnez 'Importer depuis une image'"
echo "4. Choisissez une image depuis la galerie"