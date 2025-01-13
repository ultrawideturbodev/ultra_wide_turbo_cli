import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/local_storage_value.dart';
import 'package:ultra_wide_turbo_cli/core/globals/g_date_times.dart';

part 'target_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class TargetDto extends LocalStorageValue {
  TargetDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory TargetDto.create({
    required String id,
    required String userId,
  }) {
    final now = gNow;
    return TargetDto(
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

  static const fromJsonFactory = _$TargetDtoFromJson;
  factory TargetDto.fromJson(Map<String, dynamic> json) =>
      _$TargetDtoFromJson(json);
  static const toJsonFactory = _$TargetDtoToJson;
  Map<String, dynamic> toJson() => _$TargetDtoToJson(this);

  @override
  String toString() {
    return 'TargetDto{'
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
      other is TargetDto && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
