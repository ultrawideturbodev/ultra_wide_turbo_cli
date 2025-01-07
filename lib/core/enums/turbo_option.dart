enum TurboOption {
  target;

  String get name {
    switch (this) {
      case TurboOption.target:
        return 'target';
    }
  }

  String get help {
    switch (this) {
      case TurboOption.target:
        return 'Target directory for the operation.';
    }
  }

  String get defaultsTo {
    switch (this) {
      case TurboOption.target:
        return '.';
    }
  }

  String get valueHelp {
    switch (this) {
      case TurboOption.target:
        return 'directory';
    }
  }

  String? get abbr {
    switch (this) {
      case TurboOption.target:
        return 't';
    }
  }
}
