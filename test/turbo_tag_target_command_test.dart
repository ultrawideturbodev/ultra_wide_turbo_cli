import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';
import 'package:ultra_wide_turbo_cli/core/config/app_setup.dart';
import 'package:ultra_wide_turbo_cli/core/enums/environment_type.dart';
import 'package:ultra_wide_turbo_cli/core/globals/log.dart';
import 'package:ultra_wide_turbo_cli/core/services/relation_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/turbo_command_service.dart';

void main() {
  group('Turbo Tag Target Command', () {
    late Directory directory;
    late Directory targetFolder;
    late RelationService relationService;

    setUpAll(() async {
      directory = await Directory.systemTemp.createTemp('test_workspace');
      targetFolder = Directory('${directory.path}/target_folder');
      await targetFolder.create();
    });

    setUp(() async {
      Environment.environmentOverride(environmentType: EnvironmentType.test);
      IOOverrides.global = _TestIOOverrides(targetFolder);

      await AppSetup.initialise([]);
      relationService = RelationService.locate;
    });

    tearDown(() async {
      await AppSetup.reset([]);
      IOOverrides.global = null;
    });

    tearDownAll(() async {
      await directory.delete(recursive: true);
    });

    test('Successfully links target directory to tag', () async {
      // Arrange
      when(
        () => log.chooseOne<String>(
          any(),
          choices: any(named: 'choices'),
          display: any(named: 'display'),
        ),
      ).thenReturn('test-tag');

      // Act
      final result = await TurboCommandService.locate.run(['tag', 'target']);

      // Assert
      expect(result, ExitCode.success.code);
      expect(
        relationService.targetTagRelationExists(
          tagId: 'test-tag',
          targetId: targetFolder.path,
        ),
        isTrue,
      );
    });

    test('Target-tag relation persists after service reset', () async {
      // Arrange - Create the target and tag
      when(
        () => log.chooseOne<String>(
          any(),
          choices: any(named: 'choices'),
          display: any(named: 'display'),
        ),
      ).thenReturn('test-tag');

      final result = await TurboCommandService.locate.run(['tag', 'target']);
      expect(result, ExitCode.success.code);

      // Act - Reset services and reinitialize
      relationService = RelationService.locate;

      // Assert - Verify relation still exists
      expect(
        relationService.targetTagRelationExists(
          tagId: 'test-tag',
          targetId: targetFolder.path,
        ),
        isTrue,
        reason: 'Relation should persist after service reset',
      );

      // Also verify we can list the targets by tag
      final targets = relationService.listTargetsByTagId('test-tag');
      expect(targets, hasLength(1), reason: 'Tag should have one target');
      expect(
        targets.first.targetId,
        equals(targetFolder.path),
        reason: 'Target ID should match directory path',
      );
    });
  });
}

class _TestIOOverrides extends IOOverrides {
  _TestIOOverrides(this.directory);

  final Directory directory;

  @override
  Directory getCurrentDirectory() => directory;
}
