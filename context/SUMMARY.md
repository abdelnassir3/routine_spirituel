# Projet_sprit - Résumé Compact

## CONTEXTE
• App Flutter "Spiritual Routines (RISAQ)" - routines spirituelles bilingues FR/AR
• Mission: Moderniser pratiques spirituelles avec tech mobile + IA
• Cible: Pratiquants musulmans francophones/arabophones
• Différenciation: Audio hybride, RTL/LTR natif, offline-first, sécurité OWASP Grade B

## ARCHITECTURE & STACK
• Flutter 3.x + Riverpod 2.5+ + Drift/Isar + just_audio + audio_service
• TTS hybride: Edge-TTS (primaire) + Coqui XTTS-v2 + Flutter TTS (fallback)
• Détection contenu coranique >85% → APIs Quran vs synthèse générale
• Material Design 3 unifié, 28+ services modulaires
• Persistance: Drift (SQL) + Isar (NoSQL) + cache sécurisé

## CONTRAINTES CRITIQUES
• Performance: latence UI <200ms, TTI <2s, mémoire <150MB, bundle <35MB
• Sécurité: AES-256, auth biométrique + PIN, HTTPS + certificate pinning
• Multilingue: FR+AR RTL/LTR, polices Noto Naskh Arabic + Inter
• Support: iOS/Android 95%, macOS 60%, Web 40%

## SERVEURS & PARAMÈTRES
• VPS Edge-TTS: http://168.231.112.71:8010/api/tts (timeout 15s, 8€/mois)
• VPS Coqui: http://168.231.112.71:8001/api/xtts (timeout 15s)
• APIs Quran: AlQuran.cloud + Everyayah.com + Quran.com
• Cache: hit rate 85%, 100MB max, purge auto 7j
• Corpus: assets/corpus/quran_full.json (6236 versets)

## TODO CRITIQUE
1. Fix TabController crash modern_settings_page.dart
2. Import corpus Coran (quran_combined.json vide)
3. Consolidation 40% code dupliqué (3 thèmes, 6 readers)
4. Configuration Supabase + RLS
5. Tests coverage 60% minimum

KPI: Rétention D30 >50%, session >10min, crash <0.1%