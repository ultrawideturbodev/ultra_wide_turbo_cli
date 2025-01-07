import 'package:hive_ce/hive.dart';
import 'package:ultra_wide_turbo_cli/core/adapters/date_time_adapter.dart';

enum HiveAdapters {
  dateTime,
  ;

  void registerAdapter() {
    switch (this) {
      case HiveAdapters.dateTime:
        Hive.registerAdapter(DateTimeAdapter());
        break;
    }
  }
}
