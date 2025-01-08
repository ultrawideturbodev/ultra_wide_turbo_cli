import 'package:get_it/get_it.dart';
import 'package:mason_logger/mason_logger.dart';

/// Provides centralized logging functionality using [mason_logger].
///
/// Supports different log levels, progress indication, and user interaction.
/// All logging operations should go through this service to maintain consistency.
///
/// ```dart
/// // Log different levels
/// logger.log.info('Operation completed');
/// logger.log.err('Something went wrong');
///
/// // Show progress
/// final progress = logger.log.progress('Loading...');
/// await someOperation();
/// progress.complete('Done!');
/// ```
class LoggerService {
  static LoggerService get locate => GetIt.I.get();
  static void registerSingleton() => GetIt.I.registerSingleton<LoggerService>(LoggerService());

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  /// The main logger instance for all logging operations.
  ///
  /// Provides methods for different log levels and utilities:
  /// - info: General information
  /// - err: Errors and failures
  /// - detail: Detailed debug information
  /// - progress: Show operation progress
  ///
  /// ```dart
  /// // Show error with details
  /// log.err('Failed to process file', error: error, stackTrace: stackTrace);
  ///
  /// // Show progress
  /// final progress = log.progress('Processing...');
  /// progress.complete('Done!');
  /// ```
  final Logger log = Logger();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
