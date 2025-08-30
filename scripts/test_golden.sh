#!/bin/bash
# Script pour exécuter et mettre à jour les tests golden

set -e

echo "🧪 Exécution des tests Golden..."

# Fonction pour utiliser fvm si disponible, sinon flutter standard
flutter_cmd() {
    if command -v fvm &> /dev/null && [ -f .fvm/fvm_config.json ]; then
        fvm flutter "$@"
    else
        flutter "$@"
    fi
}

case "${1:-run}" in
    "update"|"--update-goldens")
        echo "🔄 Mise à jour des goldens de référence..."
        flutter_cmd test --update-goldens test/goldens/
        echo "✅ Goldens mis à jour!"
        ;;
    "run"|"")
        echo "▶️ Exécution des tests golden..."
        flutter_cmd test test/goldens/
        echo "✅ Tests golden terminés!"
        ;;
    "clean")
        echo "🧹 Nettoyage des goldens échecs..."
        find test -name "failures" -type d -exec rm -rf {} + 2>/dev/null || true
        echo "✅ Nettoyage terminé!"
        ;;
    *)
        echo "Usage: $0 [run|update|clean]"
        echo "  run    - Exécuter les tests golden (défaut)"
        echo "  update - Mettre à jour les goldens de référence"
        echo "  clean  - Nettoyer les fichiers d'échec"
        exit 1
        ;;
esac