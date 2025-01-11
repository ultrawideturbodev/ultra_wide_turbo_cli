import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/services/update_service.dart';

class MockPubUpdater extends Mock implements PubUpdater {}

void main() {
  late UpdateService service;
  late MockPubUpdater mockPubUpdater;
  const testVersion = '0.1.0';

  setUp(() async {
    // Initialize app
    await AppSetup.initialise();

    mockPubUpdater = MockPubUpdater();
    service = UpdateService.locate;
    service.pubUpdater = mockPubUpdater;

    // Register the mock method
    registerFallbackValue(Environment.packageName);

    // Create a mock pubspec.yaml file with test version
    final pubspecFile = File('pubspec.yaml');
    if (!await pubspecFile.exists()) {
      await pubspecFile.writeAsString('''
name: ultra_wide_turbo_cli
version: $testVersion
''');
    }
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('checkForUpdates', () {
    test('returns false when on latest version', () async {
      // Arrange
      when(() => mockPubUpdater.getLatestVersion(any()))
          .thenAnswer((_) async => testVersion);

      // Act
      final result = await service.checkForUpdates();

      // Assert
      expect(result.when(success: (r) => r.result, fail: (_) => false), false);
      verify(() => mockPubUpdater.getLatestVersion(Environment.packageName))
          .called(1);
    });

    test('returns true when newer version available', () async {
      // Arrange
      const newVersion = '0.2.0';
      when(() => mockPubUpdater.getLatestVersion(any()))
          .thenAnswer((_) async => newVersion);

      // Act
      final result = await service.checkForUpdates();

      // Assert
      expect(result.when(success: (r) => r.result, fail: (_) => false), true);
      verify(() => mockPubUpdater.getLatestVersion(Environment.packageName))
          .called(1);
    });

    test('returns false when older version available', () async {
      // Arrange
      const olderVersion = '0.0.9';
      when(() => mockPubUpdater.getLatestVersion(any()))
          .thenAnswer((_) async => olderVersion);

      // Act
      final result = await service.checkForUpdates();

      // Assert
      expect(result.when(success: (r) => r.result, fail: (_) => false), false);
      verify(() => mockPubUpdater.getLatestVersion(Environment.packageName))
          .called(1);
    });
  });

  group('manualUpdate', () {
    test('returns success when already on latest version', () async {
      // Arrange
      when(() => mockPubUpdater.getLatestVersion(any()))
          .thenAnswer((_) async => testVersion);

      // Act
      final result = await service.manualUpdate();

      // Assert
      expect(result.when(success: (_) => true, fail: (_) => false), true);
      verify(() => mockPubUpdater.getLatestVersion(Environment.packageName))
          .called(1);
      verifyNever(
          () => mockPubUpdater.update(packageName: any(named: 'packageName')));
    });

    test('updates successfully when newer version available', () async {
      // Arrange
      const newVersion = '999.999.999';
      when(() => mockPubUpdater.getLatestVersion(any()))
          .thenAnswer((_) async => newVersion);
      when(() => mockPubUpdater.update(packageName: any(named: 'packageName')))
          .thenAnswer((_) async => ProcessResult(0, 0, '', ''));

      // Act
      final result = await service.manualUpdate();

      // Assert
      expect(result.when(success: (_) => true, fail: (_) => false), true);
      verify(() => mockPubUpdater.getLatestVersion(Environment.packageName))
          .called(1);
      verify(() => mockPubUpdater.update(packageName: Environment.packageName))
          .called(1);
    });

    test('returns failure when update fails', () async {
      // Arrange
      const newVersion = '999.999.999';
      when(() => mockPubUpdater.getLatestVersion(any()))
          .thenAnswer((_) async => newVersion);
      when(() => mockPubUpdater.update(packageName: any(named: 'packageName')))
          .thenThrow(Exception('Update failed'));

      // Act
      final result = await service.manualUpdate();

      // Assert
      expect(result.when(success: (_) => true, fail: (_) => false), false);
      verify(() => mockPubUpdater.getLatestVersion(Environment.packageName))
          .called(1);
      verify(() => mockPubUpdater.update(packageName: Environment.packageName))
          .called(1);
    });

    test('returns failure when version check fails', () async {
      // Arrange
      when(() => mockPubUpdater.getLatestVersion(any()))
          .thenThrow(Exception('Version check failed'));

      // Act
      final result = await service.manualUpdate();

      // Assert
      expect(result.when(success: (_) => true, fail: (_) => false), false);
      verify(() => mockPubUpdater.getLatestVersion(Environment.packageName))
          .called(1);
      verifyNever(
          () => mockPubUpdater.update(packageName: any(named: 'packageName')));
    });
  });
}
