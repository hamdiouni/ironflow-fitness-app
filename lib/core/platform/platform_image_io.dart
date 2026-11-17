import 'dart:io';

import 'package:flutter/widgets.dart';

/// Cross-platform image helper for `dart:io` targets.
class PlatformImage {
  const PlatformImage._();

  static Widget buildLocalOrNetwork(
    String path, {
    BoxFit fit = BoxFit.cover,
    Widget Function(BuildContext context, Object error, StackTrace? stackTrace)?
        errorBuilder,
  }) {
    if (path.startsWith('http://') ||
        path.startsWith('https://') ||
        path.startsWith('data:')) {
      return Image.network(path, fit: fit, errorBuilder: errorBuilder);
    }
    return Image.file(File(path), fit: fit, errorBuilder: errorBuilder);
  }
}
