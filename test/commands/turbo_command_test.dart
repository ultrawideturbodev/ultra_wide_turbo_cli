import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:test/test.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/services/command_service.dart';

void main() {
  group('Turbo Commands', () {
    late Directory tempDir;
    late CommandService commandService;

    setUp(() async {
      await AppSetup.initialise();
      commandService = CommandService.locate;
      await commandService.isReady;

      // Create a temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('turbo_test_');
    });

    tearDown(() async {
      // Clean up after each test
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('fix command', () {
      test('runs fix script without clean flag', () async {
        final result = await commandService.run(['fix']);
        expect(result, equals(ExitCode.success.code));
      });

      test('runs fix script with clean flag', () async {
        final result = await commandService.run(['fix', '--clean']);
        expect(result, equals(ExitCode.success.code));
      });
    });

    group('clone workspace command', () {
      late Directory sourceDir;

      setUp(() async {
        // Create a mock source workspace
        sourceDir =
            await Directory('${tempDir.path}/ultra_wide_turbo_workspace').create(recursive: true);

        // Create some test files
        await File('${sourceDir.path}/_test.md').writeAsString('test content');
        await File('${sourceDir.path}/normal.txt').writeAsString('normal content');
        await Directory('${sourceDir.path}/_test_dir').create();

        // Set current directory to temp dir for relative path resolution
        Directory.current = tempDir;
      });

      test('fails without workspace argument', () async {
        final result = await commandService.run(['clone']);
        expect(result, equals(ExitCode.usage.code));
      });

      test('fails with invalid clone type', () async {
        final result = await commandService.run(['clone', 'invalid']);
        expect(result, equals(ExitCode.usage.code));
      });

      test('clones workspace successfully', () async {
        final targetDir = '${tempDir.path}/target';

        final result = await commandService.run([
          'clone',
          'workspace',
          '--target',
          targetDir,
        ]);
        expect(result, equals(ExitCode.success.code));

        // Verify the files were copied correctly
        expect(await File('$targetDir/test.md').exists(), isTrue);
        expect(await File('$targetDir/normal.txt').exists(), isTrue);
        expect(await Directory('$targetDir/test_dir').exists(), isTrue);

        // Verify underscore files were renamed
        expect(await File('$targetDir/_test.md').exists(), isFalse);
        expect(await Directory('$targetDir/_test_dir').exists(), isFalse);

        // Verify file contents
        expect(
          await File('$targetDir/test.md').readAsString(),
          equals('test content'),
        );
        expect(
          await File('$targetDir/normal.txt').readAsString(),
          equals('normal content'),
        );
      });

      test('fails when target exists without force flag', () async {
        final targetDir = '${tempDir.path}/target';
        await Directory(targetDir).create();

        final result = await commandService.run([
          'clone',
          'workspace',
          '--target',
          targetDir,
        ]);
        expect(result, equals(ExitCode.software.code));
      });

      test('overwrites existing directory with force flag', () async {
        final targetDir = '${tempDir.path}/target';
        await Directory(targetDir).create();
        await File('$targetDir/existing.txt').writeAsString('existing');

        final result = await commandService.run([
          'clone',
          'workspace',
          '--target',
          targetDir,
          '--force',
        ]);
        expect(result, equals(ExitCode.success.code));

        // Verify the directory was overwritten
        expect(await File('$targetDir/existing.txt').exists(), isFalse);
        expect(await File('$targetDir/test.md').exists(), isTrue);
        expect(
          await File('$targetDir/test.md').readAsString(),
          equals('test content'),
        );
      });

      test('handles relative paths correctly', () async {
        final result = await commandService.run([
          'clone',
          'workspace',
          '--target',
          './relative_target',
        ]);
        expect(result, equals(ExitCode.success.code));

        final targetDir = '${tempDir.path}/relative_target';
        expect(await File('$targetDir/test.md').exists(), isTrue);
        expect(
          await File('$targetDir/test.md').readAsString(),
          equals('test content'),
        );
      });
    });
  });
}
