---
document_type: agent work document
goal: getting as clear as possible what needs to be done
gpt_action: use as a reference work to understand exactly what (still) needs to be done and document progress
---

# 👤 Actors & 🧩 Components (Who or what)
> - Someone or something that can perform actions or be interacted with
---

- [ ] [[CLI User]]
    - [ ] Runs `turbo tag target <tag>` command
    - [ ] Provides tag name parameter
- [ ] [[Command Runner]]
    - [ ] Validates tag parameter
    - [ ] Checks tag existence
    - [ ] Validates target directory
    - [ ] Creates/reuses tag
    - [ ] Creates/reuses target
    - [ ] Links tag to target
- [ ] [[Storage System]]
    - [ ] Manages tag storage
    - [ ] Manages target storage
    - [ ] Manages relation storage
- [ ] [[File System]]
    - [ ] Validates directory access

# 🎬 Activities (Who or what does what?)
> - Actions that an Actor or Component performs
---

## Feature: Tag Target Command
- [ ] M1: Command Layer Implementation
    - [ ] Scenario: Register new tag target command
        - GIVEN the CLI application is running
        - WHEN the system initializes commands
        - THEN the "tag target" command is registered under "tag"
        - AND it accepts a tag parameter
        - AND it shows in help text

    - [ ] Scenario: Validate tag parameter
        - GIVEN the user runs "turbo tag target"
        - WHEN no tag parameter is provided
        - THEN the system shows an error message

- [ ] M2: Tag Validation and Creation
    - [ ] Scenario: Validate existing tag
        - GIVEN the user runs "turbo tag target <existing-tag>"
        - WHEN the system checks local storage
        - THEN it finds the tag
        - AND proceeds with target linking

    - [ ] Scenario: Create new tag
        - GIVEN the user runs "turbo tag target <new-tag>"
        - WHEN the system checks local storage
        - AND doesn't find the tag
        - THEN it creates a new TurboTagDto
        - AND stores it in local storage
        - AND proceeds with target linking

- [ ] M3: Target Management
    - [ ] Scenario: Create new target from directory
        - GIVEN the command has a valid tag
        - WHEN the system checks the current directory
        - AND the directory is not registered as a target
        - THEN it creates a new TurboTargetDto
        - AND stores it in local storage

    - [ ] Scenario: Use existing target
        - GIVEN the command has a valid tag
        - WHEN the system checks the current directory
        - AND the directory is already registered as a target
        - THEN it uses the existing TurboTargetDto

- [ ] M4: Relation Creation
    - [ ] Scenario: Create new relation
        - GIVEN valid tag and target exist
        - WHEN the system checks for an existing relation
        - AND no relation exists
        - THEN it creates a new TurboRelationDto
        - AND stores it in local storage

    - [ ] Scenario: Handle existing relation
        - GIVEN valid tag and target exist
        - WHEN the system checks for an existing relation
        - AND a relation already exists
        - THEN it shows "already exists" message
        - AND does not create duplicate relation

    - [ ] Scenario: Handle invalid directory
        - GIVEN the user runs the command
        - WHEN the system checks the current directory
        - THEN it shows an error message

    - [ ] Scenario: Show operation success
        - GIVEN the user runs the command
        - WHEN the system completes all operations
        - THEN it shows a success message

# 📝 Properties (Which values?)
> - Describes a value or configuration that belongs to an object
---

- [ ] [[Tag Name]]
    - [ ] Length: 2-50 characters
    - [ ] Pattern: letters, numbers, hyphens, underscores
    - [ ] Cannot start/end with hyphen or underscore

- [ ] [[Directory]]
    - [ ] Must be accessible
    - [ ] Must be absolute path
    - [ ] Must be valid directory

- [ ] [[Relation]]
    - [ ] Unique per tag-target pair
    - [ ] Type: targetTag

# 🛠️ Behaviours (How does it act when.. in terms of.. ?)
> - Defines how something looks, works and performs
---

- [ ] [[Command Actions]]
    - [ ] Show error if tag parameter missing
    - [ ] Display usage instructions on error
    - [ ] Show help text with --help flag

- [ ] [[Tag Actions]]
    - [ ] Create new tag if not exists
    - [ ] Use existing tag if found
    - [ ] Show appropriate messages

- [ ] [[Target Actions]]
    - [ ] Create new target if not exists
    - [ ] Use existing target if found
    - [ ] Show appropriate messages

- [ ] [[Relation Actions]]
    - [ ] Create new relation if not exists
    - [ ] Show message if relation exists
    - [ ] Show error if directory invalid

# 💡 Ideas & 🪵 Backlog
> - Anything that could be added later
---

- [ ] Add support for multiple targets in one command
- [ ] Add force flag to override existing relations
- [ ] Add recursive directory tagging

# ❓ Questions
> - Questions that need to be answered to clarify requirements
---

None - we can mirror the source command implementation exactly.

# 🎯 Roles, 📝 Tasks & 🎓 Suggested Approach
> - Each item must cascade to a todo with assigned role
---

- [ ] Backend Developer
    - [ ] Add tagTarget to TurboCommandType enum
    - [ ] Add command description and help text
    - [ ] Register command under tag parent
    - [ ] Implement tag parameter validation
    - [ ] Add target directory validation
    - [ ] Create/reuse tag and target entries
    - [ ] Create relation between tag and target
