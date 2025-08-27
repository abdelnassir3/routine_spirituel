# Matrice de Parité Multi-Plateforme — Baseline
**État actuel de la compatibilité cross-platform**

## Légende
- ✅ **OK** : Fonctionnalité complètement implémentée et testée
- ⚠️ **Partiel** : Implémentation incomplète ou non testée
- ❌ **Manquant** : Non implémenté pour cette plateforme
- 🔧 **En cours** : Développement actif

## Matrice Feature × Plateforme

| Feature | iOS | Android | Web | macOS | Windows | Linux | Impact UX | Contournement |
|---------|-----|---------|-----|-------|---------|-------|-----------|---------------|
| **Core Features** |
| Navigation (go_router) | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | Critique | - |
| State Management (Riverpod) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | - | - |
| Localisation FR/AR | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Majeur | - |
| RTL Support | ✅ | ✅ | ⚠️ | ⚠️ | ❌ | ❌ | Majeur | CSS custom pour Web |
| **Persistance** |
| Drift (SQL) | ✅ | ✅ | ⚠️ | ✅ | ⚠️ | ⚠️ | Critique | drift_web.dart stub |
| Isar (NoSQL) | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | Majeur | isar_web_stub.dart fallback |
| Secure Storage | ✅ | ✅ | ⚠️ | ⚠️ | ❌ | ❌ | Mineur | LocalStorage pour Web |
| Session Recovery | ✅ | ✅ | ⚠️ | ⚠️ | ❌ | ❌ | Majeur | SharedPreferences fallback |
| **Audio/TTS** |
| TTS Français | ✅ | ✅ | ⚠️ | ✅ | ❌ | ❌ | Critique | Web Speech API |
| TTS Arabe | ⚠️ | ⚠️ | ❌ | ⚠️ | ❌ | ❌ | Critique | Cloud TTS fallback |
| Audio Player | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | Majeur | HTML5 Audio pour Web |
| Background Audio | ✅ | ✅ | ❌ | ⚠️ | ❌ | ❌ | Mineur | Service Worker Web |
| **UI/UX** |
| Material Design 3 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | - | - |
| Dark Mode | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Mineur | - |
| Animations 60fps | ✅ | ✅ | ⚠️ | ✅ | ⚠️ | ⚠️ | Mineur | Reduce motion option |
| Haptic Feedback | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | Mineur | Visual feedback |
| Responsive Layout | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Majeur | - |
| **Services** |
| OCR (MLKit) | ✅ | ✅ | ❌ | ⚠️ | ❌ | ❌ | Mineur | ocr_macos_vision.dart |
| PDF Rendering | ✅ | ✅ | ❌ | ⚠️ | ❌ | ❌ | Mineur | pdf_stub.dart |
| File Picker | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | Mineur | - |
| Permissions | ✅ | ✅ | ⚠️ | ⚠️ | ❌ | ❌ | Majeur | Browser API permissions |
| **Offline** |
| Corpus Local | ✅ | ✅ | ⚠️ | ✅ | ⚠️ | ⚠️ | Critique | IndexedDB pour Web |
| Cache TTS | ✅ | ✅ | ❌ | ⚠️ | ❌ | ❌ | Majeur | Cache API Web |
| Sync Queue | ✅ | ✅ | ⚠️ | ⚠️ | ❌ | ❌ | Mineur | Background Sync API |

## Analyse par Plateforme

### iOS ✅ (95% Complete)
**État** : Production-ready
- **Points forts** : Toutes features core fonctionnelles
- **Limitations** : TTS Arabe qualité variable
- **Tests** : Complets sur iPhone/iPad

### Android ✅ (95% Complete)
**État** : Production-ready
- **Points forts** : Parité complète avec iOS
- **Limitations** : TTS Arabe dépend du device
- **Tests** : API 21-34 validés

### Web ⚠️ (40% Complete)
**État** : Experimental
- **Blockers** :
  - Isar non supporté → drift_web stub only
  - TTS Arabe non disponible
  - Background audio limité
- **Contournements** :
  - content_service_web.dart implémenté
  - LocalStorage pour persistance simple
  - Web Speech API pour TTS basique

### macOS ⚠️ (60% Complete)
**État** : Beta
- **Points forts** : Drift/Isar fonctionnels
- **Limitations** :
  - OCR via Vision framework only
  - Background audio partiel
  - RTL bugs visuels

### Windows ❌ (20% Complete)
**État** : Non supporté
- **Blockers** : Pas de TTS natif, Isar non compatible
- **Plan** : Support différé v2.0

### Linux ❌ (20% Complete)
**État** : Non supporté
- **Blockers** : Idem Windows
- **Plan** : Community contribution

## Tests de Parité Proposés

### Test Suite Mobile (iOS/Android)
```dart
// test/parity/mobile_parity_test.dart
- Session persistence après kill app
- TTS bilingue avec queue
- Mode offline complet
- RTL/LTR switch dynamique
```

### Test Suite Desktop (macOS)
```dart
// test/parity/desktop_parity_test.dart
- Multi-window support
- Keyboard shortcuts
- File system access
- Native menus
```

### Test Suite Web
```dart
// test/parity/web_parity_test.dart
- PWA installation
- Service Worker caching
- IndexedDB persistence
- Responsive breakpoints
```

## Recommandations Prioritaires

### Court Terme (v1.0)
1. **Focus iOS/Android** : Garantir parité 100%
2. **Web Minimal** : Read-only avec TTS FR uniquement
3. **Tests E2E** : Couvrir parcours critiques mobile

### Moyen Terme (v1.5)
4. **Web Enhanced** : Ajouter Isar polyfill
5. **macOS Beta** : Publier TestFlight
6. **Cloud TTS** : Intégrer pour qualité arabe

### Long Terme (v2.0)
7. **Desktop Full** : Windows/Linux support
8. **PWA Complete** : Offline-first Web
9. **Sync Multi-Device** : Via Supabase

## Métriques de Succès

- **Mobile Coverage** : >95% features parité iOS/Android
- **Web Coverage** : >60% features read-only
- **Desktop Coverage** : >70% macOS, différé autres
- **Test Coverage** : >80% par plateforme supportée
- **Crash Rate** : <0.1% toutes plateformes