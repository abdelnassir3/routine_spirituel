#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Script d'audit de sécurité automatisé pour RISAQ
///
/// Usage: dart run tools/security_audit.dart
void main() async {
  print('🔒 RISAQ Security Audit Tool');
  print('=' * 50);
  print('');

  final results = <String, AuditResult>{};

  // 1. Recherche de secrets hardcodés
  results['hardcoded_secrets'] = await checkHardcodedSecrets();

  // 2. Vérification des permissions
  results['permissions'] = await checkPermissions();

  // 3. Analyse des dépendances
  results['dependencies'] = await checkDependencies();

  // 4. Configuration de sécurité
  results['security_config'] = await checkSecurityConfiguration();

  // 5. Analyse du code
  results['code_analysis'] = await analyzeCode();

  // 6. Vérification du stockage
  results['storage'] = await checkStorageSecurity();

  // 7. Vérification du logging
  results['logging'] = await checkLoggingSecurity();

  // 8. Vérification de l'authentification
  results['authentication'] = await checkAuthenticationSecurity();

  // Afficher le rapport
  printReport(results);

  // Calculer le score global
  final score = calculateSecurityScore(results);
  printSecurityScore(score);

  // Exit code basé sur le score
  exit(score >= 80 ? 0 : 1);
}

/// Résultat d'un audit
class AuditResult {
  final String name;
  final bool passed;
  final List<String> issues;
  final List<String> recommendations;
  final int score; // 0-100

  AuditResult({
    required this.name,
    required this.passed,
    this.issues = const [],
    this.recommendations = const [],
    required this.score,
  });
}

/// 1. Vérifier les secrets hardcodés
Future<AuditResult> checkHardcodedSecrets() async {
  print('🔍 Checking for hardcoded secrets...');

  final issues = <String>[];
  final recommendations = <String>[];

  final patterns = [
    'api_key',
    'apikey',
    'api-key',
    'secret',
    'password',
    'pwd',
    'token',
    'private_key',
    'privatekey',
    'client_secret',
  ];

  final excludeDirs = [
    '.dart_tool',
    'build',
    'test',
    '.git',
    'docs',
  ];

  int filesScanned = 0;
  int issuesFound = 0;

  await for (final file in Directory('lib').list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      filesScanned++;
      final content = await file.readAsString();
      final lines = content.split('\n');

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].toLowerCase();

        // Skip comments
        if (line.trim().startsWith('//') || line.trim().startsWith('*')) {
          continue;
        }

        for (final pattern in patterns) {
          if (line.contains(pattern) && line.contains('=')) {
            // Check if it's an actual assignment
            if (!line.contains('fromEnvironment') &&
                !line.contains('getenv') &&
                !line.contains('[REDACTED]')) {
              issues.add('${file.path}:${i + 1} - Potential secret: $pattern');
              issuesFound++;
            }
          }
        }
      }
    }
  }

  print('  Scanned $filesScanned files');
  print('  Found $issuesFound potential issues');

  if (issuesFound == 0) {
    recommendations.add('Continue using environment variables for secrets');
  } else {
    recommendations.add('Move all secrets to environment variables');
    recommendations.add('Use --dart-define for compile-time secrets');
  }

  return AuditResult(
    name: 'Hardcoded Secrets',
    passed: issuesFound == 0,
    issues: issues,
    recommendations: recommendations,
    score: issuesFound == 0 ? 100 : max(0, 100 - (issuesFound * 20)),
  );
}

/// 2. Vérifier les permissions
Future<AuditResult> checkPermissions() async {
  print('🔍 Checking permissions...');

  final issues = <String>[];
  final recommendations = <String>[];
  int score = 100;

  // Check Android permissions
  final androidManifest = File('android/app/src/main/AndroidManifest.xml');
  if (await androidManifest.exists()) {
    final content = await androidManifest.readAsString();

    // Permissions dangereuses à éviter
    final dangerousPerms = [
      'CAMERA',
      'RECORD_AUDIO',
      'ACCESS_FINE_LOCATION',
      'ACCESS_COARSE_LOCATION',
      'READ_CONTACTS',
      'WRITE_CONTACTS',
      'READ_CALENDAR',
      'WRITE_CALENDAR',
      'READ_SMS',
      'SEND_SMS',
      'READ_PHONE_STATE',
      'CALL_PHONE',
      'READ_EXTERNAL_STORAGE',
      'WRITE_EXTERNAL_STORAGE',
    ];

    for (final perm in dangerousPerms) {
      if (content.contains('android.permission.$perm')) {
        issues.add('Android: Uses dangerous permission $perm');
        score -= 10;
      }
    }

    // Permissions attendues
    final expectedPerms = [
      'INTERNET',
      'USE_BIOMETRIC',
      'USE_FINGERPRINT',
    ];

    for (final perm in expectedPerms) {
      if (!content.contains('android.permission.$perm')) {
        recommendations
            .add('Android: Consider adding permission $perm if needed');
      }
    }
  }

  // Check iOS permissions
  final infoPlist = File('ios/Runner/Info.plist');
  if (await infoPlist.exists()) {
    final content = await infoPlist.readAsString();

    // Usage descriptions requises
    final requiredDescriptions = {
      'NSFaceIDUsageDescription': 'Face ID usage description',
    };

    for (final entry in requiredDescriptions.entries) {
      if (!content.contains(entry.key)) {
        issues.add('iOS: Missing ${entry.value}');
        score -= 10;
      }
    }

    // Permissions dangereuses
    final dangerousKeys = [
      'NSCameraUsageDescription',
      'NSMicrophoneUsageDescription',
      'NSLocationWhenInUseUsageDescription',
      'NSLocationAlwaysUsageDescription',
      'NSContactsUsageDescription',
      'NSCalendarsUsageDescription',
    ];

    for (final key in dangerousKeys) {
      if (content.contains(key)) {
        issues.add('iOS: Uses potentially unnecessary permission $key');
        score -= 5;
      }
    }
  }

  return AuditResult(
    name: 'Permissions',
    passed: issues.isEmpty,
    issues: issues,
    recommendations: recommendations,
    score: max(0, score),
  );
}

/// 3. Analyser les dépendances
Future<AuditResult> checkDependencies() async {
  print('🔍 Checking dependencies...');

  final issues = <String>[];
  final recommendations = <String>[];
  int score = 100;

  // Lire pubspec.yaml
  final pubspec = File('pubspec.yaml');
  if (await pubspec.exists()) {
    final content = await pubspec.readAsString();

    // Dépendances à risque connues
    final riskyDeps = {
      'http': 'Use dio instead for better security features',
      'shared_preferences': 'Never store sensitive data here',
      'sqflite': 'Consider using encrypted database',
    };

    for (final entry in riskyDeps.entries) {
      if (content.contains('${entry.key}:')) {
        recommendations.add('${entry.key}: ${entry.value}');
        score -= 5;
      }
    }

    // Dépendances de sécurité recommandées
    final securityDeps = [
      'flutter_secure_storage',
      'local_auth',
      'crypto',
    ];

    for (final dep in securityDeps) {
      if (!content.contains('$dep:')) {
        issues.add('Missing recommended security package: $dep');
        score -= 10;
      }
    }
  }

  // Vérifier les versions outdated
  final result = await Process.run('flutter', ['pub', 'outdated']);
  if (result.exitCode == 0) {
    final output = result.stdout.toString();
    final lines = output.split('\n');

    int outdatedCount = 0;
    for (final line in lines) {
      if (line.contains('OUTDATED') || line.contains('major')) {
        outdatedCount++;
      }
    }

    if (outdatedCount > 0) {
      issues.add('$outdatedCount packages are outdated');
      recommendations.add('Run: flutter pub upgrade');
      score -= outdatedCount * 2;
    }
  }

  return AuditResult(
    name: 'Dependencies',
    passed: issues.isEmpty,
    issues: issues,
    recommendations: recommendations,
    score: max(0, score),
  );
}

/// 4. Vérifier la configuration de sécurité
Future<AuditResult> checkSecurityConfiguration() async {
  print('🔍 Checking security configuration...');

  final issues = <String>[];
  final recommendations = <String>[];
  int score = 100;

  // Vérifier les scripts de build
  final buildScript = File('scripts/build_secure.sh');
  if (await buildScript.exists()) {
    final content = await buildScript.readAsString();

    if (!content.contains('--obfuscate')) {
      issues.add('Build script missing obfuscation');
      score -= 20;
    }

    if (!content.contains('--split-debug-info')) {
      issues.add('Build script missing debug info splitting');
      score -= 10;
    }
  } else {
    issues.add('Secure build script not found');
    score -= 30;
  }

  // Vérifier AppConfig
  final appConfig = File('lib/core/config/app_config.dart');
  if (await appConfig.exists()) {
    final content = await appConfig.readAsString();

    if (!content.contains('fromEnvironment')) {
      issues.add('AppConfig not using environment variables');
      score -= 20;
    }

    if (!content.contains('ConfigurationException')) {
      recommendations.add('Add validation for missing configuration');
    }
  } else {
    issues.add('AppConfig not found');
    score -= 30;
  }

  // Vérifier .env.example
  final envExample = File('.env.example');
  if (!await envExample.exists()) {
    issues.add('.env.example not found');
    recommendations.add('Create .env.example for documentation');
    score -= 10;
  }

  // Vérifier .gitignore
  final gitignore = File('.gitignore');
  if (await gitignore.exists()) {
    final content = await gitignore.readAsString();

    final requiredIgnores = [
      '.env',
      '*.keystore',
      '*.jks',
      '*.p12',
      '*.key',
      '*.pem',
    ];

    for (final pattern in requiredIgnores) {
      if (!content.contains(pattern)) {
        issues.add('.gitignore missing: $pattern');
        score -= 5;
      }
    }
  }

  return AuditResult(
    name: 'Security Configuration',
    passed: score >= 70,
    issues: issues,
    recommendations: recommendations,
    score: max(0, score),
  );
}

/// 5. Analyser le code
Future<AuditResult> analyzeCode() async {
  print('🔍 Analyzing code...');

  final issues = <String>[];
  final recommendations = <String>[];
  int score = 100;

  // Run flutter analyze
  final result = await Process.run('flutter', ['analyze', '--no-fatal-infos']);

  if (result.exitCode != 0) {
    final output = result.stdout.toString();
    final lines = output.split('\n');

    int errorCount = 0;
    int warningCount = 0;
    int infoCount = 0;

    for (final line in lines) {
      if (line.contains('error •')) errorCount++;
      if (line.contains('warning •')) warningCount++;
      if (line.contains('info •')) infoCount++;
    }

    if (errorCount > 0) {
      issues.add('$errorCount errors found in code analysis');
      score -= errorCount * 10;
    }

    if (warningCount > 0) {
      issues.add('$warningCount warnings found in code analysis');
      score -= warningCount * 5;
    }

    if (infoCount > 10) {
      recommendations
          .add('$infoCount info messages - consider addressing them');
    }
  }

  // Check for common security issues
  await for (final file in Directory('lib').list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = await file.readAsString();

      // Check for print statements (should use logger)
      if (content.contains('print(') && !file.path.contains('test')) {
        recommendations.add('Use SecureLoggingService instead of print()');
        score -= 2;
      }

      // Check for TODO/FIXME related to security
      if (content.contains('TODO') &&
          content.toLowerCase().contains('security')) {
        issues.add('Security-related TODO found in ${file.path}');
        score -= 5;
      }
    }
  }

  return AuditResult(
    name: 'Code Analysis',
    passed: issues.isEmpty,
    issues: issues,
    recommendations: recommendations,
    score: max(0, score),
  );
}

/// 6. Vérifier la sécurité du stockage
Future<AuditResult> checkStorageSecurity() async {
  print('🔍 Checking storage security...');

  final issues = <String>[];
  final recommendations = <String>[];
  int score = 100;

  // Vérifier SecureStorageService
  final secureStorage = File('lib/core/services/secure_storage_service.dart');
  if (await secureStorage.exists()) {
    final content = await secureStorage.readAsString();

    if (!content.contains('FlutterSecureStorage')) {
      issues.add('SecureStorageService not using FlutterSecureStorage');
      score -= 30;
    }

    if (!content.contains('sha256') && !content.contains('SHA256')) {
      recommendations.add('Consider using SHA256 for hashing');
      score -= 10;
    }
  } else {
    issues.add('SecureStorageService not found');
    score -= 50;
  }

  // Chercher l'utilisation de SharedPreferences pour données sensibles
  await for (final file in Directory('lib').list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = await file.readAsString();

      if (content.contains('SharedPreferences')) {
        final lines = content.split('\n');
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].toLowerCase();
          if (line.contains('sharedpreferences') &&
              (line.contains('token') ||
                  line.contains('password') ||
                  line.contains('key'))) {
            issues.add(
                'Potential sensitive data in SharedPreferences: ${file.path}:${i + 1}');
            score -= 20;
          }
        }
      }
    }
  }

  return AuditResult(
    name: 'Storage Security',
    passed: score >= 80,
    issues: issues,
    recommendations: recommendations,
    score: max(0, score),
  );
}

/// 7. Vérifier la sécurité du logging
Future<AuditResult> checkLoggingSecurity() async {
  print('🔍 Checking logging security...');

  final issues = <String>[];
  final recommendations = <String>[];
  int score = 100;

  // Vérifier SecureLoggingService
  final loggingService = File('lib/core/services/secure_logging_service.dart');
  if (await loggingService.exists()) {
    final content = await loggingService.readAsString();

    if (!content.contains('_sanitizeText')) {
      issues.add('Logging service missing PII sanitization');
      score -= 30;
    }

    if (!content.contains('_piiPatterns')) {
      issues.add('Logging service missing PII patterns');
      score -= 30;
    }
  } else {
    issues.add('SecureLoggingService not found');
    score -= 50;
  }

  // Vérifier l'utilisation de print() au lieu du logger
  int printCount = 0;
  await for (final file in Directory('lib').list(recursive: true)) {
    if (file is File &&
        file.path.endsWith('.dart') &&
        !file.path.contains('test') &&
        !file.path.contains('logging')) {
      final content = await file.readAsString();

      if (content.contains('print(')) {
        printCount++;
      }
    }
  }

  if (printCount > 0) {
    issues
        .add('Found $printCount files using print() instead of secure logger');
    recommendations.add('Replace all print() with SecureLoggingService');
    score -= printCount * 2;
  }

  return AuditResult(
    name: 'Logging Security',
    passed: score >= 80,
    issues: issues,
    recommendations: recommendations,
    score: max(0, score),
  );
}

/// 8. Vérifier la sécurité de l'authentification
Future<AuditResult> checkAuthenticationSecurity() async {
  print('🔍 Checking authentication security...');

  final issues = <String>[];
  final recommendations = <String>[];
  int score = 100;

  // Vérifier BiometricService
  final biometricService = File('lib/core/services/biometric_service.dart');
  if (await biometricService.exists()) {
    final content = await biometricService.readAsString();

    if (!content.contains('LocalAuthentication')) {
      issues.add('BiometricService not using LocalAuthentication');
      score -= 30;
    }

    if (!content.contains('maxFailedAttempts')) {
      recommendations.add('Add max failed attempts limit');
      score -= 10;
    }
  } else {
    issues.add('BiometricService not found');
    recommendations.add('Implement biometric authentication');
    score -= 40;
  }

  // Vérifier le timeout de session
  bool hasSessionTimeout = false;
  await for (final file in Directory('lib').list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = await file.readAsString();
      if (content.contains('sessionTimeout') ||
          content.contains('session_timeout')) {
        hasSessionTimeout = true;
        break;
      }
    }
  }

  if (!hasSessionTimeout) {
    issues.add('No session timeout implementation found');
    recommendations.add('Implement 15-minute session timeout');
    score -= 20;
  }

  return AuditResult(
    name: 'Authentication Security',
    passed: score >= 70,
    issues: issues,
    recommendations: recommendations,
    score: max(0, score),
  );
}

/// Afficher le rapport
void printReport(Map<String, AuditResult> results) {
  print('\n' + '=' * 50);
  print('📊 SECURITY AUDIT REPORT');
  print('=' * 50 + '\n');

  for (final entry in results.entries) {
    final result = entry.value;
    final icon = result.passed ? '✅' : '❌';
    final color = result.passed ? '\x1B[32m' : '\x1B[31m'; // Green or Red
    const reset = '\x1B[0m';

    print('$color$icon ${result.name}$reset (Score: ${result.score}/100)');

    if (result.issues.isNotEmpty) {
      print('  Issues:');
      for (final issue in result.issues.take(5)) {
        print('    ⚠️  $issue');
      }
      if (result.issues.length > 5) {
        print('    ... and ${result.issues.length - 5} more');
      }
    }

    if (result.recommendations.isNotEmpty) {
      print('  Recommendations:');
      for (final rec in result.recommendations.take(3)) {
        print('    💡 $rec');
      }
    }

    print('');
  }
}

/// Calculer le score global
int calculateSecurityScore(Map<String, AuditResult> results) {
  if (results.isEmpty) return 0;

  int totalScore = 0;
  for (final result in results.values) {
    totalScore += result.score;
  }

  return totalScore ~/ results.length;
}

/// Afficher le score de sécurité
void printSecurityScore(int score) {
  print('=' * 50);

  String grade;
  String color;
  String emoji;

  if (score >= 90) {
    grade = 'A';
    color = '\x1B[32m'; // Green
    emoji = '🏆';
  } else if (score >= 80) {
    grade = 'B';
    color = '\x1B[32m'; // Green
    emoji = '✅';
  } else if (score >= 70) {
    grade = 'C';
    color = '\x1B[33m'; // Yellow
    emoji = '⚠️';
  } else if (score >= 60) {
    grade = 'D';
    color = '\x1B[31m'; // Red
    emoji = '⛔';
  } else {
    grade = 'F';
    color = '\x1B[31m'; // Red
    emoji = '🚨';
  }

  const reset = '\x1B[0m';

  print('$color');
  print('  SECURITY SCORE: $score/100 (Grade: $grade) $emoji');
  print('$reset');

  if (score < 80) {
    print('\n⚠️  Security improvements needed!');
    print('Run this audit regularly to track progress.');
  } else {
    print('\n✅ Good security posture!');
    print('Keep up the good work and continue monitoring.');
  }

  print('=' * 50);
}

/// Helper pour max
int max(int a, int b) => a > b ? a : b;
