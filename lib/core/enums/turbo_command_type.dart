import 'package:ultra_wide_turbo_cli/core/enums/turbo_flag_type.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_option.dart';

enum TurboCommandType {
  update,
  tag,
  tagSource,
  tagTarget;

  List<String> bashCommands() {
    switch (this) {
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

  String get argument {
    switch (this) {
      case TurboCommandType.update:
        return name;
      case TurboCommandType.tag:
        return name;
      case TurboCommandType.tagSource:
        return 'source';
      case TurboCommandType.tagTarget:
        return 'target';
    }
  }

  String get help {
    switch (this) {
      case TurboCommandType.update:
        return 'Manually check and update Ultra Wide Turbo CLI to the latest version.';
      case TurboCommandType.tag:
        return 'Manage tags and their associations.';
      case TurboCommandType.tagSource:
        return 'Link current directory to a tag.';
      case TurboCommandType.tagTarget:
        return 'Link current directory as a target for a tag.';
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
      case TurboCommandType.tag:
        return '''
Manage tags and their associations.

Available subcommands:
  source    Link current directory to a tag
  target    Link current directory as a target for a tag
  
Examples:
  turbo tag source my-project     # Link current directory to "my-project" tag
  turbo tag target frontend_v2    # Link current directory as target for "frontend_v2" tag

For more information, visit: https://docs.turbo.build/tags''';
      case TurboCommandType.tagSource:
        return '''
Links the current directory to a tag for easy reference and organization.

The tag name must:
- Be between 2 and 50 characters
- Contain only letters, numbers, hyphens, and underscores
- Not start or end with a hyphen or underscore

Examples:
  turbo tag source my-project     # Link current directory to "my-project" tag
  turbo tag source frontend_v2    # Link current directory to "frontend_v2" tag

Common errors:
- Invalid tag name format: Use only allowed characters and follow naming rules
- Directory not accessible: Ensure you have read permissions
- Tag already linked: The directory is already linked to this tag

For more information, visit: https://docs.turbo.build/tags''';
      case TurboCommandType.tagTarget:
        return '''
Links the current directory as a target for a tag.

The tag name must:
- Be between 2 and 50 characters
- Contain only letters, numbers, hyphens, and underscores
- Not start or end with a hyphen or underscore

Examples:
  turbo tag target my-project     # Link current directory as target for "my-project" tag
  turbo tag target frontend_v2    # Link current directory as target for "frontend_v2" tag

Common errors:
- Invalid tag name format: Use only allowed characters and follow naming rules
- Directory not accessible: Ensure you have read permissions
- Target already linked: The directory is already linked to this tag

For more information, visit: https://docs.turbo.build/tags''';
    }
  }

  List<String> get aliases {
    switch (this) {
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

  List<TurboFlagType> get flags {
    switch (this) {
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

  List<TurboOption> get options {
    switch (this) {
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

  String? script({required Set<TurboFlagType> activeFlags}) {
    switch (this) {
      case TurboCommandType.update:
        return null;
      case TurboCommandType.tag:
        return null;
      case TurboCommandType.tagSource:
        return null;
      case TurboCommandType.tagTarget:
        return null;
    }
  }
}
