# Matrice de Parité Multi-Plateforme — Mise à jour
**État actuel après audit technique approfondi**

## Changements depuis Baseline
- ✅ **Corpus trouvé** : quran_full.json (2.7MB) mais combined vide
- ❌ **TabController bug** : Crash confirmé dans settings
- ⚠️ **Web/macOS** : Dégradé vs baseline, stubs non fonctionnels

## Matrice Feature × Plateforme (Actualisée)

| Feature | iOS | Android | Web | macOS | Impact | Fix Proposé | Test Requis |
|---------|-----|---------|-----|-------|--------|-------------|-------------|
| **Navigation & État** |
| go_router | ✅ | ✅ | ✅ | ✅ | - | - | - |
| Riverpod state | ✅ | ✅ | ✅ | ✅ | - | - | - |
| Deep links | ✅ | ✅ | ⚠️ | ❌ | Moyen | URL strategy | E2E routes |
| State restoration | ✅ | ✅ | ❌ | ⚠️ | Majeur | SessionStorage Web | Persistence test |
| **UI/UX** |
| Material Design 3 | ✅ | ✅ | ✅ | ✅ | - | Unifier themes | Visual regression |
| RTL Support | ✅ | ✅ | ⚠️ | ⚠️ | Majeur | Directionality wrapper | RTL screenshots |
| Dark Mode | ✅ | ✅ | ✅ | ✅ | - | - | - |
| Responsive Layout | ⚠️ | ⚠️ | ❌ | ❌ | Critique | Breakpoints system | Multi-device |
| TabBar Controller | ❌ | ❌ | ❌ | ❌ | Critique | DefaultTabController | Widget test |
| Animations 60fps | ✅ | ✅ | ⚠️ | ✅ | Mineur | Reduce motion | Performance |
| Haptic Feedback | ✅ | ✅ | ❌ | ❌ | Mineur | Visual fallback | - |
| **Persistance** |
| Drift SQL | ✅ | ✅ | ⚠️ | ✅ | Majeur | drift_web impl | CRUD tests |
| Isar NoSQL | ✅ | ✅ | ❌ | ✅ | Critique | IndexedDB adapter | Storage test |
| Secure Storage | ✅ | ✅ | ❌ | ⚠️ | Majeur | Crypto.subtle Web | Security test |
| Session Recovery | ✅ | ✅ | ❌ | ⚠️ | Critique | localStorage fallback | Recovery test |
| **Audio/TTS** |
| TTS Français | ✅ | ✅ | ⚠️ | ✅ | Majeur | Web Speech API | Voice test |
| TTS Arabe | ⚠️ | ⚠️ | ❌ | ⚠️ | Critique | Cloud TTS API | Quality test |
| Audio Player | ✅ | ✅ | ✅ | ✅ | - | - | - |
| Background Audio | ✅ | ✅ | ❌ | ⚠️ | Mineur | Service Worker | Background test |
| Audio Queue | ✅ | ✅ | ⚠️ | ✅ | Moyen | Promise chain Web | Queue test |
| **Data & Content** |
| Corpus Local | ✅ | ✅ | ⚠️ | ✅ | Critique | Fix combined.json | Content test |
| Cache TTS | ✅ | ✅ | ❌ | ⚠️ | Majeur | Cache API Web | Cache test |
| Offline Mode | ✅ | ✅ | ❌ | ⚠️ | Majeur | PWA manifest | Offline test |
| **Services** |
| OCR MLKit | ✅ | ✅ | ❌ | ❌ | Mineur | Tesseract.js | OCR test |
| PDF Rendering | ✅ | ✅ | ❌ | ⚠️ | Mineur | PDF.js | PDF test |
| Permissions | ✅ | ✅ | ⚠️ | ⚠️ | Majeur | Browser API | Permission test |
| File Picker | ✅ | ✅ | ✅ | ✅ | - | - | - |
| **Platform Specific** |
| Keyboard Nav | ✅ | ✅ | ❌ | ❌ | Critique | Focus management | Keyboard test |
| Mouse Support | ❌ | ❌ | ✅ | ✅ | Majeur | MouseRegion | Hover test |
| Window Resize | ❌ | ❌ | ✅ | ❌ | Majeur | LayoutBuilder | Resize test |
| Context Menus | ❌ | ❌ | ❌ | ❌ | Moyen | Custom menu | Menu test |

## Analyse Détaillée par Plateforme

### iOS ✅ (85% Complete)
**Régression** : TabController bug affecte iOS
- **Nouveaux bugs** : Settings crash
- **Fix prioritaire** : DefaultTabController wrapper
- **Tests requis** : Golden tests iOS 14-17

### Android ✅ (85% Complete)  
**Régression** : Idem iOS pour TabController
- **API Support** : 21-34 validé mais TabBar KO
- **Fix prioritaire** : Idem iOS
- **Tests requis** : Espresso UI tests

### Web ❌ (25% Complete)
**Dégradation** : Plus cassé que baseline
- **Nouveaux blockers** :
  - Responsive layout absent
  - Keyboard navigation KO
  - No mouse hover states
- **Fixes critiques** :
  ```dart
  // Responsive breakpoints
  class Breakpoints {
    static const sm = 640.0;
    static const md = 768.0;
    static const lg = 1024.0;
    static const xl = 1280.0;
  }
  ```
- **Tests** : Playwright E2E cross-browser

### macOS ⚠️ (45% Complete)
**Dégradation** : Desktop UX non implémentée
- **Missing** :
  - Window management
  - Native menus
  - Keyboard shortcuts
  - Scrollbars invisibles
- **Fixes requis** :
  ```dart
  // macOS window config
  if (Platform.isMacOS) {
    await windowManager.setMinimumSize(Size(800, 600));
    await windowManager.setTitle('Routines Spirituelles');
  }
  ```

## Tests de Parité Proposés

### Critical Path Tests
```dart
// test/parity/critical_parity_test.dart
group('Cross-platform critical features', () {
  testWidgets('TabBar has controller on all platforms', (tester) async {
    for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
      debugDefaultTargetPlatformOverride = platform;
      await tester.pumpWidget(MyApp());
      expect(find.byType(DefaultTabController), findsWidgets);
    }
  });
  
  test('Corpus loads on all platforms', () async {
    final corpus = await rootBundle.loadString('assets/corpus/quran_combined.json');
    final data = json.decode(corpus);
    expect(data, isNotEmpty);
    expect(data.first['surah'], isNotNull);
  });
});
```

### Responsive Tests
```dart
// test/parity/responsive_test.dart
testWidgets('Responsive layout adapts', (tester) async {
  for (final size in [Size(375, 812), Size(768, 1024), Size(1920, 1080)]) {
    tester.binding.window.physicalSizeTestValue = size;
    await tester.pumpWidget(MyApp());
    
    if (size.width < 768) {
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    } else {
      expect(find.byType(NavigationRail), findsOneWidget);
    }
  }
});
```

## Métriques de Parité

### Actuel
- **iOS/Android** : 85% (↓ depuis baseline 95%)
- **Web** : 25% (↓ depuis 40%)
- **macOS** : 45% (↓ depuis 60%)
- **Global** : 51% features cross-platform

### Cible v1.0
- **iOS/Android** : 100% (fix TabController)
- **Web** : 60% (responsive + keyboard)
- **macOS** : 70% (desktop UX)
- **Global** : 75% minimum

## Plan d'Action Parité

### Sprint 1 (Urgent)
1. **Fix TabController** : 2h, tous platforms
2. **Corpus combined.json** : 1j, data critique
3. **Responsive basics** : 2j, Web/Desktop

### Sprint 2 (Important)
4. **Keyboard navigation** : 2j, accessibilité
5. **Mouse/hover states** : 1j, desktop UX
6. **RTL complete** : 1j, marché arabe

### Sprint 3 (Nice to have)
7. **PWA manifest** : 1j, Web installable
8. **Native menus** : 2j, macOS pro
9. **Cloud TTS** : 3j, qualité arabe

## Risques Parité

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Isar Web impossible | Élevée | Critique | Migration vers Drift only |
| TTS Arabe qualité | Élevée | Majeur | Voix pré-enregistrées |
| Desktop adoption faible | Moyenne | Faible | Focus mobile first |
| Maintenance 4 platforms | Élevée | Majeur | CI/CD strict + tests |

## Conclusion

La parité s'est **dégradée** depuis la baseline. Actions immédiates requises :
1. Fix TabController (crash bloquant)
2. Réparer corpus combined.json
3. Implémenter responsive minimum

Sans ces fixes, l'app n'est **pas shippable** même sur mobile.