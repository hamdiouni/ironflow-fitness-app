import 'package:flutter/widgets.dart';

/// Fallback stub implementation of [PlatformImage].
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
    return Builder(
      builder: (context) =>
          errorBuilder?.call(
            context,
            UnsupportedError('Local file images are unavailable on this platform.'),
            null,
          ) ??
          const SizedBox.shrink(),
    );
  }
}
