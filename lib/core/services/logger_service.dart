import 'package:get_it/get_it.dart';
import 'package:mason_logger/mason_logger.dart';

class LoggerService {
  static LoggerService get locate => GetIt.I.get();
  static void registerSingleton() => GetIt.I.registerSingleton<LoggerService>(LoggerService());

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final Logger log = Logger();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}