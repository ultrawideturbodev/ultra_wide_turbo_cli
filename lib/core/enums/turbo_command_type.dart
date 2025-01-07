import 'package:ultra_wide_turbo_cli/core/enums/turbo_flag_type.dart';

enum TurboCommandType {
  fix;

  String get pName {
    switch (this) {
      case TurboCommandType.fix:
        return name;
    }
  }

  String get help {
    switch (this) {
      case TurboCommandType.fix:
        return 'Format and fix code in lib/ and test/ directories.';
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
    }
  }

  List<String> get aliases {
    switch (this) {
      case TurboCommandType.fix:
        return [];
    }
  }

  List<TurboFlagType> get flags {
    switch (this) {
      case TurboCommandType.fix:
        return [TurboFlagType.clean];
    }
  }

  String script({required Set<TurboFlagType> activeFlags}) {
    switch (this) {
      case TurboCommandType.fix:
        return '''
cd ../lib || exit

${activeFlags.hasClean ? 'bash scripts/clean.sh\n' : ''}
bash scripts/fix.sh

cd ../test || exit
bash ../lib/scripts/fix.sh
''';
    }
  }
}
