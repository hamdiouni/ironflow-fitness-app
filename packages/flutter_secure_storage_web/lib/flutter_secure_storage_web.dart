/// Web library for flutter_secure_storage (Wasm-compatible dart:js_interop implementation).
library flutter_secure_storage_web;

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

@JS('window.localStorage')
external _JSStorage get _localStorage;

@JS('window.crypto')
external _JSCrypto get _crypto;

extension type _JSStorage._(JSObject _) implements JSObject {
  external int get length;
  external String? key(int index);
  external String? getItem(String key);
  external void setItem(String key, String value);
  external void removeItem(String key);
  external void clear();
}

extension type _JSCrypto._(JSObject _) implements JSObject {
  external JSUint8Array getRandomValues(JSUint8Array array);
  external _JSSubtleCrypto get subtle;
}

extension type _JSSubtleCrypto._(JSObject _) implements JSObject {
  external JSPromise<_JSCryptoKey> importKey(
    String format,
    JSUint8Array keyData,
    _AesGcmAlgorithm algorithm,
    bool extractable,
    JSArray<JSString> keyUsages,
  );

  external JSPromise<_JSCryptoKey> generateKey(
    _AesGcmAlgorithm algorithm,
    bool extractable,
    JSArray<JSString> keyUsages,
  );

  external JSPromise<JSArrayBuffer> exportKey(
    String format,
    _JSCryptoKey key,
  );

  external JSPromise<JSArrayBuffer> encrypt(
    _AesGcmAlgorithm algorithm,
    _JSCryptoKey key,
    JSUint8Array data,
  );

  external JSPromise<JSArrayBuffer> decrypt(
    _AesGcmAlgorithm algorithm,
    _JSCryptoKey key,
    JSUint8Array data,
  );
}

extension type _JSCryptoKey._(JSObject _) implements JSObject {}

extension type _AesGcmAlgorithm._(JSObject _) implements JSObject {
  external factory _AesGcmAlgorithm({
    required String name,
    required int length,
    required JSUint8Array iv,
  });
}

/// Web implementation of FlutterSecureStorage using Wasm-compatible dart:js_interop.
class FlutterSecureStorageWeb extends FlutterSecureStoragePlatform {
  static const _publicKey = 'publicKey';

  /// Registrar for FlutterSecureStorageWeb
  static void registerWith(Registrar registrar) {
    FlutterSecureStoragePlatform.instance = FlutterSecureStorageWeb();
  }

  String _scopedKey(String key, Map<String, String> options) =>
      '${options[_publicKey]!}.$key';

  /// Returns true if the storage contains the given [key].
  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) =>
      Future.value(_localStorage.getItem(_scopedKey(key, options)) != null);

  /// Deletes associated value for the given [key].
  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    _localStorage.removeItem(_scopedKey(key, options));
  }

  /// Deletes all keys with associated values for the configured publicKey prefix.
  @override
  Future<void> deleteAll({
    required Map<String, String> options,
  }) =>
      Future.sync(() {
        final prefix = '${options[_publicKey]!}.';
        final keysToRemove = <String>[];
        for (int i = 0; i < _localStorage.length; i++) {
          final k = _localStorage.key(i);
          if (k != null && k.startsWith(prefix)) {
            keysToRemove.add(k);
          }
        }
        for (final k in keysToRemove) {
          _localStorage.removeItem(k);
        }
      });

  /// Decrypts and returns the value for the given [key], or null if not found.
  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    final value = _localStorage.getItem(_scopedKey(key, options));
    return _decryptValue(value, options);
  }

  /// Decrypts and returns all keys with associated values.
  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async {
    final map = <String, String>{};
    final prefix = '${options[_publicKey]!}.';
    final entries = <MapEntry<String, String>>[];
    for (int j = 0; j < _localStorage.length; j++) {
      final k = _localStorage.key(j);
      if (k == null || !k.startsWith(prefix)) {
        continue;
      }
      final raw = _localStorage.getItem(k);
      if (raw != null) {
        entries.add(MapEntry(k, raw));
      }
    }
    for (final entry in entries) {
      final value = await _decryptValue(entry.value, options);
      if (value == null) {
        continue;
      }
      map[entry.key.substring(prefix.length)] = value;
    }
    return map;
  }

  _AesGcmAlgorithm _getAlgorithm(Uint8List iv) =>
      _AesGcmAlgorithm(name: 'AES-GCM', length: 256, iv: iv.toJS);

  JSArray<JSString> get _usages => <JSString>['encrypt'.toJS, 'decrypt'.toJS].toJS;

  Future<_JSCryptoKey> _getEncryptionKey(
    _AesGcmAlgorithm algorithm,
    Map<String, String> options,
  ) async {
    final key = options[_publicKey]!;
    final existing = _localStorage.getItem(key);

    if (existing != null) {
      final jwk = Uint8List.fromList(base64Decode(existing));
      return _crypto.subtle
          .importKey('raw', jwk.toJS, algorithm, false, _usages)
          .toDart;
    } else {
      final encryptionKey = await _crypto.subtle
          .generateKey(algorithm, true, _usages)
          .toDart;
      final jsonWebKey = await _crypto.subtle
          .exportKey('raw', encryptionKey)
          .toDart;
      _localStorage.setItem(
        key,
        base64Encode(jsonWebKey.toDart.asUint8List()),
      );
      return encryptionKey;
    }
  }

  /// Encrypts and saves the [key] with the given [value].
  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    final iv = _crypto.getRandomValues(Uint8List(12).toJS).toDart;
    final algorithm = _getAlgorithm(iv);
    final encryptionKey = await _getEncryptionKey(algorithm, options);
    final plainBytes = Uint8List.fromList(utf8.encode(value));

    final encryptedContent = await _crypto.subtle
        .encrypt(algorithm, encryptionKey, plainBytes.toJS)
        .toDart;

    final encoded =
        '${base64Encode(iv)}.${base64Encode(encryptedContent.toDart.asUint8List())}';
    _localStorage.setItem(_scopedKey(key, options), encoded);
  }

  Future<String?> _decryptValue(
    String? cypherText,
    Map<String, String> options,
  ) async {
    if (cypherText == null) {
      return null;
    }
    final parts = cypherText.split('.');
    if (parts.length != 2) {
      return null;
    }
    final iv = Uint8List.fromList(base64Decode(parts[0]));
    final algorithm = _getAlgorithm(iv);
    final decryptionKey = await _getEncryptionKey(algorithm, options);
    final value = Uint8List.fromList(base64Decode(parts[1]));

    final decryptedContent = await _crypto.subtle
        .decrypt(algorithm, decryptionKey, value.toJS)
        .toDart;

    return utf8.decode(decryptedContent.toDart.asUint8List());
  }
}
