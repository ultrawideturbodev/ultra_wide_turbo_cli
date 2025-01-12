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
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => TagDto.fromJson(e as Map<String, dynamic>))
              .toSet() ??
          {},
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => SourceDto.fromJson(e as Map<String, dynamic>))
              .toSet() ??
          {},
      targets: (json['targets'] as List<dynamic>?)
              ?.map((e) => TargetDto.fromJson(e as Map<String, dynamic>))
              .toSet() ??
          {},
      relations: (json['relations'] as List<dynamic>?)
              ?.map((e) => RelationDto.fromJson(e as Map<String, dynamic>))
              .toSet() ??
          {},
    );

Map<String, dynamic> _$LocalStorageDtoToJson(LocalStorageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'tags': instance.tags.map((e) => e.toJson()).toList(),
      'sources': instance.sources.map((e) => e.toJson()).toList(),
      'targets': instance.targets.map((e) => e.toJson()).toList(),
      'relations': instance.relations.map((e) => e.toJson()).toList(),
    };
