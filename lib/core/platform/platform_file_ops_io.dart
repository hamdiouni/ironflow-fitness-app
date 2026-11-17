import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Cross-platform file operations implementation for `dart:io` targets
/// (Android, iOS, Windows, macOS, Linux).
class PlatformFileOps {
  const PlatformFileOps._();

  static bool get supportsLocalFileSystem => true;

  static String get pathSeparator => Platform.pathSeparator;

  static String joinPath(String base, String segment) {
    if (base.isEmpty) return segment;
    if (base.endsWith('/') || base.endsWith('\\')) return '$base$segment';
    return '$base${Platform.pathSeparator}$segment';
  }

  static Future<String?> resolveAppDocumentsPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<String?> resolveTemporaryPath() async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  static Future<void> ensureDirectory(String directoryPath) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  static Future<bool> fileExists(String path) => File(path).exists();

  static Future<int?> fileLength(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return file.length();
  }

  static Future<Uint8List?> readBytesPrefix(String path, int maxBytes) async {
    final file = File(path);
    if (!await file.exists()) return null;
    final raf = await file.open(mode: FileMode.read);
    try {
      final bytes = await raf.read(maxBytes);
      return bytes;
    } finally {
      await raf.close();
    }
  }

  static Future<Uint8List?> readBytes(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  static Future<String?> readUtf8File(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  static Future<String?> writeUtf8File(
    String directoryPath,
    String fileName,
    String contents,
  ) async {
    await ensureDirectory(directoryPath);
    final file = File(joinPath(directoryPath, fileName));
    await file.writeAsString(contents, flush: true);
    return file.path;
  }

  static Future<String?> writeBytesFile(
    String directoryPath,
    String fileName,
    List<int> bytes,
  ) async {
    await ensureDirectory(directoryPath);
    final file = File(joinPath(directoryPath, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  static Future<bool> copyFile(
    String sourcePath,
    String destinationPath,
  ) async {
    final src = File(sourcePath);
    if (!await src.exists()) return false;
    final dst = File(destinationPath);
    await ensureDirectory(dst.parent.path);
    final expectedLength = await src.length();
    await src.copy(destinationPath);
    final copied = File(destinationPath);
    return await copied.exists() && await copied.length() == expectedLength;
  }

  static Future<void> deleteFileIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> deleteDirectoryIfExists(String path) async {
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  static Future<List<String>> listFilesInDirectory(
    String directoryPath, {
    String? extensionFilter,
  }) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return const [];
    final results = <String>[];
    await for (final entity in dir.list()) {
      if (entity is File) {
        if (extensionFilter == null || entity.path.endsWith(extensionFilter)) {
          results.add(entity.path);
        }
      }
    }
    return results;
  }
}
