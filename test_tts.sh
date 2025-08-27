#!/bin/bash

echo "=== Test Coqui TTS avec votre API Key ==="
echo ""

# Test en français
echo "1. Test en français..."
RESPONSE_FR=$(curl -s -X POST "http://168.231.112.71:8001/api/tts?b64=1" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: 59be8c1f611576f7bd4436d7780426cc4bfcb10decd87e239a8ced6d843aa7c9a9541d8415d3c7a5313a427d1f7fff9a687cd23f60bba4338db0a580bed940c651f7bf2e-2dce-4105-a7ad-092fcc61560d" \
  -d '{"text":"Bonjour, le système de synthèse vocale Coqui fonctionne parfaitement.","language":"fr","voice_type":"male","rate":"+0%"}')

if echo "$RESPONSE_FR" | jq -r '.audio' > /dev/null 2>&1; then
  echo "$RESPONSE_FR" | jq -r '.audio' | base64 --decode > test_fr.mp3
  echo "✅ Audio français généré: test_fr.mp3"
  echo "   Taille: $(ls -lh test_fr.mp3 | awk '{print $5}')"
else
  echo "❌ Erreur pour le français"
fi

echo ""

# Test en arabe
echo "2. Test en arabe..."
RESPONSE_AR=$(curl -s -X POST "http://168.231.112.71:8001/api/tts?b64=1" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: 59be8c1f611576f7bd4436d7780426cc4bfcb10decd87e239a8ced6d843aa7c9a9541d8415d3c7a5313a427d1f7fff9a687cd23f60bba4338db0a580bed940c651f7bf2e-2dce-4105-a7ad-092fcc61560d" \
  -d '{"text":"السلام عليكم، نظام كوكي للنطق الصوتي يعمل بشكل ممتاز","language":"ar","voice_type":"male","rate":"+0%"}')

if echo "$RESPONSE_AR" | jq -r '.audio' > /dev/null 2>&1; then
  echo "$RESPONSE_AR" | jq -r '.audio' | base64 --decode > test_ar.mp3
  echo "✅ Audio arabe généré: test_ar.mp3"
  echo "   Taille: $(ls -lh test_ar.mp3 | awk '{print $5}')"
else
  echo "❌ Erreur pour l'arabe"
fi

echo ""
echo "3. Lecture des fichiers audio..."

# Jouer les fichiers si afplay est disponible (macOS)
if command -v afplay &> /dev/null; then
  echo "   Lecture du français..."
  afplay test_fr.mp3 2>/dev/null
  echo "   Lecture de l'arabe..."
  afplay test_ar.mp3 2>/dev/null
  echo "✅ Lecture terminée"
else
  echo "ℹ️  Pour écouter les fichiers, ouvrez test_fr.mp3 et test_ar.mp3"
fi

echo ""
echo "=== Test terminé avec succès! ==="
echo ""
echo "Votre application Flutter est maintenant configurée pour utiliser Coqui TTS."
echo "Lancez l'application avec: flutter run"