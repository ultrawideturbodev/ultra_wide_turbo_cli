import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/local_storage_value.dart';

part 'tag_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class TagDto extends LocalStorageValue {
  TagDto({
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

  static const fromJsonFactory = _$TagDtoFromJson;
  factory TagDto.fromJson(Map<String, dynamic> json) =>
      _$TagDtoFromJson(json);
  static const toJsonFactory = _$TagDtoToJson;
  Map<String, dynamic> toJson() => _$TagDtoToJson(this);

  @override
  String toString() {
    return 'TagDto{'
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
