import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_login/service/contentService.dart';
import 'package:firebase_login/service/userService.dart';
import 'package:firebase_login/view/world/components/world_detail.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/model/worldModel.dart';
import 'package:firebase_login/model/postItemModel.dart';

// 추가된 import 문
import 'package:firebase_login/API/firebaseAPI.dart';
import 'dart:async';
import 'package:firebase_login/application_options.dart';

class WorldViewModel extends ChangeNotifier {
  WorldModel _model;
  final UserService _userService;

  WorldViewModel(
    this._model,
    this._userService,
  ) {
    _userService.addListener(() {
      if (_userService.communityID != null) {
        initialize();
      }
    });
  }

  WorldModel get model => _model;
  UserService get user => _userService;

  // ViewModel의 초기화를 위한 팩토리 메서드
  factory WorldViewModel.initialize(UserService service) {
    final worldModel = WorldModel(); // 필요한 초기화 로직을 수행하도록 변경
    final config = RemoteConfigService.instance;

    final valueList = config.getPaymentInfoJsonMap();

    for (final value in valueList) {
      worldModel.addPaymentinfo(value['text']);
    }

    return WorldViewModel(
      worldModel,
      service,
    );
  }

  void addImagePath(String Path) {
    _model.addImagePath(Path);
  }

  Future<String> createPostItem() async {
    final api = FirebaseAPI();
    final userService = UserService.instance;

    final result = await api.createContentOnCallFunction(
        userService.uid!,
        userService.communityID!,
        _model.content.toString(),
        _model.title.toString(),
        _model.images.isEmpty ? "" : _model.images.first.toString());

    if (result.isNotEmpty) {
      String repair =
          "communities/${userService.communityID!}/contents/$result";
      _model.images.clear();
      _model.title = "";
      _model.content = "";

      return repair;
    } else {
      return "";
    }
  }

  Future<bool> getRegisterPostItem(String id) async {
    final content = ContentService.instance;
    content.addItem(id);
    return true;
  }

  Future<bool> initialize() async {
    final api = FirebaseAPI();
    final userService = UserService.instance;
    final communityID = userService.communityID.toString();

    final result = await api.listContentsOnCallFunction(
        _model.getworld_since(), _model.getworld_till(), communityID);

    if (result.isEmpty) {
      notifyListeners();
      return false;
    } else {
      final postList = await createPostItems(result);
      _model.communityItemList.addAll(postList);
      return true;
    }
  }

  Future<List<PostItemModel>> createPostItems(List<dynamic> list) async {
    final userService = UserService.instance;
    final api = FirebaseAPI();
    final uid = userService.uid;
    final profileImage = userService.profileImage.toString();
    final nickname = userService.nickname.toString();

    List<PostItemModel> itemList = [];
    for (int i = 0; i < list.length; i++) {
      // 이미 _model.communityItemList에 등록된 communityID와 중복된 경우 스킵
      if (_model.communityItemList
          .any((item) => item.contentID == list[i]["id"])) {
        continue;
      }

      final ownerId = list[i]['owner_id'];
      final likes = list[i]['liked_by'] as List<dynamic>;
      final views = list[i]['views'];
      String profilePath = "";
      String name = "";

      if (uid == ownerId) {
        profilePath = profileImage;
        name = nickname;
      } else {
        final info = await api.getUserInfoOnCallFunction(ownerId);
        if (info != null) {
          name = info["nickname"];
          profilePath = info["profile_picture_url"] ??
              ""; //"assets/images/default_Profile.png";
        }
      }

      final item = PostItemModel(
        title: list[i]['title'],
        communityID: userService.communityID.toString(),
        onwerId: ownerId,
        contentID: list[i]['id'],
        contentImg:
            list[i]['images'].toString().replaceAll(RegExp(r'[\[\]]'), ''),
        date: list[i]['created_at']['_seconds'].toString(),
        description: list[i]['body'],
        nickName: name,
        likes: likes.length,
        views: views,
        profileImg: profilePath,
        onNewComment: updateCommentMessage,
      );

      itemList.add(item);
    }

    return itemList;
  }

  Future<bool> getPayment() async {
    final api = FirebaseAPI();
    final re = await api.getPaymentsOnCallFunction(_userService.uid.toString());
    return re;
  }

  Future<bool> contentLike(String contentId) async {
    final api = FirebaseAPI();
    return api.likeContentOnCallFunction(_userService.uid.toString(),
        _userService.communityID.toString(), contentId);
  }

  Future<bool> viewUpCount(String contentId) async {
    final api = FirebaseAPI();
    return api.incrementViewsOnCallFunction(
        _userService.communityID.toString(), contentId);
  }

  Future<bool> checkPayment(String PaymentID) async {
    final api = FirebaseAPI();
    bool paymentChecked = false;

    while (!paymentChecked) {
      // checkPayMentServer 함수 호출
      bool response = await api.getPaymentOnCallFunction(
          _userService.uid.toString(), PaymentID);

      if (response == true) {
        // 원하는 조건을 충족하면 반복문을 종료합니다.
        paymentChecked = true;
      } else {
        // 원하는 조건을 충족하지 않았을 경우 잠시 기다린 후 다시 호출합니다.
        await Future.delayed(const Duration(seconds: 3)); // 5초를 기다린 후 재시도
      }
    }

    return true;
  }

  Future<bool> createPickup() async {
    final api = FirebaseAPI();

    bool response = await api.createPickupOnCallFunction(
        _userService.uid.toString(),
        _model.orderID,
        _model.address,
        _model.addressdetail,
        _model.doorpass,
        _model.content,
        _model.day,
        _model.phone);
    if (response == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> refresh_postItem() async {
    final api = FirebaseAPI();

    final userService = UserService.instance;
    final communityID = userService.communityID.toString();

    final result = await api.listContentsOnCallFunction(
        _model.getworld_since(), _model.getworld_till(), communityID);
    if (result.isEmpty) {
      notifyListeners();
      return false;
    } else {
      final postList = await createPostItems(result);
      if (postList.isNotEmpty) {
        _model.communityItemList.addAll(postList);
        notifyListeners();
      }
      return true;
    }
  }

  Future<bool> update_postItem() async {
    final api = FirebaseAPI();

    final userService = UserService.instance;
    final communityID = userService.communityID.toString();
    _model.update_world_days();
    _model.refeshWorld_till();

    final result = await api.listContentsOnCallFunction(
        _model.getworld_since(), _model.getworld_till(), communityID);
    if (result.isEmpty) {
      notifyListeners();
      return false;
    } else {
      final postList = await createPostItems(result);
      if (postList.isNotEmpty) {
        _model.communityItemList.addAll(postList);
        notifyListeners();
      }
      return true;
    }
  }

  void updateCommentMessage(bool state) {
    notifyListeners();
  }

  void sortPostItemsBycreate() {
    model.sortPostItemsBycreate();

    notifyListeners();
  }

  void sortPostItemsBylike() {
    model.sortPostItemsBylike();

    notifyListeners();
  }

  void sortPostItemsByview() {
    model.sortPostItemsByview();

    notifyListeners();
  }

  void clearModel() {
    _userService.removeListener(() {});
    _model.clearModel();
    _model = WorldModel();
    final config = RemoteConfigService.instance;

    final valueList = config.getPaymentInfoJsonMap();

    for (final value in valueList) {
      _model.addPaymentinfo(value['text']);
    }
  }
}
