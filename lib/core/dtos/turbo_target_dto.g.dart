// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turbo_target_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TurboTargetDto _$TurboTargetDtoFromJson(Map<String, dynamic> json) =>
    TurboTargetDto(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$TurboTargetDtoToJson(TurboTargetDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
    };
