import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_logging_service.dart';

/// Provider pour le service de logging sécurisé
final loggingProvider = Provider<SecureLoggingService>((ref) {
  return SecureLoggingService.instance;
});

/// Provider pour obtenir les logs récents
final recentLogsProvider = Provider<List<LogEntry>>((ref) {
  final logging = ref.watch(loggingProvider);
  return logging.getRecentLogs();
});

/// Provider pour obtenir les logs d'erreur récents
final recentErrorLogsProvider = Provider<List<LogEntry>>((ref) {
  final logging = ref.watch(loggingProvider);
  return logging.getRecentLogs(minLevel: LogLevel.error);
});

/// Provider pour l'analyse des logs
final logAnalysisProvider = Provider<Map<String, int>>((ref) {
  final logging = ref.watch(loggingProvider);
  return logging.analyzeLogs();
});

/// Classe d'extension pour faciliter le logging dans les widgets
extension LoggingWidgetRef on WidgetRef {
  SecureLoggingService get logger => read(loggingProvider);

  void logDebug(String message, [Map<String, dynamic>? data]) {
    logger.debug(message, data);
  }

  void logInfo(String message, [Map<String, dynamic>? data]) {
    logger.info(message, data);
  }

  void logWarning(String message, [Map<String, dynamic>? data]) {
    logger.warning(message, data);
  }

  void logError(String message,
      [Map<String, dynamic>? data, StackTrace? stackTrace]) {
    logger.error(message, data, stackTrace);
  }

  void logCritical(String message,
      [Map<String, dynamic>? data, StackTrace? stackTrace]) {
    logger.critical(message, data, stackTrace);
  }
}
