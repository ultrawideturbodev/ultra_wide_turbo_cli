import 'dart:io';

import 'package:path/path.dart';

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

  /// Validates the tag name format.
  ///
  /// Tag name requirements:
  /// - Must be between 2 and 50 characters
  /// - Can only contain letters, numbers, hyphens, and underscores
  /// - Cannot start or end with a hyphen or underscore
  bool get isValidTagName {
    if (length < 2 || length > 50) return false;
    if (startsWith('-') || startsWith('_')) return false;
    if (endsWith('-') || endsWith('_')) return false;
    return RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(this);
  }

  /// Validates the directory path.
  ///
  /// Directory path must:
  /// - Be an absolute path
  /// - Not contain invalid characters
  /// - Be accessible
  bool get isValidDirectoryPath {
    if (!isAbsolute(this)) return false;
    try {
      final dir = Directory(this);
      return dir.existsSync() && dir.statSync().type == FileSystemEntityType.directory;
    } catch (e) {
      return false;
    }
  }
}
