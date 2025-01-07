enum TurboFlags {
  version,
  verbose,
  ;

  String get pName {
    switch (this) {
      case TurboFlags.version:
      case TurboFlags.verbose:
        return name;
    }
  }

  String get help {
    switch (this) {
      case TurboFlags.version:
        return 'Print the current version.';
      case TurboFlags.verbose:
        return 'Enable verbose logging.';
    }
  }

  bool get negatable {
    switch (this) {
      case TurboFlags.version:
      case TurboFlags.verbose:
        return false;
    }
  }

  String? get abbr {
    switch (this) {
      case TurboFlags.version:
        return 'v';
      case TurboFlags.verbose:
        return null;
    }
  }
}
