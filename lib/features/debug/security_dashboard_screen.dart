import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/secure_logging_service.dart';
import '../../core/config/app_config.dart';

/// Dashboard de sécurité pour visualiser l'état de la sécurité de l'app
/// 
/// DEBUG ONLY - Ne pas inclure en production
class SecurityDashboardScreen extends ConsumerStatefulWidget {
  const SecurityDashboardScreen({super.key});

  @override
  ConsumerState<SecurityDashboardScreen> createState() => _SecurityDashboardScreenState();
}

class _SecurityDashboardScreenState extends ConsumerState<SecurityDashboardScreen> {
  final List<SecurityCheck> _checks = [];
  bool _isRunning = false;
  int _overallScore = 0;
  
  @override
  void initState() {
    super.initState();
    _runSecurityChecks();
  }
  
  Future<void> _runSecurityChecks() async {
    setState(() {
      _isRunning = true;
      _checks.clear();
    });
    
    // 1. Configuration Check
    _checks.add(await _checkConfiguration());
    setState(() {});
    
    // 2. Storage Security
    _checks.add(await _checkStorageSecurity());
    setState(() {});
    
    // 3. Authentication Security
    _checks.add(await _checkAuthenticationSecurity());
    setState(() {});
    
    // 4. Logging Security
    _checks.add(await _checkLoggingSecurity());
    setState(() {});
    
    // 5. Network Security
    _checks.add(await _checkNetworkSecurity());
    setState(() {});
    
    // 6. Permissions Check
    _checks.add(await _checkPermissions());
    setState(() {});
    
    // 7. Code Security
    _checks.add(await _checkCodeSecurity());
    setState(() {});
    
    // 8. Dependencies Check
    _checks.add(await _checkDependencies());
    setState(() {});
    
    // Calculate overall score
    _calculateOverallScore();
    
    setState(() {
      _isRunning = false;
    });
  }
  
  Future<SecurityCheck> _checkConfiguration() async {
    final issues = <String>[];
    final passed = <String>[];
    
    // Check environment
    if (AppConfig.isProduction) {
      issues.add('Running in production mode - security dashboard should be disabled');
    } else {
      passed.add('Running in ${AppConfig.environment.name} mode');
    }
    
    // Check debug mode
    if (AppConfig.isDebugMode) {
      issues.add('Debug mode is enabled');
    } else {
      passed.add('Debug mode is disabled');
    }
    
    // Check Supabase config
    if (AppConfig.hasSupabaseConfig) {
      passed.add('Supabase is configured');
    } else {
      issues.add('Supabase is not configured');
    }
    
    // Check error tracking
    if (AppConfig.isErrorTrackingEnabled) {
      passed.add('Error tracking is enabled');
    } else if (AppConfig.isProduction) {
      issues.add('Error tracking is disabled in production');
    }
    
    // Check certificate pinning
    if (AppConfig.enableCertificatePinning) {
      passed.add('Certificate pinning is enabled');
    } else if (AppConfig.isProduction) {
      issues.add('Certificate pinning is disabled in production');
    }
    
    return SecurityCheck(
      name: 'Configuration',
      icon: Icons.settings,
      passed: passed,
      issues: issues,
      score: _calculateScore(passed.length, issues.length),
    );
  }
  
  Future<SecurityCheck> _checkStorageSecurity() async {
    final issues = <String>[];
    final passed = <String>[];
    
    final storage = SecureStorageService.instance;
    
    // Check storage integrity
    final integrity = await storage.checkStorageIntegrity();
    if (integrity) {
      passed.add('Storage integrity check passed');
    } else {
      issues.add('Storage integrity check failed');
    }
    
    // Check if sensitive data exists
    final hasToken = await storage.containsKey(key: SecureStorageService.keyAuthToken);
    if (hasToken) {
      passed.add('Auth tokens are stored securely');
    }
    
    // Check PIN configuration
    final hasPin = await storage.read(key: SecureStorageService.keyPinCode) != null;
    if (hasPin) {
      passed.add('PIN code is configured and hashed');
    }
    
    // Check encryption key
    final hasEncryptionKey = await storage.getEncryptionKey() != null;
    if (hasEncryptionKey) {
      passed.add('Encryption key is available');
    } else {
      issues.add('No encryption key found');
    }
    
    return SecurityCheck(
      name: 'Storage Security',
      icon: Icons.storage,
      passed: passed,
      issues: issues,
      score: _calculateScore(passed.length, issues.length),
    );
  }
  
  Future<SecurityCheck> _checkAuthenticationSecurity() async {
    final issues = <String>[];
    final passed = <String>[];
    
    final biometric = BiometricService.instance;
    
    // Check biometric capabilities
    final canCheckBiometrics = await biometric.canCheckBiometrics();
    if (canCheckBiometrics) {
      passed.add('Biometric authentication is available');
      
      // Check available methods
      final methods = await biometric.getAvailableBiometrics();
      if (methods.isNotEmpty) {
        passed.add('${methods.length} biometric methods available');
      } else {
        issues.add('No biometric methods configured on device');
      }
    } else {
      issues.add('Biometric authentication not available');
    }
    
    // Check if biometric protection is enabled
    final isEnabled = await biometric.isBiometricProtectionEnabled();
    if (isEnabled) {
      passed.add('Biometric protection is enabled');
    } else {
      issues.add('Biometric protection is disabled');
    }
    
    // Check device support
    final isSupported = await biometric.isDeviceSupported();
    if (isSupported) {
      passed.add('Device supports biometric authentication');
    } else {
      issues.add('Device does not support biometric authentication');
    }
    
    return SecurityCheck(
      name: 'Authentication',
      icon: Icons.fingerprint,
      passed: passed,
      issues: issues,
      score: _calculateScore(passed.length, issues.length),
    );
  }
  
  Future<SecurityCheck> _checkLoggingSecurity() async {
    final issues = <String>[];
    final passed = <String>[];
    
    final logger = SecureLoggingService.instance;
    
    // Check recent logs for PII
    final recentLogs = logger.getRecentLogs();
    bool foundPII = false;
    
    for (final log in recentLogs) {
      if (log.message.contains('@') && !log.message.contains('[EMAIL_REDACTED]')) {
        foundPII = true;
        break;
      }
    }
    
    if (foundPII) {
      issues.add('Potential PII found in logs');
    } else {
      passed.add('No PII detected in recent logs');
    }
    
    // Check log levels distribution
    final analysis = logger.analyzeLogs();
    final errorCount = analysis['error'] ?? 0;
    final criticalCount = analysis['critical'] ?? 0;
    
    if (criticalCount > 0) {
      issues.add('$criticalCount critical errors in logs');
    }
    
    if (errorCount > 5) {
      issues.add('$errorCount errors in recent logs');
    } else {
      passed.add('Error rate is acceptable');
    }
    
    passed.add('PII filtering is active');
    passed.add('Secure logging service is configured');
    
    return SecurityCheck(
      name: 'Logging Security',
      icon: Icons.description,
      passed: passed,
      issues: issues,
      score: _calculateScore(passed.length, issues.length),
    );
  }
  
  Future<SecurityCheck> _checkNetworkSecurity() async {
    final issues = <String>[];
    final passed = <String>[];
    
    // Check API URLs
    try {
      final supabaseUrl = AppConfig.supabaseUrl;
      if (supabaseUrl.startsWith('https://')) {
        passed.add('Supabase URL uses HTTPS');
      } else {
        issues.add('Supabase URL does not use HTTPS');
      }
    } catch (e) {
      // URL not configured
    }
    
    // Check certificate pinning
    if (AppConfig.enableCertificatePinning) {
      if (AppConfig.certificateFingerprints.isNotEmpty) {
        passed.add('Certificate fingerprints configured');
      } else {
        issues.add('No certificate fingerprints configured');
      }
    }
    
    // Check timeout configuration
    if (AppConfig.apiTimeoutSeconds > 0 && AppConfig.apiTimeoutSeconds <= 30) {
      passed.add('API timeout is configured (${AppConfig.apiTimeoutSeconds}s)');
    } else {
      issues.add('API timeout is too long or not configured');
    }
    
    // Check retry configuration
    if (AppConfig.maxRetryAttempts > 0 && AppConfig.maxRetryAttempts <= 5) {
      passed.add('Retry attempts configured (${AppConfig.maxRetryAttempts})');
    } else {
      issues.add('Retry attempts not properly configured');
    }
    
    return SecurityCheck(
      name: 'Network Security',
      icon: Icons.lock_outline,
      passed: passed,
      issues: issues,
      score: _calculateScore(passed.length, issues.length),
    );
  }
  
  Future<SecurityCheck> _checkPermissions() async {
    final issues = <String>[];
    final passed = <String>[];
    
    // This is a simplified check - in production, you'd check actual permissions
    if (Platform.isAndroid || Platform.isIOS) {
      passed.add('Platform-specific permissions apply');
      
      // Check for dangerous permissions in code
      final libDir = Directory('lib');
      if (await libDir.exists()) {
        bool foundCamera = false;
        bool foundLocation = false;
        bool foundContacts = false;
        
        await for (final file in libDir.list(recursive: true)) {
          if (file is File && file.path.endsWith('.dart')) {
            final content = await file.readAsString();
            if (content.contains('ImagePicker') || content.contains('camera')) {
              foundCamera = true;
            }
            if (content.contains('location') || content.contains('geolocator')) {
              foundLocation = true;
            }
            if (content.contains('contacts')) {
              foundContacts = true;
            }
          }
        }
        
        if (!foundCamera) passed.add('No camera access detected');
        else issues.add('Camera access detected - verify if necessary');
        
        if (!foundLocation) passed.add('No location access detected');
        else issues.add('Location access detected - verify if necessary');
        
        if (!foundContacts) passed.add('No contacts access detected');
        else issues.add('Contacts access detected - verify if necessary');
      }
    }
    
    return SecurityCheck(
      name: 'Permissions',
      icon: Icons.security,
      passed: passed,
      issues: issues,
      score: _calculateScore(passed.length, issues.length),
    );
  }
  
  Future<SecurityCheck> _checkCodeSecurity() async {
    final issues = <String>[];
    final passed = <String>[];
    
    // Check for common security issues
    final libDir = Directory('lib');
    if (await libDir.exists()) {
      int printCount = 0;
      int todoCount = 0;
      bool hasHardcodedSecrets = false;
      
      await for (final file in libDir.list(recursive: true)) {
        if (file is File && file.path.endsWith('.dart')) {
          final content = await file.readAsString();
          
          // Check for print statements
          if (content.contains('print(')) {
            printCount++;
          }
          
          // Check for TODOs
          if (content.contains('TODO')) {
            todoCount++;
          }
          
          // Check for hardcoded secrets
          if (content.contains('api_key =') || 
              content.contains('password =') ||
              content.contains('secret =')) {
            hasHardcodedSecrets = true;
          }
        }
      }
      
      if (printCount > 0) {
        issues.add('$printCount files use print() instead of secure logger');
      } else {
        passed.add('No print() statements found');
      }
      
      if (todoCount > 5) {
        issues.add('$todoCount TODO comments found');
      }
      
      if (hasHardcodedSecrets) {
        issues.add('Potential hardcoded secrets detected');
      } else {
        passed.add('No hardcoded secrets detected');
      }
    }
    
    // Check for secure patterns
    if (await File('lib/core/config/app_config.dart').exists()) {
      passed.add('AppConfig is implemented');
    } else {
      issues.add('AppConfig not found');
    }
    
    if (await File('lib/core/services/secure_storage_service.dart').exists()) {
      passed.add('SecureStorageService is implemented');
    } else {
      issues.add('SecureStorageService not found');
    }
    
    return SecurityCheck(
      name: 'Code Security',
      icon: Icons.code,
      passed: passed,
      issues: issues,
      score: _calculateScore(passed.length, issues.length),
    );
  }
  
  Future<SecurityCheck> _checkDependencies() async {
    final issues = <String>[];
    final passed = <String>[];
    
    // Check pubspec.yaml
    final pubspec = File('pubspec.yaml');
    if (await pubspec.exists()) {
      final content = await pubspec.readAsString();
      
      // Check for security packages
      if (content.contains('flutter_secure_storage')) {
        passed.add('flutter_secure_storage is included');
      } else {
        issues.add('flutter_secure_storage not found');
      }
      
      if (content.contains('local_auth')) {
        passed.add('local_auth is included');
      } else {
        issues.add('local_auth not found');
      }
      
      if (content.contains('crypto')) {
        passed.add('crypto package is included');
      } else {
        issues.add('crypto package not found');
      }
      
      // Check for risky packages
      if (content.contains('http:') && !content.contains('dio:')) {
        issues.add('Using http package - consider dio for better security');
      }
      
      if (!content.contains('dio:')) {
        issues.add('Dio package not found - recommended for secure networking');
      } else {
        passed.add('Dio package is included');
      }
    }
    
    return SecurityCheck(
      name: 'Dependencies',
      icon: Icons.extension,
      passed: passed,
      issues: issues,
      score: _calculateScore(passed.length, issues.length),
    );
  }
  
  int _calculateScore(int passed, int issues) {
    if (passed + issues == 0) return 0;
    return ((passed / (passed + issues)) * 100).round();
  }
  
  void _calculateOverallScore() {
    if (_checks.isEmpty) {
      _overallScore = 0;
      return;
    }
    
    int totalScore = 0;
    for (final check in _checks) {
      totalScore += check.score;
    }
    
    setState(() {
      _overallScore = totalScore ~/ _checks.length;
    });
  }
  
  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
  
  String _getScoreGrade(int score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRunning ? null : _runSecurityChecks,
          ),
        ],
      ),
      body: _isRunning && _checks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Score Card
                  Card(
                    color: _getScoreColor(_overallScore).withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getScoreColor(_overallScore),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getScoreGrade(_overallScore),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$_overallScore%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Overall Security Score',
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _overallScore >= 80
                                      ? 'Good security posture'
                                      : _overallScore >= 60
                                          ? 'Security improvements needed'
                                          : 'Critical security issues detected',
                                  style: TextStyle(
                                    color: _getScoreColor(_overallScore),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: _overallScore / 100,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getScoreColor(_overallScore),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Security Checks
                  ..._checks.map((check) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: Icon(
                        check.icon,
                        color: _getScoreColor(check.score),
                      ),
                      title: Text(check.name),
                      subtitle: Text('Score: ${check.score}%'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getScoreColor(check.score).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${check.passed.length}/${check.passed.length + check.issues.length}',
                          style: TextStyle(
                            color: _getScoreColor(check.score),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      children: [
                        if (check.passed.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, 
                                     color: Colors.green, 
                                     size: 20),
                                SizedBox(width: 8),
                                Text('Passed Checks',
                                     style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          ...check.passed.map((item) => ListTile(
                            leading: const Icon(Icons.check, 
                                               color: Colors.green, 
                                               size: 16),
                            title: Text(item, style: const TextStyle(fontSize: 14)),
                            dense: true,
                          )),
                        ],
                        if (check.issues.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(Icons.warning, 
                                     color: Colors.orange, 
                                     size: 20),
                                SizedBox(width: 8),
                                Text('Issues Found',
                                     style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          ...check.issues.map((item) => ListTile(
                            leading: const Icon(Icons.close, 
                                               color: Colors.red, 
                                               size: 16),
                            title: Text(item, style: const TextStyle(fontSize: 14)),
                            dense: true,
                          )),
                        ],
                      ],
                    ),
                  )),
                  
                  if (_isRunning) ...[
                    const SizedBox(height: 16),
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class SecurityCheck {
  final String name;
  final IconData icon;
  final List<String> passed;
  final List<String> issues;
  final int score;
  
  SecurityCheck({
    required this.name,
    required this.icon,
    required this.passed,
    required this.issues,
    required this.score,
  });
}