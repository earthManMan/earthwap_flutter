import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_login/API/firebaseAPI.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class ItemService with ChangeNotifier {
  List<String>? _itemList;

  // 생성자를 private으로 선언하여 외부에서 인스턴스를 직접 생성하지 못하게 합니다.
  ItemService._privateConstructor();

  // 싱글톤 인스턴스를 저장하기 위한 정적 필드
  static final ItemService _instance = ItemService._privateConstructor();

  // 외부에서 싱글톤 인스턴스에 접근할 수 있는 getter 메서드
  static ItemService get instance => _instance;

  // 사용자의 아이템 목록을 가져오는 메서드
  List<String>? get itemList => _itemList;

  // 사용자의 아이템 목록을 설정하는 메서드
  void setItemList(List<String>? itemList) {
    if (!listEquals(_itemList, itemList)) {
      _itemList = itemList;
      notifyListeners(); // _itemList 변경 알림
    }
  }

  // 사용자의 아이템 목록을 설정하는 메서드
  void addItem(String itemId) {
    _itemList!.add(itemId);
    notifyListeners(); // _itemList 변경 알림
  }

  void ClearItems() {
    _itemList?.clear();
  }
}
