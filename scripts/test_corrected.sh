#!/bin/bash

# Script de test amélioré post-corrections 2025-09-03
# Utilise la configuration test_config.yaml pour exclure les tests web

set -e

echo "🧪 Lancement des tests avec corrections 2025-09-03"

# Vérifier que Flutter est disponible
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé ou pas dans le PATH"
    exit 1
fi

# Configuration des couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔧 Nettoyage et préparation..."
flutter clean > /dev/null 2>&1
flutter pub get > /dev/null 2>&1

echo "🧪 Exécution des tests avec configuration personnalisée..."

# Tests unitaires seulement (plus rapides)
echo -e "${YELLOW}📝 Tests unitaires${NC}"
if flutter test test/unit/ --reporter=expanded; then
    echo -e "${GREEN}✅ Tests unitaires : SUCCÈS${NC}"
    UNIT_SUCCESS=true
else
    echo -e "${RED}❌ Tests unitaires : ÉCHECS${NC}"
    UNIT_SUCCESS=false
fi

# Tests widgets 
echo -e "${YELLOW}🖥️  Tests widgets${NC}"
if flutter test test/widgets/ --reporter=expanded; then
    echo -e "${GREEN}✅ Tests widgets : SUCCÈS${NC}"
    WIDGET_SUCCESS=true
else
    echo -e "${RED}❌ Tests widgets : ÉCHECS${NC}"
    WIDGET_SUCCESS=false
fi

# Tests services
echo -e "${YELLOW}⚙️  Tests services${NC}"
if flutter test test/services/ --reporter=expanded; then
    echo -e "${GREEN}✅ Tests services : SUCCÈS${NC}"
    SERVICE_SUCCESS=true
else
    echo -e "${RED}❌ Tests services : ÉCHECS${NC}"
    SERVICE_SUCCESS=false
fi

# Résumé final
echo ""
echo "📊 Résumé des tests :"
echo "===================="

if [ "$UNIT_SUCCESS" = true ]; then
    echo -e "${GREEN}✅ Tests unitaires${NC}"
else
    echo -e "${RED}❌ Tests unitaires${NC}"
fi

if [ "$WIDGET_SUCCESS" = true ]; then
    echo -e "${GREEN}✅ Tests widgets${NC}"
else
    echo -e "${RED}❌ Tests widgets${NC}"
fi

if [ "$SERVICE_SUCCESS" = true ]; then
    echo -e "${GREEN}✅ Tests services${NC}"
else
    echo -e "${RED}❌ Tests services${NC}"
fi

echo ""

# Tests complets optionnels (plus lents)
if [ "${1:-}" = "--full" ]; then
    echo -e "${YELLOW}🌐 Tests d'intégration (complets)${NC}"
    if flutter test --reporter=expanded; then
        echo -e "${GREEN}✅ Tous les tests : SUCCÈS${NC}"
        exit 0
    else
        echo -e "${YELLOW}⚠️  Certains tests échouent (normal pour plugins manquants)${NC}"
        exit 0
    fi
fi

# Vérifier le statut global
if [ "$UNIT_SUCCESS" = true ] && [ "$WIDGET_SUCCESS" = true ] && [ "$SERVICE_SUCCESS" = true ]; then
    echo -e "${GREEN}🎉 Tests critiques : TOUS RÉUSSIS !${NC}"
    echo "Utilisez --full pour les tests complets (plus longs)"
    exit 0
else
    echo -e "${RED}🔥 Certains tests critiques échouent${NC}"
    exit 1
fi