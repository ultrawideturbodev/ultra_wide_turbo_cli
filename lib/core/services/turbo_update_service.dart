import 'package:pub_updater/pub_updater.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/environment.dart';

class TurboUpdateService {
  TurboUpdateService._();
  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static final TurboUpdateService _instance = TurboUpdateService._();
  static TurboUpdateService get locate => _instance;

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final _pubUpdater = PubUpdater();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  Future<String> get currentVersion => _pubUpdater.getLatestVersion(Environment.packageName);

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
