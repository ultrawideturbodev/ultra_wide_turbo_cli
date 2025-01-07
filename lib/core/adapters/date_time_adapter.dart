import 'package:hive_ce/hive.dart';

import '../enums/hive_adapters.dart';

class DateTimeAdapter extends TypeAdapter<DateTime?> {
  @override
  final int typeId = HiveAdapters.dateTime.index;

  @override
  DateTime? read(BinaryReader reader) {
    final value = reader.readInt();
    return value == -1 ? null : DateTime.fromMillisecondsSinceEpoch(value);
  }

  @override
  void write(BinaryWriter writer, DateTime? obj) =>
      writer.writeInt(obj?.millisecondsSinceEpoch ?? -1);
}
