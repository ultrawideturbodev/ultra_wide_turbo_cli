import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';
import 'package:ultra_wide_turbo_cli/core/globals/log.dart';
import 'package:ultra_wide_turbo_cli/core/typedefs/wrap_defs.dart';
import 'package:yaml/yaml.dart';

/// Service responsible for managing CLI updates.
///
/// Uses [PubUpdater] to check for and apply updates from pub.dev.
/// Implements the singleton pattern with a private constructor.
class UpdateService {
  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static UpdateService get locate => GetIt.I.get();
  static void registerLazySingleton() => GetIt.I.registerLazySingleton(
        UpdateService.new,
        dispose: (service) => service.dispose(),
      );

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  /// Instance of [PubUpdater] used to check for and apply updates.
  PubUpdater _pubUpdater = PubUpdater();

  /// Setter for [PubUpdater] instance, used for testing.
  @visibleForTesting
  set pubUpdater(PubUpdater updater) => _pubUpdater = updater;

  // 🛠 INIT & DISPOSE ------------------------------------------------------------------------ \\

  Future<void> dispose() async {
    _cachedVersion = null;
    _testPubspecPath = null;
  }

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\

  String? _cachedVersion;
  String? _testPubspecPath;

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  /// Sets a test pubspec path for testing purposes.
  @visibleForTesting
  void setTestPubspecPath(String path) {
    _testPubspecPath = path;
  }

  /// Gets the current package version from pubspec.yaml.
  ///
  /// First tries to find pubspec.yaml in the local package directory.
  /// If not found, attempts to find it in the global pub cache.
  /// Returns the version string or throws if version cannot be found.
  Future<String> getCurrentVersion() async {
    if (_cachedVersion != null) return _cachedVersion!;

    File? pubspecFile;
    String? pubspecPath;

    try {
      if (_testPubspecPath != null) {
        pubspecFile = File(_testPubspecPath!);
        pubspecPath = _testPubspecPath;
      } else {
        // Try multiple possible locations for pubspec.yaml
        final possiblePaths = <String>[];

        // 1. Try global pub cache first for global installs
        final home =
            Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
        if (home != null) {
          // Main global package location
          possiblePaths.add(
            path.join(
              home,
              '.pub-cache',
              'global_packages',
              Environment.packageName,
              'pubspec.yaml',
            ),
          );

          // Versioned global package location
          final cacheDir =
              Directory(path.join(home, '.pub-cache', 'hosted', 'pub.dev'));
          if (await cacheDir.exists()) {
            try {
              await for (final entry in cacheDir.list(recursive: true)) {
                if (entry is File &&
                    path.basename(entry.path) == 'pubspec.yaml' &&
                    entry.path.contains(Environment.packageName)) {
                  possiblePaths.add(entry.path);
                }
              }
            } catch (_) {}
          }
        }

        // 2. Try local development directory
        final scriptPath = Platform.script.toFilePath();
        final packageDir = path.dirname(path.dirname(scriptPath));
        possiblePaths.add(path.join(packageDir, 'pubspec.yaml'));

        // 3. Try executable directory's parent
        final executableDir = path.dirname(Platform.resolvedExecutable);
        possiblePaths.add(path.join(executableDir, '..', 'pubspec.yaml'));

        // Try each path until we find the file
        for (final path in possiblePaths) {
          final file = File(path);
          if (await file.exists()) {
            pubspecFile = file;
            pubspecPath = path;
            break;
          }
        }

        if (pubspecFile == null) {
          // If we can't find pubspec.yaml, try to get version from pub.dev
          try {
            final latestVersion =
                await _pubUpdater.getLatestVersion(Environment.packageName);
            _cachedVersion = latestVersion;
            return latestVersion;
          } catch (e) {
            throw Exception(
              'Could not determine version. pubspec.yaml not found in any of these locations:\n'
              '${possiblePaths.map((p) => '- $p').join('\n')}\n'
              'And failed to get version from pub.dev: $e',
            );
          }
        }
      }

      final content = await pubspecFile.readAsString();
      final yaml = loadYaml(content) as Map;
      final version = yaml['version'] as String?;

      if (version == null) {
        throw Exception(
          'Version not found in pubspec.yaml at: $pubspecPath',
        );
      }

      _cachedVersion = version;
      return version;
    } catch (e) {
      log.err('Error reading version: ${e.toString()}');
      rethrow;
    }
  }

  /// Checks if a newer version of the CLI is available on pub.dev.
  ///
  /// Compares the current version with the latest version from pub.dev.
  /// Returns a [TurboResponse] containing a boolean indicating if an update is available.
  /// Returns [TurboResponse.fail] if the version check fails.
  Future<TurboResponse<(ShouldUpdate, VersionNumber)>> checkForUpdates() async {
    try {
      log.detail('Checking for updates...');
      final currentVersion = await getCurrentVersion();
      final latestVersion =
          await _pubUpdater.getLatestVersion(Environment.packageName);

      // Parse versions to compare them properly
      final current = Version.parse(currentVersion);
      final latest = Version.parse(latestVersion);

      // Only update if latest version is higher than current
      final shouldUpdate = latest > current;

      log.detail(
        shouldUpdate
            ? 'Update available: $currentVersion -> $latestVersion'
            : 'Already on latest version: $currentVersion',
      );
      return TurboResponse.success(result: (shouldUpdate, latestVersion));
    } catch (error) {
      log.err('Failed to check for updates: $error');
      return TurboResponse.fail(error: error);
    }
  }

  /// Updates the CLI to the latest version available on pub.dev.
  ///
  /// Shows progress using [Logger] and returns a [TurboResponse] indicating success or failure.
  /// Returns [TurboResponse.successAsBool()] if the update is successful.
  /// Returns [TurboResponse.fail] if the update fails.
  Future<TurboResponse> update() async {
    final updateProgress = log.progress('Updating Ultra Wide Turbo CLI');

    try {
      await _pubUpdater.update(packageName: Environment.packageName);
      updateProgress.complete('Ultra Wide Turbo CLI has been updated!');
      log.detail('Successfully updated to latest version');
      return const TurboResponse.successAsBool();
    } catch (error) {
      log.err('Failed to update Ultra Wide Turbo CLI: $error');
      updateProgress.fail('Failed to update Ultra Wide Turbo CLI');
      return TurboResponse.fail(error: error);
    }
  }

  /// Manually checks for and applies updates.
  ///
  /// Shows the current version and checks for updates.
  /// If an update is available:
  /// - Shows the latest version
  /// - Prompts to update
  /// - Performs the update
  ///
  /// Returns [TurboResponse] indicating success or failure.
  Future<TurboResponse> manualUpdate() async {
    try {
      final currentVersion = await getCurrentVersion();
      log.info('Current version: $currentVersion');

      final latestVersion =
          await _pubUpdater.getLatestVersion(Environment.packageName);

      // Parse versions to compare them properly
      final current = Version.parse(currentVersion);
      final latest = Version.parse(latestVersion);

      // Only update if latest version is higher than current
      if (latest <= current) {
        log.success('Already on latest version!');
        return const TurboResponse.successAsBool();
      }

      log.info('Latest version: $latestVersion');
      log.info('Updating to latest version...');

      final result = await update();

      return result.when(
        success: (_) {
          log.success('Successfully updated to $latestVersion');
          return const TurboResponse.successAsBool();
        },
        fail: (f) {
          log.err('Failed to update: ${f.message}');
          return TurboResponse.fail(error: f.error);
        },
      );
    } catch (error) {
      log.err('Failed to check for updates: $error');
      return TurboResponse.fail(error: error);
    }
  }

  //🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
