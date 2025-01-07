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

  Map<TurboOption, dynamic> get activeOptions {
    return {
      for (final option in TurboOption.values)
        if (wasParsed(option.name)) option: this[option.name],
    };
  }

  T? getOption<T>(TurboOption option) => this[option.name] as T?;
}
