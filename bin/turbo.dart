import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/globals/log.dart';
import 'package:ultra_wide_turbo_cli/core/services/command_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/update_service.dart';

Future<void> main(List<String> args) async {
  try {
    await AppSetup.initialise();
    final turboCommandService = CommandService.locate;
    await turboCommandService.isReady;

    // Skip update check if we're already running an update command
    if (!args.contains('update')) {
      // Check for updates
      final updateService = UpdateService.locate;
      final updateCheck = await updateService.checkForUpdates();
      final shouldUpdate = updateCheck.when(
        success: (response) => response.result,
        fail: (_) => false,
      );

      if (shouldUpdate) {
        final updateResult = await updateService.update();
        // Only exit if update was successful, otherwise continue with command
        if (updateResult.when(success: (_) => true, fail: (_) => false)) {
          exit(ExitCode.success.code);
        }
      }
    }

    final exitCode = await turboCommandService.run(args);
    exit(exitCode);
  } catch (error) {
    log.err('$error');
    exit(ExitCode.software.code);
  }
}
