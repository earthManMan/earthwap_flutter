import 'package:firebase_login/model/alarmModel.dart';
import 'package:firebase_login/service/alarmService.dart';
import 'package:firebase_login/service/itemService.dart';
import 'package:firebase_login/service/userService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/model/homeModel.dart';
import 'package:firebase_login/model/categoryModel.dart';

// 추가된 import 문
import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:firebase_login/application_options.dart';

class HomeViewModel extends ChangeNotifier {
  HomeModel _model;
  final UserService _userService;
  final ItemService _itemService;
  final AlarmService _alarmService;
  final CategoryModel _categoryModel = CategoryModel();

  HomeModel get model => _model;
  CategoryModel get categorymodel => _categoryModel;

  // ViewModel의 초기화를 위한 팩토리 메서드
  factory HomeViewModel.initialize(
      UserService user, ItemService item, AlarmService alram) {
    /*
    final config = RemoteConfigService.instance;
    List<String> titles = [];
    List<String> subtitles = [];

    final valueList = config.getStartModelJsonMap();
    for (final value in valueList) {
      titles.add(value["infoTitle"].toString());
      subtitles.add(value["infoSubTitle"].toString());
    }
*/
    final homeModel = HomeModel(); // 필요한 초기화 로직을 수행하도록 변경
    return HomeViewModel(
      homeModel,
      user,
      item,
      alram,
    );
  }

  HomeViewModel(
      this._model, this._userService, this._itemService, this._alarmService) {
    _itemService.addListener(() {
      if (_itemService.itemList!.isNotEmpty) {
        initializeData();
      }
    });
    _alarmService.addListener(() {
      if (_alarmService.alarms!.isNotEmpty) {
        notifyListeners();
      }
    });
  }

  Future<dynamic> _readRecommendedItems(
      String id, List<String> excludeList) async {
    final api = FirebaseAPI();
    return await api.readRecommendedItemsOnCallFunction(
        id, _categoryModel.selected, excludeList);
  }

  Future<dynamic> _getUserInfo(String itemOwnerUid) async {
    final api = FirebaseAPI();
    return await api.getUserInfoOnCallFunction(itemOwnerUid);
  }

  Future<List<ItemInfo>> createItemInfo(String id) async {
    final api = FirebaseAPI();
    List<ItemInfo> resultList = [];
    List<String> excludeList = [];
    final iteminfos = await _readRecommendedItems(id, excludeList);

    if (iteminfos != null) {
      for (int i = 0; i < iteminfos.length; i++) {
        final itemOwnerUid = iteminfos[i]['owned_by'].toString();

        if (itemOwnerUid != _userService.uid) {
          const itemNickName = "";
          const itemProfileName = ""; //"assets/images/default_Profile.png";

          final dynamic dynamicList = iteminfos[i]['other_images_location'];
          final List<String> stringList =
              List<String>.from(dynamicList.map((item) => item.toString()));

          String mainColor = iteminfos[i]['main_colour'];
          String subColor = iteminfos[i]['sub_colour'];

          final item = ItemInfo(
            item_id: iteminfos[i]['id'],
            item_profile_img: itemProfileName,
            item_owner_Kickname: itemNickName,
            item_owner_id: itemOwnerUid,
            category: iteminfos[i]['category_id'].toString(),
            item_cover_img: iteminfos[i]['cover_image_location'].toString(),
            otherImagesLocation: stringList,
            description: iteminfos[i]['description'].toString(),
            isPremium: iteminfos[i]['is_premium'] as bool,
            isTraded: iteminfos[i]['is_traded'] as bool,
            likes: iteminfos[i]['likes'].toString(),
            dislikes: iteminfos[i]['dislikes'].toString(),
            main_color: Color(int.parse("0x$mainColor")),
            sub_color: Color(int.parse("0x$subColor")),
            main_Keyword: iteminfos[i]['main_keyword'].toString(),
            sub_Keyword: iteminfos[i]['sub_keyword'].toString(),
            matchItems: "",
            userPrice: 0,
            priceEnd: iteminfos[i]['price_end'] as int,
            priceStart: iteminfos[i]['price_start'] as int,
            create_time: iteminfos[i]['created_at'].toString(),
            update_time: iteminfos[i]['updated_at'].toString(),
            match_id: id,
            match_owner_id: _userService.uid.toString(),
            match_img: "",
          );
          excludeList.add(iteminfos[i]['id']);
          resultList.add(item);
        }
      }
    }

    return resultList;
  }

  Future<void> initializeData() async {
    // UserService의 itemList을 Set으로 변환
    final Set<String> ItemServiceItemSet =
        Set.from(_itemService.itemList ?? []);

    // _model.itemInfoList에서 match_id를 모아둔 Set 생성
    final Set<String> modelMatchIds =
        Set<String>.from(_model.itemInfoList.map((item) => item.match_id));

    // 중복되지 않은 아이템 ID 집합 생성
    final Set<String> uniqueItemIds =
        ItemServiceItemSet.difference(modelMatchIds);

    for (final itemId in uniqueItemIds) {
      final result = await createItemInfo(itemId);
      for (final item in result) {
        final userinfo = await _getUserInfo(item.item_owner_id);
        if (userinfo != null) {
          final itemNickName = userinfo["nickname"] ?? "";
          final itemProfileName = userinfo["profile_picture_url"] ?? "";
          item.item_profile_img = itemProfileName;
          item.item_owner_Kickname = itemNickName;
        }
        _model.addItemInfo(item);
        notifyListeners();
      }
    }
  }

  Future<void> updateItemInfo() async {
    // UserService의 itemList을 Set으로 변환
    final Set<String> ItemServiceItemSet =
        Set.from(_itemService.itemList ?? []);

    // _model.itemInfoList에서 match_id를 모아둔 Set 생성
    final Set<String> modelMatchIds =
        Set<String>.from(_model.itemInfoList.map((item) => item.match_id));

    // 중복되지 않은 아이템 ID 집합 생성
    final Set<String> uniqueItemIds =
        ItemServiceItemSet.difference(modelMatchIds);

    for (final itemId in uniqueItemIds) {
      final result = await createItemInfo(itemId);
      for (final item in result) {
        final userinfo = await _getUserInfo(item.item_owner_id);
        if (userinfo != null) {
          final itemNickName = userinfo["nickname"] ?? "";
          final itemProfileName = userinfo["profile_picture_url"] ?? "";
          item.item_profile_img = itemProfileName;
          item.item_owner_Kickname = itemNickName;
        }
        _model.addItemInfo(item);
      }
    }
    notifyListeners();
  }

  List<ItemInfo> getItemInfo() {
    return _model.itemInfoList;
  }

  Future<void> dislikeItem(String ownerid, String matchid) {
    final api = FirebaseAPI();

    return api.dislikeItemOnCallFunction(
        _userService.uid.toString(), ownerid, matchid);
  }

  Future<void> likeItem(String ownerid, String matchid) {
    final api = FirebaseAPI();

    return api.likeItemOnCallFunction(
        _userService.uid.toString(), ownerid, matchid);
  }

  Future<bool> reportUser(String reportUser, String report) {
    final api = FirebaseAPI();

    return api.reportOnCallFunction(
        _userService.uid.toString(), reportUser, report);
  }

  Future<bool> follow(String uid) {
    final api = FirebaseAPI();

    return api.followUserOnCallFunction(_userService.uid.toString(), uid);
  }

  Future<bool> unfollow(String uid) {
    final api = FirebaseAPI();

    return api.unfollowUserOnCallFunction(_userService.uid.toString(), uid);
  }

  void clearModel() {
    _itemService.removeListener(() {});
    _alarmService.removeListener(() {});
    _model.clearModel();
    _model = HomeModel();
  }
}
