import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:test/test.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_command_type.dart';
import 'package:ultra_wide_turbo_cli/core/services/command_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/logger_service.dart';

void main() {
  group('Dart Fix Command', () {
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

    test('finds project root from subdirectory', () async {
      // Create project structure
      await Directory('${tempDir.path}/lib').create(recursive: true);
      await Directory('${tempDir.path}/test').create(recursive: true);
      await File('${tempDir.path}/pubspec.yaml').writeAsString('''
name: test_project
description: A test project
version: 1.0.0
environment:
  sdk: '>=3.0.0 <4.0.0'
''');

      // Create a deep subdirectory
      final deepDir = Directory('${tempDir.path}/lib/src/deep/nested');
      await deepDir.create(recursive: true);

      // Create test file in deep directory
      await File('${deepDir.path}/test.dart').writeAsString('''void main(){
  var x=  1;
      print(x)   ;
}''');

      // Change to deep directory
      Directory.current = deepDir;

      // Run fix command
      final result = await commandService.run([TurboCommandType.dartFix.argument]);

      // Should succeed
      expect(result, equals(ExitCode.success.code));

      // Verify we're back in the deep directory
      expect(
        Directory.current.path,
        equals(Directory(deepDir.path).resolveSymbolicLinksSync()),
      );

      // Verify file was formatted
      final formattedContent = await File('${deepDir.path}/test.dart').readAsString();
      expect(
        formattedContent,
        equals('''void main() {
  var x = 1;
  print(x);
}
'''),
      );
      log.success('TEST PASSED: finds project root from subdirectory');
    });

    test('fails when no pubspec.yaml found', () async {
      // Create a directory without pubspec.yaml
      final testDir = Directory('${tempDir.path}/test_dir');
      await testDir.create();
      await File('${testDir.path}/test.dart').writeAsString('''void main(){
  var x=  1;
      print(x)   ;
}''');

      // Change to test directory
      Directory.current = testDir;

      // Run fix command
      final result = await commandService.run([TurboCommandType.dartFix.argument]);

      // Should fail
      expect(result, equals(ExitCode.software.code));

      // Verify error message
      // Note: error message is logged by the command

      // Verify we're still in the test directory
      expect(
        Directory.current.path,
        equals(Directory(testDir.path).resolveSymbolicLinksSync()),
      );

      log.success('TEST PASSED: fails when no pubspec.yaml found');
    });

    test('fails when pubspec.yaml found but no lib or test directories', () async {
      // Create project with pubspec.yaml but no lib/test dirs
      await File('${tempDir.path}/pubspec.yaml').writeAsString('''
name: test_project
description: A test project
version: 1.0.0
environment:
  sdk: '>=3.0.0 <4.0.0'
''');

      // Change to temp directory
      Directory.current = tempDir;

      // Run fix command
      final result = await commandService.run([TurboCommandType.dartFix.argument]);

      // Should fail
      expect(result, equals(ExitCode.software.code));

      // Verify error message
      // Note: error message is logged by the command

      // Verify we're still in the temp directory
      expect(
        Directory.current.path,
        equals(Directory(tempDir.path).resolveSymbolicLinksSync()),
      );

      log.success('TEST PASSED: fails when pubspec.yaml found but no lib or test directories');
    });
  });
}
