// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turbo_relation_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TurboRelationTypeAdapter extends TypeAdapter<TurboRelationType> {
  @override
  final int typeId = 5;

  @override
  TurboRelationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TurboRelationType.sourceTag;
      case 1:
        return TurboRelationType.targetTag;
      default:
        return TurboRelationType.sourceTag;
    }
  }

  @override
  void write(BinaryWriter writer, TurboRelationType obj) {
    switch (obj) {
      case TurboRelationType.sourceTag:
        writer.writeByte(0);
      case TurboRelationType.targetTag:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TurboRelationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
