import 'package:ultra_wide_turbo_cli/core/enums/environment_type.dart';

abstract class Environment {
  // 📍 LOCATOR ------------------------------------------------------------------------------- \\
  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\

  static EnvironmentType? _environmentOverride;
  static const String _prod = 'prod';
  static const String _test = 'test';
  static const argumentKey = 'env';
  static const packageName = 'ultra_wide_turbo_cli';
  static const packageTitle = 'Ultra Wide Turbo CLI';

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  static EnvironmentType get current {
    if (_environmentOverride == null) {
      switch (const String.fromEnvironment(
        Environment.argumentKey,
        defaultValue: _prod,
      )) {
        case _test:
          return EnvironmentType.test;
        case _prod:
        default:
          return EnvironmentType.prod;
      }
    }
    return _environmentOverride!;
  }

  static bool get isProd => current == EnvironmentType.prod;
  static bool get isTest => current == EnvironmentType.test;

  static bool get shouldUpdate {
    switch (current) {
      case EnvironmentType.prod:
        return true;
      case EnvironmentType.test:
        return false;
    }
  }

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  static void environmentOverride({required EnvironmentType environmentType}) =>
      _environmentOverride = environmentType;
}
