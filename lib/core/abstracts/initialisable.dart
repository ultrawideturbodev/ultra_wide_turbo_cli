import 'dart:async';

import 'package:ultra_wide_turbo_cli/core/extensions/completer_extension.dart';

/// An abstract class that provides initialization and disposal mechanisms.
///
/// This class ensures that any subclass is initialized upon creation and can be
/// disposed of when no longer needed. It provides a mechanism to check if the
/// instance is ready or initialized.
///
/// Example usage:
/// ```dart
/// class MyService extends Initialisable {
///   @override
///   Future<void> initialise() async {
///     await super.initialise();
///     // Additional initialization code here
///   }
/// }
/// ```
abstract class Initialisable {
  /// Constructs an [Initialisable] instance and calls [initialise].
  Initialisable({bool tryAutoInitialise = true}) {
    if (tryAutoInitialise) {
      _tryAutoInitialise();
    }
  }

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\
  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  /// Initializes the instance.
  ///
  /// This method should be overridden by subclasses.
  /// Call to super marks the service as ready with [markAsReady].
  void initialise() => markAsReady();

  /// Attempts to automatically initialize the instance if it is not already initialized.
  ///
  /// This method checks the [isInitialised] flag and calls [initialise] if the instance
  /// is not yet initialized.
  void _tryAutoInitialise() {
    if (!isInitialised) {
      initialise();
    }
  }

  /// Disposes of the instance, resetting its state.
  void dispose() {
    _isInitialised = false;
    _isReady = Completer();
  }

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\

  var _isInitialised = false;
  var _isReady = Completer();

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// A [Future] that completes when the instance is ready.
  ///
  /// This can be awaited and is mostly used by outside classes that need to wait until this instance is ready.
  Future get isReady => _isReady.future;

  /// Indicates whether the instance is initialized.
  ///
  /// This is mostly used internally inside methods to check the initialization state.
  bool get isInitialised => _isInitialised;

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  /// Completes the [_isReady] completer if it is not already complete.
  ///
  /// This method is used to mark the instance as ready.
  void markAsReady() {
    _isInitialised = true;
    _isReady.completeIfNotComplete();
  }

  /// Asserts that the instance is initialized.
  ///
  /// Throws an [AssertionError] if the instance is not initialized before calling this method.
  void assertInitialised() {
    assert(isInitialised, 'The instance must be initialized before calling this method.');
  }

  /// Asserts that the instance is not disposed.
  ///
  /// Throws an [AssertionError] if the instance is disposed before calling this method.
  void assertNotDisposed() {
    assert(isInitialised, 'The instance must not be disposed before calling this method.');
  }

  /// Throws a [StateError] if the instance is not initialized.
  ///
  /// Ensures that the instance is initialized before proceeding with operations that require initialization.
  void throwIfNotInitialised() {
    if (!isInitialised) {
      throw StateError('The instance must be initialized before calling this method.');
    }
  }

  /// Throws a [StateError] if the instance is disposed.
  ///
  /// Ensures that the instance is not disposed before proceeding with operations that require an active instance.
  void throwIfDisposed() {
    if (!isInitialised) {
      throw StateError('The instance must not be disposed before calling this method.');
    }
  }
}
