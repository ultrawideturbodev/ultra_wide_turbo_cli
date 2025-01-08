import 'package:ultra_wide_turbo_cli/core/enums/turbo_command_type.dart';

enum TurboFlagType {
  version,
  verbose,
  clean,
  force;

  static List<TurboFlagType> get globalValues => values.where((flag) => flag.isGlobal).toList();

  List<String> bashCommands({required TurboCommandType source}) {
    switch (source) {
      case TurboCommandType.dartFix:
        return [
          'dart clean && dart pub get',
          'dart pub run build_runner build --delete-conflicting-outputs',
        ];
      case TurboCommandType.clone:
      case TurboCommandType.archive:
        return [];
    }
  }

  bool get isGlobal {
    switch (this) {
      case TurboFlagType.version:
      case TurboFlagType.verbose:
        return true;
      case TurboFlagType.clean:
      case TurboFlagType.force:
        return false;
    }
  }

  String get argument {
    switch (this) {
      case TurboFlagType.version:
      case TurboFlagType.verbose:
      case TurboFlagType.clean:
      case TurboFlagType.force:
        return name;
    }
  }

  String get help {
    switch (this) {
      case TurboFlagType.version:
        return 'Print the current version.';
      case TurboFlagType.verbose:
        return 'Enable verbose logging.';
      case TurboFlagType.clean:
        return 'Clean and refresh dependencies before fixing';
      case TurboFlagType.force:
        return 'Force operation even if target exists';
    }
  }

  bool get negatable {
    switch (this) {
      case TurboFlagType.version:
      case TurboFlagType.verbose:
      case TurboFlagType.clean:
      case TurboFlagType.force:
        return false;
    }
  }

  String? get abbr {
    switch (this) {
      case TurboFlagType.version:
        return 'v';
      case TurboFlagType.verbose:
        return null;
      case TurboFlagType.clean:
        return 'c';
      case TurboFlagType.force:
        return 'f';
    }
  }
}

extension TurboFlagTypeSetExtension on Set<TurboFlagType> {
  bool get hasVersion => contains(TurboFlagType.version);
  bool get hasVerbose => contains(TurboFlagType.verbose);
  bool get hasClean => contains(TurboFlagType.clean);
  bool get hasForce => contains(TurboFlagType.force);
}
