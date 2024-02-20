import 'package:flutter/foundation.dart';

class MatchService with ChangeNotifier {
  List<String>? _matchItemList;

  // 생성자를 private으로 선언하여 외부에서 인스턴스를 직접 생성하지 못하게 합니다.
  MatchService._privateConstructor();

  // 싱글톤 인스턴스를 저장하기 위한 정적 필드
  static final MatchService _instance = MatchService._privateConstructor();

  // 외부에서 싱글톤 인스턴스에 접근할 수 있는 getter 메서드
  static MatchService get instance => _instance;

  // 사용자의 매치 아이템 목록을 가져오는 메서드
  List<String>? get matchItemList => _matchItemList;

  // 사용자의 매치 아이템 목록을 설정하는 메서드
  void setMatchItemList(List<String>? matchItemList) {
    if (!listEquals(_matchItemList, matchItemList)) {
      _matchItemList = matchItemList;
      notifyListeners(); // _itemList 변경 알림
    }
  }

  void clearMatchs() {
    _matchItemList?.clear();
  }
}
