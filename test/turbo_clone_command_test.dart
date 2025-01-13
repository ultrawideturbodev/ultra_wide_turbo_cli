import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/enums/environment_type.dart';
import 'package:ultra_wide_turbo_cli/core/globals/log.dart';
import 'package:ultra_wide_turbo_cli/core/services/turbo_command_service.dart';

void main() {
  group('Turbo Clone Command', () {
    late Directory workspace;
    late Directory currentDir;
    late Directory sourceDir1;
    late Directory sourceDir2;
    late File sourceFile1;
    late File sourceFile2;

    setUpAll(() async {
      // Create test workspace
      workspace = await Directory.systemTemp.createTemp('test_workspace');

      // Create current directory where files will be cloned to
      currentDir = Directory('${workspace.path}/current_dir');
      await currentDir.create();

      // Create source directories with test files
      sourceDir1 = Directory('${workspace.path}/source1');
      sourceDir2 = Directory('${workspace.path}/source2');
      await sourceDir1.create();
      await sourceDir2.create();

      // Create test files in source directories
      sourceFile1 = File('${sourceDir1.path}/test1.txt');
      sourceFile2 = File('${sourceDir2.path}/test2.txt');
      await sourceFile1.writeAsString('test content 1');
      await sourceFile2.writeAsString('test content 2');
    });

    setUp(() async {
      Environment.environmentOverride(environmentType: EnvironmentType.test);
      IOOverrides.global = _TestIOOverrides(currentDir);

      await AppSetup.initialise([]);

      // Tag both source directories with test-tag
      when(
        () => log.chooseOne<String>(
          any(),
          choices: any(named: 'choices'),
          display: any(named: 'display'),
        ),
      ).thenReturn('test-tag');

      // Tag first source directory
      IOOverrides.global = _TestIOOverrides(sourceDir1);
      await TurboCommandService.locate.run(['tag', 'source']);

      // Tag second source directory
      IOOverrides.global = _TestIOOverrides(sourceDir2);
      await TurboCommandService.locate.run(['tag', 'source']);

      // Reset to current directory for test
      IOOverrides.global = _TestIOOverrides(currentDir);
    });

    tearDown(() async {
      await AppSetup.reset([]);
      IOOverrides.global = null;
    });

    tearDownAll(() async {
      await workspace.delete(recursive: true);
    });

    test('Successfully clones files from all tagged folders', () async {
      // Act
      final result =
          await TurboCommandService.locate.run(['clone', 'test-tag']);

      // Assert
      expect(result, ExitCode.success.code);

      // Verify files were cloned
      final clonedFile1 = File('${currentDir.path}/test1.txt');
      final clonedFile2 = File('${currentDir.path}/test2.txt');

      expect(await clonedFile1.exists(), isTrue);
      expect(await clonedFile2.exists(), isTrue);

      expect(await clonedFile1.readAsString(), equals('test content 1'));
      expect(await clonedFile2.readAsString(), equals('test content 2'));
    });

    test('Successfully overrides existing files by default', () async {
      // Arrange - Create existing files with different content
      final existingFile1 = File('${currentDir.path}/test1.txt');
      final existingFile2 = File('${currentDir.path}/test2.txt');
      await existingFile1.writeAsString('old content 1');
      await existingFile2.writeAsString('old content 2');

      // Act
      final result = await TurboCommandService.locate
          .run(['clone', 'test-tag', '--force']);

      // Assert
      expect(result, ExitCode.success.code);

      // Verify files were overridden
      final clonedFile1 = File('${currentDir.path}/test1.txt');
      final clonedFile2 = File('${currentDir.path}/test2.txt');

      expect(await clonedFile1.readAsString(), equals('test content 1'));
      expect(await clonedFile2.readAsString(), equals('test content 2'));
    });
  });
}

class _TestIOOverrides extends IOOverrides {
  _TestIOOverrides(this.directory);

  final Directory directory;

  @override
  Directory getCurrentDirectory() => directory;
}
