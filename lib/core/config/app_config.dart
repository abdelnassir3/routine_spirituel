import 'package:flutter/foundation.dart';

/// Secure application configuration using compile-time constants
///
/// Usage:
/// ```bash
/// flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///            --dart-define=SUPABASE_ANON_KEY=xxx
/// ```
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  // ===== Core Configuration =====

  /// Application environment
  static Environment get environment {
    const env =
        String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    return Environment.values.firstWhere(
      (e) => e.name == env,
      orElse: () => Environment.development,
    );
  }

  /// Check if running in production
  static bool get isProduction => environment == Environment.production;

  /// Check if running in development
  static bool get isDevelopment => environment == Environment.development;

  /// Check if debug mode is enabled
  static bool get isDebugMode {
    if (kDebugMode) return true;
    return const bool.fromEnvironment('DEBUG_MODE', defaultValue: false);
  }

  // ===== Supabase Configuration =====

  /// Supabase project URL
  static String get supabaseUrl {
    const url = String.fromEnvironment('SUPABASE_URL');
    if (url.isEmpty && !isProduction) {
      // Allow empty in development for offline mode
      return 'https://localhost:54321';
    }
    if (url.isEmpty) {
      throw ConfigurationException(
        'SUPABASE_URL not configured. '
        'Run with --dart-define=SUPABASE_URL=your-url',
      );
    }
    return url;
  }

  /// Supabase anonymous key (safe for client-side)
  static String get supabaseAnonKey {
    const key = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (key.isEmpty && !isProduction) {
      // Allow empty in development for offline mode
      return 'development-key';
    }
    if (key.isEmpty) {
      throw ConfigurationException(
        'SUPABASE_ANON_KEY not configured. '
        'Run with --dart-define=SUPABASE_ANON_KEY=your-key',
      );
    }
    return key;
  }

  /// Check if Supabase is configured
  static bool get hasSupabaseConfig {
    try {
      return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ===== Optional API Keys =====

  /// OpenAI API key (optional)
  static String? get openAiKey {
    const key = String.fromEnvironment('OPENAI_API_KEY');
    return key.isEmpty ? null : key;
  }

  /// Google Maps API key (optional)
  static String? get googleMapsKey {
    const key = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    return key.isEmpty ? null : key;
  }

  // ===== Error Tracking =====

  /// Sentry DSN for error tracking
  static String? get sentryDsn {
    const dsn = String.fromEnvironment('SENTRY_DSN');
    return dsn.isEmpty ? null : dsn;
  }

  /// Check if error tracking is enabled
  static bool get isErrorTrackingEnabled {
    if (!isProduction) return false;
    return sentryDsn != null && sentryDsn!.isNotEmpty;
  }

  // ===== Analytics =====

  /// Mixpanel token
  static String? get mixpanelToken {
    const token = String.fromEnvironment('MIXPANEL_TOKEN');
    return token.isEmpty ? null : token;
  }

  /// Amplitude API key
  static String? get amplitudeKey {
    const key = String.fromEnvironment('AMPLITUDE_API_KEY');
    return key.isEmpty ? null : key;
  }

  /// Check if analytics is enabled
  static bool get isAnalyticsEnabled {
    if (!isProduction) return false;
    const enabled =
        bool.fromEnvironment('ENABLE_ANALYTICS', defaultValue: false);
    return enabled && (mixpanelToken != null || amplitudeKey != null);
  }

  // ===== Feature Flags =====

  /// Enable Crashlytics
  static bool get enableCrashlytics {
    return const bool.fromEnvironment(
      'ENABLE_CRASHLYTICS',
      defaultValue: false,
    );
  }

  /// Enable performance monitoring
  static bool get enablePerformanceMonitoring {
    return const bool.fromEnvironment(
      'ENABLE_PERFORMANCE_MONITORING',
      defaultValue: false,
    );
  }

  // ===== Security Configuration =====

  /// Certificate pinning enabled
  static bool get enableCertificatePinning {
    return isProduction;
  }

  /// Expected certificate fingerprints for pinning
  static List<String> get certificateFingerprints {
    // Add your server's certificate fingerprints here
    return [
      // 'SHA256:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    ];
  }

  /// API request timeout in seconds
  static int get apiTimeoutSeconds {
    return const int.fromEnvironment(
      'API_TIMEOUT_SECONDS',
      defaultValue: 30,
    );
  }

  /// Maximum retry attempts for failed requests
  static int get maxRetryAttempts {
    return const int.fromEnvironment(
      'MAX_RETRY_ATTEMPTS',
      defaultValue: 3,
    );
  }

  // ===== Validation & Helpers =====

  /// Validate configuration on app start
  static void validate() {
    if (isProduction) {
      // In production, certain configs must be present
      if (!hasSupabaseConfig) {
        throw ConfigurationException(
          'Supabase configuration is required in production',
        );
      }
    }

    // Log configuration status (without exposing secrets)
    _logConfiguration();
  }

  /// Log configuration status (safe for production)
  static void _logConfiguration() {
    final configs = <String, String>{
      'Environment': environment.name,
      'Debug Mode': isDebugMode.toString(),
      'Supabase': hasSupabaseConfig ? 'Configured' : 'Not configured',
      'OpenAI': openAiKey != null ? 'Configured' : 'Not configured',
      'Error Tracking': isErrorTrackingEnabled ? 'Enabled' : 'Disabled',
      'Analytics': isAnalyticsEnabled ? 'Enabled' : 'Disabled',
      'Crashlytics': enableCrashlytics ? 'Enabled' : 'Disabled',
      'Performance': enablePerformanceMonitoring ? 'Enabled' : 'Disabled',
      'Certificate Pinning': enableCertificatePinning ? 'Enabled' : 'Disabled',
    };

    if (isDebugMode) {
      print('=== App Configuration ===');
      configs.forEach((key, value) {
        print('$key: $value');
      });
      print('========================');
    }
  }

  /// Get safe configuration for logging (no secrets)
  static Map<String, dynamic> getSafeConfig() {
    return {
      'environment': environment.name,
      'debug': isDebugMode,
      'supabase_configured': hasSupabaseConfig,
      'error_tracking': isErrorTrackingEnabled,
      'analytics': isAnalyticsEnabled,
      'crashlytics': enableCrashlytics,
      'performance_monitoring': enablePerformanceMonitoring,
    };
  }
}

/// Application environments
enum Environment {
  development,
  staging,
  production,
}

/// Configuration exception
class ConfigurationException implements Exception {
  final String message;

  ConfigurationException(this.message);

  @override
  String toString() => 'ConfigurationException: $message';
}
