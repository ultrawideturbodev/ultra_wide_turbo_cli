part of 'app_setup.dart';

class Locator {
  static void _registerAPIs() {}

  static void _registerFactories() {}

  static void _registerLazySingletons() {
    TurboCommandService.registerLazySingleton();
  }

  static void _registerSingletons() {
    TurboLoggerService.registerSingleton();
  }
}
