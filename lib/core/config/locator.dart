part of 'app_setup.dart';

abstract class Locator {
  static void _registerAPIs() {}

  static void _registerFactories() {}

  static void _registerLazySingletons() {
    CloneService.registerLazySingleton();
    LocalStorageService.registerLazySingleton();
    SourceService.registerLazySingleton();
    TargetService.registerLazySingleton();
    TurboCommandService.registerLazySingleton();
    RelationService.registerLazySingleton();
    TagService.registerLazySingleton();
    UpdateService.registerLazySingleton();
  }

  static void _registerSingletons() {}
}
