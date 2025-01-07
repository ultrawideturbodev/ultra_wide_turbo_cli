# Ultra Wide Turbo CLI

A powerful command-line interface tool designed to enhance development workflows with automated tasks and intelligent processing.

## Features

- **Code Maintenance**
  - Format and fix Dart code
  - Clean and refresh dependencies
  - Run build_runner with safe options
- **Workspace Management**
  - Clone workspace templates
  - Automatic file renaming
  - Force mode for overwriting

## Installation

```bash
dart pub global activate ultra_wide_turbo_cli
```

## Usage

```bash
turbo <command> [arguments]
```

### Available Commands

#### fix
Format and fix code in lib/ and test/ directories.
```bash
turbo fix [--clean]
```
Options:
- `--clean`: Clean and refresh dependencies before fixing

#### clone workspace
Clone a new Ultra Wide Turbo workspace.
```bash
turbo clone workspace [--target=<dir>] [--force]
```
Options:
- `-t, --target`: Target directory for the clone (default: "./")
- `-f, --force`: Force clone even if directory exists

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
