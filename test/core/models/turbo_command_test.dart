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

void main() {
  group('tag source command', () {
    late CommandService commandService;

    setUpAll(() async {
      await AppSetup.initialise();
      commandService = CommandService.locate;
      await commandService.isReady;
      await LocalStorageService.locate.isReady;
    });

    test('has correct help text', () async {
      final result = await commandService.run(['tag', 'source', '--help']);
      expect(result, equals(ExitCode.success.code));
    });

    test('requires tag parameter', () async {
      final result = await commandService.run(['tag', 'source']);
      expect(result, equals(ExitCode.usage.code));
    });

    test('accepts tag parameter', () async {
      final result = await commandService.run(['tag', 'source', 'my-tag']);
      expect(result, equals(ExitCode.success.code));
    });
  });

  group('tag target command', () {
    late CommandService commandService;

    setUpAll(() async {
      await AppSetup.initialise();
      commandService = CommandService.locate;
      await commandService.isReady;
      await LocalStorageService.locate.isReady;
    });

    test('has correct help text', () async {
      final result = await commandService.run(['tag', 'target', '--help']);
      expect(result, equals(ExitCode.success.code));
    });

    test('requires tag parameter', () async {
      final result = await commandService.run(['tag', 'target']);
      expect(result, equals(ExitCode.usage.code));
    });

    test('accepts tag parameter', () async {
      final result = await commandService.run(['tag', 'target', 'my-tag']);
      expect(result, equals(ExitCode.success.code));
    });
  });

  group('clone command', () {
    late CommandService commandService;
    late Directory tempDir;
    late Directory sourceDir;

    setUpAll(() async {
      await AppSetup.initialise();
      commandService = CommandService.locate;
      await commandService.isReady;
      await LocalStorageService.locate.isReady;

      // Create temporary directories
      tempDir = await Directory.systemTemp.createTemp('turbo_test_');
      sourceDir = await Directory('${tempDir.path}/source').create();

      // Create test files in source directory
      await File('${sourceDir.path}/file1.txt').writeAsString('Test file 1');
      await File('${sourceDir.path}/file2.txt').writeAsString('Test file 2');
      await Directory('${sourceDir.path}/subdir').create();
      await File('${sourceDir.path}/subdir/file3.txt').writeAsString('Test file 3');
    });

    tearDownAll(() async {
      await tempDir.delete(recursive: true);
    });

    test('has correct help text', () async {
      final result = await commandService.run(['clone', '--help']);
      expect(result, equals(ExitCode.success.code));
    });

    test('requires tag parameter', () async {
      final result = await commandService.run(['clone']);
      expect(result, equals(ExitCode.usage.code));
    });

    test('handles non-existent tag', () async {
      final result = await commandService.run(['clone', 'non-existent-tag']);
      expect(result, equals(ExitCode.software.code));
    });

    test('handles tag without sources', () async {
      // Create a tag without sources
      final now = DateTime.now();
      final tag = TurboTagDto(
        id: 'empty-tag',
        createdAt: now,
        updatedAt: now,
        createdBy: 'test-user',
        parentId: null,
      );
      await LocalStorageService.locate.addTag(turboTag: tag);

      final result = await commandService.run(['clone', 'empty-tag']);
      expect(result, equals(ExitCode.software.code));
    });

    test('clones files from source', () async {
      // Create a tag and source
      final now = DateTime.now();
      final tag = TurboTagDto(
        id: 'test-tag',
        createdAt: now,
        updatedAt: now,
        createdBy: 'test-user',
        parentId: null,
      );
      await LocalStorageService.locate.addTag(turboTag: tag);

      final source = TurboSourceDto(
        id: sourceDir.path,
        createdAt: now,
        updatedAt: now,
        createdBy: 'test-user',
      );
      await LocalStorageService.locate.addSource(turboSource: source);

      final relation = TurboRelationDto(
        id: '${sourceDir.path}-test-tag',
        createdAt: now,
        updatedAt: now,
        createdBy: 'test-user',
        turboTagId: 'test-tag',
        turboSourceId: sourceDir.path,
        type: TurboRelationType.sourceTag,
      );
      await LocalStorageService.locate.addRelation(turboRelation: relation);

      // Create target directory
      final targetDir = await Directory('${tempDir.path}/target').create();
      Directory.current = targetDir;

      final result = await commandService.run(['clone', 'test-tag']);
      expect(result, equals(ExitCode.success.code));

      // Verify files were copied
      expect(File('${targetDir.path}/file1.txt').existsSync(), isTrue);
      expect(File('${targetDir.path}/file2.txt').existsSync(), isTrue);
      expect(File('${targetDir.path}/subdir/file3.txt').existsSync(), isTrue);

      // Verify file contents
      expect(await File('${targetDir.path}/file1.txt').readAsString(), equals('Test file 1'));
      expect(await File('${targetDir.path}/file2.txt').readAsString(), equals('Test file 2'));
      expect(
          await File('${targetDir.path}/subdir/file3.txt').readAsString(), equals('Test file 3'));
    });

    test('respects force flag', () async {
      // Create target directory with existing file
      final targetDir = await Directory('${tempDir.path}/target_force').create();
      await File('${targetDir.path}/file1.txt').writeAsString('Existing file');
      Directory.current = targetDir;

      // First attempt without force flag
      var result = await commandService.run(['clone', 'test-tag']);
      expect(result, equals(ExitCode.success.code));
      expect(await File('${targetDir.path}/file1.txt').readAsString(), equals('Existing file'));

      // Second attempt with force flag
      result = await commandService.run(['clone', 'test-tag', '--force']);
      expect(result, equals(ExitCode.success.code));
      expect(await File('${targetDir.path}/file1.txt').readAsString(), equals('Test file 1'));
    });
  });
}
