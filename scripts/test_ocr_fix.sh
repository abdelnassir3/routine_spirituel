#!/bin/bash

echo "🔧 Test des corrections OCR pour iOS"
echo "======================================"

# Vérifier que Flutter est prêt
echo "📱 Vérification de la configuration Flutter..."
flutter doctor --verbose | grep -E "(iOS toolchain|Xcode)"

# Lancer l'app sur iPhone 16 Plus
echo ""
echo "🚀 Lancement de l'app sur iPhone 16 Plus..."
echo "   1. L'app va se lancer automatiquement"
echo "   2. Naviguez vers l'éditeur de contenu"
echo "   3. Appuyez sur 'Image OCR' sous 'Source du contenu'"
echo "   4. Cliquez sur 'Importer Image'"
echo "   5. Vous devriez maintenant voir une boîte de dialogue avec 'Caméra' et 'Galerie'"
echo ""

# Instructions pour le test
echo "✅ Instructions de test :"
echo "   • Si la boîte de dialogue 'Choisir une source' apparaît → SUCCÈS !"
echo "   • Si vous pouvez sélectionner Galerie et accéder aux photos → SUCCÈS !"
echo "   • Si la page se fige encore → Problème persistant"
echo ""
echo "🎯 Objectifs du test :"
echo "   ✓ Pas de gel de l'interface"
echo "   ✓ Accès natif aux photos iOS"
echo "   ✓ Dialogue de choix source/galerie"
echo "   ✓ Fonctionnement OCR sur images sélectionnées"
echo ""

flutter run -d "iPhone 16 Plus" --verbose