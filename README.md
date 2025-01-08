# Ultra Wide Turbo CLI

A command-line tool for managing Ultra Wide Turbo development workflows.

## Features

- **Auto Updates**
  - Automatic version checking on startup
  - Seamless updates to the latest version
- **Code Maintenance**
  - Run dart fix and format on lib/ and test/
  - Run build_runner build with safe options
  - Clean and get dependencies when needed
- **Workspace Management**
  - Clone a fresh GPT agent workspace from [Ultra Wide Turbo Workspace](https://github.com/ultrawideturbodev/ultra_wide_turbo_workspace)
  - Archive workspace files to preserve state

## Installation

```bash
dart pub global activate ultra_wide_turbo_cli
```

## Usage

```bash
turbo <command> [arguments]
```

### Auto Updates

The CLI automatically checks for updates on startup. When a new version is available, it will:
1. Notify you about the new version
2. Automatically update to the latest version
3. Restart with the new version

### Code Maintenance Commands

| Command | Description | Options |
|---------|-------------|---------|
| `fix` | Format and fix code in lib/ and test/ directories | `--clean`: Clean and refresh dependencies before fixing |

Example:
```bash
turbo fix --clean
```

### Workspace Commands

| Command | Description | Options |
|---------|-------------|---------|
| `clone workspace` | Clone a new workspace from [Ultra Wide Turbo Workspace](https://github.com/ultrawideturbodev/ultra_wide_turbo_workspace) | `-t, --target`: Target directory (default: "./turbo-workspace") <br> `-f, --force`: Force clone even if directory exists |
| `archive workspace` | Archive the parent workspace directory | `-t, --target`: Target directory (default: "./turbo-archive") <br> `-f, --force`: Force archive even if directory exists |

Examples:
```bash
# Clone a workspace (uses default ./turbo-workspace)
turbo clone workspace

# Clone to custom directory
turbo clone workspace --target=my_workspace

# Force clone to existing directory
turbo clone workspace --target=existing_workspace --force

# Archive parent workspace
turbo archive workspace --target=my_archive --force
```

The cloned workspace will have the following structure:
```
turbo-workspace/
├── knowledge/
│   └── *.md
├── processes/
│   ├── _the-task-process.md
│   ├── _the-development-process.md
│   └── ...
├── protocols/
│   ├── _plx-start.md
│   ├── _plx-test.md
│   └── ...
├── prompts/
│   └── _system_prompt.md
├── your-memory.md
├── your-requirements.md
├── your-resources.md
└── your-todo-list.md
```

### Global Flags

| Flag | Description |
|------|-------------|
| `-v, --version` | Print the current version |
| `--verbose` | Enable verbose logging |

## Architecture

The CLI is built with a clean, modular architecture:

- **Services**: Command processing, logging, and updates
- **Configuration**: Environment and dependency management
- **Extensions**: Utility extensions for enhanced functionality
- **Abstractions**: Core interfaces and abstract classes

## Development

```bash
# Clone the repository
git clone https://github.com/codaveto/ultra_wide_turbo_cli.git

# Install dependencies
dart pub get

# Run tests
dart test
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

This means you can:
- ✅ Use the software commercially
- ✅ Modify the software
- ✅ Distribute the software
- ✅ Use the software privately
- ✅ Use the software for patent purposes

The only requirement is that you include the original copyright and license notice in any copy of the software/source.
