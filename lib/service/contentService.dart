import 'package:flutter/foundation.dart';

class ContentService with ChangeNotifier {
  List<String>? _contents;

  // 생성자를 private으로 선언하여 외부에서 인스턴스를 직접 생성하지 못하게 합니다.
  ContentService._privateConstructor();

  // 싱글톤 인스턴스를 저장하기 위한 정적 필드
  static final ContentService _instance = ContentService._privateConstructor();

  // 외부에서 싱글톤 인스턴스에 접근할 수 있는 getter 메서드
  static ContentService get instance => _instance;

  List<String>? get contents => _contents;

  // 사용자의 컨텐츠 목록을 설정하는 메서드
  void setContents(List<String>? contents) {
    if (!listEquals(_contents, contents)) {
      _contents = contents;
      notifyListeners(); // _contents 변경 알림
    }
  }

  // 사용자의 아이템 목록을 설정하는 메서드
  void addItem(String itemId) {
    _contents!.add(itemId);
    notifyListeners(); // _itemList 변경 알림
  }

  void ClearContents() {
    _contents?.clear();
  }
}
