import 'package:ultra_wide_turbo_cli/core/enums/turbo_command_type.dart';

enum TurboFlagType {
  version,
  verbose,
  force;

  static List<TurboFlagType> get globalValues => values.where((flag) => flag.isGlobal).toList();

  List<String> bashCommands({required TurboCommandType source}) {
    switch (source) {
      case TurboCommandType.update:
        return [];
      case TurboCommandType.tag:
        return [];
      case TurboCommandType.tagSource:
        return [];
      case TurboCommandType.tagTarget:
        return [];
    }
  }

  bool get isGlobal {
    switch (this) {
      case TurboFlagType.version:
      case TurboFlagType.verbose:
        return true;
      case TurboFlagType.force:
        return false;
    }
  }

  String get argument {
    switch (this) {
      case TurboFlagType.version:
      case TurboFlagType.verbose:
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
      case TurboFlagType.force:
        return 'Force operation even if target exists';
    }
  }

  bool get negatable {
    switch (this) {
      case TurboFlagType.version:
      case TurboFlagType.verbose:
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
      case TurboFlagType.force:
        return 'f';
    }
  }
}

extension TurboFlagTypeSetExtension on Set<TurboFlagType> {
  bool get hasVersion => contains(TurboFlagType.version);
  bool get hasVerbose => contains(TurboFlagType.verbose);
  bool get hasForce => contains(TurboFlagType.force);
}
