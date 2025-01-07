import 'package:args/args.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_flag_type.dart';

extension ArgResultsExtensionExtension on ArgResults {
  Set<TurboFlagType> get activeFlags {
    return {
      for (final rFlag in TurboFlagType.values)
        if (hasFlag(rFlag)) rFlag,
    };
  }

  bool hasFlag(TurboFlagType turboFlagType) {
    try {
      return flag(turboFlagType.argument);
    } catch (error, _) {
      return false;
    }
  }
}
