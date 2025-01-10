import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/local_storage_value.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/turbo_relation_dto.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/turbo_source_dto.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/turbo_tag_dto.dart';
import 'package:ultra_wide_turbo_cli/core/globals/g_date_times.dart';
import 'package:ultra_wide_turbo_cli/core/typedefs/update_current_def.dart';

part 'local_storage_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class LocalStorageDto extends LocalStorageValue {
  LocalStorageDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.turboTags,
    required this.turboSources,
    required this.turboRelations,
  });

  factory LocalStorageDto.defaultDto({required String userId}) {
    final now = gNow;
    return LocalStorageDto(
      id: userId,
      createdAt: now,
      updatedAt: now,
      createdBy: userId,
      turboTags: {},
      turboSources: {},
      turboRelations: {},
    );
  }

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  @JsonKey(defaultValue: {})
  final Set<TurboTagDto> turboTags;
  @JsonKey(defaultValue: {})
  final Set<TurboSourceDto> turboSources;
  @JsonKey(defaultValue: {})
  final Set<TurboRelationDto> turboRelations;

  static const fromJsonFactory = _$LocalStorageDtoFromJson;
  factory LocalStorageDto.fromJson(Map<String, dynamic> json) => _$LocalStorageDtoFromJson(json);
  static const toJsonFactory = _$LocalStorageDtoToJson;
  Map<String, dynamic> toJson() => _$LocalStorageDtoToJson(this);

  @override
  String toString() {
    return 'LocalStorageDto{'
        'id: $id, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'createdBy: $createdBy, '
        'turboTags: $turboTags, '
        'turboSources: $turboSources, '
        'turboRelations: $turboRelations'
        '}';
  }

  @override
  String get toJsonString => jsonEncode(toJson());

  LocalStorageDto copyWith({
    UpdateCurrentDef<Set<TurboTagDto>>? turboTags,
    UpdateCurrentDef<Set<TurboSourceDto>>? turboSources,
    UpdateCurrentDef<Set<TurboRelationDto>>? turboRelations,
  }) =>
      LocalStorageDto(
        id: id,
        createdAt: createdAt,
        updatedAt: gNow,
        createdBy: createdBy,
        turboTags: turboTags?.call(this.turboTags) ?? this.turboTags,
        turboSources: turboSources?.call(this.turboSources) ?? this.turboSources,
        turboRelations: turboRelations?.call(this.turboRelations) ?? this.turboRelations,
      );
}
