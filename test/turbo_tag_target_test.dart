import 'package:test/test.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/tag_dto.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/target_dto.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/relation_dto.dart';
import 'package:ultra_wide_turbo_cli/core/enums/environment_type.dart';
import 'package:ultra_wide_turbo_cli/core/services/target_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/tag_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/relation_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/local_storage_service.dart';
import 'package:ultra_wide_turbo_cli/core/models/turbo_relation.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_relation_type.dart';

void main() {
  group('TurboTagTarget - Happy Flow', () {
    late TargetService targetService;
    late TagService tagService;
    late RelationService relationService;
    late LocalStorageService localStorageService;

    setUp(() async {
      Environment.environmentOverride(environmentType: EnvironmentType.test);
      // Initialize app and services
      await AppSetup.initialise([]);

      localStorageService = LocalStorageService.locate;
      tagService = TagService.locate;
      targetService = TargetService.locate;
      relationService = RelationService.locate;

      // Wait for services to be ready
      await relationService.isReady;
    });

    tearDown(() async {
      await AppSetup.reset([]);
    });

    test('Create new tag successfully', () async {
      // Arrange
      const tagName = 'test-tag';
      const userId = 'test-user';

      // Act
      final tag = TagDto.create(
        id: tagName,
        parentId: null,
        userId: userId,
      );
      final result = await tagService.createTag(tag: tag);

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('Add target to tag successfully', () async {
      // Arrange
      const targetId = 'test-target';
      const tagId = 'test-tag';
      const userId = 'test-user';

      // First create the tag
      final tag = TagDto.create(
        id: tagId,
        parentId: null,
        userId: userId,
      );
      await tagService.createTag(tag: tag);

      // Then create the target
      final target = TargetDto.create(
        id: targetId,
        userId: userId,
      );
      await targetService.addTarget(target: target);

      // Act
      final result = await relationService.addTargetTagRelation(
        targetId: targetId,
        tagId: tagId,
      );

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('Target tag relation exists after creation', () async {
      // Arrange
      const targetId = 'test-target';
      const tagId = 'test-tag';
      const userId = 'test-user';

      // First create the tag
      final tag = TagDto.create(
        id: tagId,
        parentId: null,
        userId: userId,
      );
      await tagService.createTag(tag: tag);
      print('✅ Tag created: $tagId');

      // Then create the target
      final target = TargetDto.create(
        id: targetId,
        userId: userId,
      );
      await targetService.addTarget(target: target);
      print('✅ Target created: $targetId');

      // Create the relation
      final relationDto = RelationDto.create(
        type: RelationType.targetTag,
        tagId: tagId,
        otherId: targetId,
        userId: userId,
      );
      print('📝 Creating relation with ID: ${relationDto.id}');

      final result = await relationService.addTargetTagRelation(
        targetId: targetId,
        tagId: tagId,
      );
      print('📝 Relation creation result: ${result.isSuccess}');

      // Wait a bit to ensure relation is stored
      await Future.delayed(const Duration(milliseconds: 100));

      // Debug: Check if relation exists by ID
      final relationId = TurboRelation.genId(tagId: tagId, otherId: targetId);
      final storedRelation = relationService.getRelationById(relationId);
      print('🔍 Stored relation: $storedRelation');

      // Act
      final exists = relationService.targetTagRelationExists(
        targetId: targetId,
        tagId: tagId,
      );
      print('🔍 Relation exists check: $exists');

      // Assert
      expect(exists, isTrue, reason: 'Relation should exist after creation');
    });

    test('List targets by tag ID returns correct targets', () async {
      // Arrange
      const targetId = 'test-target';
      const tagId = 'test-tag';
      const userId = 'test-user';

      // First create the tag
      final tag = TagDto.create(
        id: tagId,
        parentId: null,
        userId: userId,
      );
      await tagService.createTag(tag: tag);

      // Then create the target
      final target = TargetDto.create(
        id: targetId,
        userId: userId,
      );
      await targetService.addTarget(target: target);

      // Create the relation
      await relationService.addTargetTagRelation(
        targetId: targetId,
        tagId: tagId,
      );

      // Wait a bit to ensure relation is stored
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      final targets = relationService.listTargetsByTagId(tagId);

      // Assert
      expect(targets, isNotEmpty);
      expect(targets.first.tagId, equals(tagId));
    });
  });
}
