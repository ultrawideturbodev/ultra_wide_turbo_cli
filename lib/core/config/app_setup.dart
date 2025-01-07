import 'dart:async';

import 'package:mason_logger/mason_logger.dart';
import 'package:ultra_wide_turbo_cli/core/services/turbo_command_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/turbo_logger_service.dart';

part 'locator.dart';

abstract class AppSetup {
  static bool _isInitialised = false;

  static Future<void> initialise() async {
    if (_isInitialised) return;
    final log = Logger();
    log.info('Initialising app..');
    Locator._registerAPIs();
    Locator._registerFactories();
    Locator._registerLazySingletons();
    Locator._registerSingletons();
    log.info('App initialised!');
    _isInitialised = true;
  }
}
