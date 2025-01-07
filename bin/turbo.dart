import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/services/turbo_command_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/turbo_logger_service.dart';

Future<void> main(List<String> args) async {
  try {
    await AppSetup.initialise();
    await TurboCommandService.locate.run(args);
  } catch (error) {
    TurboLoggerService.locate.log.err('$error');
    exit(ExitCode.software.code);
  }
}
