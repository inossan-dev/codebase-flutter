import 'package:logger/logger.dart';

/// Wrapper autour de `logger` pour centraliser et contrôler les logs.
///
/// Règles :
/// - [AppLogger.d] → Debug (détail interne, désactivé en prod)
/// - [AppLogger.i] → Info  (événements métier importants)
/// - [AppLogger.w] → Warning (cas dégradés récupérés)
/// - [AppLogger.e] → Error  (exception catchée, avec stacktrace)
///
/// IMPORTANT : n'utilisez jamais `print()` dans le code applicatif.
/// L'analyse statique est configurée pour rejeter `print`.
final class AppLogger {
  AppLogger._();

  static late final Logger _logger;

  static void init({required String flavor}) {
    final isProduction = flavor == 'prod';

    _logger = Logger(
      // En prod : level WARNING minimum, pas de stacktrace superflu
      level: isProduction ? Level.warning : Level.trace,
      printer: PrettyPrinter(
        methodCount: isProduction ? 0 : 3,
        lineLength: 80,
        colors: !isProduction,
        printEmojis: !isProduction,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      // En prod, brancher ici un LogOutput vers Crashlytics/Sentry
      output: isProduction ? null : ConsoleOutput(),
    );
  }

  static void d(String message, [Object? error, StackTrace? st]) =>
      _logger.d(message, error: error, stackTrace: st);

  static void i(String message, [Object? error, StackTrace? st]) =>
      _logger.i(message, error: error, stackTrace: st);

  static void w(String message, [Object? error, StackTrace? st]) =>
      _logger.w(message, error: error, stackTrace: st);

  static void e(String message, [Object? error, StackTrace? st]) =>
      _logger.e(message, error: error, stackTrace: st);
}
