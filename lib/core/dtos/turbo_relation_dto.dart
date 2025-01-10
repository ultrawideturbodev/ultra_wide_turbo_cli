import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/local_storage_value.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_relation_type.dart';

part 'turbo_relation_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class TurboRelationDto extends LocalStorageValue {
  TurboRelationDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.turboTagId,
    required this.turboSourceId,
    required this.type,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? turboTagId;
  final String? turboSourceId;
  final TurboRelationType type;

  static const fromJsonFactory = _$TurboRelationDtoFromJson;
  factory TurboRelationDto.fromJson(Map<String, dynamic> json) => _$TurboRelationDtoFromJson(json);
  static const toJsonFactory = _$TurboRelationDtoToJson;
  Map<String, dynamic> toJson() => _$TurboRelationDtoToJson(this);

  @override
  String toString() {
    return 'TurboRelationDto{'
        'id: $id, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'createdBy: $createdBy, '
        'tagId: $turboTagId, '
        'sourceId: $turboSourceId'
        'type: $type'
        '}';
  }

  @override
  String get toJsonString => jsonEncode(toJson());
}
