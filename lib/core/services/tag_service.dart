import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/initialisable.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/tag_dto.dart';
import 'package:ultra_wide_turbo_cli/core/extensions/iterable_extension.dart';
import 'package:ultra_wide_turbo_cli/core/extensions/string_extension.dart';
import 'package:ultra_wide_turbo_cli/core/globals/g_auth.dart';
import 'package:ultra_wide_turbo_cli/core/globals/g_self.dart';
import 'package:ultra_wide_turbo_cli/core/services/local_storage_service.dart';

class TagService extends Initialisable {
  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static TagService get locate => GetIt.I.get();
  static void registerLazySingleton() => GetIt.I.registerLazySingleton(TagService.new);

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final _localStorageService = LocalStorageService.locate;

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise() async {
    _tagsPerId.addAll(_localStorageService.localStorageDto.tags.toIdMap((element) => element.id));
    super.initialise();
  }

  @override
  Future<void> dispose() async {
    _tagsPerId.clear();
    super.dispose();
  }

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final Map<String, TagDto> _tagsPerId = {};

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  List<TagDto> get tagsSortedById =>
      _tagsPerId.values.toList()..sort((a, b) => a.id.compareTo(b.id));
  bool exists({required String name}) => _tagsPerId[name.normalize()] != null;

  TagDto? getTagById({required String id}) => _tagsPerId[id];

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  Future<TurboResponse> createTag({required TagDto tag}) async => (await _localStorageService.updateLocalStorage(
        (current) => current.copyWith(
          tags: (current) => current..add(tag),
        ),
        userId: gUserId,
      ))
          .when(
        success: (response) {
          _tagsPerId[tag.id] = tag;
          return response;
        },
        fail: gSelf,
      );
}
