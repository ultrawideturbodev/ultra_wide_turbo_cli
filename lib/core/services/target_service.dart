import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/initialisable.dart';
import 'package:ultra_wide_turbo_cli/core/constants/k_values.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/tag_dto.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/target_dto.dart';
import 'package:ultra_wide_turbo_cli/core/extensions/iterable_extension.dart';
import 'package:ultra_wide_turbo_cli/core/extensions/string_extension.dart';
import 'package:ultra_wide_turbo_cli/core/globals/g_auth.dart';
import 'package:ultra_wide_turbo_cli/core/globals/log.dart';
import 'package:ultra_wide_turbo_cli/core/services/local_storage_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/relation_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/tag_service.dart';

class TargetService extends Initialisable {
  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static TargetService get locate => GetIt.I.get();
  static void registerLazySingleton() => GetIt.I.registerLazySingleton(TargetService.new);

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  late final _tagService = TagService.locate;
  late final _relationService = RelationService.locate;
  final _localStorageService = LocalStorageService.locate;

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise() async {
    _targetPerId.addAll(
      _localStorageService.localStorageDto.targets.toIdMap((element) => element.id),
    );
    super.initialise();
  }

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final Map<String, TargetDto> _targetPerId = {};

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  TargetDto? getTargetById(String id) => _targetPerId[id];
  bool exists(String id) => _targetPerId.containsKey(id);

// 🏗️ HELPERS ------------------------------------------------------------------------------- \\
// 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  Future<int> onTagTarget() async {
    log.info('🔍 Preparing to link current directory to a tag');

    // Get list of existing tags
    final existingTags = _tagService.tagsSortedById.toList()..sort((a, b) => a.id.compareTo(b.id));
    final tagOptions = [kValues.pNew, ...existingTags.map((tag) => tag.id)];

    // Prompt user to select a tag
    final selectedTag = log.chooseOne(
      'Select a tag:',
      choices: tagOptions,
      display: (tag) => tag,
    );

    String tagName;
    if (selectedTag == kValues.pNew) {
      // Prompt for new tag name
      tagName = log.prompt('Enter a new tag name:').normalize();
      // TODO(GPT-AGENT): Double check if we are listening to _stdout because this is not async so its not waiting for the user input

      // Validate tag name format
      if (!tagName.isValidTagName) {
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
    } else {
      tagName = selectedTag;
    }

    log.info('🔍 Linking current directory to tag: $tagName');

    // Check if tag exists
    final exists = _tagService.exists(name: tagName);
    if (!exists) {
      // Create new tag
      final newTag = TagDto.create(
        id: tagName,
        userId: gUserId,
        parentId: null,
      );

      final response = await _tagService.createTag(tag: newTag);
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
    final targetId = currentDir.path;
    if (!targetId.isValidDirectoryPath) {
      log.err('❌ Invalid directory path');
      log.info('Directory path must:');
      log.info('- Be an absolute path');
      log.info('- Not contain invalid characters');
      log.info('- Be accessible');
      return ExitCode.software.code;
    }

    final dirName = basename(targetId).normalize();
    log.info('🔍 Using directory: $dirName');

    // Get updated storage state
    final updatedStorage = LocalStorageService.locate.localStorageDto;

    // Check if target exists
    final existingTarget =
        updatedStorage.targets.where((target) => target.id == targetId).firstOrNull;
    if (existingTarget == null) {
      // Create new target
      final newTarget = TargetDto.create(
        id: targetId,
        userId: gUserId,
      );

      final response = await addTarget(target: newTarget);
      if (response.isFail) {
        log.err('❌ Failed to create target: ${response.error}');
        return ExitCode.software.code;
      }
      log.info('✅ Created new target: $dirName');
    } else {
      log.info('ℹ️ Using existing target: $dirName');
    }

    // Check if relation exists
    final targetTagRelationExists = _relationService.targetTagRelationExists(
      tagId: tagName,
      targetId: targetId,
    );

    if (targetTagRelationExists) {
      final response = await _relationService.addTargetTagRelation(
        targetId: targetId,
        tagId: tagName,
      );
      if (response.isFail) {
        log.err('❌ Failed to create relation: ${response.error}');
        return ExitCode.software.code;
      }
      log.info('✅ Successfully linked tag to directory');
    } else {
      log.info('ℹ️ Tag is already linked to this directory');
    }

    return ExitCode.success.code;
  }

  Future<TurboResponse> addTarget({
    required TargetDto target,
  }) async =>
      await _localStorageService.updateLocalStorage(
        (current) => current.copyWith(
          targets: (current) => current..add(target),
        ),
        userId: gUserId,
      );
}
