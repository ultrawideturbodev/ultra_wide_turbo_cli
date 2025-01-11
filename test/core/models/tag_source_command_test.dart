import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:test/test.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/turbo_relation_dto.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/turbo_source_dto.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/turbo_tag_dto.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_relation_type.dart';
import 'package:ultra_wide_turbo_cli/core/services/command_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/local_storage_service.dart';

class _TestIOOverrides extends IOOverrides {
  final Directory testDir;
  final bool simulateInvalidDir;
  _TestIOOverrides(this.testDir, {this.simulateInvalidDir = false});

  @override
  Directory getCurrentDirectory() {
    if (simulateInvalidDir) {
      return Directory('/invalid/directory/that/does/not/exist');
    }
    return testDir;
  }
}

void main() {
  late Directory tempDir;
  late LocalStorageService storageService;
  late CommandService commandService;

  setUpAll(() async {
    // Initialize app and services
    await AppSetup.initialise();
    storageService = LocalStorageService.locate;
    commandService = CommandService.locate;

    // Wait for services to be ready
    await storageService.isReady;
    await commandService.isReady;

    // Create temp directory for testing
    tempDir = await Directory.systemTemp.createTemp('test_dir');
    IOOverrides.global = _TestIOOverrides(tempDir);
  });

  tearDownAll(() async {
    // Clean up temp directory
    IOOverrides.global = null;
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    // Reset storage before each test
    await storageService.clearTags();
    await storageService.clearSources();
    await storageService.clearRelations();

    // Wait for storage operations to complete
    await Future.delayed(const Duration(milliseconds: 100));
  });

  group('Feature: Tag Source Command', () {
    // M1: Command Layer Implementation
    group('Scenario: Register new tag source command', () {
      test('GIVEN the CLI application is running', () async {
        // WHEN the system initializes commands
        final result = await commandService.run(['tag', 'source', '--help']);

        // THEN the "tag source" command is registered under "tag"
        expect(result, equals(ExitCode.success.code));

        // AND it accepts a tag parameter
        final resultWithParam =
            await commandService.run(['tag', 'source', 'test-tag']);
        expect(resultWithParam, equals(ExitCode.success.code));

        // AND it shows in help text
        final helpResult =
            await commandService.run(['tag', 'source', '--help']);
        expect(helpResult, equals(ExitCode.success.code));
      });
    });

    group('Scenario: Validate tag parameter', () {
      test('GIVEN the user runs "turbo tag source"', () async {
        // WHEN no tag parameter is provided
        final result = await commandService.run(['tag', 'source']);

        // THEN the system shows an error message
        expect(result, equals(ExitCode.usage.code));
      });
    });

    // M2: Tag Validation and Creation
    group('Scenario: Validate existing tag', () {
      test('GIVEN the user runs "turbo tag source <existing-tag>"', () async {
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
        final result =
            await commandService.run(['tag', 'source', 'existing-tag']);

        // THEN it finds the tag
        final storage = storageService.localStorageDto;
        final foundTag =
            storage.turboTags.where((t) => t.id == 'existing-tag').firstOrNull;
        expect(foundTag, isNotNull);

        // AND proceeds with source linking
        expect(result, equals(ExitCode.success.code));
      });
    });

    group('Scenario: Create new tag', () {
      test('GIVEN the user runs "turbo tag source <new-tag>"', () async {
        // WHEN the system checks local storage
        final result = await commandService.run(['tag', 'source', 'new-tag']);

        // AND doesn't find the tag
        // THEN it creates a new TurboTagDto
        final storage = storageService.localStorageDto;
        final newTag =
            storage.turboTags.where((t) => t.id == 'new-tag').firstOrNull;
        expect(newTag, isNotNull);

        // AND stores it in local storage
        expect(newTag!.id, equals('new-tag'));

        // AND proceeds with source linking
        expect(result, equals(ExitCode.success.code));
      });
    });

    // M3: Source Management
    group('Scenario: Create new source from directory', () {
      test('GIVEN the command has a valid tag', () async {
        // WHEN the system checks the current directory
        final result = await commandService.run(['tag', 'source', 'my-tag']);
        expect(result, equals(ExitCode.success.code));

        // Wait for storage operations to complete
        await Future.delayed(const Duration(milliseconds: 300));

        // AND the directory is not registered as a source
        final storage = storageService.localStorageDto;

        // THEN it creates a new TurboSourceDto
        final source = storage.turboSources.firstWhere(
          (s) => s.id.toLowerCase().startsWith('test_dir'),
          orElse: () =>
              throw Exception('Source not found with pattern test_dir*'),
        );
        expect(source, isNotNull);

        // AND stores it in local storage
        expect(source.id.toLowerCase().startsWith('test_dir'), isTrue);
        expect(source.createdBy, isNotNull);
        expect(source.createdAt, isNotNull);
        expect(source.updatedAt, isNotNull);
      });
    });

    group('Scenario: Use existing source', () {
      test('GIVEN the command has a valid tag', () async {
        // Setup existing source
        final now = DateTime.now();
        final dirName = tempDir.path.split('/').last;
        final source = TurboSourceDto(
          id: dirName,
          createdAt: now,
          updatedAt: now,
          createdBy: 'test-user',
        );
        await storageService.addSource(turboSource: source);

        // WHEN the system checks the current directory
        final result = await commandService.run(['tag', 'source', 'my-tag']);
        expect(result, equals(ExitCode.success.code));

        // Wait for storage operations to complete
        await Future.delayed(const Duration(milliseconds: 200));

        // AND the directory is already registered as a source
        final storage = storageService.localStorageDto;
        final sources = storage.turboSources.where((s) => s.id == dirName);

        // THEN it uses the existing TurboSourceDto
        expect(sources.length, equals(1));
        expect(sources.first.id, equals(dirName));
        expect(sources.first.createdAt, equals(now));
      });
    });

    // M4: Relation Creation
    group('Scenario: Create new relation', () {
      test('GIVEN valid tag and source exist', () async {
        // WHEN the system checks for an existing relation
        final result = await commandService.run(['tag', 'source', 'my-tag']);
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

        // Verify source was created
        final source = storage.turboSources.firstWhere(
          (s) => s.id.startsWith('test_dir'),
          orElse: () => throw Exception('Source not found'),
        );
        expect(source, isNotNull);
        expect(source.id.startsWith('test_dir'), isTrue);

        // Verify relation was created
        final relation = storage.turboRelations.firstWhere(
          (r) =>
              r.turboTagId == 'my-tag' &&
              r.turboSourceId == source.id &&
              r.type == TurboRelationType.sourceTag,
          orElse: () => throw Exception('Relation not found'),
        );

        // AND stores it in local storage
        expect(relation, isNotNull);
        expect(relation.turboTagId, equals('my-tag'));
        expect(relation.turboSourceId, equals(source.id));
        expect(relation.type, equals(TurboRelationType.sourceTag));
        expect(relation.createdBy, isNotNull);
        expect(relation.createdAt, isNotNull);
        expect(relation.updatedAt, isNotNull);
      });
    });

    group('Scenario: Handle existing relation', () {
      test('GIVEN valid tag and source exist', () async {
        // Setup existing relation
        final now = DateTime.now();
        final dirName = tempDir.path.split('/').last;
        final relation = TurboRelationDto(
          id: '$dirName-my-tag',
          createdAt: now,
          updatedAt: now,
          createdBy: 'test-user',
          turboTagId: 'my-tag',
          turboSourceId: dirName,
          type: TurboRelationType.sourceTag,
        );
        await storageService.addRelation(turboRelation: relation);

        // WHEN the system checks for an existing relation
        final result = await commandService.run(['tag', 'source', 'my-tag']);
        expect(result, equals(ExitCode.success.code));

        // Wait for storage operations to complete
        await Future.delayed(const Duration(milliseconds: 200));

        // AND a relation already exists
        final storage = storageService.localStorageDto;
        final relations = storage.turboRelations.where(
          (r) =>
              r.turboTagId == 'my-tag' &&
              r.turboSourceId == dirName &&
              r.type == TurboRelationType.sourceTag,
        );

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
        IOOverrides.global =
            _TestIOOverrides(tempDir, simulateInvalidDir: true);

        // WHEN the system checks the current directory
        final result = await commandService.run(['tag', 'source', 'my-tag']);

        // THEN it shows an error message
        expect(result, equals(ExitCode.software.code));

        // Reset IOOverrides for subsequent tests
        IOOverrides.global = _TestIOOverrides(tempDir);
      });
    });

    group('Scenario: Show operation success', () {
      test('GIVEN the user runs the command', () async {
        // WHEN the system completes all operations
        final result = await commandService.run(['tag', 'source', 'my-tag']);

        // THEN it shows a success message
        expect(result, equals(ExitCode.success.code));
      });
    });
  });
}
