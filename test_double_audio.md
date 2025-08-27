# Test de Double Lecture Audio

## Instructions de Test

1. **Ouvrir l'application** sur iPhone 16 Plus
2. **Aller dans Paramètres** > **Voix et Lecture**
3. **Cliquer sur "Tester"** à côté d'une voix
4. **Écouter attentivement** : Y a-t-il une double lecture ?

## Points à vérifier

### ✅ Corrections Appliquées
- `reading_session_page.dart` : Remplacé `flutterTtsServiceProvider` par `audioTtsServiceProvider` (3 occurrences)
- `enhanced_modern_reader_page.dart` : Utilise déjà `audioTtsServiceProvider`
- Import ajouté : `smart_tts_service.dart` dans `reading_session_page.dart`

### 🔍 Observations sur macOS
- **Erreur keychain** : -34018 empêche le chargement de l'API key
- **Fallback actif** : flutter_tts est utilisé car Coqui échoue
- **Pas de double lecture** mais seulement flutter_tts

### 📱 Observations sur iPhone
- **API key chargée** : "✅ API key Coqui déjà configurée"
- **Pas d'erreur keychain** : iOS gère mieux le secure storage

## Diagnostics dans les Logs

Chercher ces messages :
```
[TTS] Tentative synthèse Coqui
[TTS] Échec Coqui, fallback vers flutter_tts
[TTS] Utilisation flutter_tts
```

## Solutions Possibles

### Si double lecture persiste :
1. **Vérifier les handlers d'événements** : Un bouton pourrait déclencher 2 fois
2. **Circuit breaker** : Coqui pourrait réessayer après échec
3. **Queue de background** : La synthèse différée pourrait jouer en double

### Si seulement flutter_tts :
1. **Vérifier l'API key** : Est-elle correctement chargée ?
2. **Tester la connexion** : Le serveur 168.231.112.71:8001 est-il accessible ?
3. **Vérifier les logs** : Y a-t-il des erreurs réseau ?

## Test Direct Coqui

Pour forcer uniquement Coqui (sans fallback) :
1. Modifier `smart_tts_service.dart` ligne ~113
2. Commenter : `// await _flutterTtsService.playText(...);`
3. Ajouter : `throw Exception('Force Coqui only');`
4. Hot reload et tester