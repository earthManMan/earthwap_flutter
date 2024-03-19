
import 'package:flutter/services.dart';

class NativeApiUtil {
  static const MethodChannel _channel = MethodChannel('native_api_util');

  // 카메라 열기
  static Future<void> openCamera() async {
    try {
      await _channel.invokeMethod('openCamera');
    } on PlatformException catch (e) {
      print("Failed to open camera: '${e.message}'.");
    }
  }

  // 앨범 열기
  static Future<void> openGallery() async {
    try {
      await _channel.invokeMethod('openGallery');
    } on PlatformException catch (e) {
      print("Failed to open gallery: '${e.message}'.");
    }
  }

  // 위치 정보 가져오기
  static Future<void> getLocation() async {
    try {
      await _channel.invokeMethod('getLocation');
    } on PlatformException catch (e) {
      print("Failed to get location: '${e.message}'.");
    }
  }

  // 다른 네이티브 기능 추가 가능
}
