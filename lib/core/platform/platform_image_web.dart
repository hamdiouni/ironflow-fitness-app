import 'package:flutter/widgets.dart';

/// Web implementation of [PlatformImage] without `dart:io` imports.
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
        path.startsWith('data:') ||
        path.startsWith('blob:')) {
      return Image.network(path, fit: fit, errorBuilder: errorBuilder);
    }
    return Builder(
      builder: (context) =>
          errorBuilder?.call(
            context,
            UnsupportedError('Local file image paths are unavailable on Web.'),
            null,
          ) ??
          const SizedBox.shrink(),
    );
  }
}
