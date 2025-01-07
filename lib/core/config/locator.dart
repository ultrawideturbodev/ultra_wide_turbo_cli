part of 'app_setup.dart';

class Locator {
  static void _registerAPIs() {}

  static void _registerFactories() {}

  static void _registerLazySingletons() {
    CommandService.registerLazySingleton();
    ScriptService.registerLazySingleton();
    LocalStorageService.registerLazySingleton();
  }

  static void _registerSingletons() {
    LoggerService.registerSingleton();
  }
}
