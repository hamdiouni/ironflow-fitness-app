import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/platform/platform_file_ops.dart';
import 'package:progression_tracker/core/platform/platform_file_ops_stub.dart'
    as stub_ops;
import 'package:progression_tracker/core/platform/platform_file_ops_web.dart'
    as web_ops;
import 'package:progression_tracker/core/platform/platform_image.dart';
import 'package:progression_tracker/core/platform/platform_image_stub.dart'
    as stub_img;
import 'package:progression_tracker/core/platform/platform_image_web.dart'
    as web_img;

void main() {
  group('PlatformFileOps & PlatformImage Web/IO compatibility (Wave 3.5)', () {
    setUp(() {
      web_ops.PlatformFileOps.clearVirtualFilesForTest();
    });

    test('PlatformFileOps IO operations handle export, recursive listing, and extractPath', () async {
      final tempDir = await Directory.systemTemp.createTemp('plat_ops_io_');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      expect(PlatformFileOps.supportsLocalFileSystem, isTrue);
      expect(PlatformFileOps.extractPath(tempDir), tempDir.path);
      expect(PlatformFileOps.extractPath(tempDir.path), tempDir.path);

      final nestedDir = PlatformFileOps.joinPath(tempDir.path, 'sub');
      await PlatformFileOps.writeUtf8File(tempDir.path, 'root.json', '{"ok":true}');
      await PlatformFileOps.writeUtf8File(nestedDir, 'nested.csv', 'a,b\n1,2');

      final directJson = await PlatformFileOps.listFilesInDirectory(
        tempDir.path,
        extensionFilter: '.json',
      );
      expect(directJson.length, 1);
      expect(directJson.single, endsWith('root.json'));

      final allFiles = await PlatformFileOps.listFilesRecursively(tempDir.path);
      expect(allFiles.length, 2);

      final modified = await PlatformFileOps.fileLastModified(directJson.single);
      expect(modified, isNotNull);

      final bytes = await PlatformFileOps.readBytes(directJson.single);
      expect(utf8.decode(bytes!), '{"ok":true}');
    });

    test('Web PlatformFileOps supports virtual exports, snapshots, and recursive directory traversal without dart:io', () async {
      expect(web_ops.PlatformFileOps.supportsLocalFileSystem, isFalse);
      expect(await web_ops.PlatformFileOps.resolveAppDocumentsPath(), isNull);
      expect(
        await web_ops.PlatformFileOps.resolveExportDirectoryPath(),
        '/virtual/documents',
      );

      final exported = await web_ops.PlatformFileOps.writeExportUtf8File(
        'backup.json',
        '{"exported":true}',
      );
      expect(exported, '/virtual/documents/backup.json');
      expect(await web_ops.PlatformFileOps.fileExists(exported), isTrue);
      expect(await web_ops.PlatformFileOps.fileLength(exported), 17);
      expect(
        await web_ops.PlatformFileOps.readUtf8File(exported),
        '{"exported":true}',
      );
      expect(await web_ops.PlatformFileOps.fileLastModified(exported), isNotNull);

      await web_ops.PlatformFileOps.writeUtf8File(
        '/virtual/documents/safety_snapshots',
        'safety_snapshot_1.json',
        '{}',
      );

      // listFilesInDirectory lists direct children only.
      final topJson = await web_ops.PlatformFileOps.listFilesInDirectory(
        '/virtual/documents',
        extensionFilter: '.json',
      );
      expect(topJson, ['/virtual/documents/backup.json']);

      // listFilesRecursively traverses subdirectories cleanly for ZIP exports.
      final recursive = await web_ops.PlatformFileOps.listFilesRecursively(
        '/virtual/documents',
      );
      expect(
        recursive,
        containsAll(<String>[
          '/virtual/documents/backup.json',
          '/virtual/documents/safety_snapshots/safety_snapshot_1.json',
        ]),
      );

      expect(
        () => stub_ops.PlatformFileOps.resolveExportDirectoryPath(),
        throwsUnsupportedError,
      );
    });

    testWidgets('PlatformImage web/stub gracefully falls back via errorBuilder for local file paths', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PlatformImage.buildLocalOrNetwork(
                  '/nonexistent/photo.png',
                  errorBuilder: (_, _, _) => const Text('fallback-io'),
                ),
                web_img.PlatformImage.buildLocalOrNetwork(
                  '/local/photo.png',
                  errorBuilder: (_, _, _) => const Text('fallback-web'),
                ),
                stub_img.PlatformImage.buildLocalOrNetwork(
                  '/local/photo.png',
                  errorBuilder: (_, _, _) => const Text('fallback-stub'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('fallback-web'), findsOneWidget);
      expect(find.text('fallback-stub'), findsOneWidget);
    });
  });
}
