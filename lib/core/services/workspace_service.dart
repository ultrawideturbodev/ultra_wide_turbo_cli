import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:turbo_response/turbo_response.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';

class WorkspaceService with TurboLogger {
  WorkspaceService._();

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static WorkspaceService get locate => GetIt.I.get();
  static void registerLazySingleton() => GetIt.I.registerLazySingleton(WorkspaceService._);

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  Future<TurboResponse> cloneWorkspace({
    required String targetDir,
    required bool force,
  }) async {
    try {
      final directory = Directory(targetDir);
      final exists = await directory.exists();

      if (exists && !force) {
        log.err('Directory already exists. Use --force to overwrite.');
        return const TurboResponse.emptyFail();
      }

      if (exists && force) {
        log.info('Removing existing directory...');
        await directory.delete(recursive: true);
      }

      // Create the directory
      await directory.create(recursive: true);

      // Get the source directory (ultra_wide_turbo_workspace)
      final sourceDir = path.join(
        Directory.current.path,
        'ultra_wide_turbo_workspace',
      );

      if (!await Directory(sourceDir).exists()) {
        log.err('Source workspace directory not found at: $sourceDir');
        return const TurboResponse.emptyFail();
      }

      log.info('Copying workspace files...');

      // Copy all files
      await for (final entity in Directory(sourceDir).list()) {
        final basename = path.basename(entity.path);
        final targetBasename = basename.startsWith('_') ? basename.substring(1) : basename;
        final targetPath = path.join(targetDir, targetBasename);

        if (entity is File) {
          await entity.copy(targetPath);
          if (basename.startsWith('_')) {
            log.info('Renamed: $basename -> $targetBasename');
          }
        } else if (entity is Directory) {
          await _copyDirectory(entity.path, targetPath);
        }
      }

      log.success('Workspace cloned successfully to: $targetDir');
      return const TurboResponse.emptySuccess();
    } catch (error) {
      log.err('Failed to clone workspace: $error');
      return TurboResponse.fail(
        error: error,
        message: 'Failed to clone workspace',
      );
    }
  }

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  Future<void> _copyDirectory(String source, String target) async {
    await Directory(target).create(recursive: true);
    await for (final entity in Directory(source).list(recursive: false)) {
      final basename = path.basename(entity.path);
      final targetBasename = basename.startsWith('_') ? basename.substring(1) : basename;
      final targetPath = path.join(target, targetBasename);

      if (entity is Directory) {
        await _copyDirectory(entity.path, targetPath);
      } else if (entity is File) {
        await entity.copy(targetPath);
        if (basename.startsWith('_')) {
          log.info('Renamed: $basename -> $targetBasename');
        }
      }
    }
  }

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
