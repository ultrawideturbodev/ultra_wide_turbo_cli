import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_clone_type.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_command_type.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_option.dart';
import 'package:ultra_wide_turbo_cli/core/extensions/arg_results_extension.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';
import 'package:ultra_wide_turbo_cli/core/services/script_service.dart';
import 'package:ultra_wide_turbo_cli/core/services/workspace_service.dart';

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
        final script = _type.script(activeFlags: argResults?.activeFlags ?? {});
        if (script == null) return ExitCode.usage.code;
        return ScriptService.locate.run(script);
      case TurboCommandType.clone:
        if (argResults?.rest.isEmpty ?? true) {
          log.err('Missing clone type. Usage: turbo clone <type>');
          return ExitCode.usage.code;
        }

        final cloneTypeArg = argResults!.rest.first;
        switch (cloneTypeArg) {
          case 'workspace':
            final targetDir = argResults!.getOption<String>(TurboOption.target)!;
            final force = argResults!.getOption<bool>(TurboOption.force)!;

            final success = await WorkspaceService.locate.cloneWorkspace(
              targetDir: targetDir,
              force: force,
            );

            return success ? ExitCode.success.code : ExitCode.software.code;
          default:
            throw UsageException(
              'Invalid clone type: $cloneTypeArg',
              'Available types:\n${TurboCloneType.values.map((t) => '- ${t.pName}: ${t.help}').join('\n')}',
            );
        }
    }
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
