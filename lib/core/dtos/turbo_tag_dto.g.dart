// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turbo_tag_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TurboTagDto _$TurboTagDtoFromJson(Map<String, dynamic> json) => TurboTagDto(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      parentId: json['parentId'] as String?,
    );

Map<String, dynamic> _$TurboTagDtoToJson(TurboTagDto instance) =>
    <String, dynamic>{
      'parentId': instance.parentId,
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
    };
