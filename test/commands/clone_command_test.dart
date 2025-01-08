import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_tag_type.dart';
import 'package:ultra_wide_turbo_cli/core/services/command_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/logger_service.dart';

void main() {
  group('Clone Command', () {
    late Directory tempDir;
    late CommandService commandService;
    late Directory originalDir;
    late Logger log;

    setUp(() async {
      await AppSetup.initialise();
      commandService = CommandService.locate;
      await commandService.isReady;
      log = LoggerService.locate.log;

      // Store original directory
      originalDir = Directory.current;

      // Create a temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('turbo_test_');

      // Create source workspace directory with test files
      final workspaceDir =
          Directory(path.join(tempDir.path, 'ultra_wide_turbo_workspace'));
      await workspaceDir.create(recursive: true);
      await File(path.join(workspaceDir.path, 'test.md'))
          .writeAsString('test content');
      await File(path.join(workspaceDir.path, 'normal.txt'))
          .writeAsString('normal content');

      final testDir = Directory(path.join(workspaceDir.path, 'test_dir'));
      await testDir.create();
      await File(path.join(testDir.path, 'file.txt'))
          .writeAsString('nested content');

      // Set current directory to temp dir for relative path resolution
      Directory.current = tempDir.path;
    });

    tearDown(() async {
      // Always restore original directory first
      Directory.current = originalDir.path;

      // Then try to clean up temp directory
      try {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (e) {
        log.warn('Failed to clean up temp directory: $e');
      }
    });

    test('fails without clone type', () async {
      final result = await commandService.run(['clone']);
      expect(result, equals(ExitCode.usage.code));
      log.success('TEST PASSED: fails without clone type');
    });

    test('fails with invalid clone type', () async {
      final result = await commandService.run(['clone', 'invalid']);
      expect(result, equals(ExitCode.usage.code));
      log.success('TEST PASSED: fails with invalid clone type');
    });

    test('clones workspace successfully', () async {
      final targetDir = path.join(tempDir.path, 'target');
      final result = await commandService.run([
        'clone',
        TurboTagType.workspace.argument,
        '--target',
        targetDir,
      ]);
      expect(result, equals(ExitCode.success.code));

      // Verify files were cloned correctly
      expect(await Directory(targetDir).exists(), isTrue);
      expect(await File(path.join(targetDir, 'test.md')).exists(), isTrue);
      expect(await File(path.join(targetDir, 'normal.txt')).exists(), isTrue);
      expect(
          await Directory(path.join(targetDir, 'test_dir')).exists(), isTrue);
      expect(await File(path.join(targetDir, 'test_dir', 'file.txt')).exists(),
          isTrue);

      // Verify content was preserved
      expect(
        await File(path.join(targetDir, 'test.md')).readAsString(),
        equals('test content'),
      );
      expect(
        await File(path.join(targetDir, 'normal.txt')).readAsString(),
        equals('normal content'),
      );
      expect(
        await File(path.join(targetDir, 'test_dir', 'file.txt')).readAsString(),
        equals('nested content'),
      );

      log.success('TEST PASSED: clones workspace successfully');
    });

    test('fails when cloning to existing directory without force flag',
        () async {
      // Given: An existing target directory with some content
      final targetDir = path.join(tempDir.path, 'existing_target');
      await Directory(targetDir).create();
      await File(path.join(targetDir, 'existing_file.txt'))
          .writeAsString('existing content');

      // When: Attempting to clone to the existing directory
      final result = await commandService.run([
        'clone',
        TurboTagType.workspace.argument,
        '--target',
        targetDir,
      ]);

      // Then: Command should fail
      expect(result, equals(ExitCode.software.code));

      // And: Original content should remain unchanged
      final existingFile = File(path.join(targetDir, 'existing_file.txt'));
      expect(await existingFile.exists(), isTrue);
      expect(await existingFile.readAsString(), equals('existing content'));

      log.success(
          'TEST PASSED: fails when cloning to existing directory without force flag');
    });

    test('succeeds when cloning to existing directory with force flag',
        () async {
      // Given: An existing target directory with some content
      final targetDir = path.join(tempDir.path, 'force_target');
      await Directory(targetDir).create();
      await File(path.join(targetDir, 'existing_file.txt'))
          .writeAsString('existing content');

      // When: Attempting to clone to the existing directory with force flag
      final result = await commandService.run([
        'clone',
        TurboTagType.workspace.argument,
        '--target',
        targetDir,
        '--force',
      ]);

      // Then: Command should succeed
      expect(result, equals(ExitCode.success.code));

      // And: Original content should be replaced with cloned content
      expect(await File(path.join(targetDir, 'existing_file.txt')).exists(),
          isFalse);
      expect(await File(path.join(targetDir, 'test.md')).exists(), isTrue);
      expect(await File(path.join(targetDir, 'normal.txt')).exists(), isTrue);
      expect(
          await Directory(path.join(targetDir, 'test_dir')).exists(), isTrue);

      log.success(
          'TEST PASSED: succeeds when cloning to existing directory with force flag');
    });

    test('fails with insufficient permissions', () async {
      // Given: A target directory with insufficient permissions
      final targetDir = path.join(tempDir.path, 'no_permissions');
      await Directory(targetDir).create();

      // Make directory read-only
      await Process.run('chmod', ['444', targetDir]);

      // When: Attempting to clone to the protected directory
      final result = await commandService.run([
        'clone',
        TurboTagType.workspace.argument,
        '--target',
        targetDir,
      ]);

      // Then: Command should fail
      expect(result, equals(ExitCode.software.code));

      // Cleanup: Restore permissions for cleanup
      await Process.run('chmod', ['755', targetDir]);

      log.success('TEST PASSED: fails with insufficient permissions');
    });
  });
}
