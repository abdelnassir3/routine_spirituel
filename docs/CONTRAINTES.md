# Contraintes Techniques - Projet Spiritual Routines

**Dernière mise à jour: 2025-08-27 14:30**

## Contraintes de performance
- **Latence UI**: <200ms pour toutes interactions
- **Time to Interactive**: <2 secondes au d�marrage � froid
- **Utilisation m�moire**: <150MB en fonctionnement normal
- **Bundle size**: <35MB pour d�ploiement stores
- **Latence TTS**: <450ms P95 pour synth�se vocale

## Contraintes de s�curit�
- **Chiffrement**: AES-256 pour stockage local sensible
- **Authentification**: Biom�trique (Face ID/Touch ID/Empreinte) + PIN fallback
- **Logging**: Filtrage automatique PII (email, t�l�phone, tokens, etc.)
- **Conformit�**: OWASP Mobile Top 10, grade minimum B (85/100)
- **Transport**: HTTPS forc�, certificate pinning en production

## Contraintes multilingues
- **Langues support�es**: Fran�ais + Arabe avec support RTL/LTR natif
- **Polices**: Noto Naskh Arabic (arabe) + Inter (fran�ais/interface)
- **Direction texte**: Auto-d�tection RTL/LTR avec mirroring ic�nes
- **Claviers**: Support claviers arabes et fran�ais
- **Formatage**: Nombres arabes vs europ�ens selon contexte

## Contraintes plateforme
- **iOS/Android**: Support production complet (95%)
- **macOS**: Beta avec limitations background audio (60%)
- **Web**: Exp�rimental avec stubs Isar requis (40%)
- **Offline-first**: Fonctionnement complet sans connexion
- **Cache**: 7j/100MB pour TTS, purge automatique

## Contraintes techniques
- **Framework**: Flutter 3.x minimum avec null safety
- **State management**: Riverpod 2.5+ obligatoire
- **Base de données**: Drift (SQL) + Isar (NoSQL) pour persistance (isar_generator temporairement désactivé - conflit freezed 3.2.0)
- **Audio**: just_audio + audio_service pour background
- **Tests**: Coverage minimum 60% global, 80% services critiques
- **Build runner**: Obligatoire après modifications modèles (drift/isar/freezed)

## Contraintes serveur
- **VPS Edge-TTS**: 168.231.112.71:8010 (timeout 15s, circuit breaker 5 échecs)
- **VPS Coqui**: 168.231.112.71:8001 (timeout 15s, circuit breaker 5 échecs)
- **Fallback**: Flutter TTS local si VPS indisponible
- **Circuit breaker**: D�sactivation apr�s 5 �checs cons�cutifs
- **Cache hit**: Objectif 85% pour r�duire co�ts serveur

## Contraintes UX/UI
- **Material Design 3**: Obligatoire avec th�me unifi�
- **Accessibilit�**: WCAG AA minimum, cibles tactiles e48dp
- **Animations**: d250ms, d�sactivables pour accessibilit�
- **Feedback haptique**: Contextuel avec 3 niveaux d'intensit�
- **Mode sombre**: Support automatique système

## Charte Qualité & Bonnes Pratiques

### Standards Code
- **Null Safety** : Obligatoire strict avec versions Dart 3.x+
- **Linting** : flutter_lints + rules supplémentaires (25+ rules actives)
- **Formatage** : dart format avec line length 80, trim trailing whitespace
- **Import** : always_use_package_imports pour lib/, pas de relative imports
- **Logs** : avoid_print en production, utiliser app_logger centralisé

### Tests & Qualité
- **Coverage minimum** : 60% global, 80% services critiques
- **Types tests** : Unit (modèles), Widget (UI), Integration (flux complets)
- **Commandes** : flutter test --reporter=expanded --coverage
- **Mock/Stub** : Provider overrides pour tests isolés Riverpod
- **Test package** : Requis en dev_dependencies

### Outils Développement
- **Scripts** : scripts/{lint.sh,test.sh,build.sh} exécutables
- **Hooks Git** : Pre-commit avec dart format + flutter analyze
- **CI/CD** : GitHub Actions avec steps lint → test → build → deploy
- **Sécurité** : Pas de secrets en dur, .env dans .gitignore, audit périodique
- **Documentation** : README avec setup, CONTRAINTES techniques à jour

### Workflow Qualité  
1. **Développement** : dart format + flutter analyze en continu
2. **Pre-commit** : lint.sh automatique
3. **Pull Request** : CI/CD avec tests + coverage
4. **Release** : build.sh + tests integration complets
5. **Post-release** : Monitoring crash rate <0.1%

## État Qualité (Août 2025)
- ✅ Infrastructure qualité déployée : scripts lint/test/build, GitHub Actions
- ✅ 45 tests unitaires créés (services critiques couverts)
- ✅ 72 dépendances mises à jour, js package forcé vers 0.7.2
- ✅ Design system réparé (colors.dart, shadows.dart, typography.dart, secure_logging_service.dart)