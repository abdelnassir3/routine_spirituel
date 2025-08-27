#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script final pour corriger les versets 1 en ajoutant un retour à la ligne après la Basmalah
"""
import json

def fix_basmalah_verses(input_file, output_file):
    """
    Ajoute des retours à la ligne après la Basmalah dans les versets 1
    """
    # Lire le fichier JSON
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    modified_verses = []
    
    for verse in data:
        if verse.get('ayah') == 1:  # Seulement les premiers versets
            text = verse.get('textAr', '')
            words = text.split()
            
            # Vérifier si les 4 premiers mots forment la Basmalah
            if len(words) >= 5:  # Au moins 5 mots (Basmalah + autre chose)
                potential_basmalah = ' '.join(words[:4])
                # Vérifier si c'est bien la Basmalah
                if 'بِسْمِ' in potential_basmalah and 'ٱللَّهِ' in potential_basmalah and 'ٱلرَّحِيمِ' in potential_basmalah:
                    remaining_words = words[4:]
                    if remaining_words:  # Il y a des mots après la Basmalah
                        # Créer le nouveau texte avec retour à la ligne
                        new_text = potential_basmalah + '\n' + ' '.join(remaining_words)
                        
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