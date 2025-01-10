import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/local_storage_value.dart';

part 'turbo_source_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class TurboSourceDto extends LocalStorageValue {
  TurboSourceDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  static const fromJsonFactory = _$TurboSourceDtoFromJson;
  factory TurboSourceDto.fromJson(Map<String, dynamic> json) =>
      _$TurboSourceDtoFromJson(json);
  static const toJsonFactory = _$TurboSourceDtoToJson;
  Map<String, dynamic> toJson() => _$TurboSourceDtoToJson(this);

  @override
  String toString() {
    return 'TurboSourceDto{'
        'id: $id, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'createdBy: $createdBy, '
        '}';
  }

  @override
  String get toJsonString => jsonEncode(toJson());
}
