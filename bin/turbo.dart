import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/services/command_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/logger_service.dart';

Future<void> main(List<String> args) async {
  try {
    await AppSetup.initialise();
    final turboCommandService = CommandService.locate;
    await turboCommandService.isReady;
    await turboCommandService.run(args);
  } catch (error) {
    LoggerService.locate.log.err('$error');
    exit(ExitCode.software.code);
  }
}
