import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/local_storage_value.dart';

part 'turbo_tag_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class TurboTagDto extends LocalStorageValue {
  TurboTagDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.parentId,
  });

  final String? parentId;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  static const fromJsonFactory = _$TurboTagDtoFromJson;
  factory TurboTagDto.fromJson(Map<String, dynamic> json) =>
      _$TurboTagDtoFromJson(json);
  static const toJsonFactory = _$TurboTagDtoToJson;
  Map<String, dynamic> toJson() => _$TurboTagDtoToJson(this);

  @override
  String toString() {
    return 'TurboTagDto{'
        'id: $id, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'createdBy: $createdBy, '
        'parentId: $parentId'
        '}';
  }

  @override
  String get toJsonString => jsonEncode(toJson());
}
