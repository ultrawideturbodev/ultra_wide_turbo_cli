import 'dart:async';

import 'package:ultra_wide_turbo_cli/core/services/command_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/local_storage_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/logger_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/script_service.dart';

part 'locator.dart';

abstract class AppSetup {
  static bool _isInitialised = false;

  static Future<void> initialise() async {
    if (_isInitialised) return;
    Locator._registerAPIs();
    Locator._registerFactories();
    Locator._registerLazySingletons();
    Locator._registerSingletons();
    _isInitialised = true;
  }
}
