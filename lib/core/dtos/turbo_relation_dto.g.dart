// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turbo_relation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TurboRelationDto _$TurboRelationDtoFromJson(Map<String, dynamic> json) =>
    TurboRelationDto(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      turboTagId: json['turboTagId'] as String?,
      turboSourceId: json['turboSourceId'] as String?,
      type: $enumDecode(_$TurboRelationTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$TurboRelationDtoToJson(TurboRelationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'turboTagId': instance.turboTagId,
      'turboSourceId': instance.turboSourceId,
      'type': _$TurboRelationTypeEnumMap[instance.type]!,
    };

const _$TurboRelationTypeEnumMap = {
  TurboRelationType.sourceTag: 'sourceTag',
};
