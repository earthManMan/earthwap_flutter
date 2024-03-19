import 'package:firebase_login/domain/alarm/alarm_model.dart';
import 'package:flutter/material.dart';

class HomeModel {
  final List<alarmModel> _alarmList = [];

  String _category_id = "";

  final List<ItemInfo> _itemInfoList = [];

  // 아이템 정보 리스트를 직접 노출하지 않고 읽기 전용 getter를 제공합니다.
  List<ItemInfo> get itemInfoList => _itemInfoList.toList();

  // 아이템 정보를 추가하는 메서드
  void addItemInfo(ItemInfo item) {
    _itemInfoList.add(item);
  }

  // 아이템 정보 리스트를 비우는 메서드
  void clearItemInfoList() {
    _itemInfoList.clear();
  }

  void setcategory(String value) {
    _category_id = value;
  }

  String getcategory() {
    return _category_id;
  }

  void clearModel() {
    _itemInfoList.clear();
    _category_id = "";
    _alarmList.clear();
  }
}

class ItemInfo {
  late String item_id; // 아이템 고유 ID
  late String item_owner_id;
  late String item_owner_Kickname;
  late String item_profile_img;
  late String category; // 아이템 카테고리
  late String item_cover_img; // 아이템 cover Image
  late List<String> otherImagesLocation; // 아이템 other image
  late String description; // 아이템 설명
  late bool isPremium; // ?? 없어도 될듯
  late bool isTraded; // 물건의 교환 유무??
  late String likes; //Lisk 한 물건 -> List로 바꿔야함
  late String dislikes; // DisLike 한 물건 -> List로 바꿔야함
  late Color main_color; // 물건의 메인 칼라
  late Color sub_color; // 물건의 서브 칼라
  late String main_Keyword;
  late String sub_Keyword;
  late String matchItems; // 물건과 Match 된 물건의 ID
  late int userPrice;
  late int priceEnd; //물건의 시작 값
  late int priceStart; // 물건의 끝 값
  late String create_time; // 물건의 등록 시간
  late String update_time; // 물건의 업데이트 시간

  late String match_id; // 해당 아이템과 Math 된 Item Id
  late String match_owner_id; //Match ID 주인
  late String match_img; // 해당 아이템과 match 된 item의 cover Image

  ItemInfo({
    required this.item_id,
    required this.item_owner_id,
    required this.item_owner_Kickname,
    required this.item_profile_img,
    required this.category,
    required this.item_cover_img,
    required this.otherImagesLocation,
    required this.description,
    required this.isPremium,
    required this.isTraded,
    required this.likes,
    required this.dislikes,
    required this.main_color,
    required this.sub_color,
    required this.main_Keyword,
    required this.sub_Keyword,
    required this.matchItems,
    required this.userPrice,
    required this.priceEnd,
    required this.priceStart,
    required this.create_time,
    required this.update_time,
    required this.match_id,
    required this.match_owner_id,
    required this.match_img,
  });
}
