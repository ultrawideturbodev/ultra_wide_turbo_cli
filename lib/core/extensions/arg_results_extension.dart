import 'package:args/args.dart';
import 'package:ultra_wide_turbo_cli/core/enums/turbo_flag_type.dart';
import 'package:ultra_wide_turbo_cli/core/extensions/list_extension.dart';

extension ArgResultsExtensionExtension on ArgResults {
  Set<TurboFlagType> get activeFlags {
    final flagArgumentsMap = TurboFlagType.values.toIdMap(
      (element) => element.argument,
    );
    return {
      for (final argument in arguments)
        if (flagArgumentsMap.containsKey(argument)) flagArgumentsMap[argument]!,
    };
  }
}
