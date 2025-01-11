import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:test/test.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/services/command_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/local_storage_service.dart';

class _TestIOOverrides extends IOOverrides {
  final Directory testDir;
  _TestIOOverrides(this.testDir);

  @override
  Directory getCurrentDirectory() => testDir;
}

void main() {
  late Directory tempDir;
  late Directory folderA;
  late Directory folderB;
  late Directory folderC;
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

    // Create temp directory structure for testing
    tempDir = await Directory.systemTemp.createTemp('test_workspace');
    folderA = await Directory('${tempDir.path}/folder_a').create();
    folderB = await Directory('${tempDir.path}/folder_b').create();
    folderC = await Directory('${tempDir.path}/folder_c').create();

    // Create some test files in folder A
    await File('${folderA.path}/file1.txt').writeAsString('Test file 1');
    await File('${folderA.path}/file2.txt').writeAsString('Test file 2');
    await Directory('${folderA.path}/subdir').create();
    await File('${folderA.path}/subdir/file3.txt').writeAsString('Test file 3');
  });

  tearDownAll(() async {
    // Clean up temp directories
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

  group('Feature: Tag Source and Clone Workflow', () {
    test('GIVEN user tags source in folder A and clones to folders B and C', () async {
      // WHEN user runs tag source in folder A
      IOOverrides.global = _TestIOOverrides(folderA);
      var result = await commandService.run(['tag', 'source', 'test-tag']);
      expect(result, equals(ExitCode.success.code));

      // Wait for storage operations to complete
      await Future.delayed(const Duration(milliseconds: 200));

      // THEN verify source was created
      var storage = storageService.localStorageDto;
      var source = storage.turboSources.firstWhere(
        (s) => s.id == folderA.path,
        orElse: () => throw Exception('Source not found'),
      );
      expect(source, isNotNull);
      expect(source.id, equals(folderA.path));

      // WHEN user clones tag in folder B
      IOOverrides.global = _TestIOOverrides(folderB);
      result = await commandService.run(['clone', 'test-tag']);
      expect(result, equals(ExitCode.success.code));

      // THEN verify files were cloned to folder B
      expect(File('${folderB.path}/file1.txt').existsSync(), isTrue);
      expect(File('${folderB.path}/file2.txt').existsSync(), isTrue);
      expect(File('${folderB.path}/subdir/file3.txt').existsSync(), isTrue);

      // AND verify file contents
      expect(await File('${folderB.path}/file1.txt').readAsString(), equals('Test file 1'));
      expect(await File('${folderB.path}/file2.txt').readAsString(), equals('Test file 2'));
      expect(await File('${folderB.path}/subdir/file3.txt').readAsString(), equals('Test file 3'));

      // WHEN user clones tag in folder C
      IOOverrides.global = _TestIOOverrides(folderC);
      result = await commandService.run(['clone', 'test-tag']);
      expect(result, equals(ExitCode.success.code));

      // THEN verify files were cloned to folder C
      expect(File('${folderC.path}/file1.txt').existsSync(), isTrue);
      expect(File('${folderC.path}/file2.txt').existsSync(), isTrue);
      expect(File('${folderC.path}/subdir/file3.txt').existsSync(), isTrue);

      // AND verify file contents
      expect(await File('${folderC.path}/file1.txt').readAsString(), equals('Test file 1'));
      expect(await File('${folderC.path}/file2.txt').readAsString(), equals('Test file 2'));
      expect(await File('${folderC.path}/subdir/file3.txt').readAsString(), equals('Test file 3'));
    });
  });
}
