import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/initialisable.dart';
import 'package:ultra_wide_turbo_cli/core/abstracts/local_storage_value.dart';
import 'package:ultra_wide_turbo_cli/core/annotations/called_by_mutex.dart';
import 'package:ultra_wide_turbo_cli/core/constants/k_values.dart';
import 'package:ultra_wide_turbo_cli/core/dtos/local_storage_dto.dart';
import 'package:ultra_wide_turbo_cli/core/enums/hive_adapters.dart';
import 'package:ultra_wide_turbo_cli/core/enums/hive_box.dart';
import 'package:ultra_wide_turbo_cli/core/globals/g_auth.dart';
import 'package:ultra_wide_turbo_cli/core/mixins/turbo_logger.dart';
import 'package:ultra_wide_turbo_cli/core/typedefs/update_current_def.dart';
import 'package:ultra_wide_turbo_cli/core/util/mutex.dart';

class LocalStorageService extends Initialisable with TurboLogger {
  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static LocalStorageService get locate => GetIt.I.get();
  static void registerLazySingleton() => GetIt.I.registerLazySingleton(LocalStorageService.new);

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise() async {
    await _mutex.lockAndRun(
      run: (unlock) async {
        try {
          await _tryInitDirAndAdapters();
          await _localStorageSanityCheck(userId: gUserId);
        } catch (error) {
          log.err(
            'Exception caught while initialising local storage service',
          );
        } finally {
          super.initialise();
          unlock();
        }
      },
    );
  }

  @override
  Future<void> dispose() async {
    try {
      log.info('Disposing LocalStorageService');
      _localStorageDto = LocalStorageDto.defaultDto(userId: kEmpty);
      await resetBoxes();
    } catch (error, _) {
      log.err(
        '$error caught while disposing LocalStorageService',
      );
    } finally {
      super.dispose();
    }
  }

  Future<void> resetBoxes() async {
    log.info('Resetting boxes');
    await _mutex.lockAndRun(
      run: (unlock) async {
        try {
          for (final box in _boxes.values) {
            try {
              await box.clear();
            } catch (error, _) {
              log.err(
                '$error caught while clearing box',
              );
            }
          }
          _boxes.clear();
        } catch (error, _) {
          log.err(
            'Exception caught while resetting boxes',
          );
        } finally {
          unlock();
        }
      },
    );
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final Map<String, Box> _boxes = {};
  var _localStorageDto = LocalStorageDto.defaultDto(userId: '');

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  final _mutex = Mutex();

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  LocalStorageDto? _fetchLocalStorageDto({required String userId}) {
    final rLocalStorage = _getBoxContent(
      hiveBox: HiveBox.localStorageDto,
      userId: userId,
    );
    return rLocalStorage == null ? null : LocalStorageDto.fromJson(rLocalStorage);
  }

  LocalStorageDto get localStorageDto => _localStorageDto;

  // 🏗 HELPERS ------------------------------------------------------------------------------- \\

  Future<void> _localStorageSanityCheck({required String userId}) async {
    final localStorageDto = _localStorageDto;
    if (localStorageDto.id != userId) {
      final hasLocalStorage = _hasBox(hiveBox: HiveBox.localStorageDto);
      final localStorageDto = hasLocalStorage ? _fetchLocalStorageDto(userId: userId) : null;
      if (localStorageDto == null) {
        await _updateLocalStorage(
          (current) => LocalStorageDto.defaultDto(userId: userId),
          userId: userId,
          doSanityCheck: false,
          doAssertInitialised: false,
        );
      } else {
        _localStorageDto = localStorageDto;
      }
    }
  }

  FutureOr<Box<T>> _getBox<T>({
    required HiveBox hiveBox,
    required String userId,
  }) async {
    if (_hasBox(hiveBox: hiveBox)) {
      return _forceGetBox<T>(hiveBox: hiveBox);
    }
    final box = await _initBox<T>(hiveBox: hiveBox, userId: userId);
    return box;
  }

  Future<Box<T>> _initBox<T>({required HiveBox hiveBox, required String userId}) async {
    final box = await _openBox<T>(hiveBox: hiveBox);
    _addBoxInMemory(hiveBox: hiveBox, box: box);
    switch (hiveBox) {
      case HiveBox.localStorageDto:
        try {
          final rLocalStorage = _getBoxContent(hiveBox: hiveBox, userId: userId);
          if (rLocalStorage != null) {
            _localStorageDto = LocalStorageDto.fromJson(rLocalStorage);
          }
        } catch (error, _) {
          log.err(
            '$error caught while updating local device settings from box',
          );
        }
    }
    return box;
  }

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  bool _hasBox({required HiveBox hiveBox}) => _boxes.containsKey(hiveBox.id);
  Box<T> _forceGetBox<T>({required HiveBox hiveBox}) => _boxes[hiveBox.id] as Box<T>;

  Future<Box<T>> _openBox<T>({required HiveBox hiveBox}) async {
    return await Hive.openBox<T>(
      hiveBox.id,
    );
  }

  void _addBoxInMemory<T>({
    required HiveBox hiveBox,
    required Box<T> box,
  }) {
    _boxes[hiveBox.id] = box;
  }

  Map<String, dynamic>? _getBoxContent({
    required HiveBox hiveBox,
    required String userId,
  }) {
    final source = _forceGetBox(hiveBox: hiveBox).get(
      hiveBox.documentId(id: userId),
    );
    if (source == null) {
      return null;
    }
    return jsonDecode(
      source,
    );
  }

  Future<void> _updateBoxContent<T extends LocalStorageValue>({
    required HiveBox hiveBox,
    required T value,
    required String userId,
  }) async {
    final box = await _getBox(hiveBox: hiveBox, userId: userId);
    await box.put(
      hiveBox.documentId(id: userId),
      value.toJsonString,
    );
  }

  @CalledByMutex()
  Future<void> _tryInitDirAndAdapters() async {
    try {
      final appDir = Directory.current;
      Hive.init(appDir.path);
      _registerAdapters();
    } catch (error, _) {
      log.err(
        'Unexpected ${error.runtimeType} caught while initialising hive box',
      );
    }
  }

  @CalledByMutex()
  void _registerAdapters() {
    for (final hiveAdapter in HiveAdapters.values) {
      if (!Hive.isAdapterRegistered(hiveAdapter.index)) {
        hiveAdapter.registerAdapter();
      }
    }
  }

  Future<TurboResponse> _updateLocalStorage(
    UpdateCurrentDef<LocalStorageDto> dtoUpdater, {
    required String userId,
    bool doSanityCheck = true,
    bool doAssertInitialised = true,
  }) async {
    if (doAssertInitialised) {
      assertInitialised();
    }
    if (doSanityCheck) {
      await _localStorageSanityCheck(userId: userId);
    }
    log.info('Updating local device settings');
    try {
      const hiveBox = HiveBox.localStorageDto;
      final newValue = dtoUpdater(_localStorageDto);
      _localStorageDto = newValue;
      await _updateBoxContent(hiveBox: hiveBox, value: newValue, userId: userId);
      return const TurboResponse.emptySuccess();
    } catch (error, _) {
      log.err(
        '$error caught while updating local device settings',
      );
      return TurboResponse.fail(error: error);
    }
  }

// 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  Future<TurboResponse> addTag({required String tag}) async => await _updateLocalStorage(
        (current) => current.copyWith(
          tags: (current) => current..add(tag),
        ),
        userId: gUserId,
      );

  Future<TurboResponse> removeTag({required String tag}) async => await _updateLocalStorage(
        (current) => current.copyWith(
          tags: (current) => current..remove(tag),
        ),
        userId: gUserId,
      );

  Future<TurboResponse> clearTags() async => await _updateLocalStorage(
        (current) => current.copyWith(
          tags: (current) => current..clear(),
        ),
        userId: gUserId,
      );
}
