import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:turbo_response/turbo_response.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';

class ArchiveService with TurboLogger {
  ArchiveService._();

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static ArchiveService get locate => GetIt.I.get();
  static void registerLazySingleton() => GetIt.I.registerLazySingleton(ArchiveService._);

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  Future<TurboResponse> archiveWorkspace({
    required String targetDir,
    required bool force,
  }) async {
    try {
      final directory = Directory(targetDir);
      final sourceDir = Directory.current;
      final exists = await directory.exists();

      if (exists && !force) {
        log.err('Directory already exists. Use --force to overwrite.');
        return const TurboResponse.emptyFail();
      }

      if (exists && force) {
        log.info('Removing existing directory...');
        await directory.delete(recursive: true);
      }

      // Create the archive directory
      await directory.create(recursive: true);

      if (!await sourceDir.exists()) {
        log.err('Source directory not found at: ${sourceDir.path}');
        return const TurboResponse.emptyFail();
      }

      log.info('Archiving workspace files...');

      // Copy all files
      await for (final entity in sourceDir.list()) {
        final basename = path.basename(entity.path);
        final targetPath = path.join(directory.absolute.path, basename);

        // Fail if target is a subdirectory of source or vice versa
        if (path.equals(entity.path, directory.absolute.path) ||
            path.isWithin(directory.absolute.path, entity.path) ||
            path.isWithin(entity.path, directory.absolute.path)) {
          log.err('Cannot archive to a subdirectory of the source directory.');
          return const TurboResponse.emptyFail();
        }

        if (entity is File) {
          await entity.copy(targetPath);
        } else if (entity is Directory) {
          await _copyDirectory(entity.path, targetPath);
        }
      }

      // Verify files were copied
      final targetFiles = await directory.list().toList();
      if (targetFiles.isEmpty) {
        log.err('No files were copied to the target directory.');
        return const TurboResponse.emptyFail();
      }

      log.success('Workspace archived successfully to: $targetDir');
      return const TurboResponse.emptySuccess();
    } catch (error) {
      log.err('Failed to archive workspace: $error');
      return TurboResponse.fail(
        error: error,
        message: 'Failed to archive workspace',
      );
    }
  }

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  Future<void> _copyDirectory(String source, String target) async {
    final sourceDir = Directory(source);
    final targetDir = Directory(target);

    // Skip if target is a subdirectory of source or vice versa
    if (path.equals(sourceDir.path, targetDir.absolute.path) ||
        path.isWithin(targetDir.absolute.path, sourceDir.path) ||
        path.isWithin(sourceDir.path, targetDir.absolute.path)) {
      return;
    }

    await targetDir.create(recursive: true);
    await for (final entity in sourceDir.list(recursive: false)) {
      final targetPath = path.join(targetDir.absolute.path, path.basename(entity.path));

      if (entity is Directory) {
        await _copyDirectory(entity.path, targetPath);
      } else if (entity is File) {
        await entity.copy(targetPath);
      }
    }
  }

// 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
