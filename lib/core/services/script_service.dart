import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:mason_logger/mason_logger.dart';
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

  Future<int> run(String script) async {
    StreamSubscription? stdoutSubscription;
    StreamSubscription? stderrSubscription;

    try {
      log.info('Running script...');

      final process = await Process.start('bash', ['-c', script]);

      // Stream stdout in real-time
      stdoutSubscription = process.stdout.transform(const SystemEncoding().decoder).listen((data) {
        if (data.trim().isNotEmpty) {
          log.info(data.trim());
        }
      });

      // Stream stderr in real-time
      stderrSubscription = process.stderr.transform(const SystemEncoding().decoder).listen((data) {
        if (data.trim().isNotEmpty) {
          log.err(data.trim());
        }
      });

      final exitCode = await process.exitCode;

      // Clean up subscriptions
      await Future.wait([
        stdoutSubscription.cancel(),
        stderrSubscription.cancel(),
      ]);

      if (exitCode != 0) {
        throw Exception('Script failed with exit code $exitCode');
      }

      log.success('Script completed successfully');
      return exitCode;
    } catch (error) {
      // Clean up subscriptions in case of error
      await Future.wait([
        if (stdoutSubscription != null) stdoutSubscription.cancel(),
        if (stderrSubscription != null) stderrSubscription.cancel(),
      ]);

      log.err('Error running script: $error');
      return ExitCode.software.code;
    }
  }

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
