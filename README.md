# Ultra Wide Turbo CLI

A command-line tool for managing Ultra Wide Turbo development workflows.

## Features

- **Code Maintenance**
  - Run dart fix and format on lib/ and test/
  - Run build_runner build with safe options
  - Clean and get dependencies when needed
- **Workspace Management**
  - Clone a fresh GPT agent workspace from [Ultra Wide Turbo Workspace](https://github.com/ultrawideturbodev/ultra_wide_turbo_workspace)

## Installation

```bash
dart pub global activate ultra_wide_turbo_cli
```

## Usage

```bash
turbo <command> [arguments]
```

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
| `clone workspace` | Clone a new workspace from [Ultra Wide Turbo Workspace](https://github.com/ultrawideturbodev/ultra_wide_turbo_workspace) | `-t, --target`: Target directory (default: "./") <br> `-f, --force`: Force clone even if directory exists |

Example:
```bash
turbo clone workspace --target=my_workspace --force
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

This project is licensed under the Apache License, Version 2.0 with Commons Clause - see the [LICENSE](LICENSE) file for details.

This means:
- ✅ You can use the software
- ✅ You can modify the software
- ✅ You can contribute to the project
- ❌ You cannot use the code commercially without permission
- ❌ You cannot use the code in other projects without permission
- ❌ You cannot sell the software or derivative services

The Commons Clause and additional terms restrict commercial use and code reuse. For permissions beyond the standard license, please contact Ultra Wide Turbo Company via ultrawideturbocompany.com.
