import 'package:ultra_wide_turbo_cli/core/enums/turbo_flag_type.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_option.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_tag_type.dart';

enum TurboCommandType {
  dartFix,
  clone,
  archive;

  List<String> bashCommands() {
    switch (this) {
      case TurboCommandType.dartFix:
        return [
          '''find . -name "*.dart" \\
    ! -path "./bin/cache/*" \\
    ! -name "*.chopper.dart" \\
    ! -path "*/gen/**" \\
    ! -name "*.g.dart" \\
    ! -name "*l10n.dart" \\
    ! -name "*.mocks.dart" \\
    ! -name "*.freezed.dart" \\
    -exec dart format --line-length 100 --indent 0 {} +''',
          'dart fix --apply',
          '''find . -name "*.dart" \\
    ! -path "./bin/cache/*" \\
    ! -name "*.chopper.dart" \\
    ! -path "*/gen/**" \\
    ! -name "*.g.dart" \\
    ! -name "*l10n.dart" \\
    ! -name "*.mocks.dart" \\
    ! -name "*.freezed.dart" \\
    -exec dart format --line-length 100 --indent 0 {} +'''
        ];
      case TurboCommandType.clone:
      case TurboCommandType.archive:
        return [];
    }
  }

  String get argument {
    switch (this) {
      case TurboCommandType.clone:
      case TurboCommandType.archive:
        return name;
      case TurboCommandType.dartFix:
        return 'dart-fix';
    }
  }

  String get help {
    switch (this) {
      case TurboCommandType.dartFix:
        return 'Format and fix code in lib/ and test/ directories.';
      case TurboCommandType.clone:
        return 'Clone various ultra wide turbo components.';
      case TurboCommandType.archive:
        return 'Archive workspace files to preserve state.';
    }
  }

  String get description {
    switch (this) {
      case TurboCommandType.dartFix:
        return '''
Formats and fixes Dart code in lib/ and test/ directories.
- Runs flutter clean & pub get if --clean flag is used
- Runs build_runner build with --delete-conflicting-outputs
- Formats all Dart files with specified exclusions
- Applies dart fix suggestions
''';
      case TurboCommandType.clone:
        return '''
Clone various ultra wide turbo components.
Usage: turbo clone <tag>
Available tags:
- ${TurboTagType.workspace.argument}: Clone a new ultra wide turbo (AI agent) workspace

Options:
  -t, --target    Target directory for the clone (default: "./")
  -f, --force     Force clone even if directory exists

Example:
  turbo clone ${TurboTagType.workspace.argument} --target=my_workspace --force
''';
      case TurboCommandType.archive:
        return '''
Archive workspace files to preserve state.
Usage: turbo archive <tag>
Available tags:
- ${TurboTagType.workspace.argument}: Archive the parent workspace directory

Options:
  -t, --target    Target directory for the archive (default: "./turbo-archive")
  -f, --force     Force archive even if directory exists

Example:
  turbo archive ${TurboTagType.workspace.argument} --target=my_archive --force
''';
    }
  }

  List<String> get aliases {
    switch (this) {
      case TurboCommandType.dartFix:
      case TurboCommandType.clone:
      case TurboCommandType.archive:
        return [];
    }
  }

  List<TurboFlagType> get flags {
    switch (this) {
      case TurboCommandType.dartFix:
        return [TurboFlagType.clean];
      case TurboCommandType.clone:
      case TurboCommandType.archive:
        return [TurboFlagType.force];
    }
  }

  List<TurboOption> get options {
    switch (this) {
      case TurboCommandType.dartFix:
        return [];
      case TurboCommandType.clone:
      case TurboCommandType.archive:
        return [TurboOption.target];
    }
  }

  String? script({required Set<TurboFlagType> activeFlags}) {
    switch (this) {
      case TurboCommandType.dartFix:
        return [
          if (activeFlags.hasClean) ...TurboFlagType.clean.bashCommands(source: this),
          ...bashCommands(),
        ].join('\n');
      case TurboCommandType.clone:
      case TurboCommandType.archive:
        return null;
    }
  }
}
