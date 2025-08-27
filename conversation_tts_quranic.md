# Guide Complet - Entraînement TTS Coqui/XTTS-v2 pour Récitation Coranique

## Question Initiale
**Comment je puisse entraîner TTS Coqui que j'ai installé dans mon serveur VPS pour avoir différentes voix ?**

## Partie 1 : Guide Général pour Coqui TTS

### 1. Fine-tuning d'un modèle existant (Recommandé pour débuter)

C'est l'approche la plus simple et rapide :

```bash
# Installer Coqui TTS si ce n'est pas déjà fait
pip install TTS

# Télécharger un modèle pré-entraîné comme base
tts --list_models
```

#### Préparer vos données audio
- **Format requis** : WAV mono, 22050 Hz ou 16000 Hz
- **Durée** : Au minimum 30 minutes d'audio de qualité
- **Transcriptions** : Fichier texte avec transcriptions exactes

Structure des fichiers :
```
dataset/
├── wavs/
│   ├── audio_001.wav
│   ├── audio_002.wav
│   └── ...
└── metadata.csv
```

Le `metadata.csv` doit contenir :
```
audio_001|Texte de l'audio 001
audio_002|Texte de l'audio 002
```

### 2. Utiliser XTTS pour le clonage de voix

XTTS permet de cloner une voix avec seulement quelques secondes d'audio :

```python
from TTS.api import TTS

# Initialiser XTTS
tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2")

# Cloner une voix
tts.tts_to_file(
    text="Votre texte ici",
    file_path="output.wav",
    speaker_wav="chemin/vers/echantillon_voix.wav",
    language="fr"
)
```

### 3. Entraînement complet avec VITS

Pour un contrôle total, créez un fichier de configuration :

```python
# config.json pour VITS
{
    "model": "vits",
    "run_name": "ma_voix_custom",
    "dataset": {
        "name": "ljspeech",
        "path": "/chemin/vers/dataset/",
        "meta_file_train": "metadata.csv",
        "language": "fr"
    },
    "audio": {
        "sample_rate": 22050,
        "max_wav_value": 32768.0,
        "num_mels": 80,
        "num_freq": 1025
    },
    "training": {
        "epochs": 1000,
        "batch_size": 16,
        "eval_batch_size": 8,
        "learning_rate": 0.0002
    }
}
```

Lancer l'entraînement :
```bash
python TTS/bin/train_tts.py --config_path config.json
```

### 4. YourTTS pour multi-locuteurs

Pour entraîner un modèle avec plusieurs voix :

```bash
# Structure pour multi-locuteurs
dataset/
├── speaker1/
│   ├── wavs/
│   └── metadata.csv
├── speaker2/
│   ├── wavs/
│   └── metadata.csv
└── speakers.json
```

### 5. Optimisation pour VPS

Sur un VPS avec ressources limitées :

```python
# Réduire la taille du batch
"batch_size": 4,

# Utiliser mixed precision
"mixed_precision": true,

# Gradient accumulation
"grad_accum_steps": 4,

# Checkpoint fréquent
"save_step": 500
```

### Commandes utiles

```bash
# Monitoring de l'entraînement
tensorboard --logdir=output/logs

# Tester le modèle
tts --model_path checkpoint.pth \
    --config_path config.json \
    --text "Test de ma nouvelle voix" \
    --out_path test.wav

# Convertir en format optimisé
python TTS/bin/convert_model.py \
    --model_path best_model.pth \
    --output_path model_optimized.pth
```

### Conseils pratiques

1. **Qualité audio** : Utilisez des enregistrements sans bruit de fond
2. **Cohérence** : Gardez le même ton et rythme dans les enregistrements
3. **GPU** : Si possible, utilisez un VPS avec GPU (réduction du temps d'entraînement de 10x)
4. **Sauvegarde** : Faites des checkpoints réguliers en cas d'interruption

---

## Partie 2 : XTTS-v2 Installé et Fonctionnel

### 1. Clonage rapide de voix avec XTTS-v2

XTTS-v2 excelle dans le clonage de voix avec peu de données. Voici comment créer plusieurs voix :

#### Méthode simple - Clonage direct :

```python
import torch
from TTS.api import TTS

# Charger XTTS-v2
device = "cuda" if torch.cuda.is_available() else "cpu"
tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2").to(device)

# Créer différentes voix
voices = {
    "voix1": "samples/personne1.wav",
    "voix2": "samples/personne2.wav",
    "voix3": "samples/personne3.wav"
}

# Générer avec différentes voix
for voice_name, voice_path in voices.items():
    tts.tts_to_file(
        text="Bonjour, ceci est un test de ma voix",
        speaker_wav=voice_path,
        language="fr",
        file_path=f"output_{voice_name}.wav"
    )
```

### 2. Préparer vos échantillons de voix

Pour de meilleurs résultats avec XTTS-v2 :

```bash
# Structure recommandée
voix_samples/
├── homme_jeune/
│   ├── sample_1.wav  # 6-15 secondes
│   ├── sample_2.wav
│   └── sample_3.wav
├── femme_senior/
│   └── sample.wav
└── voix_neutre/
    └── sample.wav
```

#### Script de préparation audio :
```python
import torchaudio
import torch

def prepare_voice_sample(input_path, output_path):
    """Prépare un échantillon pour XTTS-v2"""
    
    # Charger l'audio
    waveform, sample_rate = torchaudio.load(input_path)
    
    # Convertir en mono si nécessaire
    if waveform.shape[0] > 1:
        waveform = torch.mean(waveform, dim=0, keepdim=True)
    
    # Resampler à 22050 Hz (recommandé pour XTTS-v2)
    if sample_rate != 22050:
        resampler = torchaudio.transforms.Resample(sample_rate, 22050)
        waveform = resampler(waveform)
    
    # Normaliser
    waveform = waveform / waveform.abs().max()
    
    # Sauvegarder
    torchaudio.save(output_path, waveform, 22050)
    
# Utilisation
prepare_voice_sample("raw_voice.wav", "prepared_voice.wav")
```

### 3. Fine-tuning XTTS-v2 (Avancé)

Pour adapter XTTS-v2 à une voix spécifique :

```python
# config_ft.json pour fine-tuning
{
    "output_path": "output/xtts_ft/",
    "model_args": {
        "gpt_model_path": "path/to/xtts_v2/model.pth",
        "speaker_wav": "path/to/target_voice/",
        "language": "fr"
    },
    "dataset": {
        "path": "datasets/ma_voix/",
        "meta_file": "metadata.csv"
    },
    "train_params": {
        "batch_size": 2,  # Petit pour VPS
        "epochs": 50,
        "learning_rate": 5e-6,
        "gradient_accumulation_steps": 8
    }
}
```

Script de fine-tuning :
```python
from TTS.tts.configs.xtts_config import XttsConfig
from TTS.tts.models.xtts import Xtts

# Charger la config
config = XttsConfig()
config.load_json("config_ft.json")

# Initialiser le modèle
model = Xtts.init_from_config(config)
model.load_checkpoint(config, checkpoint_path="xtts_v2.pth")

# Fine-tuning
model.train()
# ... code d'entraînement ...
```

### 4. API pour gérer plusieurs voix

Créez un serveur simple pour gérer vos voix :

```python
from fastapi import FastAPI, UploadFile
from TTS.api import TTS
import os
import json

app = FastAPI()
tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2")

# Base de données des voix
VOICES_DB = "voices_db.json"

def load_voices():
    if os.path.exists(VOICES_DB):
        with open(VOICES_DB, 'r') as f:
            return json.load(f)
    return {}

@app.post("/add_voice")
async def add_voice(name: str, file: UploadFile):
    """Ajouter une nouvelle voix"""
    
    # Sauvegarder l'échantillon
    voice_path = f"voices/{name}.wav"
    with open(voice_path, "wb") as f:
        f.write(await file.read())
    
    # Mettre à jour la DB
    voices = load_voices()
    voices[name] = {
        "path": voice_path,
        "created": str(datetime.now())
    }
    
    with open(VOICES_DB, 'w') as f:
        json.dump(voices, f)
    
    return {"message": f"Voix '{name}' ajoutée"}

@app.post("/synthesize")
async def synthesize(text: str, voice_name: str):
    """Synthétiser avec une voix spécifique"""
    
    voices = load_voices()
    if voice_name not in voices:
        return {"error": "Voix non trouvée"}
    
    output_path = f"output_{int(time.time())}.wav"
    
    tts.tts_to_file(
        text=text,
        speaker_wav=voices[voice_name]["path"],
        language="fr",
        file_path=output_path
    )
    
    return {"audio_path": output_path}

# Lancer avec: uvicorn app:app --host 0.0.0.0 --port 8000
```

### 5. Optimisation pour VPS

```python
# Réduire l'utilisation mémoire
import torch

class XTTSOptimized:
    def __init__(self):
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2")
        
        if self.device == "cpu":
            # Mode CPU optimisé
            torch.set_num_threads(4)
            self.tts.synthesizer.tts_model.half()  # FP16
    
    def generate(self, text, speaker_wav, language="fr"):
        with torch.no_grad():  # Économiser la mémoire
            return self.tts.tts(
                text=text,
                speaker_wav=speaker_wav,
                language=language,
                temperature=0.7,  # Contrôle de la variation
                length_penalty=1.0,
                repetition_penalty=2.0,
                top_k=50,
                top_p=0.85
            )
```

### 6. Script batch pour créer plusieurs voix

```bash
#!/bin/bash
# create_voices.sh

VOICES_DIR="./voices"
OUTPUT_DIR="./output"

for voice_file in $VOICES_DIR/*.wav; do
    voice_name=$(basename "$voice_file" .wav)
    echo "Traitement de $voice_name..."
    
    python -c "
from TTS.api import TTS
tts = TTS('tts_models/multilingual/multi-dataset/xtts_v2')
tts.tts_to_file(
    text='Test de la voix $voice_name',
    speaker_wav='$voice_file',
    language='fr',
    file_path='$OUTPUT_DIR/test_$voice_name.wav'
)
"
done
```

### Conseils pratiques pour XTTS-v2

1. **Qualité des échantillons** : 6-15 secondes d'audio clair suffisent
2. **Format** : WAV 22050Hz mono pour de meilleurs résultats
3. **Langue** : XTTS-v2 supporte le multilangue, spécifiez toujours `language="fr"`
4. **Mémoire** : Sur VPS limité, traitez une voix à la fois

---

## Partie 3 : Entraînement pour la Récitation Coranique

**Objectif** : Entraîner pour la lecture de texte coranique avec des voix de récitateurs comme Mishary Rashid, Abdul Rahman As-Sudais, Ali al-Hudhaify, Afif Mohammed Taj

### 1. Préparation des échantillons de voix des récitateurs

#### Structure des dossiers :
```bash
quranic_reciters/
├── mishary_rashid/
│   ├── sample.wav      # 10-20 secondes de récitation claire
│   └── backup/         # Plusieurs échantillons pour tests
├── sudais/
│   ├── sample.wav
│   └── backup/
├── hudhaify/
│   ├── sample.wav
│   └── backup/
└── afif_taj/
    ├── sample.wav
    └── backup/
```

#### Script pour préparer les échantillons audio :

```python
import os
import torch
import torchaudio
from pydub import AudioSegment
import numpy as np

class QuranicVoicePreparer:
    def __init__(self):
        self.target_sr = 22050  # Fréquence optimale pour XTTS-v2
        self.reciters = {
            "mishary_rashid": "Mishary Rashid Alafasy",
            "sudais": "Abdul Rahman As-Sudais", 
            "hudhaify": "Ali Al-Hudhaify",
            "afif_taj": "Afif Mohammed Taj"
        }
    
    def extract_best_segment(self, audio_path, output_path, start_sec=10, duration=15):
        """
        Extraire le meilleur segment pour XTTS-v2
        Entre 10-20 secondes de récitation claire
        """
        # Charger l'audio
        audio = AudioSegment.from_file(audio_path)
        
        # Convertir en mono et normaliser
        audio = audio.set_channels(1)
        audio = audio.set_frame_rate(self.target_sr)
        
        # Extraire le segment (éviter début/fin avec silence)
        start_ms = start_sec * 1000
        end_ms = start_ms + (duration * 1000)
        segment = audio[start_ms:end_ms]
        
        # Normaliser le volume
        segment = segment.normalize()
        
        # Réduire le bruit de fond
        segment = segment.apply_gain(-segment.dBFS + (-20.0))
        segment = segment.normalize()
        
        # Sauvegarder
        segment.export(output_path, format="wav")
        print(f"✓ Échantillon préparé: {output_path}")
        return output_path
    
    def prepare_multiple_samples(self, source_audio, reciter_name, num_samples=3):
        """
        Créer plusieurs échantillons d'un récitateur
        """
        output_dir = f"quranic_reciters/{reciter_name}"
        os.makedirs(f"{output_dir}/backup", exist_ok=True)
        
        audio = AudioSegment.from_file(source_audio)
        audio_duration = len(audio) / 1000  # en secondes
        
        samples = []
        
        # Extraire plusieurs segments
        for i in range(num_samples):
            start = min(i * 30 + 10, audio_duration - 20)
            
            if start + 15 <= audio_duration:
                output_path = f"{output_dir}/backup/sample_{i+1}.wav"
                self.extract_best_segment(
                    source_audio, 
                    output_path,
                    start_sec=start,
                    duration=15
                )
                samples.append(output_path)
        
        # Choisir le meilleur comme principal
        if samples:
            import shutil
            shutil.copy(samples[0], f"{output_dir}/sample.wav")
            
        return samples

# Utilisation
preparer = QuranicVoicePreparer()

# Préparer les échantillons pour Mishary Rashid
preparer.prepare_multiple_samples(
    "source_audio/mishary_rahman.mp3",  # Audio source
    "mishary_rashid",
    num_samples=3
)
```

### 2. Clonage de voix avec XTTS-v2

```python
from TTS.api import TTS
import torch
import json
import os

class QuranicXTTS:
    def __init__(self):
        # Charger XTTS-v2
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        print(f"Utilisation de: {self.device}")
        
        self.tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2").to(self.device)
        
        # Configuration des récitateurs
        self.reciters_config = {
            "mishary_rashid": {
                "name": "Mishary Rashid Alafasy",
                "sample": "quranic_reciters/mishary_rashid/sample.wav",
                "speed": 0.9,          # Vitesse de récitation
                "temperature": 0.5,     # Stabilité de la voix
                "top_p": 0.85,         
                "top_k": 50
            },
            "sudais": {
                "name": "Abdul Rahman As-Sudais",
                "sample": "quranic_reciters/sudais/sample.wav",
                "speed": 0.85,
                "temperature": 0.45,
                "top_p": 0.8,
                "top_k": 50
            },
            "hudhaify": {
                "name": "Ali Al-Hudhaify",
                "sample": "quranic_reciters/hudhaify/sample.wav",
                "speed": 0.95,
                "temperature": 0.5,
                "top_p": 0.85,
                "top_k": 50
            },
            "afif_taj": {
                "name": "Afif Mohammed Taj",
                "sample": "quranic_reciters/afif_taj/sample.wav", 
                "speed": 0.88,
                "temperature": 0.55,
                "top_p": 0.85,
                "top_k": 50
            }
        }
    
    def synthesize_ayah(self, text, reciter="mishary_rashid", output_path=None):
        """
        Synthétiser une ayah avec la voix d'un récitateur
        """
        if reciter not in self.reciters_config:
            print(f"❌ Récitateur '{reciter}' non disponible")
            return None
        
        config = self.reciters_config[reciter]
        print(f"🎤 Génération avec la voix de {config['name']}...")
        
        # Vérifier que l'échantillon existe
        if not os.path.exists(config['sample']):
            print(f"❌ Échantillon manquant: {config['sample']}")
            return None
        
        # Générer l'audio
        try:
            if output_path:
                self.tts.tts_to_file(
                    text=text,
                    speaker_wav=config['sample'],
                    language="ar",  # Arabe
                    file_path=output_path,
                    speed=config['speed'],
                    temperature=config['temperature'],
                    top_p=config['top_p'],
                    top_k=config['top_k']
                )
                print(f"✅ Audio sauvegardé: {output_path}")
                return output_path
            else:
                wav = self.tts.tts(
                    text=text,
                    speaker_wav=config['sample'],
                    language="ar",
                    speed=config['speed'],
                    temperature=config['temperature'],
                    top_p=config['top_p'],
                    top_k=config['top_k']
                )
                return wav
                
        except Exception as e:
            print(f"❌ Erreur: {e}")
            return None
    
    def batch_synthesize(self, ayat_list, reciter="mishary_rashid"):
        """
        Synthétiser plusieurs ayat
        """
        output_dir = f"output/{reciter}"
        os.makedirs(output_dir, exist_ok=True)
        
        results = []
        for i, ayah in enumerate(ayat_list, 1):
            output_path = f"{output_dir}/ayah_{i:03d}.wav"
            result = self.synthesize_ayah(ayah, reciter, output_path)
            results.append(result)
            
        return results

# Utilisation
quranic_tts = QuranicXTTS()

# Test avec Sourate Al-Fatiha
ayat_fatiha = [
    "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
    "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
    "الرَّحْمَٰنِ الرَّحِيمِ",
    "مَالِكِ يَوْمِ الدِّينِ",
    "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",
    "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ",
    "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ"
]

# Générer avec différents récitateurs
for reciter in ["mishary_rashid", "sudais", "hudhaify", "afif_taj"]:
    print(f"\n📖 Génération avec {reciter}...")
    quranic_tts.batch_synthesize(ayat_fatiha, reciter)
```

### 3. Optimisation pour VPS (ressources limitées)

```python
import gc
import torch

class OptimizedQuranicTTS:
    def __init__(self, low_memory=True):
        self.low_memory = low_memory
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        
        if low_memory and self.device == "cpu":
            # Mode économie de mémoire pour VPS
            torch.set_num_threads(2)
            torch.set_grad_enabled(False)
        
        # Charger le modèle une seule fois
        self.tts = None
        self.load_model()
    
    def load_model(self):
        """Charger le modèle avec optimisations"""
        if self.tts is None:
            print("⏳ Chargement du modèle XTTS-v2...")
            self.tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2")
            
            if self.low_memory:
                # Utiliser FP16 pour économiser la mémoire
                if hasattr(self.tts.synthesizer.tts_model, 'half'):
                    self.tts.synthesizer.tts_model.half()
                    
            self.tts.to(self.device)
            print("✅ Modèle chargé")
    
    def unload_model(self):
        """Libérer la mémoire"""
        if self.tts:
            del self.tts
            self.tts = None
            gc.collect()
            if self.device == "cuda":
                torch.cuda.empty_cache()
    
    def synthesize_with_memory_management(self, text, speaker_wav, output_path):
        """
        Synthèse avec gestion de la mémoire
        """
        try:
            # S'assurer que le modèle est chargé
            if self.tts is None:
                self.load_model()
            
            # Synthétiser
            with torch.no_grad():
                self.tts.tts_to_file(
                    text=text,
                    speaker_wav=speaker_wav,
                    language="ar",
                    file_path=output_path,
                    speed=0.9
                )
            
            # Nettoyer la mémoire après chaque génération si nécessaire
            if self.low_memory:
                gc.collect()
                
            return True
            
        except Exception as e:
            print(f"Erreur: {e}")
            return False
```

### 4. Script de déploiement simple

```bash
#!/bin/bash
# deploy_quranic_tts.sh

# Créer la structure des dossiers
mkdir -p quranic_reciters/{mishary_rashid,sudais,hudhaify,afif_taj}
mkdir -p output
mkdir -p source_audio

# Script Python pour tester
cat > test_quranic_tts.py << 'EOF'
from TTS.api import TTS
import sys

# Test simple
tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2")

# Texte de test (Bismillah)
text = "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"

# Récitateur par défaut (vous devez avoir l'échantillon)
speaker_wav = sys.argv[1] if len(sys.argv) > 1 else "quranic_reciters/mishary_rashid/sample.wav"

print(f"Test avec: {speaker_wav}")

tts.tts_to_file(
    text=text,
    speaker_wav=speaker_wav,
    language="ar",
    file_path="test_output.wav"
)

print("✅ Test terminé: test_output.wav")
EOF

# Lancer le test
python test_quranic_tts.py
```

### 5. Interface Web simple (FastAPI)

```python
# api_quranic.py
from fastapi import FastAPI, HTTPException, File, UploadFile
from fastapi.responses import FileResponse
from pydantic import BaseModel
import os

app = FastAPI(title="Quranic TTS API")

# Initialiser une fois au démarrage
from quranic_xtts import QuranicXTTS
tts_engine = QuranicXTTS()

class RecitationRequest(BaseModel):
    text: str
    reciter: str = "mishary_rashid"

@app.post("/recite/")
async def create_recitation(request: RecitationRequest):
    """Créer une récitation"""
    
    output_file = f"output/recitation_{hash(request.text)}_{request.reciter}.wav"
    
    try:
        result = tts_engine.synthesize_ayah(
            text=request.text,
            reciter=request.reciter,
            output_path=output_file
        )
        
        if result:
            return {
                "status": "success",
                "file": output_file,
                "reciter": request.reciter
            }
        else:
            raise HTTPException(status_code=500, detail="Échec de la génération")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/audio/{filename}")
async def get_audio(filename: str):
    """Récupérer un fichier audio"""
    file_path = f"output/{filename}"
    if os.path.exists(file_path):
        return FileResponse(file_path, media_type="audio/wav")
    raise HTTPException(status_code=404, detail="Fichier non trouvé")

@app.post("/upload_sample/")
async def upload_reciter_sample(
    reciter: str,
    file: UploadFile = File(...)
):
    """Uploader un échantillon de récitateur"""
    
    # Sauvegarder l'échantillon
    save_path = f"quranic_reciters/{reciter}/sample.wav"
    os.makedirs(os.path.dirname(save_path), exist_ok=True)
    
    with open(save_path, "wb") as f:
        content = await file.read()
        f.write(content)
    
    return {"status": "success", "path": save_path}

# Lancer avec:
# uvicorn api_quranic:app --host 0.0.0.0 --port 8000 --workers 1
```

## Notes importantes finales

1. **Échantillons** : 10-20 secondes de récitation claire suffisent pour XTTS-v2
2. **Format** : WAV 22050Hz mono recommandé
3. **Mémoire** : ~2-4GB RAM nécessaire
4. **CPU vs GPU** : GPU 10x plus rapide, mais fonctionne sur CPU
5. **Qualité** : Dépend fortement de la qualité de l'échantillon source
6. **Respect du tajweed** : Les règles de récitation sont cruciales
7. **Légalité** : Assurez-vous d'avoir les droits pour utiliser les enregistrements

---

*Document généré à partir de la conversation sur l'entraînement de Coqui TTS/XTTS-v2 pour différentes voix et spécifiquement pour la récitation coranique.*