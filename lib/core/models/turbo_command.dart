import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_command_type.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';
import 'package:ultra_wide_turbo_cli/core/services/update_service.dart';

class TurboCommand extends Command<int> with TurboLogger {
  TurboCommand({
    required TurboCommandType type,
  }) : _type = type;

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\
  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final TurboCommandType _type;

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  String get description => _type.description;

  @override
  String get name => _type.argument;

  @override
  Future<int> run() async {
    switch (_type) {
      case TurboCommandType.update:
        final response = await UpdateService.locate.manualUpdate();
        return response.when(
          success: (_) => ExitCode.success.code,
          fail: (_) => ExitCode.software.code,
        );
    }
  }

// 🎩 STATE --------------------------------------------------------------------------------- \\
// 🛠 UTIL ---------------------------------------------------------------------------------- \\
// 🧲 FETCHERS ------------------------------------------------------------------------------ \\
// 🏗️ HELPERS ------------------------------------------------------------------------------- \\
// 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
