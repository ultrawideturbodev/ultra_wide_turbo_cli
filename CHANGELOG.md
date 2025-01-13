# Changelog

All notable changes to this project will be documented in this file.

## 0.1.16 - 2024-01-09

### 🧪 Tests:
- Cleaned up test files for better readability and maintainability
- Improved test organization and structure
- Removed unused imports and variables

## 0.1.15 - 2024-01-09

### 🐛 Bug fixes:
- Fixed update service to correctly handle global package paths
- Added fallback path resolution for global packages
- Improved error messages for missing configuration files

### 🧪 Tests:
- Added integration test for tag source and clone workflow
- Added test coverage for multi-directory operations
- Fixed test setup for global package scenarios

## 0.1.14 - 2024-01-09

### 🐛 Bug fixes:
- Fixed Hive database location to store in user's home directory for better persistence
- Fixed source path storage to use full paths instead of just directory names
- Fixed clone feature to correctly find and copy files using absolute paths

* test: add integration test for tag source and clone workflow
* test: improve test coverage for multi-directory operations

## 0.1.12

### Added
- `turbo clone` command for copying files from tagged sources
  - Clone files from all sources associated with a tag
  - Force flag to overwrite existing files
  - Progress reporting with file counts
  - Error handling and summaries
  - Comprehensive test coverage

### Added
- `turbo tag target` command for linking directories as tag targets
  - Tag validation and automatic creation
  - Target management with validation
  - Relation creation and error handling
  - Enhanced test coverage
  - Improved directory validation in tests

### Added
- New `turbo tag source` command for linking directories to tags
  - Tag validation and automatic creation
  - Source management from current directory
  - Relation creation and validation
  - Comprehensive error handling and user feedback
- Enhanced test coverage with BDD-style tests
- Improved directory validation in tests

## 0.1.11

### Fixed
- Fixed version constant to prevent update loop

## 0.1.10

### Fixed
- Fixed workspace clone command to correctly locate template files in package directory

## 0.1.9

- Added manual update command (`turbo update`)
- Enhanced update service with manual update functionality
- Added comprehensive tests for update service

## 0.1.8 - 2024-01-08

### Changed
- Made workspace clone command safer by removing deletion operations
- Added proper file existence checks
- Improved error handling for existing files
- Added force flag support for overwriting
- Changed default target path to "./turbo-workspace"
- Improved directory structure preservation
- Removed underscore renaming logic
- Enhanced conflict detection for nested directories

## 0.1.7

### Added
- Verified publisher status
- Updated package metadata

## 0.1.6

### Changed
- Switched to GNU License
- Updated documentation to reflect GNU license terms

## 0.1.5

### Added
- Verified publisher status
- Updated package metadata

## 0.1.4

### Fixed
- Continue with original command after successful update
- Only exit after update if it was successful

## 0.1.3

### Fixed
- Include workspace template and documentation in package

## 0.1.2

### Added
- Auto-update feature that checks for new versions on startup
- Automatic update process when new version is available
- Comprehensive Dart documentation for all services
- Code examples in documentation
- Detailed parameter and return value descriptions
- Thread safety documentation for local storage operations

## 0.1.1

### Fixed
- Use provided arguments in turbo.dart instead of hardcoded command

## 0.1.0

Initial release 🎉

### Added
- Core CLI architecture with dependency injection
- Command processing service
- Logging service with mason_logger integration
- Update service for version management
- Environment configuration and type management
- Utility extensions for enhanced functionality
- Clean architecture with abstractions and services
- Clone workspace command with file renaming support
- Comprehensive test suite for commands
- Force flag and target option support
- Archive workspace command
- Dart fix command

### Changed
- Improved script service stream handling
- Enhanced command service for consistent option and flag handling
