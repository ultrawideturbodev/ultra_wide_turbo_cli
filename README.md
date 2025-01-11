# Ultra Wide Turbo CLI

A powerful CLI tool for managing and organizing your development workspace.

## Features

- 🏷️ Tag Management
  - Link directories to tags for easy reference
  - Create and manage tag targets
  - Clone files from tagged sources
  - Persistent storage in user's home directory
- 🔄 Auto Updates
  - Automatic version checks
  - Seamless update process

## Installation

```bash
dart pub global activate ultra_wide_turbo_cli
```

## Usage

### Tag Source Command

Link the current directory to a tag:

```bash
turbo tag source my-project
```

### Tag Target Command

Link the current directory as a target for a tag:

```bash
turbo tag target frontend_v2
```

### Clone Command

Clone files from all sources associated with a tag to the current directory:

```bash
# Clone files from my-project tag sources
turbo clone my-project

# Clone and overwrite existing files
turbo clone frontend_v2 --force
```

## Common Errors

### Tag Commands
- Invalid tag name format: Use only allowed characters (letters, numbers, hyphens, underscores)
- Directory not accessible: Ensure you have read permissions
- Tag already linked: The directory is already linked to this tag

### Clone Command
- Tag not found: The specified tag does not exist
- No sources found: The tag has no associated source directories
- Directory not accessible: Ensure you have write permissions
- Insufficient space: Not enough space to copy files

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the GNU License - see the [LICENSE](LICENSE) file for details.