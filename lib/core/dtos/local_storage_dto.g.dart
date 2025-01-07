// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_storage_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalStorageDto _$LocalStorageDtoFromJson(Map<String, dynamic> json) =>
    LocalStorageDto(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
          const {},
    );

Map<String, dynamic> _$LocalStorageDtoToJson(LocalStorageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'updatedBy': instance.updatedBy,
      'tags': instance.tags.toList(),
    };
