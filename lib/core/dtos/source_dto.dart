import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/local_storage_value.dart';
import 'package:ultra_wide_turbo_cli/core/globals/g_date_times.dart';

part 'source_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class SourceDto extends LocalStorageValue {
  SourceDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory SourceDto.create({
    required String id,
    required String userId,
  }) {
    final now = gNow;
    return SourceDto(
      id: id,
      createdAt: now,
      updatedAt: now,
      createdBy: userId,
    );
  }

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  static const fromJsonFactory = _$SourceDtoFromJson;
  factory SourceDto.fromJson(Map<String, dynamic> json) => _$SourceDtoFromJson(json);
  static const toJsonFactory = _$SourceDtoToJson;
  Map<String, dynamic> toJson() => _$SourceDtoToJson(this);

  @override
  String toString() {
    return 'SourceDto{'
        'id: $id, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'createdBy: $createdBy, '
        '}';
  }

  @override
  String get toJsonString => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceDto && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
