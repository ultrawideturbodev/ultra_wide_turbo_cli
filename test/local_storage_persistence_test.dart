import 'package:test/test.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/source_dto.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/tag_dto.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/target_dto.dart';
import 'package:ultra_wide_turbo_cli/core/enums/environment_type.dart';
import 'package:ultra_wide_turbo_cli/core/services/local_storage_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/relation_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/source_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/tag_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/target_service.dart';

void main() {
  group('Local Storage Persistence', () {
    late SourceService sourceService;
    late TargetService targetService;
    late TagService tagService;
    late RelationService relationService;
    late LocalStorageService localStorageService;

    setUp(() async {
      Environment.environmentOverride(environmentType: EnvironmentType.test);
      await AppSetup.initialise([]);

      localStorageService = LocalStorageService.locate;
      tagService = TagService.locate;
      sourceService = SourceService.locate;
      targetService = TargetService.locate;
      relationService = RelationService.locate;

      await relationService.isReady;
    });

    tearDown(() async {
      await AppSetup.reset([]);
    });

    test('Tags persist after service reset', () async {
      // Arrange - Create initial data
      const tagId = 'test-tag';
      const userId = 'test-user';

      final tag = TagDto.create(
        id: tagId,
        parentId: null,
        userId: userId,
      );
      await tagService.createTag(tag: tag);
      print('✅ Created tag: $tagId');

      // Verify data is saved
      final storageBeforeReset = localStorageService.localStorageDto;
      print('📦 Storage before reset: ${storageBeforeReset.toJsonString}');

      // Act - Reset services and reinitialize
      await AppSetup.reset([]);
      await AppSetup.initialise([]);
      final reloadedTagService = TagService.locate;
      print('🔄 Services reinitialized');

      // Assert - Check if data is reloaded
      final exists = reloadedTagService.exists(name: tagId);
      print('🔍 Tag exists after reload: $exists');
      expect(exists, isTrue, reason: 'Tag should persist after service reset');

      final reloadedTag = reloadedTagService.getTagById(id: tagId);
      print('🔍 Reloaded tag: $reloadedTag');
      expect(reloadedTag?.id, equals(tagId),
          reason: 'Tag ID should match after reload');
    });

    test('Sources persist after service reset', () async {
      // Arrange - Create initial data
      const sourceId = 'test-source';
      const userId = 'test-user';

      final source = SourceDto.create(
        id: sourceId,
        userId: userId,
      );
      await sourceService.addSource(source: source);
      print('✅ Created source: $sourceId');

      // Verify data is saved
      final storageBeforeReset = localStorageService.localStorageDto;
      print('📦 Storage before reset: ${storageBeforeReset.toJsonString}');

      // Act - Reset services and reinitialize
      await AppSetup.reset([]);
      await AppSetup.initialise([]);
      final reloadedSourceService = SourceService.locate;
      print('🔄 Services reinitialized');

      // Assert - Check if data is reloaded
      final reloadedSource = reloadedSourceService.getSourceById(sourceId);
      print('🔍 Reloaded source: $reloadedSource');
      expect(
        reloadedSource?.id,
        equals(sourceId),
        reason: 'Source should persist after service reset',
      );
    });

    test('Targets persist after service reset', () async {
      // Arrange - Create initial data
      const targetId = 'test-target';
      const userId = 'test-user';

      final target = TargetDto.create(
        id: targetId,
        userId: userId,
      );
      await targetService.addTarget(target: target);
      print('✅ Created target: $targetId');

      // Verify data is saved
      final storageBeforeReset = localStorageService.localStorageDto;
      print('📦 Storage before reset: ${storageBeforeReset.toJsonString}');

      // Act - Reset services and reinitialize
      await AppSetup.reset([]);
      await AppSetup.initialise([]);
      final reloadedTargetService = TargetService.locate;
      print('🔄 Services reinitialized');

      // Assert - Check if data is reloaded
      final reloadedTarget = reloadedTargetService.getTargetById(targetId);
      print('🔍 Reloaded target: $reloadedTarget');
      expect(
        reloadedTarget?.id,
        equals(targetId),
        reason: 'Target should persist after service reset',
      );
    });

    test('Relations persist after service reset', () async {
      // Arrange - Create initial data
      const tagId = 'test-tag';
      const sourceId = 'test-source';
      const targetId = 'test-target';
      const userId = 'test-user';

      // Create tag
      final tag = TagDto.create(
        id: tagId,
        parentId: null,
        userId: userId,
      );
      await tagService.createTag(tag: tag);
      print('✅ Created tag: $tagId');

      // Create source and target
      final source = SourceDto.create(
        id: sourceId,
        userId: userId,
      );
      await sourceService.addSource(source: source);
      print('✅ Created source: $sourceId');

      final target = TargetDto.create(
        id: targetId,
        userId: userId,
      );
      await targetService.addTarget(target: target);
      print('✅ Created target: $targetId');

      // Create relations
      await relationService.addSourceTagRelation(
        sourceId: sourceId,
        tagId: tagId,
      );
      print('✅ Created source-tag relation');

      await relationService.addTargetTagRelation(
        targetId: targetId,
        tagId: tagId,
      );
      print('✅ Created target-tag relation');

      // Verify data is saved
      final storageBeforeReset = localStorageService.localStorageDto;
      print('📦 Storage before reset: ${storageBeforeReset.toJsonString}');

      // Act - Reset services and reinitialize
      await AppSetup.reset([]);
      await AppSetup.initialise([]);
      final reloadedRelationService = RelationService.locate;
      await reloadedRelationService.isReady;
      print('🔄 Services reinitialized');

      // Assert - Check if relations are reloaded
      final sourceRelationExists =
          reloadedRelationService.sourceTagRelationExists(
        sourceId: sourceId,
        tagId: tagId,
      );
      print('🔍 Source relation exists after reload: $sourceRelationExists');
      expect(
        sourceRelationExists,
        isTrue,
        reason: 'Source relation should persist after service reset',
      );

      final targetRelationExists =
          reloadedRelationService.targetTagRelationExists(
        targetId: targetId,
        tagId: tagId,
      );
      print('🔍 Target relation exists after reload: $targetRelationExists');
      expect(
        targetRelationExists,
        isTrue,
        reason: 'Target relation should persist after service reset',
      );

      // Check if we can list relations
      final sources = reloadedRelationService.listSourcesByTagId(tagId);
      print('🔍 Sources for tag after reload: ${sources.length}');
      expect(sources, isNotEmpty,
          reason: 'Should be able to list sources after reload');

      final targets = reloadedRelationService.listTargetsByTagId(tagId);
      print('🔍 Targets for tag after reload: ${targets.length}');
      expect(targets, isNotEmpty,
          reason: 'Should be able to list targets after reload');
    });
  });
}
