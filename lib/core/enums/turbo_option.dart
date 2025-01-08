enum TurboOption {
  target;

  String get argument {
    switch (this) {
      case TurboOption.target:
        return name;
    }
  }

  String get help {
    switch (this) {
      case TurboOption.target:
        return 'Target directory for the operation (default: ./turbo-workspace).';
    }
  }

  String get defaultsTo {
    switch (this) {
      case TurboOption.target:
        return './turbo-workspace';
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
