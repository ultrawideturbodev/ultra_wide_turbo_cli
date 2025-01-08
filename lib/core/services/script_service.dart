import 'dart:async';
import 'dart:io' as io;

import 'package:get_it/get_it.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';

class ScriptService with TurboLogger {
  ScriptService._();

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static ScriptService get locate => GetIt.I.get();
  static void registerLazySingleton() => GetIt.I.registerLazySingleton(ScriptService._);

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

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
