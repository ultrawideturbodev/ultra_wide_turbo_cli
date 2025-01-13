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
import 'package:ultra_wide_turbo_cli/core/globals/log.dart';
import 'package:ultra_wide_turbo_cli/core/typedefs/update_current_def.dart';
import 'package:ultra_wide_turbo_cli/core/util/mutex.dart';

/// Manages local data persistence using Hive boxes.
///
/// Provides thread-safe storage operations with features like:
/// - Automatic initialization and cleanup
/// - User-specific storage
/// - Data sanity checks
/// - Mutex-protected operations
///
/// ```dart
/// // Initialize storage
/// await localStorageService.initialise();
///
/// // Access stored data
/// final settings = localStorageService.localStorageDto;
///
/// // Clean up
/// await localStorageService.dispose();
/// ```
class LocalStorageService extends Initialisable {
  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static LocalStorageService get locate => GetIt.I.get();
  static void registerLazySingleton() => GetIt.I.registerLazySingleton(
        LocalStorageService.new,
        dispose: (service) => service.dispose(),
      );

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  /// Initializes the local storage service.
  ///
  /// Sets up Hive boxes and performs initial data sanity checks.
  /// Uses mutex to ensure thread-safe initialization.
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

  /// Cleans up resources and resets storage to default state.
  ///
  /// Clears all boxes and resets the local storage DTO.
  @override
  Future<void> dispose() async {
    try {
      log.info('Disposing LocalStorageService');
      _localStorageDto = LocalStorageDto.defaultDto(userId: kValues.empty);
    } catch (error, _) {
      log.err(
        '$error caught while disposing LocalStorageService',
      );
    } finally {
      super.dispose();
    }
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  /// In-memory cache of opened Hive boxes.
  final Map<String, Box> _boxes = {};

  /// Current local storage settings.
  var _localStorageDto = LocalStorageDto.defaultDto(userId: '');

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\

  /// Mutex for thread-safe operations.
  final _mutex = Mutex();

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Retrieves local storage settings for a specific user.
  ///
  /// Returns null if no settings exist for the [userId].
  LocalStorageDto? _fetchLocalStorageDto({required String userId}) {
    final rLocalStorage = _getBoxContent(
      hiveBox: HiveBox.localStorageDto,
      userId: userId,
    );
    return rLocalStorage == null
        ? null
        : LocalStorageDto.fromJson(rLocalStorage);
  }

  /// Current local storage settings.
  LocalStorageDto get localStorageDto => _localStorageDto;

  // 🏗 HELPERS ------------------------------------------------------------------------------- \\

  /// Ensures local storage settings match the current user.
  ///
  /// Creates default settings if none exist for the [userId].
  Future<void> _localStorageSanityCheck({required String userId}) async {
    final localStorageDto = _localStorageDto;
    if (localStorageDto.id != userId) {
      final hasLocalStorage = _hasBox(hiveBox: HiveBox.localStorageDto);
      final localStorageDto =
          hasLocalStorage ? _fetchLocalStorageDto(userId: userId) : null;
      if (localStorageDto == null) {
        await updateLocalStorage(
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

  /// Gets or initializes a Hive box.
  ///
  /// Returns existing box if available, otherwise initializes a new one.
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

  /// Initializes a new Hive box and updates local storage if needed.
  Future<Box<T>> _initBox<T>({
    required HiveBox hiveBox,
    required String userId,
  }) async {
    final box = await _openBox<T>(hiveBox: hiveBox);
    _addBoxInMemory(hiveBox: hiveBox, box: box);
    switch (hiveBox) {
      case HiveBox.localStorageDto:
        try {
          final rLocalStorage =
              _getBoxContent(hiveBox: hiveBox, userId: userId);
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

  /// Checks if a Hive box is already opened.
  bool _hasBox({required HiveBox hiveBox}) => _boxes.containsKey(hiveBox.id);

  /// Gets an opened Hive box, assuming it exists.
  Box<T> _forceGetBox<T>({required HiveBox hiveBox}) =>
      _boxes[hiveBox.id] as Box<T>;

  /// Opens a new Hive box.
  Future<Box<T>> _openBox<T>({required HiveBox hiveBox}) async {
    return await Hive.openBox<T>(
      hiveBox.id,
    );
  }

  /// Adds a box to the in-memory cache.
  void _addBoxInMemory<T>({
    required HiveBox hiveBox,
    required Box<T> box,
  }) {
    _boxes[hiveBox.id] = box;
  }

  /// Retrieves content from a Hive box for a specific user.
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

  /// Updates content in a Hive box for a specific user.
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

  /// Initializes Hive directory and registers adapters.
  @CalledByMutex()
  Future<void> _tryInitDirAndAdapters() async {
    try {
      final homeDir =
          Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
      if (homeDir == null) {
        throw Exception('Could not find home directory');
      }
      final appDir = Directory('$homeDir/.ultra_wide_turbo_cli');
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }
      Hive.init(appDir.path);
      _registerAdapters();
    } catch (error, _) {
      log.err(
        'Unexpected ${error.runtimeType} caught while initialising hive box',
      );
    }
  }

  /// Registers all Hive type adapters.
  @CalledByMutex()
  void _registerAdapters() {
    for (final hiveAdapter in HiveAdapters.values) {
      if (!Hive.isAdapterRegistered(hiveAdapter.index)) {
        hiveAdapter.registerAdapter();
      }
    }
  }

  /// Updates local storage settings with thread safety.
  ///
  /// Uses [dtoUpdater] to modify the current settings.
  /// Performs sanity checks unless disabled via parameters.
  Future<TurboResponse> updateLocalStorage(
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
      await _updateBoxContent(
        hiveBox: hiveBox,
        value: newValue,
        userId: userId,
      );
      return const TurboResponse.successAsBool();
    } catch (error, _) {
      log.err(
        '$error caught while updating local device settings',
      );
      return TurboResponse.fail(error: error);
    }
  }

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
