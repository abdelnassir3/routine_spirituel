# Project Architecture Overview - Spiritual Routines

## Core Architecture
- **Framework**: Flutter 3.x with Dart 3.x, strict null safety
- **State Management**: Riverpod 2.5+ (providers, AsyncValue, ConsumerStatefulWidget)
- **Persistence**: Hybrid Drift (SQL) + Isar (NoSQL)
- **Audio**: just_audio + audio_service for background playback

## Audio Routing System
**Intelligent Content Detection**:
1. **Quranic Arabic text** (confidence >85%) → Quran recitation APIs
2. **Simple Arabic/French text** → Edge-TTS synthesis 
3. **Linked audio files** → Direct playback

**TTS Fallback Chain**:
Edge-TTS (168.231.112.71:8010) → Coqui (168.231.112.71:8001) → Flutter TTS → Silent mode

## Key Services
- **UserSettingsService**: Persists TTS preferences, display settings
- **AudioTtsService**: TTS orchestration with fallback logic
- **SessionService**: Global session state and recovery
- **QuranCorpusService**: Offline Quran corpus access

## Web Platform Stubs
- **drift_web_stub.dart**: In-memory SQL simulation for browser
- **isar_web_stub.dart**: NoSQL document simulation (temporarily disabled)
- **Web Speech API**: Browser TTS integration in tts_web.dart

## File Organization
```
lib/
├── core/           # Shared services, models, persistence
├── features/       # Domain modules (counter, reader, routines)
├── design_system/ # UI theming and components
└── l10n/          # FR/AR localization
```