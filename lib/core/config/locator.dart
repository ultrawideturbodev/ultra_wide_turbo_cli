part of 'app_setup.dart';

abstract class Locator {
  static void _registerAPIs() {}

  static void _registerFactories() {}

  static void _registerLazySingletons() {
    ArchiveService.registerLazySingleton();
    CommandService.registerLazySingleton();
    LocalStorageService.registerLazySingleton();
    ScriptService.registerLazySingleton();
    WorkspaceService.registerLazySingleton();
  }

  static void _registerSingletons() {}
}
