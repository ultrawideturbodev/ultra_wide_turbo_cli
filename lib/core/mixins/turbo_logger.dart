import 'package:ultra_wide_turbo_cli/core/services/turbo_logger_service.dart';

mixin TurboLogger {
  final log = TurboLoggerService.locate.log;
}
