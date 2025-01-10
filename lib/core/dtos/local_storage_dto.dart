import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/local_storage_value.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/tag_dto.dart';
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
    this.tags = const {},
  });

  factory LocalStorageDto.defaultDto({required String userId}) {
    final now = gNow;
    return LocalStorageDto(
      id: userId,
      createdAt: now,
      updatedAt: now,
      createdBy: userId,
      tags: {},
    );
  }

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final Set<TagDto> tags;

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
        'tags: $tags'
        '}';
  }

  @override
  String get toJsonString => jsonEncode(toJson());

  LocalStorageDto copyWith({
    UpdateCurrentDef<Set<TagDto>>? tags,
  }) =>
      LocalStorageDto(
        id: id,
        createdAt: createdAt,
        updatedAt: gNow,
        createdBy: createdBy,
        tags: tags?.call(this.tags) ?? this.tags,
      );
}
