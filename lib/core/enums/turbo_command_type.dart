import 'package:ultra_wide_turbo_cli/core/enums/turbo_flag_type.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_option.dart';

enum TurboCommandType {
  update,
  tag,
  source,
  target,
  clone;

  List<TurboCommandType> get subcommands {
    switch (this) {
      case TurboCommandType.update:
        return [];
      case TurboCommandType.tag:
        return [TurboCommandType.source, TurboCommandType.target];
      case TurboCommandType.source:
        return [];
      case TurboCommandType.target:
        return [];
      case TurboCommandType.clone:
        return [];
    }
  }

  List<String> bashCommands() {
    switch (this) {
      case TurboCommandType.update:
        return [];
      case TurboCommandType.tag:
        return [];
      case TurboCommandType.source:
        return [];
      case TurboCommandType.target:
        return [];
      case TurboCommandType.clone:
        return [];
    }
  }

  String get argument {
    switch (this) {
      case TurboCommandType.update:
      case TurboCommandType.tag:
      case TurboCommandType.source:
      case TurboCommandType.target:
      case TurboCommandType.clone:
        return name;
    }
  }

  String get help {
    switch (this) {
      case TurboCommandType.update:
        return 'Manually check and update Ultra Wide Turbo CLI to the latest version.';
      case TurboCommandType.tag:
        return 'Manage tags and their associations.';
      case TurboCommandType.source:
        return 'Link current directory to a tag.';
      case TurboCommandType.target:
        return 'Link current directory as a target for a tag.';
      case TurboCommandType.clone:
        return 'Clone files from all sources associated with a tag to the current directory.';
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
      case TurboCommandType.source:
        return '''
Links the current directory to a tag for easy reference and organization.

You will be prompted to select an existing tag or create a new one.

The tag name must:
- Be between 2 and 50 characters
- Contain only letters, numbers, hyphens, and underscores
- Not start or end with a hyphen or underscore

Examples:
  turbo tag source    # Select or create a tag for the current directory

Common errors:
- Invalid tag name format: Use only allowed characters and follow naming rules
- Directory not accessible: Ensure you have read permissions
- Tag already linked: The directory is already linked to this tag

For more information, visit: https://docs.turbo.build/tags''';
      case TurboCommandType.target:
        return '''
Links the current directory as a target for a tag.

You will be prompted to select an existing tag or create a new one.

The tag name must:
- Be between 2 and 50 characters
- Contain only letters, numbers, hyphens, and underscores
- Not start or end with a hyphen or underscore

Examples:
  turbo tag target    # Select or create a tag for the current directory

Common errors:
- Invalid tag name format: Use only allowed characters and follow naming rules
- Directory not accessible: Ensure you have read permissions
- Target already linked: The directory is already linked to this tag

For more information, visit: https://docs.turbo.build/tags''';
      case TurboCommandType.clone:
        return '''
Clone files from all sources associated with a tag to the current directory.

The tag name must:
- Be between 2 and 50 characters
- Contain only letters, numbers, hyphens, and underscores
- Not start or end with a hyphen or underscore

Options:
  -f, --force    Overwrite existing files

Examples:
  turbo clone my-project              # Clone files from my-project tag sources
  turbo clone frontend_v2 --force     # Clone and overwrite existing files

Common errors:
- Invalid tag name format: Use only allowed characters and follow naming rules
- Tag not found: The specified tag does not exist
- No sources found: The tag has no associated source directories
- Directory not accessible: Ensure you have read permissions
- Insufficient space: Not enough space to copy files

For more information, visit: https://docs.turbo.build/clone''';
    }
  }

  List<String> get aliases {
    switch (this) {
      case TurboCommandType.update:
        return [];
      case TurboCommandType.tag:
        return [];
      case TurboCommandType.source:
        return [];
      case TurboCommandType.target:
        return [];
      case TurboCommandType.clone:
        return [];
    }
  }

  List<TurboFlagType> get flags {
    switch (this) {
      case TurboCommandType.update:
        return [];
      case TurboCommandType.tag:
        return [];
      case TurboCommandType.source:
        return [];
      case TurboCommandType.target:
        return [];
      case TurboCommandType.clone:
        return [TurboFlagType.force];
    }
  }

  List<TurboOption> get options {
    switch (this) {
      case TurboCommandType.update:
        return [];
      case TurboCommandType.tag:
        return [];
      case TurboCommandType.source:
        return [];
      case TurboCommandType.target:
        return [];
      case TurboCommandType.clone:
        return [];
    }
  }

  String? script({required Set<TurboFlagType> activeFlags}) {
    switch (this) {
      case TurboCommandType.update:
        return null;
      case TurboCommandType.tag:
        return null;
      case TurboCommandType.source:
        return null;
      case TurboCommandType.target:
        return null;
      case TurboCommandType.clone:
        return null;
    }
  }
}
