import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/local_storage_value.dart';
import 'package:ultra_wide_turbo_cli/core/extensions/string_extension.dart';

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

  factory TagDto.create({
    required String id,
    required String? parentId,
    required String userId,
  }) {
    final now = DateTime.now();
    return TagDto(
      id: id.normalize(),
      createdAt: now,
      updatedAt: now,
      createdBy: userId,
      parentId: parentId,
    );
  }

  final String? parentId;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  static const fromJsonFactory = _$TagDtoFromJson;
  factory TagDto.fromJson(Map<String, dynamic> json) => _$TagDtoFromJson(json);
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagDto && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
