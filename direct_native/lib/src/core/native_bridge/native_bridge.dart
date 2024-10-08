// lib/src/core/native_bridge.dart

import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

final DynamicLibrary nativeLib = Platform.isAndroid
    ? ffi.DynamicLibrary.open("libdirect_native.so")
    : ffi.DynamicLibrary.process();

typedef NativeInitializeFunc = ffi.Pointer<ffi.Uint8> Function();
typedef DartInitializeFunc = ffi.Pointer<ffi.Uint8> Function();

typedef NativeNotifyFunc = ffi.Void Function(ffi.Int32);
typedef DartNotifyFunc = void Function(int);

class MethodChannel {
  static const int BUFFER_SIZE = 1024 * 1024; // 1MB buffer
  static late ffi.Pointer<ffi.Uint8> _sharedBuffer;
  static late Uint8List _dartView;

  static final DartInitializeFunc _nativeInitialize = nativeLib
      .lookup<ffi.NativeFunction<NativeInitializeFunc>>('initialize')
      .asFunction();

  static final DartNotifyFunc _nativeNotify = nativeLib
      .lookup<ffi.NativeFunction<NativeNotifyFunc>>('notifyNative')
      .asFunction();

  static void initialize() {
    _sharedBuffer = _nativeInitialize();
    _dartView = _sharedBuffer.asTypedList(BUFFER_SIZE);
  }

  static void invokeMethod(String method, Map<String, dynamic> arguments) {
    final message = {'method': method, 'arguments': arguments};
    final encoded = utf8.encode(json.encode(message));
    _dartView.setAll(0, encoded);
    _nativeNotify(encoded.length);
  }
}

class NativeBridge {
  static void render(String uiDescription) {
    MethodChannel.invokeMethod('render', {'uiDescription': uiDescription});
  }
}