import 'package:meta/meta.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';
import 'package:ultra_wide_turbo_cli/core/constants/k_version.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';

/// Service responsible for managing CLI updates.
///
/// Uses [PubUpdater] to check for and apply updates from pub.dev.
/// Implements the singleton pattern with a private constructor.
class UpdateService with TurboLogger {
  UpdateService._();
  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  /// Singleton instance of [UpdateService].
  static final UpdateService _instance = UpdateService._();

  /// Access the singleton instance of [UpdateService].
  static UpdateService get locate => _instance;

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  /// Instance of [PubUpdater] used to check for and apply updates.
  PubUpdater _pubUpdater = PubUpdater();

  /// Setter for [PubUpdater] instance, used for testing.
  @visibleForTesting
  set pubUpdater(PubUpdater updater) => _pubUpdater = updater;

  // 🛠 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  /// Checks if a newer version of the CLI is available on pub.dev.
  ///
  /// Compares the current [packageVersion] with the latest version from pub.dev.
  /// Returns a [TurboResponse] containing a boolean indicating if an update is available.
  /// Returns [TurboResponse.fail] if the version check fails.
  Future<TurboResponse<bool>> checkForUpdates() async {
    try {
      log.detail('Checking for updates...');
      final latestVersion =
          await _pubUpdater.getLatestVersion(Environment.packageName);
      final shouldUpdate = latestVersion != packageVersion;
      log.detail(
        shouldUpdate
            ? 'Update available: $packageVersion -> $latestVersion'
            : 'Already on latest version: $packageVersion',
      );
      return TurboResponse<bool>.success(result: shouldUpdate);
    } catch (error) {
      log.err('Failed to check for updates: $error');
      return TurboResponse.fail(error: error);
    }
  }

  /// Updates the CLI to the latest version available on pub.dev.
  ///
  /// Shows progress using [Logger] and returns a [TurboResponse] indicating success or failure.
  /// Returns [TurboResponse.emptySuccess] if the update is successful.
  /// Returns [TurboResponse.fail] if the update fails.
  Future<TurboResponse> update() async {
    final updateProgress = log.progress('Updating Ultra Wide Turbo CLI');

    try {
      await _pubUpdater.update(packageName: Environment.packageName);
      updateProgress.complete('Ultra Wide Turbo CLI has been updated!');
      log.detail('Successfully updated to latest version');
      return const TurboResponse.emptySuccess();
    } catch (error) {
      log.err('Failed to update Ultra Wide Turbo CLI: $error');
      updateProgress.fail('Failed to update Ultra Wide Turbo CLI');
      return TurboResponse.fail(error: error);
    }
  }

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
