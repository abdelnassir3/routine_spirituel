import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../config/app_config.dart';

/// Service de logging sécurisé sans PII
///
/// Ce service assure que les logs ne contiennent jamais d'informations
/// personnellement identifiables (PII) comme :
/// - Emails, noms, numéros de téléphone
/// - Tokens, mots de passe, clés API
/// - Adresses IP, locations GPS
/// - IDs utilisateur non anonymisés
class SecureLoggingService {
  static SecureLoggingService? _instance;
  static const int _maxLogFileSize = 10 * 1024 * 1024; // 10MB
  static const int _maxLogFiles = 5;

  final List<LogEntry> _memoryBuffer = [];
  static const int _maxMemoryBuffer = 100;

  File? _currentLogFile;
  IOSink? _logSink;

  // Patterns PII à filtrer
  static final List<RegExp> _piiPatterns = [
    // Email
    RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
    // Numéro de téléphone (formats variés)
    RegExp(
        r'\b(?:\+?[1-9]\d{0,2}[\s.-]?)?\(?\d{1,4}\)?[\s.-]?\d{1,4}[\s.-]?\d{1,4}\b'),
    // Carte de crédit
    RegExp(r'\b(?:\d{4}[\s-]?){3}\d{4}\b'),
    // Numéro de sécurité sociale français
    RegExp(r'\b[12]\s?\d{2}\s?\d{2}\s?\d{2}\s?\d{3}\s?\d{3}\b'),
    // Token Bearer
    RegExp(r'Bearer\s+[A-Za-z0-9\-._~\+\/]+=*', caseSensitive: false),
    // Clés API communes
    RegExp(
        r'(api[_-]?key|apikey|api_secret|access[_-]?token|auth[_-]?token|authorization)\s*[:=]\s*["\x27]?[\w\-]+["\x27]?',
        caseSensitive: false),
    // Mots de passe
    RegExp(r'(password|passwd|pwd|pass)\s*[:=]\s*["\x27]?[^"\x27]+["\x27]?',
        caseSensitive: false),
    // Adresse IP
    RegExp(r'\b(?:\d{1,3}\.){3}\d{1,3}\b'),
    // UUID
    RegExp(r'\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b',
        caseSensitive: false),
    // Coordonnées GPS
    RegExp(
        r'[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?),\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)'),
  ];

  // Singleton
  static SecureLoggingService get instance {
    _instance ??= SecureLoggingService._();
    return _instance!;
  }

  SecureLoggingService._() {
    _initializeLogging();
  }

  Future<void> _initializeLogging() async {
    if (!kDebugMode && AppConfig.isProduction) {
      // En production, initialiser le fichier de log
      await _setupLogFile();
    }
  }

  Future<void> _setupLogFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logsDir = Directory(path.join(dir.path, 'logs'));

      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      // Nettoyer les vieux logs
      await _cleanOldLogs(logsDir);

      // Créer nouveau fichier de log
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentLogFile = File(path.join(logsDir.path, 'app_$timestamp.log'));
      _logSink = _currentLogFile!.openWrite(mode: FileMode.append);
    } catch (e) {
      if (kDebugMode) {
        print('SecureLogging: Failed to setup log file: $e');
      }
    }
  }

  Future<void> _cleanOldLogs(Directory logsDir) async {
    try {
      final files = await logsDir.list().toList();
      final logFiles = files
          .whereType<File>()
          .where((f) => f.path.endsWith('.log'))
          .toList();

      // Trier par date de modification
      logFiles.sort((a, b) {
        final aTime = a.statSync().modified;
        final bTime = b.statSync().modified;
        return bTime.compareTo(aTime);
      });

      // Supprimer les fichiers excédentaires
      if (logFiles.length >= _maxLogFiles) {
        for (int i = _maxLogFiles - 1; i < logFiles.length; i++) {
          await logFiles[i].delete();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('SecureLogging: Failed to clean old logs: $e');
      }
    }
  }

  // ===== Méthodes de logging =====

  void debug(String message, [Map<String, dynamic>? data]) {
    _log(LogLevel.debug, message, data);
  }

  void info(String message, [Map<String, dynamic>? data]) {
    _log(LogLevel.info, message, data);
  }

  void warning(String message, [Map<String, dynamic>? data]) {
    _log(LogLevel.warning, message, data);
  }

  void error(String message,
      [Map<String, dynamic>? data, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, data, stackTrace: stackTrace);
  }

  void critical(String message,
      [Map<String, dynamic>? data, StackTrace? stackTrace]) {
    _log(LogLevel.critical, message, data, stackTrace: stackTrace);
  }

  // ===== Logging principal =====

  void _log(
    LogLevel level,
    String message,
    Map<String, dynamic>? data, {
    StackTrace? stackTrace,
  }) {
    // Filtrer les PII du message
    final sanitizedMessage = _sanitizeText(message);

    // Filtrer les PII des données
    final sanitizedData = data != null ? _sanitizeData(data) : null;

    // Créer l'entrée de log
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: sanitizedMessage,
      data: sanitizedData,
      stackTrace: stackTrace,
      environment: AppConfig.environment.name,
      sessionId: _generateSessionId(),
    );

    // En debug, afficher dans la console
    if (kDebugMode) {
      _printToConsole(entry);
    }

    // Ajouter au buffer mémoire
    _addToMemoryBuffer(entry);

    // Écrire dans le fichier si configuré
    if (!kDebugMode && _logSink != null) {
      _writeToFile(entry);
    }

    // Envoyer à Sentry si configuré et niveau approprié
    if (level.index >= LogLevel.error.index && AppConfig.sentryDsn != null) {
      _sendToSentry(entry);
    }
  }

  // ===== Filtrage PII =====

  String _sanitizeText(String text) {
    var sanitized = text;

    // Appliquer tous les patterns de filtrage
    for (final pattern in _piiPatterns) {
      sanitized = sanitized.replaceAllMapped(pattern, (match) {
        final matchText = match.group(0)!;

        // Déterminer le type de donnée pour un remplacement approprié
        if (matchText.contains('@')) {
          return '[EMAIL_REDACTED]';
        } else if (RegExp(r'^\+?\d').hasMatch(matchText) &&
            matchText.length > 6) {
          return '[PHONE_REDACTED]';
        } else if (matchText.toLowerCase().contains('token') ||
            matchText.toLowerCase().contains('bearer')) {
          return '[TOKEN_REDACTED]';
        } else if (matchText.toLowerCase().contains('key')) {
          return '[API_KEY_REDACTED]';
        } else if (matchText.toLowerCase().contains('pass')) {
          return '[PASSWORD_REDACTED]';
        } else if (RegExp(r'^[\d\.]+$').hasMatch(matchText)) {
          return '[IP_REDACTED]';
        } else if (matchText.contains('-') && matchText.length > 30) {
          return '[UUID_REDACTED]';
        } else {
          return '[PII_REDACTED]';
        }
      });
    }

    return sanitized;
  }

  Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      // Filtrer les clés sensibles
      if (_isSensitiveKey(key)) {
        sanitized[key] = '[REDACTED]';
        continue;
      }

      // Traiter les valeurs
      if (value is String) {
        sanitized[key] = _sanitizeText(value);
      } else if (value is Map<String, dynamic>) {
        sanitized[key] = _sanitizeData(value);
      } else if (value is List) {
        sanitized[key] = value.map((item) {
          if (item is String) {
            return _sanitizeText(item);
          } else if (item is Map<String, dynamic>) {
            return _sanitizeData(item);
          }
          return item;
        }).toList();
      } else {
        // Pour les autres types (int, bool, etc.), garder tel quel
        sanitized[key] = value;
      }
    }

    return sanitized;
  }

  bool _isSensitiveKey(String key) {
    final lowerKey = key.toLowerCase();
    final sensitiveKeywords = [
      'password',
      'pwd',
      'pass',
      'token',
      'secret',
      'key',
      'api',
      'email',
      'mail',
      'phone',
      'tel',
      'mobile',
      'ssn',
      'social',
      'credit',
      'card',
      'lat',
      'lng',
      'longitude',
      'latitude',
      'ip',
      'address',
      'user_id',
      'userid',
      'username',
    ];

    return sensitiveKeywords.any((keyword) => lowerKey.contains(keyword));
  }

  // ===== Helpers =====

  String _generateSessionId() {
    // Générer un ID de session anonyme basé sur le timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = timestamp.hashCode.toRadixString(16);
    return 'session_$hash';
  }

  void _addToMemoryBuffer(LogEntry entry) {
    _memoryBuffer.add(entry);

    // Limiter la taille du buffer
    if (_memoryBuffer.length > _maxMemoryBuffer) {
      _memoryBuffer.removeAt(0);
    }
  }

  void _printToConsole(LogEntry entry) {
    final emoji = _getLogEmoji(entry.level);
    final color = _getLogColor(entry.level);

    print(
        '$color$emoji ${entry.level.name.toUpperCase()} [${entry.timestamp.toIso8601String()}]');
    print('  ${entry.message}');

    if (entry.data != null && entry.data!.isNotEmpty) {
      print('  Data: ${jsonEncode(entry.data)}');
    }

    if (entry.stackTrace != null) {
      print('  Stack trace:\n${entry.stackTrace}');
    }

    print('\x1B[0m'); // Reset color
  }

  String _getLogEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🚨';
    }
  }

  String _getLogColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '\x1B[36m'; // Cyan
      case LogLevel.info:
        return '\x1B[34m'; // Blue
      case LogLevel.warning:
        return '\x1B[33m'; // Yellow
      case LogLevel.error:
        return '\x1B[31m'; // Red
      case LogLevel.critical:
        return '\x1B[35m'; // Magenta
    }
  }

  Future<void> _writeToFile(LogEntry entry) async {
    try {
      if (_logSink != null) {
        final json = entry.toJson();
        _logSink!.writeln(jsonEncode(json));

        // Vérifier la taille du fichier
        if (_currentLogFile != null) {
          final size = await _currentLogFile!.length();
          if (size > _maxLogFileSize) {
            await _rotateLogFile();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('SecureLogging: Failed to write to file: $e');
      }
    }
  }

  Future<void> _rotateLogFile() async {
    try {
      await _logSink?.close();
      await _setupLogFile();
    } catch (e) {
      if (kDebugMode) {
        print('SecureLogging: Failed to rotate log file: $e');
      }
    }
  }

  void _sendToSentry(LogEntry entry) {
    // TODO: Implémenter l'envoi à Sentry
    // Cette méthode serait appelée pour envoyer les erreurs à Sentry
    // en utilisant le package sentry_flutter
  }

  // ===== Méthodes publiques utilitaires =====

  /// Obtenir les logs récents du buffer mémoire
  List<LogEntry> getRecentLogs({LogLevel? minLevel}) {
    if (minLevel == null) {
      return List.unmodifiable(_memoryBuffer);
    }

    return _memoryBuffer
        .where((entry) => entry.level.index >= minLevel.index)
        .toList();
  }

  /// Effacer le buffer mémoire
  void clearMemoryBuffer() {
    _memoryBuffer.clear();
  }

  /// Exporter les logs vers un fichier
  Future<File?> exportLogs() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final exportFile = File(path.join(
        dir.path,
        'export_${DateTime.now().millisecondsSinceEpoch}.log',
      ));

      final logs = _memoryBuffer.map((e) => jsonEncode(e.toJson())).join('\n');
      await exportFile.writeAsString(logs);

      return exportFile;
    } catch (e) {
      error('Failed to export logs', {'error': e.toString()});
      return null;
    }
  }

  /// Analyser les logs pour des patterns
  Map<String, int> analyzeLogs() {
    final analysis = <String, int>{
      'total': _memoryBuffer.length,
      'debug': 0,
      'info': 0,
      'warning': 0,
      'error': 0,
      'critical': 0,
    };

    for (final entry in _memoryBuffer) {
      analysis[entry.level.name] = (analysis[entry.level.name] ?? 0) + 1;
    }

    return analysis;
  }

  /// Nettoyer et fermer les ressources
  Future<void> dispose() async {
    await _logSink?.flush();
    await _logSink?.close();
    _memoryBuffer.clear();
  }
}

// ===== Classes de support =====

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final Map<String, dynamic>? data;
  final StackTrace? stackTrace;
  final String environment;
  final String sessionId;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.data,
    this.stackTrace,
    required this.environment,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'level': level.name,
        'message': message,
        'data': data,
        'stackTrace': stackTrace?.toString(),
        'environment': environment,
        'sessionId': sessionId,
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
        timestamp: DateTime.parse(json['timestamp'] as String),
        level: LogLevel.values.firstWhere((e) => e.name == (json['level'] as String)),
        message: json['message'] as String,
        data: json['data'] as Map<String, dynamic>?,
        stackTrace: json['stackTrace'] != null
            ? StackTrace.fromString(json['stackTrace'] as String)
            : null,
        environment: json['environment'] as String,
        sessionId: json['sessionId'] as String,
      );
}
