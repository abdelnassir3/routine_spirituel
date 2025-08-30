import 'package:flutter_test/flutter_test.dart';
import 'package:spiritual_routines/core/services/secure_logging_service.dart';

void main() {
  group('SecureLoggingService', () {
    late SecureLoggingService logger;

    setUp(() {
      logger = SecureLoggingService.instance;
      logger.clearMemoryBuffer();
    });

    group('PII Filtering', () {
      test('should filter email addresses', () {
        logger.info('User email is john.doe@example.com for testing');

        final logs = logger.getRecentLogs();
        expect(logs.isNotEmpty, isTrue);
        expect(logs.last.message, contains('[EMAIL_REDACTED]'));
        expect(logs.last.message, isNot(contains('john.doe@example.com')));
      });

      test('should filter phone numbers', () {
        final testCases = [
          '+33 6 12 34 56 78',
          '06 12 34 56 78',
          '+1-555-123-4567',
          '(555) 123-4567',
        ];

        for (final phone in testCases) {
          logger.clearMemoryBuffer();
          logger.info('Contact phone: $phone');

          final logs = logger.getRecentLogs();
          expect(logs.last.message, contains('[PHONE_REDACTED]'));
          expect(logs.last.message, isNot(contains(phone)));
        }
      });

      test('should filter credit card numbers', () {
        logger.info('Card number: 4532 1234 5678 9012');

        final logs = logger.getRecentLogs();
        expect(logs.last.message, contains('[PII_REDACTED]'));
        expect(logs.last.message, isNot(contains('4532')));
      });

      test('should filter API keys and tokens', () {
        final testCases = [
          'api_key: sk-1234567890abcdef',
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
          'apikey=abcd1234efgh5678',
          'access_token: token_xyz123',
        ];

        for (final sensitive in testCases) {
          logger.clearMemoryBuffer();
          logger.info('Auth: $sensitive');

          final logs = logger.getRecentLogs();
          expect(
            logs.last.message,
            anyOf(
              contains('[TOKEN_REDACTED]'),
              contains('[API_KEY_REDACTED]'),
            ),
          );
        }
      });

      test('should filter passwords', () {
        final testCases = [
          'password: mySecretPass123',
          'pwd=test123',
          'pass: "super_secret"',
        ];

        for (final pwd in testCases) {
          logger.clearMemoryBuffer();
          logger.info('Login with $pwd');

          final logs = logger.getRecentLogs();
          expect(logs.last.message, contains('[PASSWORD_REDACTED]'));
          expect(logs.last.message, isNot(contains('Secret')));
          expect(logs.last.message, isNot(contains('test123')));
        }
      });

      test('should filter IP addresses', () {
        logger.info('Connection from 192.168.1.100');

        final logs = logger.getRecentLogs();
        expect(logs.last.message, contains('[IP_REDACTED]'));
        expect(logs.last.message, isNot(contains('192.168')));
      });

      test('should filter UUIDs', () {
        logger.info('User ID: 550e8400-e29b-41d4-a716-446655440000');

        final logs = logger.getRecentLogs();
        expect(logs.last.message, contains('[UUID_REDACTED]'));
        expect(logs.last.message, isNot(contains('550e8400')));
      });

      test('should filter GPS coordinates', () {
        logger.info('Location: 48.8566, 2.3522');

        final logs = logger.getRecentLogs();
        expect(logs.last.message, contains('[PII_REDACTED]'));
        expect(logs.last.message, isNot(contains('48.8566')));
      });

      test('should filter data in Map', () {
        logger.info('User login', {
          'email': 'user@example.com',
          'password': 'secret123',
          'token': 'Bearer abc123',
          'safe_data': 'this is ok',
        });

        final logs = logger.getRecentLogs();
        final data = logs.last.data!;

        expect(data['email'], equals('[REDACTED]'));
        expect(data['password'], equals('[REDACTED]'));
        expect(data['token'], equals('[REDACTED]'));
        expect(data['safe_data'], equals('this is ok'));
      });

      test('should filter nested data structures', () {
        logger.info('Complex data', {
          'user': {
            'email': 'test@example.com',
            'profile': {
              'phone': '+33612345678',
            },
          },
          'tokens': ['token1', 'Bearer xyz'],
        });

        final logs = logger.getRecentLogs();
        final data = logs.last.data!;
        final user = data['user'] as Map<String, dynamic>;
        final profile = user['profile'] as Map<String, dynamic>;
        final tokens = data['tokens'] as List;

        expect(user['email'], equals('[REDACTED]'));
        expect(profile['phone'], equals('[REDACTED]'));
        expect(tokens[0], equals('token1')); // Pas sensible
        expect(tokens[1], contains('[TOKEN_REDACTED]'));
      });
    });

    group('Log Levels', () {
      test('should create logs with correct levels', () {
        logger.debug('Debug message');
        logger.info('Info message');
        logger.warning('Warning message');
        logger.error('Error message');
        logger.critical('Critical message');

        final logs = logger.getRecentLogs();
        expect(logs.length, equals(5));

        expect(logs[0].level, equals(LogLevel.debug));
        expect(logs[1].level, equals(LogLevel.info));
        expect(logs[2].level, equals(LogLevel.warning));
        expect(logs[3].level, equals(LogLevel.error));
        expect(logs[4].level, equals(LogLevel.critical));
      });

      test('should filter logs by minimum level', () {
        logger.debug('Debug');
        logger.info('Info');
        logger.warning('Warning');
        logger.error('Error');
        logger.critical('Critical');

        final errorLogs = logger.getRecentLogs(minLevel: LogLevel.error);
        expect(errorLogs.length, equals(2));
        expect(errorLogs[0].level, equals(LogLevel.error));
        expect(errorLogs[1].level, equals(LogLevel.critical));
      });
    });

    group('Memory Buffer', () {
      test('should limit buffer size', () {
        // Ajouter plus de logs que la limite
        for (int i = 0; i < 150; i++) {
          logger.info('Log message $i');
        }

        final logs = logger.getRecentLogs();
        expect(logs.length, lessThanOrEqualTo(100)); // Max buffer size
      });

      test('should clear memory buffer', () {
        logger.info('Test log 1');
        logger.info('Test log 2');

        expect(logger.getRecentLogs().length, equals(2));

        logger.clearMemoryBuffer();
        expect(logger.getRecentLogs().length, equals(0));
      });
    });

    group('Log Analysis', () {
      test('should analyze log distribution', () {
        logger.debug('Debug');
        logger.debug('Debug 2');
        logger.info('Info');
        logger.warning('Warning');
        logger.error('Error');
        logger.error('Error 2');
        logger.error('Error 3');

        final analysis = logger.analyzeLogs();

        expect(analysis['total'], equals(7));
        expect(analysis['debug'], equals(2));
        expect(analysis['info'], equals(1));
        expect(analysis['warning'], equals(1));
        expect(analysis['error'], equals(3));
        expect(analysis['critical'], equals(0));
      });
    });

    group('Context Information', () {
      test('should include environment in logs', () {
        logger.info('Test message');

        final logs = logger.getRecentLogs();
        expect(logs.last.environment, isNotEmpty);
      });

      test('should include session ID in logs', () {
        logger.info('Test message');

        final logs = logger.getRecentLogs();
        expect(logs.last.sessionId, isNotEmpty);
        expect(logs.last.sessionId, startsWith('session_'));
      });

      test('should include timestamp in logs', () {
        final before = DateTime.now();
        logger.info('Test message');
        final after = DateTime.now();

        final logs = logger.getRecentLogs();
        final logTime = logs.last.timestamp;

        expect(logTime.isAfter(before) || logTime.isAtSameMomentAs(before),
            isTrue);
        expect(
            logTime.isBefore(after) || logTime.isAtSameMomentAs(after), isTrue);
      });
    });

    group('Stack Traces', () {
      test('should include stack trace for errors', () {
        try {
          throw Exception('Test error');
        } catch (e, stack) {
          logger.error('Caught error', null, stack);
        }

        final logs = logger.getRecentLogs();
        expect(logs.last.stackTrace, isNotNull);
      });
    });

    group('Safe Data Handling', () {
      test('should handle null data gracefully', () {
        expect(() => logger.info('Message', null), returnsNormally);
      });

      test('should handle empty data gracefully', () {
        expect(() => logger.info('Message', {}), returnsNormally);
      });

      test('should preserve non-sensitive data', () {
        logger.info('Operation completed', {
          'duration': 123,
          'success': true,
          'count': 42,
          'operation': 'data_sync',
        });

        final logs = logger.getRecentLogs();
        final data = logs.last.data!;

        expect(data['duration'], equals(123));
        expect(data['success'], equals(true));
        expect(data['count'], equals(42));
        expect(data['operation'], equals('data_sync'));
      });
    });
  });
}
