import 'dart:async';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:get_it/get_it.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_command_type.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_flag_type.dart';
import 'package:ultra_wide_turbo_cli/core/extensions/arg_results_extension.dart';
import 'package:ultra_wide_turbo_cli/core/extensions/completer_extension.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';
import 'package:ultra_wide_turbo_cli/core/models/turbo_command.dart';
import 'package:ultra_wide_turbo_cli/core/services/update_service.dart';

/// Handles CLI command registration, parsing, and execution.
///
/// Manages global flags, command-specific flags, and command execution.
/// Extends [CommandRunner] to provide a structured CLI interface.
///
/// ```dart
/// // Register and run commands
/// final runner = CommandService();
/// await runner.run(['command', '--flag']);
///
/// // Check version
/// await runner.run(['--version']);
///
/// // Get help
/// await runner.run(['--help']);
/// ```
class CommandService extends CommandRunner<int> with TurboLogger {
  CommandService() : super(Environment.packageName, Environment.packageTitle) {
    initialise();
  }

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static CommandService get locate => GetIt.I.get();
  static void registerLazySingleton() =>
      GetIt.I.registerLazySingleton(CommandService.new);

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  /// Initializes the command service by setting up flags and commands.
  ///
  /// Sets up global flags like --version and --verbose.
  /// Registers all available commands from [TurboCommandType].
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

  /// Resets the service to its initial state.
  void dispose() {
    _isReady = Completer();
  }

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  /// Runs the command specified by [args].
  ///
  /// Parses the arguments and executes the corresponding command.
  /// Handles format and usage exceptions with appropriate error messages.
  ///
  /// ```dart
  /// // Run a command
  /// final exitCode = await run(['clone', '--target', 'path']);
  ///
  /// // Run with verbose logging
  /// final exitCode = await run(['command', '--verbose']);
  /// ```
  @override
  Future<int> run(Iterable<String> args) async {
    try {
      if (args.contains('--version')) {
        final version = await UpdateService.locate.getCurrentVersion();
        log.info(version);
        return ExitCode.success.code;
      }
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
    } catch (error) {
      log.err('$error');
      return ExitCode.software.code;
    }
  }

  /// Processes global flags and runs the specified command.
  ///
  /// Handles flags like --verbose and --version before command execution.
  /// Returns the command's exit code or [ExitCode.success] for version flag.
  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    for (final flag in topLevelResults.activeFlags) {
      switch (flag) {
        case TurboFlagType.verbose:
          log.level = Level.verbose;
          break;
        case TurboFlagType.version:
          final version = await UpdateService.locate.getCurrentVersion();
          log.info(version);
          return ExitCode.success.code;
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

  /// Future that completes when the service is ready to handle commands.
  Future get isReady => _isReady.future;

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  /// Initializes global flags available to all commands.
  ///
  /// Adds flags like --version and --verbose that can be used
  /// with any command or directly with the CLI.
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

  /// Initializes all available commands from [TurboCommandType].
  ///
  /// Creates command instances and sets up their flags and options.
  /// Each command is registered with the command runner.
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
