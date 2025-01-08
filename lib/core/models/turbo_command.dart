import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_command_type.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_flag_type.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_option.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_tag_type.dart';
import 'package:ultra_wide_turbo_cli/core/extensions/arg_results_extension.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';
import 'package:ultra_wide_turbo_cli/core/services/archive_service.dart';
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
  String get name => _type.argument;

  @override
  Future<int> run() async {
    switch (_type) {
      case TurboCommandType.dartFix:
        // Find project root by looking for pubspec.yaml
        var currentDir = Directory.current;
        var foundRoot = false;
        while (currentDir.path != currentDir.parent.path) {
          if (await File('${currentDir.path}/pubspec.yaml').exists()) {
            foundRoot = true;
            break;
          }
          currentDir = currentDir.parent;
        }

        if (!foundRoot) {
          log.err('Could not find project root (pubspec.yaml)');
          return ExitCode.software.code;
        }

        // Check for lib and test directories in project root
        if (!await Directory('${currentDir.path}/lib').exists() &&
            !await Directory('${currentDir.path}/test').exists()) {
          log.err('Invalid directory structure: neither lib/ nor test/ directory exists');
          return ExitCode.software.code;
        }

        final script = _type.script(activeFlags: argResults?.activeFlags ?? {});
        if (script == null) return ExitCode.usage.code;

        // Store original directory
        final originalDir = Directory.current;
        // Change to project root
        Directory.current = currentDir;

        final response = await ScriptService.locate.run(script);

        // Change back to original directory
        Directory.current = originalDir;

        return response.when(
          success: (_) => ExitCode.success.code,
          fail: (_) => ExitCode.software.code,
        );
      case TurboCommandType.clone:
        final activeTags = argResults?.activeTags;
        if (activeTags == null || activeTags.isEmpty) {
          log.err('Missing tag. Usage: turbo clone <tag>');
          return ExitCode.usage.code;
        }

        for (final tag in activeTags) {
          switch (tag) {
            case TurboTagType.workspace:
              final options = argResults!.activeOptions;
              final targetDir = options[TurboOption.target] ?? TurboOption.target.defaultsTo;
              final force = argResults!.activeFlags.hasForce;

              final response = await WorkspaceService.locate.cloneWorkspace(
                targetDir: targetDir,
                force: force,
              );

              return response.when(
                success: (_) => ExitCode.success.code,
                fail: (_) => ExitCode.software.code,
              );
          }
        }
      case TurboCommandType.archive:
        final activeTags = argResults?.activeTags;
        if (activeTags == null || activeTags.isEmpty) {
          log.err('Missing tag. Usage: turbo archive <tag>');
          return ExitCode.usage.code;
        }

        for (final tag in activeTags) {
          switch (tag) {
            case TurboTagType.workspace:
              final options = argResults!.activeOptions;
              final targetDir = options[TurboOption.target] ?? './turbo-archive';
              final force = argResults!.activeFlags.hasForce;

              final response = await ArchiveService.locate.archiveWorkspace(
                targetDir: targetDir,
                force: force,
              );

              return response.when(
                success: (_) => ExitCode.success.code,
                fail: (_) => ExitCode.software.code,
              );
          }
        }
    }
    return ExitCode.usage.code;
  }

// 🎩 STATE --------------------------------------------------------------------------------- \\
// 🛠 UTIL ---------------------------------------------------------------------------------- \\
// 🧲 FETCHERS ------------------------------------------------------------------------------ \\
// 🏗️ HELPERS ------------------------------------------------------------------------------- \\
// 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
