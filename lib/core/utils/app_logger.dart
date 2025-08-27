import 'package:flutter/foundation.dart';
import '../services/secure_logging_service.dart';
import '../config/app_config.dart';

/// Classe utilitaire pour le logging global de l'application
class AppLogger {
  static final SecureLoggingService _logger = SecureLoggingService.instance;
  
  // ===== Lifecycle Events =====
  
  static void logAppStart() {
    _logger.info('Application started', {
      'environment': AppConfig.environment.name,
      'debug_mode': AppConfig.isDebugMode,
      'platform': defaultTargetPlatform.name,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  static void logAppResume() {
    _logger.debug('Application resumed');
  }
  
  static void logAppPause() {
    _logger.debug('Application paused');
  }
  
  static void logAppStop() {
    _logger.info('Application stopped');
  }
  
  // ===== Navigation Events =====
  
  static void logNavigation(String from, String to, [Map<String, dynamic>? params]) {
    _logger.info('Navigation', {
      'from': from,
      'to': to,
      if (params != null) 'params': params,
    });
  }
  
  static void logScreenView(String screenName, [Map<String, dynamic>? properties]) {
    _logger.info('Screen view', {
      'screen': screenName,
      if (properties != null) ...properties,
    });
  }
  
  // ===== User Events =====
  
  static void logUserLogin(String method, {bool success = true}) {
    if (success) {
      _logger.info('User login successful', {
        'method': method,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } else {
      _logger.warning('User login failed', {
        'method': method,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }
  
  static void logUserLogout([String? reason]) {
    _logger.info('User logout', {
      if (reason != null) 'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  static void logUserAction(String action, [Map<String, dynamic>? details]) {
    _logger.info('User action', {
      'action': action,
      if (details != null) ...details,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  // ===== Feature Events =====
  
  static void logFeatureUsage(String feature, [Map<String, dynamic>? properties]) {
    _logger.info('Feature usage', {
      'feature': feature,
      if (properties != null) ...properties,
    });
  }
  
  static void logPrayerSession({
    required String routineId,
    required String action,
    int? counter,
    Duration? duration,
  }) {
    _logger.info('Prayer session', {
      'routine_id': routineId,
      'action': action,
      if (counter != null) 'counter': counter,
      if (duration != null) 'duration_seconds': duration.inSeconds,
    });
  }
  
  // ===== Performance Events =====
  
  static void logPerformance(String metric, double value, [String? unit]) {
    final level = value > 1000 ? LogLevel.warning : LogLevel.debug;
    
    _logger.log(level, 'Performance metric', {
      'metric': metric,
      'value': value,
      if (unit != null) 'unit': unit,
    });
  }
  
  static void logSlowOperation(String operation, Duration duration) {
    _logger.warning('Slow operation detected', {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
    });
  }
  
  // ===== Error Events =====
  
  static void logError(
    String context,
    dynamic error, [
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  ]) {
    _logger.error('Error occurred', {
      'context': context,
      'error_type': error.runtimeType.toString(),
      'error_message': error.toString(),
      if (additionalData != null) ...additionalData,
    }, stackTrace);
  }
  
  static void logCriticalError(
    String context,
    dynamic error, [
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  ]) {
    _logger.critical('Critical error', {
      'context': context,
      'error_type': error.runtimeType.toString(),
      'error_message': error.toString(),
      if (additionalData != null) ...additionalData,
    }, stackTrace);
  }
  
  static void logApiError({
    required String endpoint,
    required int statusCode,
    String? errorMessage,
    Map<String, dynamic>? requestData,
  }) {
    _logger.error('API error', {
      'endpoint': endpoint,
      'status_code': statusCode,
      if (errorMessage != null) 'error': errorMessage,
      if (requestData != null) 'request': requestData,
    });
  }
  
  // ===== Database Events =====
  
  static void logDatabaseOperation({
    required String operation,
    required String table,
    int? affectedRows,
    Duration? duration,
    bool success = true,
  }) {
    final data = {
      'operation': operation,
      'table': table,
      if (affectedRows != null) 'affected_rows': affectedRows,
      if (duration != null) 'duration_ms': duration.inMilliseconds,
      'success': success,
    };
    
    if (success) {
      _logger.debug('Database operation', data);
    } else {
      _logger.error('Database operation failed', data);
    }
  }
  
  // ===== Cache Events =====
  
  static void logCacheHit(String key) {
    _logger.debug('Cache hit', {'key': key});
  }
  
  static void logCacheMiss(String key) {
    _logger.debug('Cache miss', {'key': key});
  }
  
  static void logCacheEviction(String key, [String? reason]) {
    _logger.debug('Cache eviction', {
      'key': key,
      if (reason != null) 'reason': reason,
    });
  }
  
  // ===== Network Events =====
  
  static void logNetworkRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    Duration? duration,
    int? statusCode,
  }) {
    _logger.debug('Network request', {
      'method': method,
      'url': url,
      if (headers != null) 'headers': headers,
      if (duration != null) 'duration_ms': duration.inMilliseconds,
      if (statusCode != null) 'status_code': statusCode,
    });
  }
  
  static void logNetworkConnectivity(bool isConnected) {
    if (isConnected) {
      _logger.info('Network connected');
    } else {
      _logger.warning('Network disconnected');
    }
  }
  
  // ===== Security Events =====
  
  static void logSecurityEvent(String event, [Map<String, dynamic>? details]) {
    _logger.warning('Security event', {
      'event': event,
      if (details != null) ...details,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  static void logAuthenticationAttempt({
    required String method,
    required bool success,
    String? failureReason,
  }) {
    final data = {
      'method': method,
      'success': success,
      if (failureReason != null) 'failure_reason': failureReason,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    if (success) {
      _logger.info('Authentication successful', data);
    } else {
      _logger.warning('Authentication failed', data);
    }
  }
  
  // ===== Debug Helpers =====
  
  static void logDebugInfo(String message, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      _logger.debug(message, data);
    }
  }
  
  static void logTodo(String message) {
    if (kDebugMode) {
      _logger.debug('TODO: $message');
    }
  }
  
  static void logDeprecation(String feature, [String? alternative]) {
    _logger.warning('Deprecation warning', {
      'feature': feature,
      if (alternative != null) 'alternative': alternative,
    });
  }
}