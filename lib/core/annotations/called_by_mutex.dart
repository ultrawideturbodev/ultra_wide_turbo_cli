/// An annotation indicating that a method is called by a mutex.
///
/// Used to mark methods that are already protected by a mutex lock from their caller.
/// Adding another mutex inside these methods would be redundant and could lead to deadlocks.
///
/// Example:
/// ```dart
/// class DataStore {
///   final _mutex = Mutex();
///
///   Future<void> updateData() async {
///     await _mutex.protect(() => _updateDataInternal());
///   }
///
///   @CalledByMutex()
///   Future<void> _updateDataInternal() async {
///     // This method is protected by the mutex in updateData()
///     // Do not add another mutex here
///   }
/// }
/// ```
class CalledByMutex {
  /// Creates a new [CalledByMutex] annotation.
  const CalledByMutex();
}
