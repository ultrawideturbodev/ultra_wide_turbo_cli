import 'dart:async';

import 'package:args/args.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_command_type.dart';

typedef RunCommandDef = FutureOr<int> Function(
    TurboCommandType type, ArgResults? argResults);
