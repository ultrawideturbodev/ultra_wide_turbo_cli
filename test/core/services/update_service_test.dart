import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/services/update_service.dart';

class MockPubUpdater extends Mock implements PubUpdater {}

void main() {
  late UpdateService service;
  late MockPubUpdater mockPubUpdater;
  late Directory tempDir;
  late String pubspecPath;

  setUpAll(() async {
    await AppSetup.initialise([]);
  });

  setUp(() async {
    mockPubUpdater = MockPubUpdater();
    service = UpdateService.locate;
    service.pubUpdater = mockPubUpdater;

    // Create a temporary directory for test files
    tempDir = await Directory.systemTemp.createTemp();

    // Create a pubspec.yaml file in the temp directory
    pubspecPath = path.join(tempDir.path, 'pubspec.yaml');
    final pubspecFile = File(pubspecPath);
    await pubspecFile.writeAsString('''
name: ultra_wide_turbo_cli
version: 1.0.0
''');

    // Set the test pubspec path
    service.setTestPubspecPath(pubspecPath);
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('checkForUpdates returns false when on latest version', () async {
    when(() => mockPubUpdater.getLatestVersion(Environment.packageName))
        .thenAnswer((_) async => '1.0.0');

    final result = await service.checkForUpdates();
    expect(result.result, false);
    verify(() => mockPubUpdater.getLatestVersion(Environment.packageName)).called(1);
  });

  test('checkForUpdates returns true when newer version available', () async {
    when(() => mockPubUpdater.getLatestVersion(Environment.packageName))
        .thenAnswer((_) async => '2.0.0');

    final result = await service.checkForUpdates();
    expect(result.result, true);
    verify(() => mockPubUpdater.getLatestVersion(Environment.packageName)).called(1);
  });

  test('checkForUpdates returns false when older version available', () async {
    when(() => mockPubUpdater.getLatestVersion(Environment.packageName))
        .thenAnswer((_) async => '0.5.0');

    final result = await service.checkForUpdates();
    expect(result.result, false);
    verify(() => mockPubUpdater.getLatestVersion(Environment.packageName)).called(1);
  });

  test('manualUpdate returns success when already on latest version', () async {
    when(() => mockPubUpdater.getLatestVersion(Environment.packageName))
        .thenAnswer((_) async => '1.0.0');

    final result = await service.manualUpdate();
    expect(result.when(success: (_) => true, fail: (_) => false), true);
  });

  test('manualUpdate updates successfully when newer version available', () async {
    when(() => mockPubUpdater.getLatestVersion(Environment.packageName))
        .thenAnswer((_) async => '2.0.0');
    when(() => mockPubUpdater.update(packageName: Environment.packageName))
        .thenAnswer((_) async => ProcessResult(0, 0, '', ''));

    final result = await service.manualUpdate();
    expect(result.when(success: (_) => true, fail: (_) => false), true);
    verify(() => mockPubUpdater.update(packageName: Environment.packageName)).called(1);
  });

  test('manualUpdate returns failure when update fails', () async {
    when(() => mockPubUpdater.getLatestVersion(Environment.packageName))
        .thenAnswer((_) async => '2.0.0');
    when(() => mockPubUpdater.update(packageName: Environment.packageName))
        .thenThrow(Exception('Update failed'));

    final result = await service.manualUpdate();
    expect(result.when(success: (_) => true, fail: (_) => false), false);
  });

  test('manualUpdate returns failure when version check fails', () async {
    when(() => mockPubUpdater.getLatestVersion(Environment.packageName))
        .thenThrow(Exception('Version check failed'));

    final result = await service.manualUpdate();
    expect(result.when(success: (_) => true, fail: (_) => false), false);
  });
}
