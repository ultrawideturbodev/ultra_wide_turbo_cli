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
