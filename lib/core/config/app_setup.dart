import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';
import 'package:ultra_wide_turbo_cli/core/services/turbo_command_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/turbo_logger_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/turbo_update_service.dart';

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
    await trySetCurrentVersion();
    Locator._registerSingletons();
    log.info('App initialised!');
    _isInitialised = true;
  }

  static Future<void> trySetCurrentVersion() async {
    try {
      Environment.currentVersion = await TurboUpdateService.locate.currentVersion;
    } catch (error, stackTrace) {
      Logger().err(
        'Unexpected ${error.runtimeType} caught while trying to set current version!',
      );
      Environment.currentVersion = '0.0.1';
    }
  }
}
