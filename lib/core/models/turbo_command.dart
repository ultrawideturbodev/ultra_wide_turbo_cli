import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:turbo_response/turbo_response.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/turbo_relation_dto.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/turbo_source_dto.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/turbo_tag_dto.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/turbo_target_dto.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_command_type.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_relation_type.dart';
import 'package:ultra_wide_turbo_cli/core/extensions/string_extension.dart';
import 'package:ultra_wide_turbo_cli/core/globals/g_auth.dart';
import 'package:ultra_wide_turbo_cli/core/globals/g_date_times.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';
import 'package:ultra_wide_turbo_cli/core/services/local_storage_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/update_service.dart';

class TurboCommand extends Command<int> with TurboLogger {
  TurboCommand({
    required TurboCommandType type,
  }) : _type = type {
    // Add subcommands for parent commands
    if (type == TurboCommandType.tag) {
      addSubcommand(TurboCommand(type: TurboCommandType.tagSource));
      addSubcommand(TurboCommand(type: TurboCommandType.tagTarget));
    }
  }

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\
  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final TurboCommandType _type;

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  String get description => _type.description;

  @override
  String get name => _type.argument;

  @override
  Future<int> run() async {
    switch (_type) {
      case TurboCommandType.update:
        final response = await UpdateService.locate.manualUpdate();
        return response.when(
          success: (_) => ExitCode.success.code,
          fail: (_) => ExitCode.software.code,
        );
      case TurboCommandType.tag:
        // Parent command - show help
        log.info(description);
        return ExitCode.success.code;
      case TurboCommandType.tagSource:
        // Validate tag parameter
        if (argResults?.rest.isEmpty ?? true) {
          log.err('❌ Tag name is required');
          log.info('');
          log.info('Usage: turbo tag source <tag>');
          log.info('Example: turbo tag source my-project');
          return ExitCode.usage.code;
        }

        final tagName = argResults!.rest.first.normalize();

        // Validate tag name format
        if (!_isValidTagName(tagName)) {
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

        log.info('🔍 Linking current directory to tag: $tagName');

        // Get current storage state
        final storage = LocalStorageService.locate.localStorageDto;

        // Check if tag exists
        final existingTag = storage.turboTags.where((tag) => tag.id == tagName).firstOrNull;
        if (existingTag == null) {
          // Create new tag
          final now = gNow;
          final newTag = TurboTagDto(
            id: tagName,
            createdAt: now,
            updatedAt: now,
            createdBy: gUserId,
            parentId: null,
          );

          final response = await LocalStorageService.locate.addTag(turboTag: newTag);
          if (response.isFail) {
            log.err('❌ Failed to create tag: ${response.error}');
            return ExitCode.software.code;
          }
          log.info('✅ Created new tag: $tagName');
        } else {
          log.info('ℹ️ Using existing tag: $tagName');
        }

        // Get current directory
        final currentDir = Directory.current;
        if (!currentDir.existsSync()) {
          log.err('❌ Current directory is not accessible');
          log.info('Please ensure you have read permissions for this directory');
          return ExitCode.software.code;
        }

        // Validate directory path
        if (!_isValidDirectoryPath(currentDir.path)) {
          log.err('❌ Invalid directory path');
          log.info('Directory path must:');
          log.info('- Be an absolute path');
          log.info('- Not contain invalid characters');
          log.info('- Be accessible');
          return ExitCode.software.code;
        }

        final dirName = path.basename(currentDir.path).normalize();
        log.info('🔍 Using directory: $dirName');

        // Get updated storage state
        final updatedStorage = LocalStorageService.locate.localStorageDto;

        // Check if source exists
        final existingSource =
            updatedStorage.turboSources.where((source) => source.id == dirName).firstOrNull;
        if (existingSource == null) {
          // Create new source
          final now = gNow;
          final newSource = TurboSourceDto(
            id: dirName,
            createdAt: now,
            updatedAt: now,
            createdBy: gUserId,
          );

          final response = await LocalStorageService.locate.addSource(turboSource: newSource);
          if (response.isFail) {
            log.err('❌ Failed to create source: ${response.error}');
            return ExitCode.software.code;
          }
          log.info('✅ Created new source: $dirName');
        } else {
          log.info('ℹ️ Using existing source: $dirName');
        }

        // Get final storage state
        final finalStorage = LocalStorageService.locate.localStorageDto;

        // Check if relation already exists
        final existingRelation = finalStorage.turboRelations
            .where((relation) =>
                relation.turboTagId == tagName &&
                relation.turboSourceId == dirName &&
                relation.type == TurboRelationType.sourceTag)
            .firstOrNull;

        if (existingRelation != null) {
          log.info('ℹ️ Tag is already linked to this directory');
          return ExitCode.success.code;
        }

        // Create new relation
        final now = gNow;
        final newRelation = TurboRelationDto(
          id: '$dirName-$tagName',
          createdAt: now,
          updatedAt: now,
          createdBy: gUserId,
          turboTagId: tagName,
          turboSourceId: dirName,
          type: TurboRelationType.sourceTag,
        );

        final response = await LocalStorageService.locate.addRelation(turboRelation: newRelation);
        if (response.isFail) {
          log.err('❌ Failed to link tag to directory: ${response.error}');
          return ExitCode.software.code;
        }
        log.info('✅ Successfully linked tag to directory');

        return ExitCode.success.code;
      case TurboCommandType.tagTarget:
        // Validate tag parameter
        if (argResults?.rest.isEmpty ?? true) {
          log.err('❌ Tag name is required');
          log.info('');
          log.info('Usage: turbo tag target <tag>');
          log.info('Example: turbo tag target my-project');
          return ExitCode.usage.code;
        }

        final tagName = argResults!.rest.first.normalize();

        // Validate tag name format
        if (!_isValidTagName(tagName)) {
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

        log.info('🔍 Linking current directory as target for tag: $tagName');

        // Get current storage state
        final storage = LocalStorageService.locate.localStorageDto;

        // Check if tag exists
        final existingTag = storage.turboTags.where((tag) => tag.id == tagName).firstOrNull;
        TurboTagDto tag;
        if (existingTag == null) {
          // Create new tag
          final now = gNow;
          tag = TurboTagDto(
            id: tagName,
            createdAt: now,
            updatedAt: now,
            createdBy: gUserId,
            parentId: null,
          );
          try {
            await LocalStorageService.locate.addTag(turboTag: tag);
            log.info('✅ Created new tag: $tagName');
          } catch (e) {
            log.err('❌ Failed to create tag: $e');
            return ExitCode.software.code;
          }
        } else {
          tag = existingTag;
          log.info('ℹ️ Using existing tag: $tagName');
        }

        // Get current directory
        final currentDir = Directory.current;
        final dirName = path.basename(currentDir.path);
        log.info('🔍 Using directory: $dirName');

        // Refresh storage state after tag creation
        final updatedStorage = LocalStorageService.locate.localStorageDto;

        // Check if target exists
        final existingTarget =
            updatedStorage.turboTargets.where((target) => target.id == dirName).firstOrNull;
        TurboTargetDto target;
        if (existingTarget == null) {
          // Create new target
          final now = gNow;
          target = TurboTargetDto(
            id: dirName,
            createdAt: now,
            updatedAt: now,
            createdBy: gUserId,
          );
          try {
            await LocalStorageService.locate.addTarget(turboTarget: target);
            log.info('✅ Created new target: $dirName');
          } catch (e) {
            log.err('❌ Failed to create target: $e');
            return ExitCode.software.code;
          }
        } else {
          target = existingTarget;
          log.info('ℹ️ Using existing target: $dirName');
        }

        // Check if relation exists
        final existingRelation = updatedStorage.turboRelations
            .where((relation) =>
                relation.turboTagId == tag.id &&
                relation.turboTargetId == target.id &&
                relation.type == TurboRelationType.targetTag)
            .firstOrNull;

        if (existingRelation != null) {
          log.info('ℹ️ Tag is already linked to this directory');
          return ExitCode.success.code;
        }

        // Create new relation
        final now = gNow;
        final relation = TurboRelationDto(
          id: '${target.id}-${tag.id}',
          createdAt: now,
          updatedAt: now,
          createdBy: gUserId,
          turboTagId: tag.id,
          turboTargetId: target.id,
          type: TurboRelationType.targetTag,
        );

        try {
          await LocalStorageService.locate.addRelation(turboRelation: relation);
          log.info('✅ Successfully linked tag to directory');
          return ExitCode.success.code;
        } catch (e) {
          log.err('❌ Failed to create relation: $e');
          return ExitCode.software.code;
        }
    }
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  /// Validates the tag name format.
  ///
  /// Tag name requirements:
  /// - Must be between 2 and 50 characters
  /// - Can only contain letters, numbers, hyphens, and underscores
  /// - Cannot start or end with a hyphen or underscore
  bool _isValidTagName(String tagName) {
    if (tagName.length < 2 || tagName.length > 50) return false;
    if (tagName.startsWith('-') || tagName.startsWith('_')) return false;
    if (tagName.endsWith('-') || tagName.endsWith('_')) return false;
    return RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(tagName);
  }

  /// Validates the directory path.
  ///
  /// Directory path must:
  /// - Be an absolute path
  /// - Not contain invalid characters
  /// - Be accessible
  bool _isValidDirectoryPath(String dirPath) {
    if (!path.isAbsolute(dirPath)) return false;
    try {
      final dir = Directory(dirPath);
      return dir.existsSync() && dir.statSync().type == FileSystemEntityType.directory;
    } catch (e) {
      return false;
    }
  }

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
