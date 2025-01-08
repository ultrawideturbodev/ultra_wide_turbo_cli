import 'dart:io' show ProcessResult;

import 'package:mocktail/mocktail.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/constants/k_version.dart';
import 'package:ultra_wide_turbo_cli/core/services/update_service.dart';
import 'package:get_it/get_it.dart';

class MockPubUpdater extends Mock implements PubUpdater {}

void main() {
  late UpdateService service;
  late MockPubUpdater mockPubUpdater;

  setUp(() async {
    // Initialize app
    await AppSetup.initialise();

    mockPubUpdater = MockPubUpdater();
    service = UpdateService.locate;
    service.pubUpdater = mockPubUpdater;
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('manualUpdate', () {
    test('returns success when already on latest version', () async {
      // Arrange
      when(
        () => mockPubUpdater.getLatestVersion(Environment.packageName),
      ).thenAnswer((_) async => packageVersion);

      // Act
      final result = await service.manualUpdate();

      // Assert
      expect(result.when(success: (_) => true, fail: (_) => false), true);
      verify(() => mockPubUpdater.getLatestVersion(Environment.packageName)).called(1);
      verifyNever(() => mockPubUpdater.update(packageName: Environment.packageName));
    });

    test('updates successfully when newer version available', () async {
      // Arrange
      const newVersion = '999.999.999';
      when(
        () => mockPubUpdater.getLatestVersion(Environment.packageName),
      ).thenAnswer((_) async => newVersion);
      when(
        () => mockPubUpdater.update(packageName: Environment.packageName),
      ).thenAnswer((_) async => ProcessResult(0, 0, '', ''));

      // Act
      final result = await service.manualUpdate();

      // Assert
      expect(result.when(success: (_) => true, fail: (_) => false), true);
      verify(() => mockPubUpdater.getLatestVersion(Environment.packageName)).called(1);
      verify(() => mockPubUpdater.update(packageName: Environment.packageName)).called(1);
    });

    test('returns failure when update fails', () async {
      // Arrange
      const newVersion = '999.999.999';
      when(
        () => mockPubUpdater.getLatestVersion(Environment.packageName),
      ).thenAnswer((_) async => newVersion);
      when(
        () => mockPubUpdater.update(packageName: Environment.packageName),
      ).thenThrow(Exception('Update failed'));

      // Act
      final result = await service.manualUpdate();

      // Assert
      expect(result.when(success: (_) => true, fail: (_) => false), false);
      verify(() => mockPubUpdater.getLatestVersion(Environment.packageName)).called(1);
      verify(() => mockPubUpdater.update(packageName: Environment.packageName)).called(1);
    });

    test('returns failure when version check fails', () async {
      // Arrange
      when(
        () => mockPubUpdater.getLatestVersion(Environment.packageName),
      ).thenThrow(Exception('Version check failed'));

      // Act
      final result = await service.manualUpdate();

      // Assert
      expect(result.when(success: (_) => true, fail: (_) => false), false);
      verify(() => mockPubUpdater.getLatestVersion(Environment.packageName)).called(1);
      verifyNever(() => mockPubUpdater.update(packageName: Environment.packageName));
    });
  });
}
