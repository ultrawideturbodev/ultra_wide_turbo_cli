import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/globals/log.dart';
import 'package:ultra_wide_turbo_cli/core/services/turbo_command_service.dart';

Future<void> main(List<String> args) async {
  try {
    await AppSetup.initialise(args);
    final exitCode = await TurboCommandService.locate.run(args);
    exit(exitCode);
  } catch (error) {
    log.err('$error');
    exit(ExitCode.software.code);
  }
}
