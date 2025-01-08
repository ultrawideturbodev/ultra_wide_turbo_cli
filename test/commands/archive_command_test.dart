import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:test/test.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_tag_type.dart';
import 'package:ultra_wide_turbo_cli/core/services/command_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/logger_service.dart';

void main() {
  group('Archive Command', () {
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

      // Create source directory with test files
      final sourceDir = Directory('${tempDir.path}/source');
      await sourceDir.create();
      await File('${sourceDir.path}/test.txt').writeAsString('test content');
      await File('${sourceDir.path}/another.txt').writeAsString('another content');
      await Directory('${sourceDir.path}/subdir').create();
      await File('${sourceDir.path}/subdir/nested.txt').writeAsString('nested content');

      // Set current directory to source dir for relative path resolution
      Directory.current = sourceDir;
    });

    tearDown(() async {
      try {
        // Restore original directory
        Directory.current = originalDir;

        // Clean up temp directory
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (e) {
        // Ignore errors during cleanup
      }
    });

    test('fails without archive type argument', () async {
      final result = await commandService.run(['archive']);
      expect(result, equals(ExitCode.usage.code));
      log.success('TEST PASSED: fails without archive type argument');
    });

    test('fails with invalid archive type', () async {
      final result = await commandService.run(['archive', 'invalid']);
      expect(result, equals(ExitCode.usage.code));
      log.success('TEST PASSED: fails with invalid archive type');
    });

    test('archives workspace successfully', () async {
      final targetDir = '${tempDir.path}/archive';
      final result = await commandService.run([
        'archive',
        TurboTagType.workspace.argument,
        '--target',
        targetDir,
      ]);
      expect(result, equals(ExitCode.success.code));

      // Verify files were copied
      final archiveDir = Directory(targetDir);
      expect(await archiveDir.exists(), isTrue);
      expect(
        await File('$targetDir/test.txt').readAsString(),
        equals('test content'),
      );
      expect(
        await File('$targetDir/another.txt').readAsString(),
        equals('another content'),
      );
      expect(
        await File('$targetDir/subdir/nested.txt').readAsString(),
        equals('nested content'),
      );
      log.success('TEST PASSED: archives workspace successfully');
    });

    group('when target directory exists', () {
      late String targetDir;

      setUp(() async {
        targetDir = '${tempDir.path}/archive';
        await Directory(targetDir).create();
        await File('$targetDir/existing.txt').writeAsString('existing content');
      });

      test('fails when target exists without force flag', () async {
        final result = await commandService.run([
          'archive',
          TurboTagType.workspace.argument,
          '--target',
          targetDir,
        ]);
        expect(result, equals(ExitCode.software.code));

        // Verify existing files were not modified
        expect(
          await File('$targetDir/existing.txt').readAsString(),
          equals('existing content'),
        );
        log.success('TEST PASSED: fails when target exists without force flag');
      });

      test('overwrites existing directory with force flag', () async {
        final result = await commandService.run([
          'archive',
          TurboTagType.workspace.argument,
          '--target',
          targetDir,
          '--force',
        ]);
        expect(result, equals(ExitCode.success.code));

        // Verify directory was overwritten
        expect(await File('$targetDir/existing.txt').exists(), isFalse);
        expect(
          await File('$targetDir/test.txt').readAsString(),
          equals('test content'),
        );
        log.success(
          'TEST PASSED: overwrites existing directory with force flag',
        );
      });
    });

    test('handles relative paths correctly', () async {
      final result = await commandService.run([
        'archive',
        TurboTagType.workspace.argument,
        '--target',
        '../relative_archive',
      ]);
      expect(result, equals(ExitCode.success.code));

      // Verify files were copied
      final archiveDir = Directory('${tempDir.path}/relative_archive');
      expect(await archiveDir.exists(), isTrue);
      expect(
        await File('${archiveDir.path}/test.txt').readAsString(),
        equals('test content'),
      );
      log.success('TEST PASSED: handles relative paths correctly');
    });

    test('prevents archiving to subdirectory of source', () async {
      final result = await commandService.run([
        'archive',
        TurboTagType.workspace.argument,
        '--target',
        './subdir/archive',
      ]);
      expect(result, equals(ExitCode.software.code));
      log.success('TEST PASSED: prevents archiving to subdirectory of source');
    });

    test('fails when archiving empty workspace', () async {
      // Remove all files from source directory recursively
      await for (final entity in Directory.current.list()) {
        if (entity is Directory) {
          await entity.delete(recursive: true);
        } else {
          await entity.delete();
        }
      }

      final result = await commandService.run([
        'archive',
        TurboTagType.workspace.argument,
        '--target',
        '${tempDir.path}/archive',
      ]);
      expect(result, equals(ExitCode.software.code));
      log.success('TEST PASSED: fails when archiving empty workspace');
    });
  });
}
