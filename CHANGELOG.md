# Changelog

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
