#!/usr/bin/env python3
"""
Script pour forcer une réimportation des données du corpus Coran
en supprimant la base de données Isar locale.
"""

import os
import shutil
from pathlib import Path

def find_and_delete_isar_files():
    """
    Trouve et supprime tous les fichiers de base de données Isar
    """
    possible_locations = [
        # iOS Simulator
        Path.home() / "Library/Developer/CoreSimulator/Devices",
        # macOS app data  
        Path.home() / "Library/Application Support/spiritual_routines",
        # Project local data
        Path.cwd() / "build",
        Path.cwd() / ".dart_tool",
    ]
    
    deleted_files = []
    
    for location in possible_locations:
        if location.exists():
            # Recherche récursive de fichiers .isar
            for isar_file in location.rglob("*.isar"):
                try:
                    print(f"🗑️  Suppression: {isar_file}")
                    isar_file.unlink()
                    deleted_files.append(str(isar_file))
                except Exception as e:
                    print(f"❌ Erreur lors de la suppression de {isar_file}: {e}")
            
            # Recherche de dossiers isar
            for isar_dir in location.rglob("isar"):
                if isar_dir.is_dir():
                    try:
                        print(f"🗑️  Suppression du dossier: {isar_dir}")
                        shutil.rmtree(isar_dir)
                        deleted_files.append(str(isar_dir))
                    except Exception as e:
                        print(f"❌ Erreur lors de la suppression de {isar_dir}: {e}")
    
    return deleted_files

if __name__ == "__main__":
    print("🔄 Forçage de la réimportation du corpus Coran")
    print("=" * 50)
    
    deleted = find_and_delete_isar_files()
    
    if deleted:
        print(f"\n✅ {len(deleted)} fichier(s)/dossier(s) supprimé(s):")
        for file in deleted:
            print(f"   - {file}")
        print("\n🎉 Cache supprimé avec succès !")
    else:
        print("\nℹ️  Aucun fichier de cache Isar trouvé.")
    
    print("\n📱 Prochaines étapes :")
    print("1. Lancez l'application : flutter run")
    print("2. L'application détectera automatiquement l'absence de données")
    print("3. Elle réimportera depuis assets/corpus/quran_full.json (modifié)")
    print("4. Les versets afficheront maintenant la Basmalah séparée !")
    
    print(f"\n🔍 Ou allez dans Paramètres > Import du corpus pour forcer manuellement")