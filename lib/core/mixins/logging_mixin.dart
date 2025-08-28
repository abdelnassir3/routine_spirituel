import 'package:flutter/foundation.dart';
import '../services/secure_logging_service.dart';

/// Mixin pour ajouter des capacités de logging à n'importe quelle classe
mixin LoggingMixin {
  late final SecureLoggingService _logger = SecureLoggingService.instance;

  /// Nom de la classe pour contexte (override si nécessaire)
  String get loggerName => runtimeType.toString();

  /// Log debug avec contexte automatique
  @protected
  void logDebug(String message, [Map<String, dynamic>? data]) {
    _logger.debug('[$loggerName] $message', _addContext(data));
  }

  /// Log info avec contexte automatique
  @protected
  void logInfo(String message, [Map<String, dynamic>? data]) {
    _logger.info('[$loggerName] $message', _addContext(data));
  }

  /// Log warning avec contexte automatique
  @protected
  void logWarning(String message, [Map<String, dynamic>? data]) {
    _logger.warning('[$loggerName] $message', _addContext(data));
  }

  /// Log error avec contexte automatique
  @protected
  void logError(String message,
      [Map<String, dynamic>? data, StackTrace? stackTrace]) {
    _logger.error('[$loggerName] $message', _addContext(data), stackTrace);
  }

  /// Log critical avec contexte automatique
  @protected
  void logCritical(String message,
      [Map<String, dynamic>? data, StackTrace? stackTrace]) {
    _logger.critical('[$loggerName] $message', _addContext(data), stackTrace);
  }

  /// Ajouter le contexte de la classe aux données
  Map<String, dynamic>? _addContext(Map<String, dynamic>? data) {
    final contextData = <String, dynamic>{
      'class': loggerName,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (data != null) {
      contextData.addAll(data);
    }

    return contextData;
  }
}

/// Mixin pour logging dans les repositories
mixin RepositoryLoggingMixin on LoggingMixin {
  /// Log une opération de base de données
  @protected
  void logDatabaseOperation(
    String operation, {
    String? table,
    int? affectedRows,
    Duration? duration,
    Map<String, dynamic>? additionalData,
  }) {
    final data = <String, dynamic>{
      'operation': operation,
      if (table != null) 'table': table,
      if (affectedRows != null) 'affected_rows': affectedRows,
      if (duration != null) 'duration_ms': duration.inMilliseconds,
      ...?additionalData,
    };

    logDebug('Database operation: $operation', data);
  }

  /// Log une requête API
  @protected
  void logApiRequest(
    String method,
    String endpoint, {
    int? statusCode,
    Duration? duration,
    Map<String, dynamic>? additionalData,
  }) {
    final data = <String, dynamic>{
      'method': method,
      'endpoint': endpoint,
      if (statusCode != null) 'status_code': statusCode,
      if (duration != null) 'duration_ms': duration.inMilliseconds,
      ...?additionalData,
    };

    if (statusCode != null && statusCode >= 400) {
      logError('API request failed: $method $endpoint', data);
    } else {
      logInfo('API request: $method $endpoint', data);
    }
  }
}

/// Mixin pour logging dans les services
mixin ServiceLoggingMixin on LoggingMixin {
  /// Log le démarrage d'un service
  @protected
  void logServiceStart([Map<String, dynamic>? config]) {
    logInfo('Service started', config);
  }

  /// Log l'arrêt d'un service
  @protected
  void logServiceStop([String? reason]) {
    logInfo('Service stopped', reason != null ? {'reason': reason} : null);
  }

  /// Log une opération de service
  @protected
  void logServiceOperation(
    String operation, {
    bool success = true,
    Duration? duration,
    Map<String, dynamic>? additionalData,
  }) {
    final data = <String, dynamic>{
      'operation': operation,
      'success': success,
      if (duration != null) 'duration_ms': duration.inMilliseconds,
      ...?additionalData,
    };

    if (success) {
      logDebug('Service operation: $operation', data);
    } else {
      logWarning('Service operation failed: $operation', data);
    }
  }
}

/// Mixin pour logging dans les contrôleurs/ViewModels
mixin ControllerLoggingMixin on LoggingMixin {
  /// Log une action utilisateur
  @protected
  void logUserAction(String action, [Map<String, dynamic>? details]) {
    logInfo('User action: $action', details);
  }

  /// Log un changement d'état
  @protected
  void logStateChange(String fromState, String toState,
      [Map<String, dynamic>? details]) {
    logDebug('State change: $fromState → $toState', details);
  }

  /// Log une validation
  @protected
  void logValidation(String field, bool isValid, [String? errorMessage]) {
    final data = <String, dynamic>{
      'field': field,
      'is_valid': isValid,
      if (errorMessage != null) 'error': errorMessage,
    };

    if (isValid) {
      logDebug('Validation passed: $field', data);
    } else {
      logWarning('Validation failed: $field', data);
    }
  }
}

/// Mixin pour logging de performance
mixin PerformanceLoggingMixin on LoggingMixin {
  final Map<String, DateTime> _performanceTimers = {};

  /// Démarrer un timer de performance
  @protected
  void startPerformanceTimer(String operation) {
    _performanceTimers[operation] = DateTime.now();
    logDebug('Performance timer started: $operation');
  }

  /// Arrêter un timer de performance et logger le résultat
  @protected
  Duration? stopPerformanceTimer(
    String operation, {
    Map<String, dynamic>? additionalData,
    bool logResult = true,
  }) {
    final startTime = _performanceTimers.remove(operation);
    if (startTime == null) {
      logWarning('Performance timer not found: $operation');
      return null;
    }

    final duration = DateTime.now().difference(startTime);

    if (logResult) {
      final data = <String, dynamic>{
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        ...?additionalData,
      };

      // Log comme warning si trop lent
      if (duration.inMilliseconds > 1000) {
        logWarning('Slow operation detected: $operation', data);
      } else {
        logDebug('Performance: $operation completed', data);
      }
    }

    return duration;
  }

  /// Mesurer le temps d'exécution d'une fonction
  @protected
  Future<T> measureAsync<T>(
    String operation,
    Future<T> Function() function, {
    Map<String, dynamic>? additionalData,
  }) async {
    startPerformanceTimer(operation);
    try {
      final result = await function();
      stopPerformanceTimer(operation, additionalData: additionalData);
      return result;
    } catch (e, stack) {
      stopPerformanceTimer(operation, additionalData: {
        ...?additionalData,
        'error': e.toString(),
      });
      logError('Operation failed: $operation', {'error': e.toString()}, stack);
      rethrow;
    }
  }

  /// Mesurer le temps d'exécution d'une fonction synchrone
  @protected
  T measureSync<T>(
    String operation,
    T Function() function, {
    Map<String, dynamic>? additionalData,
  }) {
    startPerformanceTimer(operation);
    try {
      final result = function();
      stopPerformanceTimer(operation, additionalData: additionalData);
      return result;
    } catch (e, stack) {
      stopPerformanceTimer(operation, additionalData: {
        ...?additionalData,
        'error': e.toString(),
      });
      logError('Operation failed: $operation', {'error': e.toString()}, stack);
      rethrow;
    }
  }
}
