import 'dart:convert';
import 'package:flutter/foundation.dart';

enum TtsLogLevel {
  debug,
  info,
  warning,
  error,
}

/// Service de logging structuré pour TTS
/// Masque automatiquement les données sensibles
class TtsLogger {
  static TtsLogLevel _minLevel =
      kDebugMode ? TtsLogLevel.debug : TtsLogLevel.info;

  static void setMinLevel(TtsLogLevel level) {
    _minLevel = level;
  }

  static void debug(String message, [Map<String, dynamic>? data]) {
    _log(TtsLogLevel.debug, message, data);
  }

  static void info(String message, [Map<String, dynamic>? data]) {
    _log(TtsLogLevel.info, message, data);
  }

  static void warning(String message, [Map<String, dynamic>? data]) {
    _log(TtsLogLevel.warning, message, data);
  }

  static void error(String message,
      [Map<String, dynamic>? data, Object? error, StackTrace? stackTrace]) {
    final errorData = {
      ...?data,
      if (error != null) 'error': _sanitizeError(error),
      if (stackTrace != null && kDebugMode)
        'stackTrace': stackTrace.toString().split('\n').take(5).join('\n'),
    };
    _log(TtsLogLevel.error, message, errorData);
  }

  static void metric(String name, dynamic value, [Map<String, dynamic>? tags]) {
    _log(TtsLogLevel.info, 'METRIC', {
      'metric': name,
      'value': value,
      ...?tags,
    });
  }

  static void _log(
      TtsLogLevel level, String message, Map<String, dynamic>? data) {
    if (level.index < _minLevel.index) return;

    final timestamp = DateTime.now().toUtc().toIso8601String();
    final logEntry = {
      'timestamp': timestamp,
      'level': level.name,
      'message': message,
      if (data != null) 'data': _sanitizeData(data),
    };

    // En production, envoyer vers service de monitoring
    // Pour l'instant, affichage console en mode debug seulement
    if (kDebugMode) {
      final output = jsonEncode(logEntry);
      debugPrint('[TTS] $output');
    }
  }

  /// Masque les données sensibles dans les logs
  static Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    return data.map((key, value) {
      // Liste des clés sensibles à masquer
      const sensitiveKeys = [
        'apikey',
        'api_key',
        'apiKey',
        'password',
        'secret',
        'token',
        'authorization',
        'x-api-key',
      ];

      // Masquer les clés sensibles
      if (sensitiveKeys
          .any((k) => key.toLowerCase().contains(k.toLowerCase()))) {
        if (value is String && value.isNotEmpty) {
          return MapEntry(key, _maskString(value));
        }
      }

      // Tronquer les textes trop longs (potentiellement du contenu utilisateur)
      if (key.toLowerCase().contains('text') ||
          key.toLowerCase().contains('content')) {
        if (value is String && value.length > 100) {
          return MapEntry(
              key, '${value.substring(0, 50)}...[${value.length} chars]');
        }
      }

      // Récursif pour les maps imbriquées
      if (value is Map<String, dynamic>) {
        return MapEntry(key, _sanitizeData(value));
      }

      // Récursif pour les listes
      if (value is List) {
        return MapEntry(
            key,
            value.map((item) {
              if (item is Map<String, dynamic>) {
                return _sanitizeData(item);
              }
              return item;
            }).toList());
      }

      return MapEntry(key, value);
    });
  }

  /// Masque une chaîne sensible
  static String _maskString(String value) {
    if (value.length <= 8) return '****';
    return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
  }

  /// Nettoie les erreurs pour les logs
  static Map<String, dynamic> _sanitizeError(Object error) {
    final errorString = error.toString();

    // Supprimer les chemins de fichiers complets
    final sanitized = errorString
        .replaceAll(RegExp(r'\/Users\/[^\/]+\/'), '/~/')
        .replaceAll(RegExp(r'C:\\Users\\[^\\]+\\'), 'C:\\~\\');

    return {
      'type': error.runtimeType.toString(),
      'message': sanitized.length > 500
          ? '${sanitized.substring(0, 500)}...'
          : sanitized,
    };
  }
}

/// Helper pour mesurer les performances
class TtsPerformanceTimer {
  final String operation;
  final DateTime _start;
  final Map<String, dynamic>? tags;

  TtsPerformanceTimer(this.operation, [this.tags]) : _start = DateTime.now();

  void stop() {
    final duration = DateTime.now().difference(_start).inMilliseconds;
    TtsLogger.metric('tts.$operation.duration', duration, {
      ...?tags,
      'unit': 'ms',
    });
  }
}
