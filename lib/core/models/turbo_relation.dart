import 'package:ultra_wide_turbo_cli/core/dtos/relation_dto.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_relation_type.dart';

/// A sealed class representing a relationship between tags and sources/targets
///
/// This class serves as the base for two types of relationships:
/// - SourceTagRelation: Links a tag to a source directory
/// - TargetTagRelation: Links a tag to a target directory
///
/// The relationships are used to track connections between tagged directories
/// in the Ultra Wide Turbo CLI system.
sealed class TurboRelation {
  /// Creates a new Relation instance
  ///
  /// Parameters:
  /// - [id]: Unique identifier for this relation
  /// - [createdAt]: Timestamp when relation was created
  /// - [updatedAt]: Timestamp when relation was last updated
  /// - [createdBy]: Identifier of user/system that created the relation
  TurboRelation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  /// Creates a Relation from a DTO object
  ///
  /// Parameters:
  /// - [dto]: The DTO containing relation data
  ///
  /// Returns: A concrete Relation instance based on the DTO type
  ///
  /// Example:
  /// ```dart
  /// final relation = Relation.fromDto(someDto);
  /// ```
  factory TurboRelation.fromDto(RelationDto dto) {
    switch (dto.type) {
      case RelationType.sourceTag:
        return SourceTagRelation(
          id: dto.id,
          createdAt: dto.createdAt,
          updatedAt: dto.updatedAt,
          createdBy: dto.createdBy,
          tagId: dto.tagId!,
          sourceId: dto.sourceId!,
        );
      case RelationType.targetTag:
        return TargetTagRelation(
          id: dto.id,
          createdAt: dto.createdAt,
          updatedAt: dto.updatedAt,
          createdBy: dto.createdBy,
          tagId: dto.tagId!,
          targetId: dto.targetId!,
        );
    }
  }

  /// Unique identifier for this relation
  final String id;

  /// Timestamp when relation was created
  final DateTime createdAt;

  /// Timestamp when relation was last updated
  final DateTime updatedAt;

  /// Identifier of user/system that created the relation
  final String createdBy;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TurboRelation && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static String genId({required String tagId, required String otherId}) =>
      [otherId, tagId].join('-');

  @override
  String toString() {
    return 'TurboRelation{id: $id, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy}';
  }
}

/// Represents a relationship between a tag and a source directory
class SourceTagRelation extends TurboRelation {
  /// Creates a new SourceTagRelation
  ///
  /// Parameters:
  /// - [id]: Unique identifier for this relation
  /// - [createdAt]: Timestamp when relation was created
  /// - [updatedAt]: Timestamp when relation was last updated
  /// - [createdBy]: Identifier of user/system that created the relation
  /// - [tagId]: ID of the associated tag
  /// - [sourceId]: ID of the associated source directory
  SourceTagRelation({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
    required this.tagId,
    required this.sourceId,
  });

  /// ID of the associated tag
  final String tagId;

  /// ID of the associated source directory
  final String sourceId;

  @override
  String toString() {
    return '${super.toString()}\nSourceTagRelation{tagId: $tagId, sourceId: $sourceId}';
  }
}

/// Represents a relationship between a tag and a target directory
class TargetTagRelation extends TurboRelation {
  /// Creates a new TargetTagRelation
  ///
  /// Parameters:
  /// - [id]: Unique identifier for this relation
  /// - [createdAt]: Timestamp when relation was created
  /// - [updatedAt]: Timestamp when relation was last updated
  /// - [createdBy]: Identifier of user/system that created the relation
  /// - [tagId]: ID of the associated tag
  /// - [targetId]: ID of the associated target directory
  TargetTagRelation({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
    required this.tagId,
    required this.targetId,
  });

  /// ID of the associated tag
  final String tagId;

  /// ID of the associated target directory
  final String targetId;

  @override
  String toString() {
    return '${super.toString()}\nTargetTagRelation{tagId: $tagId, targetId: $targetId}';
  }
}
