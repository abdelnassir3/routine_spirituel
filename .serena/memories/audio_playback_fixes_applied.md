# Audio Playback Fixes Applied - Web Platform

## Problem Statement
"Écouter" and "Mains libres" buttons in reading_session_page.dart don't work on Flutter Web. Error: "Unexpected null value" in UserSettings retrieval.

## Fixes Applied

### 1. drift_web_stub.dart - Task Progress Table
**Problem**: Missing task_progress table caused cascade failures
**Fix**: Added complete table definition and field mappings
```dart
'task_progress': [],
// Added to _createRecordPositional and _createRecordWithColumns
```

### 2. user_settings_service.dart - Null Safety
**Problem**: _getOrCreate() method could return null causing crashes
**Fix**: Added fallback default UserSettingsRow instance
```dart
// Return default instance if database fails (web stub case)
return UserSettingsRow(
  id: _defaultId,
  userId: null,
  language: 'fr',
  rtlPref: false,
  fontPrefs: '{}',
  ttsVoice: null,
  speed: 0.9,
  haptics: true,
  notifications: true,
);
```

### 3. tts_web.dart - Web Speech API
**Problem**: Poor Web Speech API initialization and voice loading
**Fix**: Enhanced initialization with voice loading and event listeners
```dart
// Force load voices on initialization
_synth!.getVoices();
// Add voices changed listener
html.window.addEventListener('voiceschanged', (event) => {...});
```

## Remaining Issue
Still getting "Unexpected null value" when clicking audio buttons. Need to investigate actual UserSettings table schema mapping in drift_web_stub.dart.

## Test Results
App runs without crashes but audio still not playing due to remaining null error in settings query.