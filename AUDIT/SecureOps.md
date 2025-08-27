# SecureOps — Guide Sécurité & Configuration

## 🔴 État Actuel : Non Sécurisé

### Problèmes Critiques Identifiés
1. **Pas de Supabase configuré** malgré mentions dans PRD
2. **Pas de .env ou secrets management**
3. **flutter_secure_storage sous-utilisé**
4. **Pas de RLS (Row Level Security)**
5. **Print statements en production**
6. **Pas d'obfuscation configurée**

## Configuration Sécurisée Proposée

### 1. Secrets Management

#### Configuration avec --dart-define
```bash
# .env.example (NE JAMAIS COMMITTER .env)
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
OPENAI_API_KEY=sk-...
SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
```

#### Script de lancement sécurisé
```bash
#!/bin/bash
# scripts/run_secure.sh

# Charger les variables d'environnement
source .env

# Lancer avec --dart-define
flutter run \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY \
  --dart-define=SENTRY_DSN=$SENTRY_DSN
```

#### Accès sécurisé dans le code
```dart
// lib/core/config/app_config.dart
class AppConfig {
  // Jamais de valeurs par défaut pour les secrets !
  static String get supabaseUrl {
    const url = String.fromEnvironment('SUPABASE_URL');
    if (url.isEmpty) {
      throw Exception('SUPABASE_URL not configured');
    }
    return url;
  }
  
  static String get supabaseAnonKey {
    const key = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY not configured');
    }
    return key;
  }
  
  // Ne jamais exposer service_role key côté client !
  static String? get openAiKey {
    const key = String.fromEnvironment('OPENAI_API_KEY');
    return key.isEmpty ? null : key; // Optional
  }
  
  static bool get isProduction {
    return const bool.fromEnvironment('dart.vm.product');
  }
}
```

### 2. Secure Storage Implementation

```dart
// lib/core/services/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );
  
  // User credentials
  static Future<void> saveUserToken(String token) async {
    await _storage.write(key: 'user_token', value: token);
  }
  
  static Future<String?> getUserToken() async {
    return await _storage.read(key: 'user_token');
  }
  
  static Future<void> clearUserToken() async {
    await _storage.delete(key: 'user_token');
  }
  
  // Session data encryption
  static Future<void> saveEncryptedSession(Map<String, dynamic> session) async {
    final encrypted = await _encryptData(jsonEncode(session));
    await _storage.write(key: 'session', value: encrypted);
  }
  
  static Future<Map<String, dynamic>?> getEncryptedSession() async {
    final encrypted = await _storage.read(key: 'session');
    if (encrypted == null) return null;
    final decrypted = await _decryptData(encrypted);
    return jsonDecode(decrypted);
  }
  
  // Encryption helpers (use crypto package)
  static Future<String> _encryptData(String plainText) async {
    // Implement AES-256 encryption
    // Use device-specific key derived from Keychain/Keystore
    return plainText; // TODO: Implement
  }
  
  static Future<String> _decryptData(String encrypted) async {
    // Implement AES-256 decryption
    return encrypted; // TODO: Implement
  }
}
```

### 3. Supabase RLS Configuration

```sql
-- Supabase RLS Policies (à exécuter dans Supabase Dashboard)

-- Table: user_routines
CREATE POLICY "Users can only see their own routines"
  ON user_routines FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own routines"
  ON user_routines FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update their own routines"
  ON user_routines FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete their own routines"
  ON user_routines FOR DELETE
  USING (auth.uid() = user_id);

-- Table: shared_routines (lecture seule pour les routines partagées)
CREATE POLICY "Anyone can read shared routines"
  ON shared_routines FOR SELECT
  USING (is_public = true);

CREATE POLICY "Only owner can modify shared routines"
  ON shared_routines FOR ALL
  USING (auth.uid() = creator_id);

-- Storage bucket: user_audio
CREATE POLICY "Users can upload their own audio"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'user_audio' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can view their own audio"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'user_audio' AND auth.uid()::text = (storage.foldername(name))[1]);
```

### 4. Network Security

```dart
// lib/core/services/network_service.dart
import 'package:dio/dio.dart';

class NetworkService {
  static final _dio = Dio();
  
  static void configureDio() {
    // Timeouts
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
    
    // Headers sécurisés
    _dio.options.headers = {
      'X-Requested-With': 'XMLHttpRequest',
      'X-App-Version': '1.0.0',
    };
    
    // Intercepteurs
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Ajouter auth token si disponible
          SecureStorageService.getUserToken().then((token) {
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          });
        },
        onError: (error, handler) {
          // Log errors sans exposer de données sensibles
          _logSecureError(error);
          handler.next(error);
        },
      ),
    );
    
    // Certificate pinning (optionnel mais recommandé)
    if (AppConfig.isProduction) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
        client.badCertificateCallback = (cert, host, port) {
          // Vérifier le fingerprint du certificat
          final expectedFingerprint = 'SHA256:XXXXXX';
          final actualFingerprint = _getCertFingerprint(cert);
          return actualFingerprint == expectedFingerprint;
        };
        return client;
      };
    }
  }
  
  static void _logSecureError(DioError error) {
    // Ne jamais logger : tokens, passwords, données personnelles
    final sanitized = {
      'type': error.type.toString(),
      'status': error.response?.statusCode,
      'path': error.requestOptions.path,
      // Pas de data ou headers !
    };
    
    if (!AppConfig.isProduction) {
      print('Network error: $sanitized');
    }
  }
}
```

### 5. Logging Sécurisé

```dart
// lib/core/services/logger_service.dart
class LoggerService {
  static void log(String message, {Map<String, dynamic>? metadata}) {
    if (AppConfig.isProduction) {
      // En production : Sentry uniquement
      Sentry.captureMessage(
        message,
        level: SentryLevel.info,
        withScope: (scope) {
          metadata?.forEach((key, value) {
            // Filtrer les données sensibles
            if (!_isSensitiveKey(key)) {
              scope.setTag(key, value.toString());
            }
          });
        },
      );
    } else {
      // En dev : console (mais filtré)
      final safe = _sanitizeMetadata(metadata);
      debugPrint('[$message] $safe');
    }
  }
  
  static void error(dynamic error, {StackTrace? stack}) {
    if (AppConfig.isProduction) {
      Sentry.captureException(error, stackTrace: stack);
    } else {
      debugPrint('ERROR: ${error.toString()}');
      if (stack != null) debugPrint(stack.toString());
    }
  }
  
  static bool _isSensitiveKey(String key) {
    final sensitive = ['password', 'token', 'key', 'secret', 'email', 'phone'];
    return sensitive.any((s) => key.toLowerCase().contains(s));
  }
  
  static Map<String, dynamic> _sanitizeMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null) return {};
    return metadata.map((key, value) {
      if (_isSensitiveKey(key)) {
        return MapEntry(key, '***REDACTED***');
      }
      return MapEntry(key, value);
    });
  }
}
```

### 6. Build Configuration

#### Android
```groovy
// android/app/build.gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
            
            // Obfuscation
            ndk {
                debugSymbolLevel 'SYMBOL_TABLE'
            }
        }
    }
}

// Signing config (utiliser keystore sécurisé)
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

#### iOS
```ruby
# ios/Podfile
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Activer bitcode et optimisations
      config.build_settings['ENABLE_BITCODE'] = 'YES'
      config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-O'
    end
  end
end
```

### 7. .gitignore Sécurisé

```gitignore
# Secrets - JAMAIS committer
.env
.env.*
*.keystore
*.jks
*.p12
*.p8
*.mobileprovision
*.cer

# API Keys
**/google-services.json
**/GoogleService-Info.plist
**/apikeys.properties

# Build artifacts
*.apk
*.aab
*.ipa
*.app
*.dSYM.zip

# IDE
.idea/
.vscode/
*.iml

# macOS
.DS_Store

# Logs
*.log
```

## Matrice de Permissions

| Permission | iOS | Android | Justification | Fallback |
|------------|-----|---------|---------------|----------|
| Audio Recording | NSMicrophoneUsageDescription | RECORD_AUDIO | TTS & Transcription | Texte only |
| Camera | NSCameraUsageDescription | CAMERA | OCR scan | File picker |
| Storage | NSPhotoLibraryUsageDescription | READ_EXTERNAL_STORAGE | Import corpus | Built-in only |
| Notifications | UNUserNotificationCenter | POST_NOTIFICATIONS | Rappels prière | In-app only |

## Security Checklist

### Avant Release
- [ ] Aucun secret en dur dans le code
- [ ] .env dans .gitignore
- [ ] flutter_secure_storage pour données sensibles
- [ ] Obfuscation activée (--obfuscate)
- [ ] ProGuard/R8 configuré (Android)
- [ ] Bitcode activé (iOS)
- [ ] Certificats SSL vérifiés
- [ ] RLS Supabase configuré
- [ ] Logs sanitisés (pas de PII)
- [ ] Sentry configuré pour crash reports

### Runtime Security
- [ ] Token expiration vérifiée
- [ ] Session timeout implémentée
- [ ] Biometric auth optionnelle
- [ ] Data encryption at rest
- [ ] Network encryption (HTTPS only)
- [ ] Input validation stricte
- [ ] SQL injection impossible (ORM)

### Privacy Compliance
- [ ] RGPD : Opt-in analytics
- [ ] RGPD : Data export possible
- [ ] RGPD : Right to deletion
- [ ] COPPA : Pas de tracking <13 ans
- [ ] CCPA : Privacy policy claire

## Incident Response Plan

### En cas de fuite de données
1. **Isoler** : Désactiver les endpoints affectés
2. **Identifier** : Scope de la fuite via logs
3. **Notifier** : Users affectés sous 72h (RGPD)
4. **Patcher** : Fix et déploiement urgent
5. **Audit** : Post-mortem et amélioration

### Contacts Urgence
- Security Lead : [À définir]
- DPO : [À définir]
- Supabase Support : support@supabase.io
- Apple Security : product-security@apple.com
- Google Security : security@android.com