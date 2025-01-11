---
document_type: agent work document
goal: define technical implementation details for turbo tag target command
gpt_action: use as a reference for implementation details and technical specifications
---

# 🎯 User Story
> As a CLI user, I want to link the current directory to a tag using the `turbo tag target` command, so that I can organize my directories by their purpose.

# 🔍 Technical Analysis

## Command Structure
- Parent command: `tag`
- Subcommand: `target`
- Usage: `turbo tag target <tag>`
- Example: `turbo tag target my-project`

## Implementation Details

### Command Layer
- Add `tagTarget` to `TurboCommandType` enum
- Mirror `tagSource` command structure
- Register under `tag` parent command
- Implement help text and descriptions

### Data Models
- Use existing DTOs:
  - `TurboTagDto` for tag management
  - `TurboTargetDto` for target management
  - `TurboRelationDto` for relations
- Add `targetTag` to `TurboRelationType` enum

### Storage Operations
- Use `LocalStorageService` for persistence
- Manage tags, targets, and relations
- Handle concurrent storage operations

### Validation Rules
- Tag name format:
  - Length: 2-50 characters
  - Pattern: `^[a-zA-Z0-9\-_]+$`
  - No hyphen/underscore at start/end
- Directory validation:
  - Must exist
  - Must be accessible
  - Must be absolute path

# 🔒 Security Considerations
- Validate directory permissions
- Sanitize tag name input
- Handle file system errors gracefully

# 🧪 Testing Strategy
- Follow existing BDD test patterns
- Test all scenarios from requirements
- Use temporary directories for testing
- Mock file system operations

# 📋 Implementation Steps
1. Add enum values and command registration
2. Implement command validation logic
3. Add tag management functionality
4. Add target management functionality
5. Implement relation creation
6. Add error handling and messages
7. Write comprehensive tests

# 🎨 Design Patterns
- Follow Command pattern for CLI structure
- Use Repository pattern for storage
- Implement Builder pattern for DTOs
- Follow existing service patterns

# 📚 Documentation
- Update README.md with new command
- Add usage examples
- Document error messages
- Include troubleshooting guide

# 🎫 Turbo Clone Command Implementation

## User Story
As a developer, I want to clone all files from sources tagged with a specific tag to my current directory, so I can quickly replicate tagged file structures.

## Technical Specifications

### Command Structure
```bash
turbo clone <tag> [options]
```

### Options
- `--force, -f`: Overwrite existing files
- `--help, -h`: Show help text

### Implementation Details

1. Command Layer
   - Add `clone` to `TurboCommandType` enum
   - Implement command registration in `TurboCommand`
   - Add help text and usage examples

2. Tag Validation
   - Use `LocalStorageService` to find tag
   - Query `turboRelations` for source links
   - Validate source directories exist

3. File System Operations
   - Use `dart:io` for file operations
   - Implement recursive directory copy
   - Handle file existence checks
   - Manage file permissions

4. Progress Reporting
   - Use `mason_logger` for progress bars
   - Implement error collection
   - Show operation summary

### Data Models

```dart
// Command registration
enum TurboCommandType {
  clone,
  // ... existing values
}

// File copy result
class CopyResult {
  final String sourcePath;
  final String targetPath;
  final bool success;
  final String? error;
}

// Copy summary
class CopySummary {
  final int totalFiles;
  final int successCount;
  final int skipCount;
  final int errorCount;
  final List<CopyResult> errors;
}
```

### Process Flow
1. Validate command input
2. Find tag in storage
3. Query related sources
4. Validate source directories
5. Create target directories
6. Copy files with progress
7. Show operation summary

### Error Handling
- Missing tag parameter
- Non-existent tag
- Invalid source directories
- File system errors
- Permission issues
- Space constraints

### Validation Rules
- Tag name format:
  - Length: 2-50 characters
  - Pattern: `^[a-zA-Z0-9\-_]+$`
  - No hyphen/underscore at start/end
- Source directories:
  - Must exist
  - Must be readable
- Target directory:
  - Must be writable
  - Must have space

# 🔒 Security Considerations
- Validate all paths
- Check file permissions
- Handle symlinks safely
- Prevent directory traversal
- Respect file system limits

# 🧪 Testing Strategy
- Unit tests for command layer
- Integration tests for file operations
- Mock file system for tests
- Test error scenarios
- Test large file structures

# 📋 Implementation Steps
1. Add command registration
2. Implement tag validation
3. Add source lookup
4. Implement file copy
5. Add progress reporting
6. Write comprehensive tests

# 🎨 Design Patterns
- Command pattern for CLI
- Repository pattern for storage
- Strategy pattern for copy operations
- Observer pattern for progress

# 📚 Documentation
- Update README.md
- Add command examples
- Document error messages
- Include troubleshooting guide
