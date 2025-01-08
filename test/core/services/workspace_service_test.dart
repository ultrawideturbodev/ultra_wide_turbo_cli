import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/services/workspace_service.dart';

void main() {
  late Directory tempDir;
  late Directory sourceDir;

  setUp(() async {
    // Initialize app
    await AppSetup.initialise();

    // Create a fresh test directory
    tempDir = await Directory.systemTemp.createTemp('test_workspace');
    sourceDir = Directory(path.join(tempDir.path, 'ultra_wide_turbo_workspace'));

    // Create source workspace files
    await sourceDir.create(recursive: true);
    await File(path.join(sourceDir.path, 'test1.txt')).writeAsString('test1');
    await File(path.join(sourceDir.path, '_test2.txt')).writeAsString('test2');
    await Directory(path.join(sourceDir.path, 'subdir')).create();
    await File(path.join(sourceDir.path, 'subdir', 'test3.txt')).writeAsString('test3');

    // Override Directory.current to point to our test directory
    IOOverrides.global = _TestIOOverrides(tempDir);
  });

  tearDown(() async {
    // Remove override and clean up
    IOOverrides.global = null;
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('turbo clone workspace pastes all workspace documents', () async {
    final service = WorkspaceService.locate;
    final targetDir = path.join(tempDir.path, 'target');

    // Act
    final result = await service.cloneWorkspace(
      targetDir: targetDir,
      force: false,
    );

    // Assert
    await result.when(
      success: (_) async {
        final test1File = File(path.join(targetDir, 'test1.txt'));
        final test2File = File(path.join(targetDir, 'test2.txt'));
        final test3File = File(path.join(targetDir, 'subdir', 'test3.txt'));

        expect(await test1File.exists(), true);
        expect(await test2File.exists(), true);
        expect(await test3File.exists(), true);

        expect(await test1File.readAsString(), 'test1');
        expect(await test2File.readAsString(), 'test2');
        expect(await test3File.readAsString(), 'test3');
      },
      fail: (f) => fail('Should not fail: ${f.message}'),
    );
  });

  test('turbo clone workspace shows error message if documents already exist and no force is used',
      () async {
    final service = WorkspaceService.locate;
    final targetDir = path.join(tempDir.path, 'target');

    // Create existing file
    await Directory(targetDir).create(recursive: true);
    await File(path.join(targetDir, 'test1.txt')).writeAsString('existing');

    // Act
    final result = await service.cloneWorkspace(
      targetDir: targetDir,
      force: false,
    );

    // Assert
    await result.when(
      success: (_) => fail('Should fail when files exist without force'),
      fail: (_) async {
        final existingFile = File(path.join(targetDir, 'test1.txt'));
        expect(await existingFile.exists(), true);
        expect(await existingFile.readAsString(), 'existing');
      },
    );
  });

  test('turbo clone workspace --force pastes and overwrites all workspace documents', () async {
    final service = WorkspaceService.locate;
    final targetDir = path.join(tempDir.path, 'target');

    // Create existing files
    await Directory(targetDir).create(recursive: true);
    await File(path.join(targetDir, 'test1.txt')).writeAsString('existing');

    // Act
    final result = await service.cloneWorkspace(
      targetDir: targetDir,
      force: true,
    );

    // Assert
    await result.when(
      success: (_) async {
        final test1File = File(path.join(targetDir, 'test1.txt'));
        final test2File = File(path.join(targetDir, 'test2.txt'));
        final test3File = File(path.join(targetDir, 'subdir', 'test3.txt'));

        expect(await test1File.exists(), true);
        expect(await test2File.exists(), true);
        expect(await test3File.exists(), true);

        expect(await test1File.readAsString(), 'test1');
        expect(await test2File.readAsString(), 'test2');
        expect(await test3File.readAsString(), 'test3');
      },
      fail: (f) => fail('Should not fail with force: ${f.message}'),
    );
  });
}

class _TestIOOverrides extends IOOverrides {
  final Directory _testDir;
  _TestIOOverrides(this._testDir);

  @override
  Directory getCurrentDirectory() => _testDir;
}
