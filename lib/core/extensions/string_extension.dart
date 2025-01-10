extension StringExtension on String {
  /// Normalizes a string by:
  /// - Replacing all spaces with empty string
  /// - Converting to lowercase
  /// - Trimming whitespace
  ///
  /// ```dart
  /// final result = ' Hello World '.normalize(); // Returns 'helloworld'
  /// ```
  String normalize() => trim().toLowerCase().replaceAll(' ', '');
}
