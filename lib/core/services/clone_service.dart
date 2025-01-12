import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:get_it/get_it.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart';
import 'package:ultra_wide_turbo_cli/core/extensions/string_extension.dart';
import 'package:ultra_wide_turbo_cli/core/globals/log.dart';
import 'package:ultra_wide_turbo_cli/core/services/relation_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/source_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/tag_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/target_service.dart';

class CloneService {
  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static CloneService get locate => GetIt.I.get();
  static void registerLazySingleton() => GetIt.I.registerLazySingleton(CloneService.new);

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  late final _tagService = TagService.locate;
  late final _relationService = RelationService.locate;

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  Future get isReady => Future.wait(
        [
          TargetService.locate.isReady,
          SourceService.locate.isReady,
          TagService.locate.isReady,
        ],
      );

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  Future<int> onClone({required ArgResults? argResults}) async {
    // Validate tag parameter
    if (argResults?.rest.isEmpty ?? true) {
      log.err('❌ Tag name is required');
      log.info('');
      log.info('Usage: turbo clone <tag>');
      log.info('Example: turbo clone my-project');
      return ExitCode.usage.code;
    }

    final tagId = argResults!.rest.first.normalize();

    // Validate tag name format
    if (!tagId.isValidTagName) {
      log.err('❌ Invalid tag name format');
      log.info('');
      log.info('Tag name requirements:');
      log.info('- Must be between 2 and 50 characters');
      log.info('- Can only contain letters, numbers, hyphens, and underscores');
      log.info('- Cannot start or end with a hyphen or underscore');
      log.info('');
      log.info('Example: my-project-123');
      return ExitCode.usage.code;
    }

    log.info('🔍 Looking up tag: $tagId');

    // Check if tag exists
    final existingTag = _tagService.exists(name: tagId);
    if (!existingTag) {
      log.err('❌ Tag not found: $tagId');
      return ExitCode.software.code;
    }

    log.info('✅ Found tag: $tagId');

    // Find all source relations for the tag
    final sourceRelations = _relationService.listSourcesByTagId(tagId);

    if (sourceRelations.isEmpty) {
      log.err('❌ No sources found for tag: $tagId');
      return ExitCode.software.code;
    }

    log.info('✅ Found ${sourceRelations.length} source(s)');

    // Get current directory
    final currentDir = Directory.current;
    if (!currentDir.existsSync()) {
      log.err('❌ Current directory is not accessible');
      log.info('Please ensure you have write permissions for this directory');
      return ExitCode.software.code;
    }

    // Track copy results
    int totalFiles = 0;
    int successCount = 0;
    int skipCount = 0;
    int errorCount = 0;
    final errors = <String>[];

    // Copy files from each source
    for (final relation in sourceRelations) {
      final sourceId = relation.sourceId;
      final sourceDir = Directory(sourceId);

      if (!sourceDir.existsSync()) {
        log.err('❌ Source directory not found: $sourceId');
        errorCount++;
        errors.add('Source directory not found: $sourceId');
        continue;
      }

      log.info('📂 Copying files from: $sourceId');

      try {
        // List all files in source directory
        final files = sourceDir.listSync(recursive: true);
        totalFiles += files.length;

        for (final file in files) {
          if (file is File) {
            final relativePath = relative(file.path, from: sourceDir.path);
            final targetPath = join(currentDir.path, relativePath);
            final targetFile = File(targetPath);

            // Create parent directories if they don't exist
            await targetFile.parent.create(recursive: true);

            if (targetFile.existsSync() && !(argResults['force'] as bool)) {
              log.info('⚠️ Skipping existing file: $relativePath');
              skipCount++;
              continue;
            }

            await file.copy(targetPath);
            successCount++;
            log.info('✅ Copied: $relativePath');
          }
        }
      } catch (e) {
        log.err('❌ Error copying files from $sourceId: $e');
        errorCount++;
        errors.add('Error copying files from $sourceId: $e');
      }
    }

    // Show summary
    log.info('');
    log.info('📊 Copy Summary:');
    log.info('Total files: $totalFiles');
    log.info('Successfully copied: $successCount');
    log.info('Skipped: $skipCount');
    log.info('Errors: $errorCount');

    if (errors.isNotEmpty) {
      log.info('');
      log.info('❌ Error Details:');
      for (final error in errors) {
        log.err('- $error');
      }
    }

    return errorCount > 0 ? ExitCode.software.code : ExitCode.success.code;
  }
}
