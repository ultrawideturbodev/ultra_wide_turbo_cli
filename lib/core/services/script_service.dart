import 'dart:async';
import 'dart:io' as io;

import 'package:get_it/get_it.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';

/// Executes shell scripts and commands in a controlled environment.
///
/// Uses bash to execute commands and handles stdout/stderr streams.
/// Provides proper cleanup of resources and process management.
///
/// ```dart
/// final result = await scriptService.run('ls -la');
/// if (result.isSuccess) {
///   print('Command executed successfully');
/// }
/// ```
class ScriptService with TurboLogger {
  /// Private constructor to enforce singleton pattern.
  ScriptService._();

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static ScriptService get locate => GetIt.I.get();
  static void registerLazySingleton() =>
      GetIt.I.registerLazySingleton(ScriptService._);

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  /// Executes a shell command through bash.
  ///
  /// Pipes the command output directly to the current process stdout/stderr.
  /// Automatically cleans up resources when the process completes.
  ///
  /// The [script] is the shell command to execute.
  ///
  /// Returns a [TurboResponse] indicating success or failure.
  /// Throws an [Exception] if the script exits with a non-zero code.
  ///
  /// ```dart
  /// // Run a simple command
  /// final result = await scriptService.run('echo "Hello"');
  ///
  /// // Run a complex command
  /// final result = await scriptService.run('git clone https://github.com/user/repo');
  /// ```
  Future<TurboResponse> run(String script) async {
    StreamSubscription? stdoutSub;
    StreamSubscription? stderrSub;

    try {
      final process = await io.Process.start(
        'bash',
        ['-c', script],
        mode: io.ProcessStartMode.normal,
      );

      // Use broadcast streams to allow multiple listeners
      final stdout = process.stdout.asBroadcastStream();
      final stderr = process.stderr.asBroadcastStream();

      // Pass through stdout directly
      stdoutSub = stdout.listen(
        io.stdout.add,
        cancelOnError: true,
      );

      // Pass through stderr directly
      stderrSub = stderr.listen(
        io.stderr.add,
        cancelOnError: true,
      );

      final exitCode = await process.exitCode;

      // Clean up subscriptions
      await Future.wait([
        stdoutSub.cancel(),
        stderrSub.cancel(),
      ]);

      if (exitCode != 0 && exitCode != -15) {
        // -15 is SIGTERM (Ctrl+C)
        throw Exception('Script failed with exit code $exitCode');
      }

      return const TurboResponse.emptySuccess();
    } catch (error) {
      // Clean up subscriptions in case of error
      await Future.wait([
        if (stdoutSub != null) stdoutSub.cancel(),
        if (stderrSub != null) stderrSub.cancel(),
      ]);

      log.err('Error running script: $error');
      return TurboResponse.fail(error: ExitCode.software.code);
    }
  }

// 🧲 FETCHERS ------------------------------------------------------------------------------ \\
// 🏗️ HELPERS ------------------------------------------------------------------------------- \\
// 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
