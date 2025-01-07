import 'package:args/command_runner.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_command_type.dart';
import 'package:ultra_wide_turbo_cli/core/extensions/arg_results_extension.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';
import 'package:ultra_wide_turbo_cli/core/services/script_service.dart';

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
  String get name => _type.pName;

  @override
  Future<int> run() async {
    switch (_type) {
      case TurboCommandType.fix:
        return ScriptService.locate.run(_type.script(activeFlags: argResults?.activeFlags ?? {})!);
    }
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
