import 'dart:io' show ProcessResult;
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/constants/k_version.dart';
import 'package:ultra_wide_turbo_cli/core/services/logger_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/update_service.dart';

class MockPubUpdater extends Mock implements PubUpdater {}

void main() {
  group('UpdateService', () {
    late UpdateService updateService;
    late Logger log;
    late MockPubUpdater mockPubUpdater;

    setUp(() async {
      await AppSetup.initialise();
      updateService = UpdateService.locate;
      log = LoggerService.locate.log;
      mockPubUpdater = MockPubUpdater();

      // Replace the real PubUpdater with our mock
      updateService.pubUpdater = mockPubUpdater;
    });

    group('checkForUpdates', () {
      test('returns false when on latest version', () async {
        // Mock the latest version to be the same as current
        when(() => mockPubUpdater.getLatestVersion(Environment.packageName))
            .thenAnswer((_) async => packageVersion);

        final result = await updateService.checkForUpdates();
        var wasSuccess = false;
        var updateNeeded = true;

        result.when(
          success: (response) {
            wasSuccess = true;
            updateNeeded = response.result;
          },
          fail: (_) => wasSuccess = false,
        );

        expect(wasSuccess, isTrue, reason: 'Expected successful response');
        expect(updateNeeded, isFalse, reason: 'Expected no update needed');
      });

      test('returns true when update is available', () async {
        // Mock a newer version being available
        when(() => mockPubUpdater.getLatestVersion(Environment.packageName))
            .thenAnswer((_) async => '99.99.99');

        final result = await updateService.checkForUpdates();
        var wasSuccess = false;
        var updateNeeded = false;

        result.when(
          success: (response) {
            wasSuccess = true;
            updateNeeded = response.result;
          },
          fail: (_) => wasSuccess = false,
        );

        expect(wasSuccess, isTrue, reason: 'Expected successful response');
        expect(updateNeeded, isTrue, reason: 'Expected update needed');
      });

      test('handles errors gracefully', () async {
        // Mock an error occurring
        when(() => mockPubUpdater.getLatestVersion(Environment.packageName))
            .thenThrow(Exception('Test error'));

        final result = await updateService.checkForUpdates();
        var wasSuccess = true;

        result.when(
          success: (_) {},
          fail: (_) => wasSuccess = false,
        );

        expect(wasSuccess, isFalse, reason: 'Expected error response');
      });
    });

    group('update', () {
      test('returns success when update completes', () async {
        // Mock successful update
        when(() => mockPubUpdater.update(packageName: Environment.packageName))
            .thenAnswer((_) async => ProcessResult(0, 0, '', ''));

        final result = await updateService.update();
        var wasSuccess = false;

        result.when(
          success: (_) => wasSuccess = true,
          fail: (_) => wasSuccess = false,
        );

        expect(wasSuccess, isTrue, reason: 'Expected successful update');
      });

      test('handles errors gracefully', () async {
        // Mock an error during update
        when(() => mockPubUpdater.update(packageName: Environment.packageName))
            .thenThrow(Exception('Test error'));

        final result = await updateService.update();
        var wasSuccess = true;

        result.when(
          success: (_) {},
          fail: (_) => wasSuccess = false,
        );

        expect(wasSuccess, isFalse, reason: 'Expected error response');
      });
    });
  });
}
