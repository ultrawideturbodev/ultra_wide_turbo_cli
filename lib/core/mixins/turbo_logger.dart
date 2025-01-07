import 'package:ultra_wide_turbo_cli/core/services/logger_service.dart';

mixin TurboLogger {
  final log = LoggerService.locate.log;
}
