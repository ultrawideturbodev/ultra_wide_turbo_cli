---
document_type: agent work document
goal: track high-level milestones and overall project progress
gpt_action: maintain organized milestone list and track overall project direction
---

# 🚀 [M1] Command Layer Implementation
> Implement the basic command structure for `turbo tag source`
---
```gherkin
Feature: Tag Source Command Registration

Scenario: Register new tag source command
  GIVEN the CLI application is running
  WHEN the system initializes commands
  THEN the "tag source" command is registered under "tag"
  AND it accepts a tag parameter
  AND it shows in help text

Scenario: Validate tag parameter
  GIVEN the user runs "turbo tag source"
  WHEN no tag parameter is provided
  THEN the system shows an error message
  AND explains proper usage
```

# 🚀 [M2] Tag Validation and Creation
> Handle tag validation and automatic creation
---
```gherkin
Feature: Tag Validation and Creation

Scenario: Validate existing tag
  GIVEN the user runs "turbo tag source <existing-tag>"
  WHEN the system checks local storage
  THEN it finds the tag
  AND proceeds with source linking

Scenario: Create new tag
  GIVEN the user runs "turbo tag source <new-tag>"
  WHEN the system checks local storage
  AND doesn't find the tag
  THEN it creates a new TurboTagDto
  AND stores it in local storage
  AND proceeds with source linking
```

# 🚀 [M3] Source Management
> Handle current directory as source
---
```gherkin
Feature: Source Management

Scenario: Create new source from directory
  GIVEN the command has a valid tag
  WHEN the system checks the current directory
  AND the directory is not registered as a source
  THEN it creates a new TurboSourceDto
  AND stores it in local storage
  AND uses the directory name as identifier

Scenario: Use existing source
  GIVEN the command has a valid tag
  WHEN the system checks the current directory
  AND the directory is already registered as a source
  THEN it uses the existing TurboSourceDto
```

# 🚀 [M4] Relation Creation
> Create or validate tag-source relationship
---
```gherkin
Feature: Relation Management

Scenario: Create new relation
  GIVEN valid tag and source exist
  WHEN the system checks for an existing relation
  AND no relation exists
  THEN it creates a new TurboRelationDto
  AND stores it in local storage
  AND shows success message

Scenario: Handle existing relation
  GIVEN valid tag and source exist
  WHEN the system checks for an existing relation
  AND a relation already exists
  THEN it shows "already exists" message
  AND does not create duplicate relation
```

# 🚀 [M5] Error Handling and Feedback
> Implement proper error handling and user feedback
---
```gherkin
Feature: Error Handling and User Feedback

Scenario: Handle invalid directory
  GIVEN the user runs the command
  WHEN the current directory is invalid or inaccessible
  THEN it shows appropriate error message
  AND exits gracefully

Scenario: Show operation success
  GIVEN the user runs the command
  WHEN all operations complete successfully
  THEN it shows confirmation message
  AND displays the created relation details
```
