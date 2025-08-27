------------------------------------------------------
## Donnee de connexion VPS
-------------------------------------------------------

ssh root@168.231.112.71  

Mot de passe : nasir319900M@

--------------------------------------------------------
## donnee de connexion session Edge-TTS sur le port 8010
--------------------------------------------------------

# Retourner en tant que ttsuser
su - ttsuser
cd ~/tts_app

Mot de passe : Nassir@2025


# Créer l'environnement virtuel
python3 -m venv tts_env

# Activer l'environnement virtuel
source tts_env/bin/activate

# Lancer en arrière-plan
nohup uvicorn tts_server:app --host 0.0.0.0 --port 8010 --workers 2 > server.log 2>&1 &

# En tant que root
sudo nano /etc/systemd/system/tts-api.service
ttsuser@srv805134:~$ 
# Activer et démarrer le service
sudo systemctl daemon-reload
sudo systemctl enable tts-api
sudo systemctl start tts-api
sudo systemctl status tts-api


# Autoriser le port 8010
sudo ufw allow 8010/tcp
sudo ufw status


## Si tu veux le remettre plus tard (sur 8010 par ex.):
systemctl unmask edge-tts.service
systemctl enable --now edge-tts
ss -ltnp | egrep ':8001|:8010'


----------------------------------------------------------
## donnee de connexion session XTTS-Coqui sur le port 8001
----------------------------------------------------------

# ── Environnement Python
cd /root
python3 -m venv xtts_env
source xtts_env/bin/activate# ── Projet
# creer repertoire et dossier
mkdir -p /root/xtts_project/{models,cache,outputs,api,logs}
# Aller dans ce dossier
cd /root/xtts_project


# Pour lancer les services 

systemctl daemon-reload
systemctl restart xtts-api
sleep 2
systemctl status xtts-api --no-pager
journalctl -u xtts-api -n 50 --no-pager

# Vérifs
ss -ltnp | grep :8001
curl -s http://127.0.0.1:8001/health
# => doit renvoyer: {"status":"healthy","engine":"xtts-v2","threads":4}

# Pour faire des Test TTS (taille MP3 “réaliste”)

curl -X POST http://127.0.0.1:8001/api/tts \
  -F 'text=Bonjour, ceci est un test XTTS sur CPU.' \
  -o /root/xtts_project/outputs/test.mp3

ls -lh /root/xtts_project/outputs/test.mp3
file /root/xtts_project/outputs/test.mp3

# Recuperer un fichier specifique sur le serveur

scp user@206.168.83.150:~/xtts_project/outputs/bismillah.wav ~/Downloads/

# Recuperer un dossier specifiqur sur le serveur

scp -r user@206.168.83.150:~/xtts_project/outputs/fatiha ~/Downloads/

scp "/Users/mac/Documents/Son_recitateur/dossier sans titre/test1_Afif.wav" \
    root@168.231.112.71:/root/xtts_project/ref/arabic_src.wav







# 1) Health
curl http://168.231.112.71:8001/health

curl -o out.mp3 -X POST http://168.231.112.71:8001/api/tts \
  -F 'text=مرحبًا، هذا اختبار للنظام بالصوت العربي.'

curl -o out.wav -X POST http://168.231.112.71:8001/api/tts \
  -F 'text=تجربة ثانية.' \
  -F 'fmt=wav'


scp -r root@168.231.112.71:~/xtts_project/outputs ~/Downloads/


# commencer un key API sur mon serveur VPS 

curl -X POST "http://168.231.112.71:8001/api/tts » 


# Modifier tts_server.py API_KEY = "votre_cle_secrete_ici" @app.post("/api/tts") async def generate_speech(request: TTSRequest, api_key: str = Header(None)): if api_key != API_KEY: raise HTTPException(status_code=401, detail="API key invalide") # ... reste du code