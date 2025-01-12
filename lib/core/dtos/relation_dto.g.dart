// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelationDto _$RelationDtoFromJson(Map<String, dynamic> json) => RelationDto(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      tagId: json['tagId'] as String?,
      sourceId: json['sourceId'] as String?,
      targetId: json['targetId'] as String?,
      type: $enumDecode(_$RelationTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$RelationDtoToJson(RelationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'tagId': instance.tagId,
      'sourceId': instance.sourceId,
      'targetId': instance.targetId,
      'type': _$RelationTypeEnumMap[instance.type]!,
    };

const _$RelationTypeEnumMap = {
  RelationType.sourceTag: 'sourceTag',
  RelationType.targetTag: 'targetTag',
};
