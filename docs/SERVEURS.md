# Configuration Serveurs - Projet Spiritual Routines

## Serveur Edge-TTS (Principal)
- **URL**: http://168.231.112.71:8010/api/tts
- **Port**: 8010
- **Protocole**: HTTP (HTTPS en production)
- **Timeout**: 15 secondes
- **Usage**: Synth�se vocale fran�ais/arabe g�n�ral
- **Fallback**: Flutter TTS local si indisponible
- **Co�t**: ~8�/mois selon utilisation

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

## Serveur Coqui XTTS-v2 (Haute Qualit�)
- **URL**: http://168.231.112.71:8001/api/xtts
- **Port**: 8001
- **Protocole**: HTTP
- **Timeout**: 15 secondes
- **Usage**: TTS haute qualit� pour contenu sp�cialis�
- **Status**: Configur� mais Edge-TTS pr�f�r� pour stabilit�

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
- **AlQuran.cloud**: API principale pour r�citations
- **Everyayah.com**: API secondaire pour r�citations
- **Quran.com**: API de fallback
- **Usage**: Routage automatique pour contenu coranique d�tect�
- **Cache**: 30 jours pour audio Quran vs 7 jours TTS

### D�tection et Routage
```
Contenu d�tect� comme coranique (confidence >85%)
� APIs Quran pour r�citation professionnelle
Contenu g�n�ral arabe/fran�ais
� Edge-TTS pour synth�se vocale
```

## Base de Donn�es Cloud
- **Service**: Supabase (non configur� actuellement)
- **Usage pr�vu**: Synchronisation multi-devices
- **S�curit�**: RLS (Row Level Security) requis
- **Fallback**: Fonctionnement offline complet avec Drift/Isar

## Cache et Stockage Local
- **Cache TTS**: 100MB max, purge auto apr�s 7 jours
- **Cache Quran**: 30 jours, priorit� haute
- **Hit rate objectif**: 85% pour optimiser co�ts serveur
- **Stockage s�curis�**: flutter_secure_storage pour tokens/cl�s

## Monitoring et Circuit Breaker
- **Circuit breaker**: Activation apr�s 5 �checs cons�cutifs
- **Health check**: Ping p�riodique des VPS
- **Fallback automatique**: Edge-TTS � Flutter TTS � Mode silencieux
- **M�triques**: Latence P95, taux erreur, co�t par requ�te

## S�curit� Serveurs
- **Production**: HTTPS obligatoire avec certificate pinning
- **D�veloppement**: HTTP autoris� pour tests locaux
- **API Keys**: Chiffr�es AES-256 dans secure storage
- **Rate limiting**: Pr�vention spam avec quota utilisateur
- **Logs serveur**: Pas de donn�es personnelles utilisateur

## Configuration par Environnement
```bash
# D�veloppement
EDGE_TTS_URL=http://168.231.112.71:8010/api/tts
COQUI_URL=http://168.231.112.71:8001/api/xtts

# Production (� configurer)
EDGE_TTS_URL=https://tts.spiritual-app.com/api/tts
COQUI_URL=https://xtts.spiritual-app.com/api/xtts
```