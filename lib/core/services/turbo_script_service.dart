import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';

class TurboScriptService with TurboLogger {
  TurboScriptService._();

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static TurboScriptService get locate => GetIt.I.get();
  static void registerLazySingleton() => GetIt.I.registerLazySingleton(TurboScriptService._);

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  Future<int> run(String script) async {
    try {
      final result = await Process.run('bash', ['-c', script]);
      if (result.stdout.toString().isNotEmpty) {
        log.info(result.stdout);
      }
      if (result.stderr.toString().isNotEmpty) {
        log.err(result.stderr);
      }
      if (result.exitCode != 0) {
        throw Exception('Script failed with exit code ${result.exitCode}');
      }
      return result.exitCode;
    } catch (error) {
      log.err('Error running script: $error');
      return ExitCode.software.code;
    }
  }

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
