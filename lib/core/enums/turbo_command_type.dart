import 'package:ultra_wide_turbo_cli/core/enums/turbo_flag_type.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_option.dart';

enum TurboCommandType {
  update;

  List<String> bashCommands() {
    switch (this) {
      case TurboCommandType.update:
        return [];
    }
  }

  String get argument {
    switch (this) {
      case TurboCommandType.update:
        return name;
    }
  }

  String get help {
    switch (this) {
      case TurboCommandType.update:
        return 'Manually check and update Ultra Wide Turbo CLI to the latest version.';
    }
  }

  String get description {
    switch (this) {
      case TurboCommandType.update:
        return '''
Manually check and update Ultra Wide Turbo CLI to the latest version.
- Shows current and latest version
- Updates if a newer version is available
- No options or flags needed

Example:
  turbo update
''';
    }
  }

  List<String> get aliases {
    switch (this) {
      case TurboCommandType.update:
        return [];
    }
  }

  List<TurboFlagType> get flags {
    switch (this) {
      case TurboCommandType.update:
        return [];
    }
  }

  List<TurboOption> get options {
    switch (this) {
      case TurboCommandType.update:
        return [];
    }
  }

  String? script({required Set<TurboFlagType> activeFlags}) {
    switch (this) {
      case TurboCommandType.update:
        return null;
    }
  }
}
