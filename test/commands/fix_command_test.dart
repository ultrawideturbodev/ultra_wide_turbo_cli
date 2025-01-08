import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_command_type.dart';
import 'package:ultra_wide_turbo_cli/core/services/command_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/logger_service.dart';

void main() {
  group('Fix Command', () {
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

      // Create symbolic link for dart-fix
      final dartPath = Platform.resolvedExecutable;
      final dartDir = path.dirname(dartPath);
      await Process.run('ln', ['-s', path.join(dartDir, 'dart'), path.join(dartDir, 'dart-fix')]);

      // Create pubspec.yaml for a valid Dart project
      await File('${tempDir.path}/pubspec.yaml').writeAsString('''
name: test_project
description: A test project
version: 1.0.0
environment:
  sdk: '>=3.0.0 <4.0.0'
dependencies:
  build_runner: ^2.4.0
  dart_style: ^2.3.0
dev_dependencies:
  test: ^1.24.0
''');

      // Run pub get in test directory
      await Process.run('dart', ['pub', 'get'], workingDirectory: tempDir.path);

      // Create test Dart files with unformatted code
      await Directory('${tempDir.path}/lib').create(recursive: true);
      await Directory('${tempDir.path}/test').create(recursive: true);
      await File('${tempDir.path}/lib/test.dart').writeAsString('''void main(){
  var x=  1;
      print(x)   ;
}''');
      await File('${tempDir.path}/test/test.dart').writeAsString('''void main(){
  var y=  2;
      print(y)   ;
}''');

      // Set current directory to temp dir for relative path resolution
      Directory.current = tempDir;
    });

    tearDown(() async {
      try {
        // Restore original directory
        Directory.current = originalDir;

        // Remove dart-fix symbolic link
        final dartPath = Platform.resolvedExecutable;
        final dartDir = path.dirname(dartPath);
        await Process.run('rm', [path.join(dartDir, 'dart-fix')]);

        // Clean up temp directory
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (e) {
        // Ignore errors during cleanup
      }
    });

    test('formats Dart files when running fix command', () async {
      // Given: Unformatted Dart files
      final libFile = File('${tempDir.path}/lib/test.dart');
      final testFile = File('${tempDir.path}/test/test.dart');
      final initialLibContent = await libFile.readAsString();
      final initialTestContent = await testFile.readAsString();

      // When: Running fix command
      final result = await commandService.run([TurboCommandType.dartFix.argument]);

      // Then: Command should succeed
      expect(result, equals(ExitCode.success.code));

      // And: Files should be formatted
      final formattedLibContent = await libFile.readAsString();
      final formattedTestContent = await testFile.readAsString();
      expect(formattedLibContent, isNot(equals(initialLibContent)));
      expect(formattedTestContent, isNot(equals(initialTestContent)));
      expect(
        formattedLibContent,
        equals('''void main() {
  var x = 1;
  print(x);
}
'''),
      );
      expect(
        formattedTestContent,
        equals('''void main() {
  var y = 2;
  print(y);
}
'''),
      );
      log.success('TEST PASSED: formats Dart files when running fix command');
    });

    test('formats Dart files when running fix command with clean flag', () async {
      // Given: Unformatted Dart files and a pubspec.yaml
      final libFile = File('${tempDir.path}/lib/test.dart');
      final testFile = File('${tempDir.path}/test/test.dart');
      final pubspecFile = File('${tempDir.path}/pubspec.yaml');

      await pubspecFile.writeAsString('''
name: test_project
description: A test project
version: 1.0.0
environment:
  sdk: '>=3.0.0 <4.0.0'
dependencies:
  build_runner: ^2.4.0
  dart_style: ^2.3.0
dev_dependencies:
  test: ^1.24.0
''');

      final initialLibContent = await libFile.readAsString();
      final initialTestContent = await testFile.readAsString();

      // When: Running fix command with clean flag
      final result = await commandService.run([TurboCommandType.dartFix.argument, '--clean']);

      // Then: Command should succeed
      expect(result, equals(ExitCode.success.code));

      // And: Files should be formatted
      final formattedLibContent = await libFile.readAsString();
      final formattedTestContent = await testFile.readAsString();
      expect(formattedLibContent, isNot(equals(initialLibContent)));
      expect(formattedTestContent, isNot(equals(initialTestContent)));

      log.success('TEST PASSED: formats Dart files when running fix command with clean flag');
    });

    test('fails with invalid directory structure', () async {
      // Given: Invalid directory structure (no lib or test directory)
      await Directory('${tempDir.path}/lib').delete(recursive: true);
      await Directory('${tempDir.path}/test').delete(recursive: true);

      // When: Running fix command
      final result = await commandService.run([TurboCommandType.dartFix.argument]);

      // Then: Command should fail
      expect(result, equals(ExitCode.software.code));
      log.success('TEST PASSED: fails with invalid directory structure');
    });

    test('fails with malformed Dart files', () async {
      // Given: Malformed Dart file
      await File('${tempDir.path}/lib/test.dart').writeAsString('''
void main() {
  // Missing closing brace
  if (true) {
    print('test');
''');

      // When: Running fix command
      final result = await commandService.run([TurboCommandType.dartFix.argument]);

      // Then: Command should fail
      expect(result, equals(ExitCode.software.code));
      log.success('TEST PASSED: fails with malformed Dart files');
    });
  });
}
