# Configuration de Sécurité RISAQ

## 1. Configuration Flutter Secure Storage

### Android
Ajouter dans `android/app/build.gradle` :
```gradle
android {
    ...
    defaultConfig {
        ...
        minSdkVersion 18 // Minimum pour flutter_secure_storage
    }
}
```

### iOS
Aucune configuration supplémentaire requise. Le trousseau (Keychain) est utilisé automatiquement.

## 2. Configuration Local Auth (Biométrie)

### Android

1. **Ajouter les permissions** dans `android/app/src/main/AndroidManifest.xml` :
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions pour la biométrie -->
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
    <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
    
    <application>
        ...
    </application>
</manifest>
```

2. **Modifier MainActivity** dans `android/app/src/main/kotlin/.../MainActivity.kt` :
```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
    // Utiliser FlutterFragmentActivity au lieu de FlutterActivity
}
```

### iOS

1. **Ajouter dans `ios/Runner/Info.plist`** :
```xml
<key>NSFaceIDUsageDescription</key>
<string>L'application utilise Face ID pour sécuriser vos données spirituelles</string>
```

2. **Capabilities dans Xcode** :
- Ouvrir `ios/Runner.xcworkspace` dans Xcode
- Sélectionner Runner > Signing & Capabilities
- S'assurer que "Keychain Sharing" est activé si nécessaire

## 3. Configuration Web (PWA)

Pour le web, flutter_secure_storage utilise le localStorage chiffré. 
Aucune configuration supplémentaire requise.

## 4. Configuration macOS

1. **Ajouter dans `macos/Runner/Info.plist`** :
```xml
<key>NSFaceIDUsageDescription</key>
<string>L'application utilise Touch ID pour sécuriser vos données spirituelles</string>
```

2. **Entitlements dans `macos/Runner/DebugProfile.entitlements` et `macos/Runner/Release.entitlements`** :
```xml
<key>com.apple.security.personal-information.keychain</key>
<true/>
```

## 5. Utilisation dans le Code

### Initialisation au démarrage de l'app

```dart
// Dans main.dart ou app initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Valider la configuration
  AppConfig.validate();
  
  // Vérifier l'intégrité du stockage
  final storage = SecureStorageService.instance;
  final isValid = await storage.checkStorageIntegrity();
  
  if (!isValid) {
    // Gérer l'erreur ou réinitialiser
    print('Warning: Storage integrity check failed');
  }
  
  runApp(MyApp());
}
```

### Protection de l'app avec biométrie

```dart
// Dans votre écran de démarrage ou splash
class SplashScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: _checkBiometricProtection(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          // Demander l'authentification biométrique
          return BiometricAuthScreen();
        }
        // Continuer normalement
        return HomeScreen();
      },
    );
  }
  
  Future<bool> _checkBiometricProtection() async {
    final storage = SecureStorageService.instance;
    return await storage.isBiometricEnabled();
  }
}
```

### Exemple d'utilisation complète

```dart
// Écran de paramètres de sécurité
class SecuritySettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometric = BiometricService.instance;
    
    return Scaffold(
      appBar: AppBar(title: Text('Sécurité')),
      body: ListView(
        children: [
          FutureBuilder<bool>(
            future: biometric.canCheckBiometrics(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!) {
                return ListTile(
                  title: Text('Authentification biométrique'),
                  subtitle: Text('Non disponible sur cet appareil'),
                  enabled: false,
                );
              }
              
              return SwitchListTile(
                title: Text('Protection biométrique'),
                subtitle: FutureBuilder<String>(
                  future: biometric.getPrimaryBiometricType(),
                  builder: (context, snapshot) {
                    return Text('Utiliser ${snapshot.data ?? "la biométrie"}');
                  },
                ),
                value: ref.watch(isBiometricEnabledProvider).value ?? false,
                onChanged: (enabled) async {
                  if (enabled) {
                    final success = await biometric.enableBiometricProtection();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Protection activée')),
                      );
                    }
                  } else {
                    final success = await biometric.disableBiometricProtection();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Protection désactivée')),
                      );
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
```

## 6. Variables d'Environnement (.env)

Créer un fichier `.env` à la racine du projet :
```bash
cp .env.example .env
```

Configurer vos valeurs :
```env
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_ANON_KEY=votre-cle-anon
ENVIRONMENT=development
DEBUG_MODE=true
```

## 7. Lancement Sécurisé

### Développement
```bash
./scripts/run_secure.sh
# ou
./scripts/run_secure.sh -d chrome  # Pour le web
```

### Production
```bash
./scripts/build_secure.sh appbundle  # Android
./scripts/build_secure.sh ipa        # iOS
./scripts/build_secure.sh web        # Web
```

## 8. Checklist de Sécurité

- [ ] `.env` ajouté à `.gitignore`
- [ ] `.env.production` jamais commité
- [ ] Permissions biométriques configurées (Android/iOS)
- [ ] Messages d'usage Face ID/Touch ID en français
- [ ] MainActivity hérite de FlutterFragmentActivity (Android)
- [ ] Tests de sécurité passés
- [ ] Obfuscation activée pour les builds de production
- [ ] Certificats SSL vérifiés
- [ ] Pas de logs sensibles en production
- [ ] Stockage sécurisé testé sur toutes les plateformes

## 9. Debugging

### Vérifier la configuration
```dart
// Dans votre code de debug
AppConfig.debugPrintAllKeys();
BiometricService.instance.getAvailableBiometrics().then((list) {
  print('Biométries disponibles: $list');
});
```

### Réinitialiser le stockage sécurisé
```dart
// En cas de problème
await SecureStorageService.instance.deleteAll();
```

## 10. Notes de Sécurité

1. **Ne jamais stocker** :
   - Mots de passe en clair
   - Clés privées API côté serveur
   - Données bancaires complètes

2. **Toujours utiliser** :
   - HTTPS pour toutes les API
   - Certificate pinning en production
   - Chiffrement pour les données sensibles

3. **Bonnes pratiques** :
   - Rotation régulière des tokens
   - Expiration des sessions
   - Audit des accès
   - Logs sans PII (Personally Identifiable Information)