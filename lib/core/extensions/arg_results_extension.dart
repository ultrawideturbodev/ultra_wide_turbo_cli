import 'package:args/args.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_flag_type.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_option.dart';

extension ArgResultsExtension on ArgResults {
  Set<TurboFlagType> get activeFlags {
    return {
      for (final flag in TurboFlagType.values)
        if (hasFlag(flag)) flag,
    };
  }

  bool hasFlag(TurboFlagType turboFlagType) {
    try {
      return flag(turboFlagType.argument);
    } catch (error, _) {
      return false;
    }
  }

  Map<TurboOption, String> get activeOptions {
    return {
      for (final option in TurboOption.values)
        if (hasOption(option)) option: this[option.argument] as String,
    };
  }

  bool hasOption(TurboOption option) {
    try {
      return wasParsed(option.argument);
    } catch (_) {
      return false;
    }
  }
}
