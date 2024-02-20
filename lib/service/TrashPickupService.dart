import 'package:flutter/foundation.dart';

class TrashPickupService with ChangeNotifier {
  List<String>? _pickups;

  // 생성자를 private으로 선언하여 외부에서 인스턴스를 직접 생성하지 못하게 합니다.
  TrashPickupService._privateConstructor();

  // 싱글톤 인스턴스를 저장하기 위한 정적 필드
  static final TrashPickupService _instance =
      TrashPickupService._privateConstructor();

  // 외부에서 싱글톤 인스턴스에 접근할 수 있는 getter 메서드
  static TrashPickupService get instance => _instance;

  List<String>? get pickups => _pickups;

  void setPickups(List<String>? pickups) {
    if (!listEquals(_pickups, pickups)) {
      _pickups = pickups;
      notifyListeners();
    }
  }

  void clearTrash() {
    _pickups?.clear();
  }
}
