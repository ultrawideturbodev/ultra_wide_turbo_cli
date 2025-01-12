import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/relation_dto.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_relation_type.dart';
import 'package:ultra_wide_turbo_cli/core/globals/g_auth.dart';
import 'package:ultra_wide_turbo_cli/core/globals/g_self.dart';
import 'package:ultra_wide_turbo_cli/core/globals/log.dart';
import 'package:ultra_wide_turbo_cli/core/models/turbo_relation.dart';
import 'package:ultra_wide_turbo_cli/core/services/local_storage_service.dart';

class RelationService {
  RelationService() {
    initialise();
  }

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static RelationService get locate => GetIt.I.get();
  static void registerLazySingleton() => GetIt.I.registerLazySingleton(
        RelationService.new,
    dispose: (service) => service.dispose(),
      );

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  late final _localStorageService = LocalStorageService.locate;

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  Future<void> initialise() async {
    try {
      final relations =
          _localStorageService.localStorageDto.relations.map((e) => TurboRelation.fromDto(e));
      for (final relation in relations) {
        _addLocalRelation(relation);
      }
    } catch (error, _) {
      log.err(
        '$error caught while initialising RelationService',
      );
    } finally {
      _isReady.complete();
    }
  }

  Future<void> dispose() async {
    _sourcesPerTagId.clear();
    _targetsPerTagId.clear();
    _relationsPerId.clear();
    _isReady = Completer();
  }

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  Future get isReady => _isReady.future;

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  var _isReady = Completer();
  final Map<String, List<SourceTagRelation>> _sourcesPerTagId = {};
  final Map<String, List<TargetTagRelation>> _targetsPerTagId = {};
  final Map<String, TurboRelation> _relationsPerId = {};

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  List<SourceTagRelation> listSourcesByTagId(String tagId) => _sourcesPerTagId[tagId] ?? [];
  List<TargetTagRelation> listTargetsByTagId(String tagId) => _targetsPerTagId[tagId] ?? [];

  TurboRelation? getRelationById(String id) => _relationsPerId[id];

  bool sourceTagRelationExists({
    required String tagId,
    required String sourceId,
  }) =>
      getRelationById(
        TurboRelation.genId(
          tagId: tagId,
          otherId: sourceId,
        ),
      ) !=
      null;

  bool targetTagRelationExists({
    required String tagId,
    required String targetId,
  }) =>
      getRelationById(
        TurboRelation.genId(
          tagId: tagId,
          otherId: targetId,
        ),
      ) !=
      null;

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  void _addLocalRelation(TurboRelation relation) {
    _relationsPerId[relation.id] = relation;

    switch (relation) {
      case SourceTagRelation():
        _sourcesPerTagId.putIfAbsent(relation.tagId, () => []).add(relation);
      case TargetTagRelation():
        _targetsPerTagId.putIfAbsent(relation.tagId, () => []).add(relation);
    }
  }

  Future<TurboResponse> _addRelation({
    required RelationDto relationDto,
  }) async =>
      (await _localStorageService.updateLocalStorage(
        (current) => current.copyWith(
          relations: (current) => current..add(relationDto),
        ),
        userId: gUserId,
      ))
          .when(
        success: (response) {
          final relation = TurboRelation.fromDto(relationDto);
          _addLocalRelation(relation);
          return response;
        },
        fail: gSelf,
      );

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  Future<TurboResponse> addSourceTagRelation({
    required String sourceId,
    required String tagId,
  }) =>
      _addRelation(
        relationDto: RelationDto.create(
          type: RelationType.sourceTag,
          tagId: tagId,
          otherId: sourceId,
          userId: gUserId,
        ),
      );

  Future<TurboResponse> addTargetTagRelation({
    required String targetId,
    required String tagId,
  }) =>
      _addRelation(
        relationDto: RelationDto.create(
          type: RelationType.targetTag,
          tagId: tagId,
          otherId: targetId,
          userId: gUserId,
        ),
      );
}
