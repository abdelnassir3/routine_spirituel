
------------------------------------------------------
## Donnee de connexion VPS
-------------------------------------------------------

ssh user@206.168.83.150

Mot de passe : nassir319900M@


python3 -m venv ~/xtts_ft
source ~/xtts_ft/bin/activate


# Lancer la démo de fine-tuning XTTS

python -m TTS.demos.xtts_ft_demo.xtts_demo --port 7862


# libère le port si besoin
fuser -k 7862/tcp 2>/dev/null || true

# lance dans tmux pour ne plus perdre la session
tmux new -s xtts -d 'python -m TTS.demos.xtts_ft_demo.xtts_demo --port 7862 2>&1 | tee -a ~/xtts_demo.log'
tmux attach -t xtts

# Dans Output path, mets un dossier persistant,

/home/user/xtts_project/outputs/afif_xtts_ft/




python3.11 -m venv ~/xtts311
source ~/xtts311/bin/activate


python3.10 -m venv ~/xtts310
source ~/xtts310/bin/activate



