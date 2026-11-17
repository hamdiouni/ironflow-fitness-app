import 'dart:convert';
import 'dart:typed_data';

/// Web implementation of [PlatformFileOps].
///
/// Browser apps run Hive over IndexedDB and lack raw filesystem access, so
/// local file writes/reads are safely stored in an in-memory virtual map when
/// needed for export/preview flows and pre-migration backups become no-ops.
class PlatformFileOps {
  const PlatformFileOps._();

  static final Map<String, Uint8List> _virtualFiles = <String, Uint8List>{};

  static bool get supportsLocalFileSystem => false;

  static String get pathSeparator => '/';

  static String joinPath(String base, String segment) {
    if (base.isEmpty) return segment;
    if (base.endsWith('/')) return '$base$segment';
    return '$base/$segment';
  }

  static Future<String?> resolveAppDocumentsPath() async => null;

  static Future<String?> resolveTemporaryPath() async => null;

  static Future<void> ensureDirectory(String directoryPath) async {}

  static Future<bool> fileExists(String path) async =>
      _virtualFiles.containsKey(path);

  static Future<int?> fileLength(String path) async =>
      _virtualFiles[path]?.length;

  static Future<Uint8List?> readBytesPrefix(String path, int maxBytes) async {
    final bytes = _virtualFiles[path];
    if (bytes == null) return null;
    final end = maxBytes < bytes.length ? maxBytes : bytes.length;
    return Uint8List.sublistView(bytes, 0, end);
  }

  static Future<Uint8List?> readBytes(String path) async => _virtualFiles[path];

  static Future<String?> readUtf8File(String path) async {
    final bytes = _virtualFiles[path];
    if (bytes == null) return null;
    return utf8.decode(bytes);
  }

  static Future<String?> writeUtf8File(
    String directoryPath,
    String fileName,
    String contents,
  ) async {
    final path = joinPath(directoryPath, fileName);
    _virtualFiles[path] = Uint8List.fromList(utf8.encode(contents));
    return path;
  }

  static Future<String?> writeBytesFile(
    String directoryPath,
    String fileName,
    List<int> bytes,
  ) async {
    final path = joinPath(directoryPath, fileName);
    _virtualFiles[path] = Uint8List.fromList(bytes);
    return path;
  }

  static Future<bool> copyFile(
    String sourcePath,
    String destinationPath,
  ) async {
    final src = _virtualFiles[sourcePath];
    if (src == null) return false;
    _virtualFiles[destinationPath] = Uint8List.fromList(src);
    return true;
  }

  static Future<void> deleteFileIfExists(String path) async {
    _virtualFiles.remove(path);
  }

  static Future<void> deleteDirectoryIfExists(String path) async {
    final prefix = path.endsWith('/') ? path : '$path/';
    _virtualFiles.removeWhere((k, _) => k.startsWith(prefix) || k == path);
  }

  static Future<List<String>> listFilesInDirectory(
    String directoryPath, {
    String? extensionFilter,
  }) async {
    final prefix = directoryPath.endsWith('/')
        ? directoryPath
        : '$directoryPath/';
    return _virtualFiles.keys.where((k) {
      if (!k.startsWith(prefix)) return false;
      return extensionFilter == null || k.endsWith(extensionFilter);
    }).toList();
  }
}
