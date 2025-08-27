#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour corriger les versets 1 en ajoutant un retour à la ligne après la Basmalah
"""
import json

def fix_basmalah_verses(input_file, output_file):
    """
    Ajoute des retours à la ligne après la Basmalah dans les versets 1
    """
    # Basmalah exacte comme trouvée dans le fichier (sans le BOM de la sourate 1)
    basmalah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ'
    
    # Lire le fichier JSON
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    modified_verses = []
    
    for verse in data:
        if verse.get('ayah') == 1:  # Seulement les premiers versets
            text = verse.get('textAr', '')
            
            # Vérifier si le texte contient la Basmalah suivie d'autre texte
            if text.startswith(basmalah) and len(text) > len(basmalah):
                # Extraire le texte après la Basmalah
                remaining_text = text[len(basmalah):].strip()
                
                if remaining_text:  # Il y a du texte après la Basmalah
                    # Créer le nouveau texte avec retour à la ligne
                    new_text = basmalah + '\n' + remaining_text
                    
                    print(f"Sourate {verse['surah']}:")
                    print(f"  Ancien: {text}")
                    print(f"  Nouveau: {new_text}")
                    print()
                    
                    # Modifier le verset
                    verse['textAr'] = new_text
                    modified_verses.append(verse['surah'])
    
    # Sauvegarder le fichier modifié
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"Modification terminée!")
    print(f"Sourates modifiées: {modified_verses}")
    print(f"Nombre total de versets modifiés: {len(modified_verses)}")
    
    return modified_verses

if __name__ == "__main__":
    input_file = "/Users/mac/Documents/Projet_sprit/assets/corpus/quran_full.json"
    output_file = "/Users/mac/Documents/Projet_sprit/assets/corpus/quran_full_fixed.json"
    
    print("Recherche des versets à modifier...")
    modified = fix_basmalah_verses(input_file, output_file)
    
    if modified:
        print(f"\nFichier sauvegardé: {output_file}")
        print("Vérifiez les modifications avant de remplacer le fichier original.")
    else:
        print("Aucun verset à modifier trouvé.")