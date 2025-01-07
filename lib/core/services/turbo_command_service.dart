import 'dart:async';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:get_it/get_it.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_flags.dart';
import 'package:ultra_wide_turbo_cli/core/extensions/completer_extension.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';

class TurboCommandService extends CommandRunner<int> with TurboLogger {
  TurboCommandService() : super(Environment.packageName, Environment.packageTitle) {
    initialise();
  }

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static TurboCommandService get locate => GetIt.I.get();
  static void registerLazySingleton() => GetIt.I.registerLazySingleton(TurboCommandService.new);

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  Future<void> initialise() async {
    try {
      _initFlags();
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
    for (final flag in TurboFlags.values) {
      if (topLevelResults.flag(flag.pName)) {
        switch (flag) {
          case TurboFlags.verbose:
            log.level = Level.verbose;
            break;
          case TurboFlags.version:
            log.info(Environment.currentVersion);
            return ExitCode.success.code;
        }
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

  void _addFlag(
    String name, {
    String? abbr,
    String? help,
    bool? defaultsTo = false,
    bool negatable = true,
    void Function(bool)? callback,
    bool hide = false,
    List<String> aliases = const [],
  }) {
    try {
      argParser.addFlag(
        name,
        abbr: abbr,
        help: help,
        defaultsTo: defaultsTo,
        negatable: negatable,
        callback: callback,
        hide: hide,
        aliases: aliases,
      );
    } catch (error, _) {
      log.err(
        '$error caught while trying to add flag $name!',
      );
    }
  }

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void _initFlags() {
    for (final flag in TurboFlags.values) {
      _addFlag(
        flag.pName,
        help: flag.help,
        negatable: flag.negatable,
        abbr: flag.abbr,
      );
    }
  }
}
