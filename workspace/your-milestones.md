---
document_type: agent work document
goal: track progress of implementation milestones
gpt_action: use as a reference to track progress and next steps
---

# 🎯 Milestones

## M1: Command Layer Implementation ⏳
> Add command registration and parameter validation

### Tests
```dart
group('Feature: Tag Target Command', () {
  group('Scenario: Register new tag target command', () {
    test('GIVEN the CLI application is running', () async {
      // WHEN the system initializes commands
      final result = await commandService.run(['tag', 'target', '--help']);

      // THEN the "tag target" command is registered under "tag"
      expect(result, equals(ExitCode.success.code));

      // AND it accepts a tag parameter
      final resultWithParam = await commandService.run(['tag', 'target', 'test-tag']);
      expect(resultWithParam, equals(ExitCode.success.code));

      // AND it shows in help text
      final helpResult = await commandService.run(['tag', 'target', '--help']);
      expect(helpResult, equals(ExitCode.success.code));
    });
  });

  group('Scenario: Validate tag parameter', () {
    test('GIVEN the user runs "turbo tag target"', () async {
      // WHEN no tag parameter is provided
      final result = await commandService.run(['tag', 'target']);

      // THEN the system shows an error message
      expect(result, equals(ExitCode.usage.code));
    });
  });
});
```

### Tasks
- [ ] Add `tagTarget` to `TurboCommandType` enum
- [ ] Add command description and help text
- [ ] Register command under `tag` parent
- [ ] Implement tag parameter validation

## M2: Tag Validation and Creation ⏳
> Implement tag validation and creation logic

### Tests
```dart
group('Scenario: Validate existing tag', () {
  test('GIVEN the user runs "turbo tag target <existing-tag>"', () async {
    // Setup existing tag
    final now = DateTime.now();
    final tag = TurboTagDto(
      id: 'existing-tag',
      createdAt: now,
      updatedAt: now,
      createdBy: 'test-user',
      parentId: null,
    );
    await storageService.addTag(turboTag: tag);

    // WHEN the system checks local storage
    final result = await commandService.run(['tag', 'target', 'existing-tag']);

    // THEN it finds the tag
    final storage = storageService.localStorageDto;
    final foundTag = storage.turboTags.where((t) => t.id == 'existing-tag').firstOrNull;
    expect(foundTag, isNotNull);

    // AND proceeds with target linking
    expect(result, equals(ExitCode.success.code));
  });
});

group('Scenario: Create new tag', () {
  test('GIVEN the user runs "turbo tag target <new-tag>"', () async {
    // WHEN the system checks local storage
    final result = await commandService.run(['tag', 'target', 'new-tag']);

    // AND doesn't find the tag
    // THEN it creates a new TurboTagDto
    final storage = storageService.localStorageDto;
    final newTag = storage.turboTags.where((t) => t.id == 'new-tag').firstOrNull;
    expect(newTag, isNotNull);

    // AND stores it in local storage
    expect(newTag!.id, equals('new-tag'));

    // AND proceeds with target linking
    expect(result, equals(ExitCode.success.code));
  });
});
```

### Tasks
- [ ] Implement tag name validation
- [ ] Add tag existence check
- [ ] Implement tag creation logic
- [ ] Add storage integration

## M3: Target Management ⏳
> Implement target directory validation and management

### Tests
```dart
group('Scenario: Create new target from directory', () {
  test('GIVEN the command has a valid tag', () async {
    // WHEN the system checks the current directory
    final result = await commandService.run(['tag', 'target', 'my-tag']);
    expect(result, equals(ExitCode.success.code));

    // Wait for storage operations to complete
    await Future.delayed(const Duration(milliseconds: 300));

    // AND the directory is not registered as a target
    final storage = storageService.localStorageDto;

    // THEN it creates a new TurboTargetDto
    final target = storage.turboTargets.firstWhere(
      (s) => s.id.toLowerCase().startsWith('test_dir'),
      orElse: () => throw Exception('Target not found with pattern test_dir*'),
    );
    expect(target, isNotNull);

    // AND stores it in local storage
    expect(target.id.toLowerCase().startsWith('test_dir'), isTrue);
    expect(target.createdBy, isNotNull);
    expect(target.createdAt, isNotNull);
    expect(target.updatedAt, isNotNull);
  });
});

group('Scenario: Use existing target', () {
  test('GIVEN the command has a valid tag', () async {
    // Setup existing target
    final now = DateTime.now();
    final dirName = tempDir.path.split('/').last;
    final target = TurboTargetDto(
      id: dirName,
      createdAt: now,
      updatedAt: now,
      createdBy: 'test-user',
    );
    await storageService.addTarget(turboTarget: target);

    // WHEN the system checks the current directory
    final result = await commandService.run(['tag', 'target', 'my-tag']);
    expect(result, equals(ExitCode.success.code));

    // Wait for storage operations to complete
    await Future.delayed(const Duration(milliseconds: 200));

    // AND the directory is already registered as a target
    final storage = storageService.localStorageDto;
    final targets = storage.turboTargets.where((s) => s.id == dirName);

    // THEN it uses the existing TurboTargetDto
    expect(targets.length, equals(1));
    expect(targets.first.id, equals(dirName));
    expect(targets.first.createdAt, equals(now));
  });
});
```

### Tasks
- [ ] Add directory validation
- [ ] Implement target creation
- [ ] Add target existence check
- [ ] Add storage integration

## M4: Relation Creation ⏳
> Implement relation management and error handling

### Tests
```dart
group('Scenario: Create new relation', () {
  test('GIVEN valid tag and target exist', () async {
    // WHEN the system checks for an existing relation
    final result = await commandService.run(['tag', 'target', 'my-tag']);
    expect(result, equals(ExitCode.success.code));

    // Wait for storage operations to complete
    await Future.delayed(const Duration(milliseconds: 200));

    // AND no relation exists
    // THEN it creates a new TurboRelationDto
    final storage = storageService.localStorageDto;

    // Verify tag was created
    final tag = storage.turboTags.firstWhere(
      (t) => t.id == 'my-tag',
      orElse: () => throw Exception('Tag not found'),
    );
    expect(tag, isNotNull);
    expect(tag.id, equals('my-tag'));

    // Verify target was created
    final target = storage.turboTargets.firstWhere(
      (s) => s.id.startsWith('test_dir'),
      orElse: () => throw Exception('Target not found'),
    );
    expect(target, isNotNull);
    expect(target.id.startsWith('test_dir'), isTrue);

    // Verify relation was created
    final relation = storage.turboRelations.firstWhere(
      (r) =>
          r.turboTagId == 'my-tag' &&
          r.turboTargetId == target.id &&
          r.type == TurboRelationType.targetTag,
      orElse: () => throw Exception('Relation not found'),
    );

    // AND stores it in local storage
    expect(relation, isNotNull);
    expect(relation.turboTagId, equals('my-tag'));
    expect(relation.turboTargetId, equals(target.id));
    expect(relation.type, equals(TurboRelationType.targetTag));
    expect(relation.createdBy, isNotNull);
    expect(relation.createdAt, isNotNull);
    expect(relation.updatedAt, isNotNull);
  });
});

group('Scenario: Handle existing relation', () {
  test('GIVEN valid tag and target exist', () async {
    // Setup existing relation
    final now = DateTime.now();
    final dirName = tempDir.path.split('/').last;
    final relation = TurboRelationDto(
      id: '$dirName-my-tag',
      createdAt: now,
      updatedAt: now,
      createdBy: 'test-user',
      turboTagId: 'my-tag',
      turboTargetId: dirName,
      type: TurboRelationType.targetTag,
    );
    await storageService.addRelation(turboRelation: relation);

    // WHEN the system checks for an existing relation
    final result = await commandService.run(['tag', 'target', 'my-tag']);
    expect(result, equals(ExitCode.success.code));

    // Wait for storage operations to complete
    await Future.delayed(const Duration(milliseconds: 200));

    // AND a relation already exists
    final storage = storageService.localStorageDto;
    final relations = storage.turboRelations.where((r) =>
        r.turboTagId == 'my-tag' &&
        r.turboTargetId == dirName &&
        r.type == TurboRelationType.targetTag);

    // THEN it shows "already exists" message
    expect(result, equals(ExitCode.success.code));

    // AND does not create duplicate relation
    expect(relations.length, equals(1));
    expect(relations.first.id, equals('$dirName-my-tag'));
    expect(relations.first.createdAt, equals(now));
    expect(relations.first.createdBy, equals('test-user'));
  });
});

group('Scenario: Handle invalid directory', () {
  test('GIVEN the user runs the command', () async {
    // Setup invalid directory
    IOOverrides.global = _TestIOOverrides(tempDir, simulateInvalidDir: true);

    // WHEN the system checks the current directory
    final result = await commandService.run(['tag', 'target', 'my-tag']);

    // THEN it shows an error message
    expect(result, equals(ExitCode.software.code));

    // Reset IOOverrides for subsequent tests
    IOOverrides.global = _TestIOOverrides(tempDir);
  });
});

group('Scenario: Show operation success', () {
  test('GIVEN the user runs the command', () async {
    // WHEN the system completes all operations
    final result = await commandService.run(['tag', 'target', 'my-tag']);

    // THEN it shows a success message
    expect(result, equals(ExitCode.success.code));
  });
});
```

### Tasks
- [ ] Add `targetTag` to `TurboRelationType` enum
- [ ] Implement relation creation
- [ ] Add relation existence check
- [ ] Add error handling
- [ ] Add success messages
