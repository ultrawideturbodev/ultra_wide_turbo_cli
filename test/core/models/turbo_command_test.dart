import 'package:mason_logger/mason_logger.dart';
import 'package:test/test.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
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
}
