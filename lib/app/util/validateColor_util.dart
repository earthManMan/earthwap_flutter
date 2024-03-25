import 'package:flutter/material.dart';

Color hexStringToColor(String hexColor) {
  if (hexColor == 'null') return Colors.red;
  // HEX 색상 코드에서 # 기호를 제거하고 앞에 0xFF를 추가합니다.
  final hexCode = hexColor.replaceAll('#', '0xFF');

  // int.tryParse를 사용하여 HEX 코드를 정수로 변환하고 오류를 처리합니다.
  final intColor = int.tryParse(hexCode);

  if (intColor != null) {
    // 정상적으로 정수로 변환된 경우 Color 객체로 반환합니다.
    return Color(intColor);
  } else {
    // 오류 처리 또는 기본 값 설정 등을 수행할 수 있습니다.
    // 예를 들어, 빨간색을 기본 값으로 설정:
    return Colors.red;
  }
}
