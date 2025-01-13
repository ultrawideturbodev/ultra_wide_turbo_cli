import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';
import 'package:ultra_wide_turbo_cli/core/enums/environment_type.dart';

final log = switch (Environment.current) {
  EnvironmentType.prod => Logger(),
  EnvironmentType.test => _MockLogger(),
};

class _MockLogger extends Mock implements Logger {}
