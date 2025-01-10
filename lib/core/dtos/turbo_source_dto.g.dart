// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turbo_source_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TurboSourceDto _$TurboSourceDtoFromJson(Map<String, dynamic> json) =>
    TurboSourceDto(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$TurboSourceDtoToJson(TurboSourceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
    };
