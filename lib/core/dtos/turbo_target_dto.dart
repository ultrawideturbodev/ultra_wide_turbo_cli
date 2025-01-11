import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/local_storage_value.dart';

part 'turbo_target_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class TurboTargetDto extends LocalStorageValue {
  TurboTargetDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  static const fromJsonFactory = _$TurboTargetDtoFromJson;
  factory TurboTargetDto.fromJson(Map<String, dynamic> json) => _$TurboTargetDtoFromJson(json);
  static const toJsonFactory = _$TurboTargetDtoToJson;
  Map<String, dynamic> toJson() => _$TurboTargetDtoToJson(this);

  @override
  String toString() {
    return 'TurboTargetDto{'
        'id: $id, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'createdBy: $createdBy, '
        '}';
  }

  @override
  String get toJsonString => jsonEncode(toJson());
}
