# PR #002: Cleanup Doublons et Orphelins

## Description
Supprime les duplications massives (3 thèmes, 6 readers, services dupliqués) et fichiers orphelins pour réduire la dette technique de 40%.

## Impact
- **Gravité**: MAJEUR - Dette technique élevée
- **Réduction code**: ~40% (estimation 15K lignes)
- **Maintenabilité**: +100%
- **Risque**: Moyen (changements étendus)

## Fichiers à Supprimer

### Thèmes Dupliqués
```bash
# À SUPPRIMER
rm lib/design_system/theme.dart              # 380 lignes - ancien système
rm lib/design_system/advanced_theme.dart     # 450 lignes - non utilisé

# À GARDER
# lib/design_system/inspired_theme.dart      # Système principal actuel
```

### Readers Dupliqués
```bash
# À SUPPRIMER
rm lib/features/reader/reader_page.dart           # Version legacy
rm lib/features/reader/modern_reader_page.dart    # Version intermédiaire
rm lib/features/reader/premium_reader_page.dart   # Expérimentation abandonnée
rm lib/features/reader/reading_session_page.dart  # Non référencé dans router
rm lib/features/reader/enhanced_modern_reader_page.dart.backup  # Backup

# À GARDER
# lib/features/reader/enhanced_modern_reader_page.dart  # Version finale
```

### Services Dupliqués
```bash
# À SUPPRIMER
rm lib/features/settings/user_settings_service.dart  # Doublon

# À GARDER  
# lib/core/services/user_settings_service.dart        # Version canonique
```

### Pages Non Utilisées
```bash
# À SUPPRIMER
rm lib/features/home/home_page.dart          # Remplacé par modern_home_page
rm lib/features/routines/routines_page.dart  # Remplacé par modern_routines_page
rm lib/features/settings/settings_page.dart  # Remplacé par modern_settings_page
rm lib/features/content/content_editor_page.dart     # Remplacé par modern version
rm lib/features/content/content_editor_page_v2.dart  # Version abandonnée
rm lib/test_home_final.dart                  # Fichier de test
rm lib/test_splash.dart                      # Fichier de test
rm lib/demo/routine_status_demo.dart         # Demo non utilisée
```

## Migrations Requises

### 1. Router Updates
```diff
// lib/app/router.dart
- import 'package:spiritual_routines/features/reader/modern_reader_page.dart';
- import 'package:spiritual_routines/features/reader/premium_reader_page.dart';
import 'package:spiritual_routines/features/reader/enhanced_modern_reader_page.dart';

// Vérifier tous les imports
```

### 2. Theme References
```diff
// Tous les fichiers utilisant l'ancien thème
- import 'package:spiritual_routines/design_system/theme.dart';
- import 'package:spiritual_routines/design_system/advanced_theme.dart';
+ import 'package:spiritual_routines/design_system/inspired_theme.dart';

- M3Theme.of(context)
+ InspiredTheme.of(context)
```

### 3. Service References
```diff
// Tous les fichiers
- import 'package:spiritual_routines/features/settings/user_settings_service.dart';
+ import 'package:spiritual_routines/core/services/user_settings_service.dart';
```

## Script de Vérification

```dart
// tool/check_orphans.dart
import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  final allDartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();
  
  final imports = <String>{};
  final files = <String>{};
  
  for (final file in allDartFiles) {
    files.add(file.path);
    final content = await file.readAsString();
    final importMatches = RegExp(r"import\s+'([^']+)'").allMatches(content);
    imports.addAll(importMatches.map((m) => m.group(1)!));
  }
  
  // Trouver les orphelins
  final orphans = files.where((f) {
    final relativePath = f.replaceFirst('lib/', '');
    return !imports.any((i) => i.endsWith(relativePath));
  });
  
  print('Fichiers orphelins trouvés: ${orphans.length}');
  orphans.forEach(print);
}
```

## Tests de Non-Régression

```dart
// test/cleanup_test.dart
void main() {
  group('No duplicate imports after cleanup', () {
    test('Only one theme system', () {
      final themeFiles = Directory('lib/design_system')
          .listSync()
          .where((f) => f.path.contains('theme'))
          .length;
      expect(themeFiles, equals(1)); // Only inspired_theme.dart
    });
    
    test('Only one reader implementation', () {
      final readers = Directory('lib/features/reader')
          .listSync()
          .where((f) => f.path.contains('reader_page'))
          .length;
      expect(readers, equals(1)); // Only enhanced_modern_reader_page.dart
    });
    
    test('No duplicate services', () {
      final userSettings = Directory('lib')
          .listSync(recursive: true)
          .where((f) => f.path.contains('user_settings_service.dart'))
          .length;
      expect(userSettings, equals(1));
    });
  });
  
  test('Router still works', () async {
    final router = AppRouter();
    expect(router.configuration.routes, isNotEmpty);
    expect(() => router.go('/reader'), returnsNormally);
  });
}
```

## CI/CD Check

```yaml
# .github/workflows/no-duplicates.yml
name: Check No Duplicates
on: [push, pull_request]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: dart tool/check_orphans.dart
      - run: |
          # Verify no multiple themes
          count=$(find lib -name "*theme.dart" | wc -l)
          if [ $count -gt 1 ]; then
            echo "Error: Multiple theme files found"
            exit 1
          fi
```

## Métriques Avant/Après

| Métrique | Avant | Après | Gain |
|----------|-------|-------|------|
| Fichiers .dart | 95+ | ~60 | -37% |
| Lignes de code | ~35K | ~21K | -40% |
| Thèmes | 3 | 1 | -67% |
| Readers | 6 | 1 | -83% |
| Services dupliqués | 2 | 0 | -100% |
| Temps build | ? | -20% | Estimé |

## Rollback Plan

```bash
# Si problème, restaurer depuis git
git checkout HEAD~1 -- lib/
git commit -m "Revert: Restore deleted files"
```

## Risques & Mitigations

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Import cassé oublié | Moyenne | Faible | flutter analyze avant commit |
| Feature cachée dans old code | Faible | Moyen | Code review approfondie |
| A/B test en cours | Faible | Élevé | Vérifier avec PM |

## Checklist

- [ ] Backup complet avant suppression
- [ ] flutter analyze sans erreurs
- [ ] flutter test tous passent
- [ ] Vérification manuelle app fonctionne
- [ ] Code review par 2 devs minimum
- [ ] Documentation mise à jour
- [ ] CI/CD passe

## Gains Attendus

1. **Développement** : -50% temps pour nouvelles features
2. **Bugs** : -30% bugs dus à confusion
3. **Onboarding** : 2j → 0.5j pour nouveaux devs
4. **Build** : -20% temps compilation
5. **Bundle** : -5MB taille finale