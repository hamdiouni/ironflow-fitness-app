import 'dart:typed_data';

/// Cross-platform file operations abstraction (fallback stub implementation).
class PlatformFileOps {
  const PlatformFileOps._();

  static bool get supportsLocalFileSystem => false;

  static String get pathSeparator => '/';

  static String joinPath(String base, String segment) {
    if (base.isEmpty) return segment;
    if (base.endsWith('/') || base.endsWith('\\')) return '$base$segment';
    return '$base/$segment';
  }

  static Future<String?> resolveAppDocumentsPath() async => null;

  static Future<String?> resolveTemporaryPath() async => null;

  static Future<void> ensureDirectory(String directoryPath) async {}

  static Future<bool> fileExists(String path) async => false;

  static Future<int?> fileLength(String path) async => null;

  static Future<Uint8List?> readBytesPrefix(String path, int maxBytes) async =>
      null;

  static Future<Uint8List?> readBytes(String path) async => null;

  static Future<String?> readUtf8File(String path) async => null;

  static Future<String?> writeUtf8File(
    String directoryPath,
    String fileName,
    String contents,
  ) async =>
      null;

  static Future<String?> writeBytesFile(
    String directoryPath,
    String fileName,
    List<int> bytes,
  ) async =>
      null;

  static Future<bool> copyFile(String sourcePath, String destinationPath) async =>
      false;

  static Future<void> deleteFileIfExists(String path) async {}

  static Future<void> deleteDirectoryIfExists(String path) async {}

  static Future<List<String>> listFilesInDirectory(
    String directoryPath, {
    String? extensionFilter,
  }) async =>
      const [];
}
