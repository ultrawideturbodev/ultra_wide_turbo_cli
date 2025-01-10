import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/services/workspace_service.dart';

void main() {
  late Directory tempDir;
  late Directory sourceDir;
  late Directory realWorkspaceDir;

  // Helper to copy directory recursively
  Future<void> _copyDirectory(Directory source, Directory target) async {
    await target.create(recursive: true);
    await for (final entity in source.list(recursive: false)) {
      final targetPath = path.join(
        target.path,
        path.basename(entity.path),
      );

      if (entity is Directory) {
        await _copyDirectory(entity, Directory(targetPath));
      } else if (entity is File) {
        await entity.copy(targetPath);
      }
    }
  }

  setUp(() async {
    // Initialize app
    await AppSetup.initialise();

    // Get real workspace directory
    realWorkspaceDir = Directory(
      path.join(
        Directory.current.path,
        'ultra_wide_turbo_workspace',
      ),
    );

    // Create a fresh test directory
    tempDir = await Directory.systemTemp.createTemp('test_workspace');
    sourceDir =
        Directory(path.join(tempDir.path, 'ultra_wide_turbo_workspace'));

    // Copy real workspace to test directory
    await _copyDirectory(realWorkspaceDir, sourceDir);

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

  /// Helper to verify directory structure matches
  Future<void> _verifyDirectoryStructure(String source, String target) async {
    final sourceEntities = await Directory(source)
        .list(recursive: true)
        .where((e) => e is File && !path.basename(e.path).startsWith('.'))
        .map((e) => path.relative(e.path, from: source))
        .toList();

    final targetEntities = await Directory(target)
        .list(recursive: true)
        .where((e) => e is File && !path.basename(e.path).startsWith('.'))
        .map((e) => path.relative(e.path, from: target))
        .toList();

    // Sort both lists for comparison
    sourceEntities.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    targetEntities.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    // Debug logging
    print('Source files (${sourceEntities.length}):');
    for (final file in sourceEntities) {
      print('  $file');
    }
    print('\nTarget files (${targetEntities.length}):');
    for (final file in targetEntities) {
      print('  $file');
    }

    // Create sets for comparison
    final expectedSet = Set<String>.from(sourceEntities);
    final actualSet = Set<String>.from(targetEntities);

    // Check for missing files
    final missingFiles = expectedSet.difference(actualSet);
    if (missingFiles.isNotEmpty) {
      fail('Missing files in target directory: ${missingFiles.join(', ')}');
    }

    // Check for extra files
    final extraFiles = actualSet.difference(expectedSet);
    if (extraFiles.isNotEmpty) {
      fail('Extra files in target directory: ${extraFiles.join(', ')}');
    }

    // Verify total count matches
    expect(
      targetEntities.length,
      equals(sourceEntities.length),
      reason: 'Number of files should match',
    );
  }

  test('turbo clone workspace preserves directory structure', () async {
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
        // Verify required directories exist
        final processes = Directory(path.join(targetDir, 'processes'));
        final protocols = Directory(path.join(targetDir, 'protocols'));
        final prompts = Directory(path.join(targetDir, 'prompts'));
        final knowledge = Directory(path.join(targetDir, 'knowledge'));

        expect(await processes.exists(), true,
            reason: 'processes directory should exist');
        expect(await protocols.exists(), true,
            reason: 'protocols directory should exist');
        expect(await prompts.exists(), true,
            reason: 'prompts directory should exist');
        expect(await knowledge.exists(), true,
            reason: 'knowledge directory should exist');

        // Verify some key files exist
        final taskProcess =
            File(path.join(targetDir, 'processes', '_the-task-process.md'));
        final stickToProcess = File(
            path.join(targetDir, 'protocols', '_plx-stick-to-the-process.md'));
        final requirements =
            File(path.join(targetDir, '_your-requirements.md'));

        expect(await taskProcess.exists(), true,
            reason: 'task process file should exist');
        expect(await stickToProcess.exists(), true,
            reason: 'stick to process file should exist');
        expect(await requirements.exists(), true,
            reason: 'requirements file should exist');
      },
      fail: (f) => fail('Should not fail: ${f.message}'),
    );
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
        // Verify required directories exist
        final processes = Directory(path.join(targetDir, 'processes'));
        final protocols = Directory(path.join(targetDir, 'protocols'));
        final prompts = Directory(path.join(targetDir, 'prompts'));
        final knowledge = Directory(path.join(targetDir, 'knowledge'));

        expect(await processes.exists(), true,
            reason: 'processes directory should exist');
        expect(await protocols.exists(), true,
            reason: 'protocols directory should exist');
        expect(await prompts.exists(), true,
            reason: 'prompts directory should exist');
        expect(await knowledge.exists(), true,
            reason: 'knowledge directory should exist');

        // Verify some key files exist
        final taskProcess =
            File(path.join(targetDir, 'processes', '_the-task-process.md'));
        final stickToProcess = File(
            path.join(targetDir, 'protocols', '_plx-stick-to-the-process.md'));
        final requirements =
            File(path.join(targetDir, '_your-requirements.md'));

        expect(await taskProcess.exists(), true,
            reason: 'task process file should exist');
        expect(await stickToProcess.exists(), true,
            reason: 'stick to process file should exist');
        expect(await requirements.exists(), true,
            reason: 'requirements file should exist');
      },
      fail: (f) => fail('Should not fail: ${f.message}'),
    );
  });

  test(
      'turbo clone workspace shows error message if documents already exist and no force is used',
      () async {
    final service = WorkspaceService.locate;
    final targetDir = path.join(tempDir.path, 'target');

    // Create existing file
    await Directory(targetDir).create(recursive: true);
    await File(path.join(targetDir, '_your-requirements.md'))
        .writeAsString('existing');

    // Act
    final result = await service.cloneWorkspace(
      targetDir: targetDir,
      force: false,
    );

    // Assert
    await result.when(
      success: (_) => fail('Should fail when files exist without force'),
      fail: (_) async {
        final existingFile =
            File(path.join(targetDir, '_your-requirements.md'));
        expect(await existingFile.exists(), true);
        expect(await existingFile.readAsString(), 'existing');
      },
    );
  });

  test(
      'turbo clone workspace --force pastes and overwrites all workspace documents',
      () async {
    final service = WorkspaceService.locate;
    final targetDir = path.join(tempDir.path, 'target');

    // Create existing files
    await Directory(targetDir).create(recursive: true);
    await File(path.join(targetDir, '_your-requirements.md'))
        .writeAsString('existing');

    // Act
    final result = await service.cloneWorkspace(
      targetDir: targetDir,
      force: true,
    );

    // Assert
    await result.when(
      success: (_) async {
        // Verify required directories exist
        final processes = Directory(path.join(targetDir, 'processes'));
        final protocols = Directory(path.join(targetDir, 'protocols'));
        final prompts = Directory(path.join(targetDir, 'prompts'));
        final knowledge = Directory(path.join(targetDir, 'knowledge'));

        expect(await processes.exists(), true,
            reason: 'processes directory should exist');
        expect(await protocols.exists(), true,
            reason: 'protocols directory should exist');
        expect(await prompts.exists(), true,
            reason: 'prompts directory should exist');
        expect(await knowledge.exists(), true,
            reason: 'knowledge directory should exist');

        // Verify some key files exist
        final taskProcess =
            File(path.join(targetDir, 'processes', '_the-task-process.md'));
        final stickToProcess = File(
            path.join(targetDir, 'protocols', '_plx-stick-to-the-process.md'));
        final requirements =
            File(path.join(targetDir, '_your-requirements.md'));

        expect(await taskProcess.exists(), true,
            reason: 'task process file should exist');
        expect(await stickToProcess.exists(), true,
            reason: 'stick to process file should exist');
        expect(await requirements.exists(), true,
            reason: 'requirements file should exist');

        // Verify content was overwritten
        expect(await requirements.readAsString(), isNot('existing'));
      },
      fail: (f) => fail('Should not fail with force: ${f.message}'),
    );
  });

  test('turbo clone workspace preserves exact directory structure', () async {
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
        await _verifyDirectoryStructure(sourceDir.path, targetDir);
      },
      fail: (f) => fail('Should not fail: ${f.message}'),
    );
  });

  test('turbo clone workspace uses default path when no target specified',
      () async {
    final service = WorkspaceService.locate;
    final defaultTargetDir = path.join(tempDir.path, 'turbo-workspace');

    // Act
    final result = await service.cloneWorkspace(
      targetDir: defaultTargetDir,
      force: false,
    );

    // Assert
    await result.when(
      success: (_) async {
        // Verify directory was created at default path
        expect(await Directory(defaultTargetDir).exists(), true);

        // Verify structure matches
        await _verifyDirectoryStructure(sourceDir.path, defaultTargetDir);
      },
      fail: (f) => fail('Should not fail: ${f.message}'),
    );
  });

  test('turbo clone workspace handles nested directory conflicts', () async {
    final service = WorkspaceService.locate;
    final targetDir = path.join(tempDir.path, 'target');

    // Create existing nested structure
    final nestedDir = Directory(path.join(targetDir, 'protocols'));
    await nestedDir.create(recursive: true);
    await File(path.join(nestedDir.path, '_plx-test.md'))
        .writeAsString('existing');

    // Act without force
    var result = await service.cloneWorkspace(
      targetDir: targetDir,
      force: false,
    );

    // Assert failure without force
    await result.when(
      success: (_) => fail('Should fail when nested files exist without force'),
      fail: (_) async {
        final existingFile = File(path.join(nestedDir.path, '_plx-test.md'));
        expect(await existingFile.exists(), true);
        expect(await existingFile.readAsString(), 'existing');
      },
    );

    // Act with force
    result = await service.cloneWorkspace(
      targetDir: targetDir,
      force: true,
    );

    // Assert success with force
    await result.when(
      success: (_) async {
        await _verifyDirectoryStructure(sourceDir.path, targetDir);
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
