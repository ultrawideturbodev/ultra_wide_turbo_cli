import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:turbo_response/turbo_response.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';

/// Manages Ultra Wide Turbo workspace operations.
///
/// Handles workspace cloning and file management with features like:
/// - Automatic file renaming (removing leading underscores)
/// - Directory existence checks
/// - Recursive file copying
/// - Progress feedback
///
/// ```dart
/// // Clone to a new directory
/// final result = await workspaceService.cloneWorkspace(
///   targetDir: 'my/new/workspace',
///   force: false,
/// );
///
/// // Force clone to existing directory
/// final result = await workspaceService.cloneWorkspace(
///   targetDir: 'existing/workspace',
///   force: true,
/// );
/// ```
class WorkspaceService with TurboLogger {
  WorkspaceService._();

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static WorkspaceService get locate => GetIt.I.get();
  static void registerLazySingleton() =>
      GetIt.I.registerLazySingleton(WorkspaceService._);

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  /// Clones the Ultra Wide Turbo workspace template to a target directory.
  ///
  /// Creates a new workspace at [targetDir] by copying the template files.
  /// If [force] is true, overwrites the target directory if it exists.
  ///
  /// Returns a [TurboResponse] indicating success or failure.
  /// Fails if:
  /// - Target directory exists and [force] is false
  /// - Template workspace directory not found
  /// - Any IO operation fails
  ///
  /// ```dart
  /// // Clone workspace
  /// final result = await cloneWorkspace(
  ///   targetDir: 'projects/my_workspace',
  ///   force: false,
  /// );
  /// if (result.isSuccess) {
  ///   print('Workspace cloned successfully');
  /// }
  /// ```
  Future<TurboResponse> cloneWorkspace({
    required String targetDir,
    required bool force,
  }) async {
    try {
      final directory = Directory(targetDir);
      final exists = await directory.exists();

      // Get the source directory (ultra_wide_turbo_workspace)
      final sourceDir = path.join(
        Platform.script.toFilePath(),
        '../ultra_wide_turbo_workspace',
      );

      if (!await Directory(sourceDir).exists()) {
        log.err('Source workspace directory not found at: $sourceDir');
        return const TurboResponse.failAsBool();
      }

      // Check for existing files before proceeding
      if (exists) {
        final hasConflicts = await _checkForConflicts(sourceDir, targetDir);
        if (hasConflicts && !force) {
          log.err(
              'Target directory contains existing files. Use --force to overwrite.');
          return const TurboResponse.failAsBool();
        }
      } else {
        await directory.create(recursive: true);
      }

      log.info('Copying workspace files...');

      // Copy all files and directories
      await _copyDirectory(sourceDir, targetDir);

      log.success('Workspace cloned successfully to: $targetDir');
      return const TurboResponse.successAsBool();
    } catch (error) {
      log.err('Failed to clone workspace: $error');
      return TurboResponse.fail(
        error: error,
        message: 'Failed to clone workspace',
      );
    }
  }

  /// Checks if there are any file conflicts in the target directory.
  Future<bool> _checkForConflicts(String sourceDir, String targetDir) async {
    try {
      await for (final entity in Directory(sourceDir).list(recursive: true)) {
        if (entity is! File) continue;

        final relativePath = path.relative(entity.path, from: sourceDir);
        final targetPath = path.join(targetDir, relativePath);

        if (await File(targetPath).exists()) {
          return true;
        }
      }
      return false;
    } catch (e) {
      // If we can't check, assume there are conflicts to be safe
      return true;
    }
  }

  /// Copies a directory and its contents recursively.
  Future<void> _copyDirectory(String source, String target) async {
    final targetDir = Directory(target);
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    await for (final entity in Directory(source).list(recursive: true)) {
      if (entity is! File) continue;

      final relativePath = path.relative(entity.path, from: source);
      final targetPath = path.join(target, relativePath);

      final targetFile = File(targetPath);
      if (!await targetFile.parent.exists()) {
        await targetFile.parent.create(recursive: true);
      }
      await entity.copy(targetPath);
    }
  }

  // 🪄 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
