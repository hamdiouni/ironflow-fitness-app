export 'platform_image_stub.dart'
    if (dart.library.io) 'platform_image_io.dart'
    if (dart.library.js_interop) 'platform_image_web.dart';
