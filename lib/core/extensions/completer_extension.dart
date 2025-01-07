import 'dart:async';

/// Extension on [Completer] that provides additional completion functionality.
///
/// Allows safely completing a [Completer] only if it hasn't been completed yet.
///
/// Example:
/// ```dart
/// final completer = Completer<String>();
///
/// // Won't throw if already completed
/// completer.completeIfNotComplete('value');
///
/// // Can also complete without value
/// completer.completeIfNotComplete();
/// ```
extension CompleterExtension<T> on Completer<T> {
  void completeIfNotComplete([FutureOr<T>? value]) {
    if (!isCompleted) {
      complete(value);
    }
  }
}
