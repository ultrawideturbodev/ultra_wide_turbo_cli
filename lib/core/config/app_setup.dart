import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_command_type.dart';
import 'package:ultra_wide_turbo_cli/core/services/clone_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/local_storage_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/relation_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/source_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/tag_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/target_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/turbo_command_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/update_service.dart';

import '../globals/log.dart';

part 'locator.dart';

abstract class AppSetup {
  static bool _isInitialised = false;

  static Future<void> initialise(List<String> args) async {
    if (_isInitialised) return;
    _initLocator();
    await _initEssentials();
    // Skip update check if we're already running an update command
    if (Environment.shouldUpdate &&
        !args.contains(TurboCommandType.update.argument)) {
      // Check for updates
      final updateService = UpdateService.locate;
      final response = await updateService.checkForUpdates();
      response.whenSuccess(
        (response) {
          if (response.result.$1) {
            log.info('Current version: ${response.result.$2}');
            log.info('An update is available! Run `turbo update` to update.');
          }
        },
      );
    }
    _isInitialised = true;
  }

  static Future<void> _initEssentials() async {
    try {
      final localStorageService = LocalStorageService.locate;
      await localStorageService.initialise();
      await Future.wait(
        [
          localStorageService.isReady,
          TurboCommandService.locate.isReady,
        ],
      );
    } catch (error, _) {
      log.err(
        '$error caught while trying to initialise essentials!',
      );
    }
  }

  static void _initLocator() {
    try {
      Locator._registerAPIs();
      Locator._registerFactories();
      Locator._registerLazySingletons();
      Locator._registerSingletons();
    } catch (error, _) {
      log.err(
        '$error caught while trying to initialise AppSetup!',
      );
    }
  }

  static Future<void> reset(List<String> args) async {
    await GetIt.I.reset();
    _isInitialised = false;
    await initialise(args);
  }
}
