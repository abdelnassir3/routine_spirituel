# Configuration Serveurs - Projet Spiritual Routines

## Serveur Edge-TTS (Principal)
- **URL**: http://168.231.112.71:8010/api/tts
- **Port**: 8010
- **Protocole**: HTTP (HTTPS en production)
- **Timeout**: 15 secondes
- **Usage**: Synthèse vocale français/arabe général
- **Fallback**: Flutter TTS local si indisponible
- **Coût**: ~8¬/mois selon utilisation

### Endpoints Edge-TTS
```
POST /api/tts
Headers: Content-Type: application/json
Body: {
  "text": "string",
  "voice": "fr-FR-DeniseNeural|ar-SA-HamedNeural",
  "rate": "1.0",
  "pitch": "0Hz"
}
Response: audio/mpeg base64 encoded
```

## Serveur Coqui XTTS-v2 (Haute Qualité)
- **URL**: http://168.231.112.71:8001/api/xtts
- **Port**: 8001
- **Protocole**: HTTP
- **Timeout**: 15 secondes
- **Usage**: TTS haute qualité pour contenu spécialisé
- **Status**: Configuré mais Edge-TTS préféré pour stabilité

### Configuration Coqui
```
POST /api/xtts/tts_to_audio
Headers: Content-Type: application/json
Body: {
  "text": "string",
  "speaker_wav": "path/to/reference.wav",
  "language": "fr|ar"
}
```

## APIs Quran (Contenu Coranique)
- **AlQuran.cloud**: API principale pour récitations
- **Everyayah.com**: API secondaire pour récitations
- **Quran.com**: API de fallback
- **Usage**: Routage automatique pour contenu coranique détecté
- **Cache**: 30 jours pour audio Quran vs 7 jours TTS

### Détection et Routage
```
Contenu détecté comme coranique (confidence >85%)
’ APIs Quran pour récitation professionnelle
Contenu général arabe/français
’ Edge-TTS pour synthèse vocale
```

## Base de Données Cloud
- **Service**: Supabase (non configuré actuellement)
- **Usage prévu**: Synchronisation multi-devices
- **Sécurité**: RLS (Row Level Security) requis
- **Fallback**: Fonctionnement offline complet avec Drift/Isar

## Cache et Stockage Local
- **Cache TTS**: 100MB max, purge auto après 7 jours
- **Cache Quran**: 30 jours, priorité haute
- **Hit rate objectif**: 85% pour optimiser coûts serveur
- **Stockage sécurisé**: flutter_secure_storage pour tokens/clés

## Monitoring et Circuit Breaker
- **Circuit breaker**: Activation après 5 échecs consécutifs
- **Health check**: Ping périodique des VPS
- **Fallback automatique**: Edge-TTS ’ Flutter TTS ’ Mode silencieux
- **Métriques**: Latence P95, taux erreur, coût par requête

## Sécurité Serveurs
- **Production**: HTTPS obligatoire avec certificate pinning
- **Développement**: HTTP autorisé pour tests locaux
- **API Keys**: Chiffrées AES-256 dans secure storage
- **Rate limiting**: Prévention spam avec quota utilisateur
- **Logs serveur**: Pas de données personnelles utilisateur

## Configuration par Environnement
```bash
# Développement
EDGE_TTS_URL=http://168.231.112.71:8010/api/tts
COQUI_URL=http://168.231.112.71:8001/api/xtts

# Production (à configurer)
EDGE_TTS_URL=https://tts.spiritual-app.com/api/tts
COQUI_URL=https://xtts.spiritual-app.com/api/xtts
```