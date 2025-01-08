import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/services/command_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/logger_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/update_service.dart';

Future<void> main(List<String> args) async {
  try {
    await AppSetup.initialise();
    final turboCommandService = CommandService.locate;
    await turboCommandService.isReady;

    // Check for updates
    final updateService = UpdateService.locate;
    final updateCheck = await updateService.checkForUpdates();
    final shouldUpdate = updateCheck.when(
      success: (response) => response.result,
      fail: (_) => false,
    );

    if (shouldUpdate) {
      await updateService.update();
      return;
    }

    final exitCode = await turboCommandService.run(args);
    exit(exitCode);
  } catch (error) {
    LoggerService.locate.log.err('$error');
    exit(ExitCode.software.code);
  }
}
