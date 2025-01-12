// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TargetDto _$TargetDtoFromJson(Map<String, dynamic> json) => TargetDto(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$TargetDtoToJson(TargetDto instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
    };
