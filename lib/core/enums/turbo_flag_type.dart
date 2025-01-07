enum TurboFlagType {
  version,
  verbose,
  clean,
  ;

  static List<TurboFlagType> get globalValues => values.where((flag) => flag.isGlobal).toList();

  bool get isGlobal {
    switch (this) {
      case TurboFlagType.version:
      case TurboFlagType.verbose:
        return true;
      case TurboFlagType.clean:
        return false;
    }
  }

  String get argument {
    switch (this) {
      case TurboFlagType.version:
      case TurboFlagType.verbose:
      case TurboFlagType.clean:
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
        return 'Clean and refresh dependencies before execution.';
    }
  }

  bool get negatable {
    switch (this) {
      case TurboFlagType.version:
      case TurboFlagType.verbose:
      case TurboFlagType.clean:
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
    }
  }
}

extension TurboFlagTypeSetExtension on Set<TurboFlagType> {
  bool get hasVersion => contains(TurboFlagType.version);
  bool get hasVerbose => contains(TurboFlagType.verbose);
  bool get hasClean => contains(TurboFlagType.clean);
}
