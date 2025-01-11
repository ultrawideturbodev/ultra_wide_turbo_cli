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
      turboTags: (json['turboTags'] as List<dynamic>?)
              ?.map((e) => TurboTagDto.fromJson(e as Map<String, dynamic>))
              .toSet() ??
          {},
      turboSources: (json['turboSources'] as List<dynamic>?)
              ?.map((e) => TurboSourceDto.fromJson(e as Map<String, dynamic>))
              .toSet() ??
          {},
      turboTargets: (json['turboTargets'] as List<dynamic>?)
              ?.map((e) => TurboTargetDto.fromJson(e as Map<String, dynamic>))
              .toSet() ??
          {},
      turboRelations: (json['turboRelations'] as List<dynamic>?)
              ?.map((e) => TurboRelationDto.fromJson(e as Map<String, dynamic>))
              .toSet() ??
          {},
    );

Map<String, dynamic> _$LocalStorageDtoToJson(LocalStorageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'turboTags': instance.turboTags.map((e) => e.toJson()).toList(),
      'turboSources': instance.turboSources.map((e) => e.toJson()).toList(),
      'turboTargets': instance.turboTargets.map((e) => e.toJson()).toList(),
      'turboRelations': instance.turboRelations.map((e) => e.toJson()).toList(),
    };
