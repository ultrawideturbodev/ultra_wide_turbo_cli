import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/local_storage_value.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_relation_type.dart';
import 'package:ultra_wide_turbo_cli/core/globals/g_date_times.dart';
import 'package:ultra_wide_turbo_cli/core/models/turbo_relation.dart';

part 'relation_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class RelationDto extends LocalStorageValue {
  RelationDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.tagId,
    this.sourceId,
    this.targetId,
    required this.type,
  });

  factory RelationDto.create({
    required RelationType type,
    required String tagId,
    required String otherId,
    required String userId,
  }) {
    final now = gNow;
    return RelationDto(
      id: TurboRelation.genId(tagId: tagId, otherId: otherId),
      createdAt: now,
      updatedAt: now,
      createdBy: userId,
      tagId: tagId,
      sourceId: type.isSource ? otherId : null,
      targetId: type.isTarget ? otherId : null,
      type: type,
    );
  }

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? tagId;
  final String? sourceId;
  final String? targetId;
  final RelationType type;

  static const fromJsonFactory = _$RelationDtoFromJson;
  factory RelationDto.fromJson(Map<String, dynamic> json) =>
      _$RelationDtoFromJson(json);
  static const toJsonFactory = _$RelationDtoToJson;
  Map<String, dynamic> toJson() => _$RelationDtoToJson(this);

  @override
  String toString() {
    return 'RelationDto{'
        'id: $id, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'createdBy: $createdBy, '
        'tagId: $tagId, '
        'sourceId: $sourceId, '
        'targetId: $targetId, '
        'type: $type'
        '}';
  }

  @override
  String get toJsonString => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelationDto &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
