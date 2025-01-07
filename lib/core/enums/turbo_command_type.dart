import 'package:ultra_wide_turbo_cli/core/enums/turbo_flag_type.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_option.dart';

enum TurboCommandType {
  fix,
  clone;

  String get pName {
    switch (this) {
      case TurboCommandType.fix:
      case TurboCommandType.clone:
        return name;
    }
  }

  String get help {
    switch (this) {
      case TurboCommandType.fix:
        return 'Format and fix code in lib/ and test/ directories.';
      case TurboCommandType.clone:
        return 'Clone various ultra wide turbo components.';
    }
  }

  String get description {
    switch (this) {
      case TurboCommandType.fix:
        return '''
Formats and fixes Dart code in lib/ and test/ directories.
- Runs flutter clean & pub get if --clean flag is used
- Runs build_runner build with --delete-conflicting-outputs
- Formats all Dart files with specified exclusions
- Applies dart fix suggestions
''';
      case TurboCommandType.clone:
        return '''
Clone various Ultra Wide Turbo components.
Usage: turbo clone <type>
Available types:
- workspace: Clone a new ultra wide turbo (AI agent) workspace
''';
    }
  }

  List<String> get aliases {
    switch (this) {
      case TurboCommandType.fix:
      case TurboCommandType.clone:
        return [];
    }
  }

  List<TurboFlagType> get flags {
    switch (this) {
      case TurboCommandType.fix:
        return [TurboFlagType.clean];
      case TurboCommandType.clone:
        return [TurboFlagType.force];
    }
  }

  List<TurboOption> get options {
    switch (this) {
      case TurboCommandType.fix:
        return [];
      case TurboCommandType.clone:
        return [TurboOption.target];
    }
  }

  String? script({required Set<TurboFlagType> activeFlags}) {
    switch (this) {
      case TurboCommandType.fix:
        return '''
${activeFlags.hasClean ? 'bash scripts/clean.sh\n' : ''}
bash scripts/fix.sh

cd test || exit
bash ../scripts/fix.sh
''';
      case TurboCommandType.clone:
        return null;
    }
  }
}
