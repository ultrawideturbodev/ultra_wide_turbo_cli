import 'dart:async';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:get_it/get_it.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';
import 'package:ultra_wide_turbo_cli/core/constants/k_version.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_command_type.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_flag_type.dart';
import 'package:ultra_wide_turbo_cli/core/extensions/arg_results_extension.dart';
import 'package:ultra_wide_turbo_cli/core/extensions/completer_extension.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';
import 'package:ultra_wide_turbo_cli/core/models/turbo_command.dart';

class CommandService extends CommandRunner<int> with TurboLogger {
  CommandService() : super(Environment.packageName, Environment.packageTitle) {
    initialise();
  }

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static CommandService get locate => GetIt.I.get();
  static void registerLazySingleton() => GetIt.I.registerLazySingleton(CommandService.new);

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  Future<void> initialise() async {
    try {
      _initGlobalFlags();
      _initCommands();
    } catch (error, _) {
      log.err(
        '$error caught while trying to initialise CommandService!',
      );
    } finally {
      _isReady.completeIfNotComplete();
    }
  }

  void dispose() {
    _isReady = Completer();
  }

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final argResults = parse(args);
      return await runCommand(argResults) ?? ExitCode.success.code;
    } on FormatException catch (e) {
      log
        ..err(e.message)
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      log
        ..err(e.message)
        ..info('')
        ..info(e.usage);
      return ExitCode.usage.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    for (final flag in topLevelResults.activeFlags) {
      switch (flag) {
        case TurboFlagType.verbose:
          log.level = Level.verbose;
          break;
        case TurboFlagType.version:
          log.info(packageVersion);
          return ExitCode.success.code;
        case TurboFlagType.clean:
        case TurboFlagType.force:
          break;
      }
    }
    return super.runCommand(topLevelResults);
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  var _isReady = Completer();

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  Future get isReady => _isReady.future;

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void _initGlobalFlags() {
    for (final flag in TurboFlagType.globalValues) {
      try {
        argParser.addFlag(
          flag.argument,
          abbr: flag.abbr,
          help: flag.help,
          negatable: flag.negatable,
        );
      } catch (error, _) {
        log.err(
          '$error caught while trying to add flag ${flag.argument}!',
        );
      }
    }
  }

  void _initCommands() {
    for (final command in TurboCommandType.values) {
      try {
        final turboCommand = TurboCommand(
          type: command,
        );

        // Add command-specific flags
        for (final flag in command.flags) {
          turboCommand.argParser.addFlag(
            flag.argument,
            help: flag.help,
            abbr: flag.abbr,
            negatable: flag.negatable,
          );
        }

        // Add command-specific options
        for (final option in command.options) {
          turboCommand.argParser.addOption(
            option.argument,
            abbr: option.abbr,
            help: option.help,
            defaultsTo: option.defaultsTo,
            valueHelp: option.valueHelp,
          );
        }

        addCommand(turboCommand);
      } catch (error, _) {
        log.err(
          '$error caught while trying to initialise command ${command.argument}!',
        );
      }
    }
  }
}
