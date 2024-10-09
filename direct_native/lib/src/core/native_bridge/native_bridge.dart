import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

final ffi.DynamicLibrary nativeLib = Platform.isAndroid
    ? ffi.DynamicLibrary.open("libdirect_native.so")
    : ffi.DynamicLibrary.process();

typedef NativeInitializeFunc = ffi.Pointer<ffi.Uint8> Function();
typedef DartInitializeFunc = ffi.Pointer<ffi.Uint8> Function();

typedef NativeRenderFunc = ffi.Void Function(ffi.Int32);
typedef DartRenderFunc = void Function(int);

class NativeBridge {
  static const int BUFFER_SIZE = 1024 * 1024; // 1MB buffer
  static late ffi.Pointer<ffi.Uint8> _sharedBuffer;
  static late Uint8List _dartView;

  static final DartInitializeFunc _nativeInitialize = nativeLib
      .lookup<ffi.NativeFunction<NativeInitializeFunc>>('initialize')
      .asFunction();

  static final DartRenderFunc _nativeRender = nativeLib
      .lookup<ffi.NativeFunction<NativeRenderFunc>>('render')
      .asFunction();

  static void initialize() {
    _sharedBuffer = _nativeInitialize();
    _dartView = _sharedBuffer.asTypedList(BUFFER_SIZE);
  }

  static void render(Map<String, dynamic> uiDescription) {
    final jsonString = json.encode(uiDescription);
    final utf8Data = utf8.encode(jsonString);
    _dartView.setAll(0, utf8Data);
    _nativeRender(utf8Data.length);
  }
}