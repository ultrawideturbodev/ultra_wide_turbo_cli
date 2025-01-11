# Ultra Wide Turbo CLI

A command-line tool for managing Ultra Wide Turbo development workflows.

## Features

- 🏷️ **Tag Management**: Link directories to tags for easy organization and reference
  - Tag sources: Link source directories to tags
  - Tag targets: Link target directories to tags
- 🔄 **Auto Updates**: Automatic version checking and seamless updates

## Installation

```bash
dart pub global activate ultra_wide_turbo_cli
```

## Commands

### Tag Source Command

Link the current directory to a tag for easy reference:

```bash
turbo tag source <tag>
```

Example:
```bash
# Link current directory to "my-project" tag
turbo tag source my-project

# Link current directory to "frontend_v2" tag
turbo tag source frontend_v2
```

### Tag Target Command

Link the current directory as a target for a tag:

```bash
turbo tag target <tag>
```

Example:
```bash
# Link current directory as target for "my-project" tag
turbo tag target my-project

# Link current directory as target for "frontend_v2" tag
turbo tag target frontend_v2
```

Tag names must:
- Be 2-50 characters long
- Use only letters, numbers, hyphens, and underscores
- Not start/end with hyphens or underscores

Common errors:
- Invalid tag name format: Use only allowed characters and follow naming rules
- Directory not accessible: Ensure you have read permissions
- Tag already linked: The directory is already linked to this tag

### Update Command

The CLI automatically checks for updates on startup, but you can also manually update:

```bash
# Check and apply updates
turbo update
```

## Global Options

| Option | Description |
|--------|-------------|
| `-v, --version` | Show version |
| `--verbose` | Enable verbose logging |
| `-h, --help` | Show command help |

## Documentation

- [Changelog](CHANGELOG.md)
- [Issue Tracker](https://github.com/ultrawideturbodev/ultra_wide_turbo_cli/issues)