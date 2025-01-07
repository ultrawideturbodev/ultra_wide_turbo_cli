import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
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

  Future<bool> archiveWorkspace({
    required String targetDir,
    required bool force,
  }) async {
    try {
      final directory = Directory(targetDir);
      final exists = await directory.exists();

      if (exists && !force) {
        log.err('Directory already exists. Use --force to overwrite.');
        return false;
      }

      if (exists && force) {
        log.info('Removing existing directory...');
        await directory.delete(recursive: true);
      }

      // Create the archive directory
      await directory.create(recursive: true);

      // Get the parent directory (source)
      final sourceDir = Directory.current.parent;

      if (!await sourceDir.exists()) {
        log.err('Source directory not found at: ${sourceDir.path}');
        return false;
      }

      log.info('Archiving workspace files...');

      // Copy all files
      await for (final entity in sourceDir.list()) {
        final basename = path.basename(entity.path);
        final targetPath = path.join(targetDir, basename);

        if (entity is File) {
          await entity.copy(targetPath);
        } else if (entity is Directory) {
          await _copyDirectory(entity.path, targetPath);
        }
      }

      log.success('Workspace archived successfully to: $targetDir');
      return true;
    } catch (error) {
      log.err('Failed to archive workspace: $error');
      return false;
    }
  }

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  Future<void> _copyDirectory(String source, String target) async {
    await Directory(target).create(recursive: true);
    await for (final entity in Directory(source).list(recursive: false)) {
      final targetPath = path.join(target, path.basename(entity.path));

      if (entity is Directory) {
        await _copyDirectory(entity.path, targetPath);
      } else if (entity is File) {
        await entity.copy(targetPath);
      }
    }
  }

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
