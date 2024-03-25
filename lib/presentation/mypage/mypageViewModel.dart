import 'package:firebase_login/domain/login/userService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/domain/mypage/mypage_model.dart';
import 'package:firebase_login/domain/home/home_model.dart';
import 'package:firebase_login/app/config/constant.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
// 추가된 import 문
import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:firebase_login/domain/postitem/postItem_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_login/domain/home/itemService.dart';
import 'package:firebase_login/domain/world/contentService.dart';
import 'package:firebase_login/domain/world/TrashPickupService.dart';

import 'package:firebase_login/app/config/remote_options.dart';
import 'dart:async';
import 'package:firebase_login/domain/category/service/category_service.dart';

class MypageViewModel extends ChangeNotifier {
  MypageModel _model;
  final UserService _userService;
  final ItemService _itemService;
  final TrashPickupService _pickupService;
  final CategoryService _categoryService;
  bool notification_following = false;
  bool notification_followers = false;

  final ContentService _contentService;
  MypageModel get model => _model;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _followingListener;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _followersListener;

  MypageViewModel(
    this._model,
    this._userService,
    this._categoryService,
    this._itemService,
    this._contentService,
    this._pickupService,
  ) {
    _itemService.addListener(() {
      if (_itemService.itemList!.isNotEmpty) {
        createItemList();
      }
    });
    _contentService.addListener(() {
      if (_contentService.contents!.isNotEmpty) {
        createContentList();
      }
    });
    _pickupService.addListener(() {
      if (_pickupService.pickups!.isNotEmpty) {
        createPickupList();
      }
    });
  }

  void startListeningToFollowing(String uid) async {
    final userDocRef = FirebaseFirestore.instance
        .collection('/users/')
        .doc(uid)
        .collection('/following/');
    _followingListener?.cancel();

    _followingListener = userDocRef.snapshots().listen((event) async {
      // Check if any documents exist in the 'following' subcollection
      if (event.docs.isNotEmpty) {
        final api = FirebaseAPI();
        _model.Following!.clear();
        for (int i = 0; i < event.docs.length; i++) {
          final userData = event.docs[i].data();
          String id = userData['uid'];
          if (id.isEmpty) {
            notification_following = true;
            notifyListeners();
          } else {
            final result = await api.getUserInfoOnCallFunction(id);
            if (result != null) {
              AnotherUserProfile userProfile =
                  AnotherUserProfile.fromMap(result);
              createAnotherItemInfo(userProfile);
              model.addFollowing(userProfile);
              notification_following = true;
              notifyListeners();
            }
          }
        }
      } else {
        _model.Following!.clear();
        notification_following = true;

        notifyListeners();
      }
    });
  }

  void startListeningToFollowers(String uid) {
    final userDocRef = FirebaseFirestore.instance
        .collection('/users/')
        .doc(uid)
        .collection('/followed_by/');

    // Cancel the existing listener if there is one
    _followersListener?.cancel();

    _followersListener = userDocRef.snapshots().listen((event) async {
      // Check if any documents exist in the 'following' subcollection
      if (event.docs.isNotEmpty) {
        final api = FirebaseAPI();
        _model.Followers!.clear();
        for (int i = 0; i < event.docs.length; i++) {
          final userData = event.docs[i].data();
          String id = userData['uid'];
          final result = await api.getUserInfoOnCallFunction(id);
          if (result != null) {
            model.addFollowers(AnotherUserProfile.fromMap(result));
            notification_followers = true;
            notifyListeners();
          }
        }
      } else {
        _model.Followers!.clear();
        notification_followers = true;

        notifyListeners();
      }
    });
  }

  void createAnotherItemInfo(AnotherUserProfile user) async {
    final api = FirebaseAPI();

    user.itemList.forEach((element) async {
      final re = await api.readItemInfoOnCallFunction(element);

      if (re != null) {
        final itemData = re.data['item'];
        final mainColor = itemData['main_colour'];
        final subColor = itemData['sub_colour'];
        final mainKeyword = itemData['main_keyword'];
        final subKeyword = itemData['sub_keyword'];

        final item = ItemInfo(
          item_id: element,
          item_profile_img: "",
          item_owner_Kickname: user.nickname,
          item_owner_id: user.uid,
          category: itemData['category_id'].toString(),
          item_cover_img: itemData['cover_image_location'].toString(),
          otherImagesLocation: List<String>.from(
              itemData['other_images_location'].map((item) => item.toString())),
          description: itemData['description'].toString(),
          isPremium: itemData['is_premium'] as bool,
          isTraded: itemData['is_traded'] as bool,
          likes: itemData['likes'].toString(),
          dislikes: itemData['dislikes'].toString(),
          main_color: Color(int.parse("0x$mainColor")),
          sub_color: Color(int.parse("0x$subColor")),
          main_Keyword: mainKeyword.toString(),
          sub_Keyword: subKeyword.toString(),
          matchItems: "",
          userPrice: 0,
          priceEnd: itemData['price_end'] as int,
          priceStart: itemData['price_start'] as int,
          create_time: itemData['created_at'].toString(),
          update_time: itemData['updated_at'].toString(),
          match_id: "",
          match_owner_id: "",
          match_img: itemData['cover_image_location'].toString(),
        );
        user.addItemInfoList(item);
        notifyListeners();
      }
    });
  }

  void stopListeningToFollowing() {
    // Cancel the listener when it's no longer needed
    _followingListener?.cancel();
  }

  void stopListeningToFollowers() {
    // Cancel the listener when it's no longer needed
    _followersListener?.cancel();
  }

  // ViewModel의 초기화를 위한 팩토리 메서드
  factory MypageViewModel.initialize(
      UserService user,
      ItemService item,
      CategoryService category,
      ContentService content,
      TrashPickupService pickup) {
    final mypageModel = MypageModel(); // 필요한 초기화 로직을 수행하도록 변경
    final config = RemoteConfigOptions.instance;

    final valueList = config.getCustomerServiceJsonMap();
    mypageModel.setcustomer_email(valueList['email']);
    mypageModel.setcustomer_time(valueList['time']);

    return MypageViewModel(mypageModel, user, category, item, content, pickup);
  }

  Future<bool> updateProfile() async {
    final api = FirebaseAPI();

    String uid = _userService.uid.toString();
    String url = _userService.profileImage.toString();
    String name = _userService.nickname.toString();
    String description = _userService.description.toString();

    final profileUpdateResult =
        await api.updateProfilePictureOnCallFunction(uid, url);

    final nicknameUpdateResult =
        await api.updateNicknameOnCallFunction(uid, name);
    final descriptionUpdateResult =
        await api.updateDescriptionOnCallFunction(uid, description);
    _userService.setProfileImage(url);
    _userService.setNickname(name);
    _userService.setDescription(description);
    return true;
  }

  Future<dynamic> uploadImage(UploadType type, String uid, XFile image) async {
    final api = FirebaseAPI();
    return dynamic;
    //return api.uploadImage(type, uid, image);
  }

  Future<bool> createContentList() async {
    final api = FirebaseAPI();
    try {
      for (int i = 0; i < _contentService.contents!.length; i++) {
        List<String> parts = _contentService.contents![i].toString().split('/');

        if (parts.length >= 4) {
          String communityId = parts[1]; // Tf1ttpnDzfCmDRanOa0k
          String contentId = parts[3]; // YmVYojCQl6EJsrCs0LBK

          // 이미 _model에 등록되어 있는 Item인지 확인
          bool isAlreadyAdded = _model.getPostItemList().any((postItem) {
            return postItem.contentID ==
                contentId; // 여기에서 id는 예시일 수 있습니다. 사용하는 속성에 따라 변경하세요.
          });
          if (!isAlreadyAdded) {
            final result =
                await api.readContentOnCallFunction(communityId, contentId);
            if (result != null) {
              final likes = result['liked_by'] as List<dynamic>;
              final views = result['views'];
              final item = PostItemModel(
                title: result['title'].toString(),
                communityID: communityId,
                onwerId: _userService.uid.toString(),
                contentID: contentId,
                contentImg: result['images']
                    .toString()
                    .replaceAll(RegExp(r'[\[\]]'), ''),
                date: result['created_at']['_seconds'].toString(),
                description: result['body'],
                nickName: _userService.nickname.toString(),
                likes: likes.length,
                views: views,
                profileImg: _userService.profileImage.toString(),
                onNewComment: updateCommentMessage,
              );
              _model.addPostItem(item);
            }
          }
        }
      }

      return true; // 모든 작업이 성공적으로 완료된 경우 true를 반환
    } catch (e) {
      print('Error in createContentList: $e');
      return false; // 에러가 발생한 경우 false를 반환
    }
  }

  Future<bool> createItemList() async {
    final api = FirebaseAPI();
    try {
      for (int i = 0; i < _itemService.itemList!.length; i++) {
        String currentItem = _itemService.itemList![i];

        // 이미 _model에 등록되어 있는 Item인지 확인
        bool isAlreadyAdded = _model.getItemList().any((itemInModel) {
          return itemInModel.item_id ==
              currentItem; // 여기에서 id는 예시일 수 있습니다. 사용하는 속성에 따라 변경하세요.
        });

        // 이미 등록되어 있지 않은 Item이면 _model에 추가
        if (!isAlreadyAdded) {
          final re = await api.readItemInfoOnCallFunction(currentItem);
          String myItemImg = "";

          if (re != null) {
            myItemImg = re.data['item']['cover_image_location'].toString();
            String mainColor = re.data['item']['main_colour'];
            String subColor = re.data['item']['sub_colour'];
            final dynamic dynamicList =
                re.data['item']['other_images_location'];
            final List<String> stringList =
                List<String>.from(dynamicList.map((item) => item.toString()));

            final item = ItemInfo(
              item_id: currentItem,
              item_profile_img: "",
              item_owner_Kickname: _userService.nickname.toString(),
              item_owner_id: _userService.uid.toString(),
              category: re.data['item']['category_id'].toString(),
              item_cover_img:
                  re.data['item']['cover_image_location'].toString(),
              otherImagesLocation: stringList,
              description: re.data['item']['description'].toString(),
              isPremium: re.data['item']['is_premium'] as bool,
              isTraded: re.data['item']['is_traded'] as bool,
              likes: re.data['item']['likes'].toString(),
              dislikes: re.data['item']['dislikes'].toString(),
              main_color: Color(int.parse("0x$mainColor")),
              sub_color: Color(int.parse("0x$subColor")),
              main_Keyword: re.data['item']['main_keyword'].toString(),
              sub_Keyword: re.data['item']['sub_keyword'].toString(),
              matchItems: "",
              userPrice: 0,
              priceEnd: re.data['item']['price_end'] as int,
              priceStart: re.data['item']['price_start'] as int,
              create_time: re.data['item']['created_at'].toString(),
              update_time: re.data['item']['updated_at'].toString(),
              match_id: "",
              match_owner_id: "",
              match_img: myItemImg,
            );
            _model.addItem(item);
            notifyListeners(); // _itemList 변경 알림
          }
        }
      }
      return true;
    } catch (e) {
      print('Error in createContentList: $e');
      return false; // 에러가 발생한 경우 false를 반환
    }
  }

  Future<bool> createPickupList() async {
    final api = FirebaseAPI();
    _model.TrashList!.clear();
    try {
      for (int i = 0; i < _pickupService.pickups!.length; i++) {
        final re = await api.readPickupOnCallFunction(
            _userService.uid.toString(), _pickupService.pickups![i]);

        if (re != null) {
          final item = TrashCollection(
              order_id: re['payment_id'],
              address: re['base_address'],
              address_detail: re['detail_address'],
              comment: re['contents'],
              door: re['door_password'],
              phone: re['phone_number'],
              date: re['date'],
              status: re['status']);
          _model.addTrashItem(item);
        }
      }
      notifyListeners(); // TrashList 변경 알림

      return true; // 모든 작업이 성공적으로 완료된 경우 true를 반환
    } catch (e) {
      print('Error in createPickupList: $e');
      return false; // 에러가 발생한 경우 false를 반환
    }
  }

  Future<bool> deleteItem(String itemId) async {
    _model.getItemList().removeWhere((item) => item.item_id == itemId);

    final api = FirebaseAPI();
    api.deleteItemOnCallFunction(_userService.uid.toString(), itemId);
    notifyListeners();
    return true;
  }

  Future<bool> deleteContent(String contentId) async {
    final api = FirebaseAPI();
    api
        .deleteContentOnCallFunction(_userService.uid.toString(),
            _userService.communityID.toString(), contentId)
        .then((value) => {_model.deletePostItem(contentId), notifyListeners()});

    return true;
  }

  Future<String> writeComment(String contentId, String commentId, String body) {
    final api = FirebaseAPI();

    return api.writeCommentOnCallFunction(_userService.uid.toString(),
        _userService.communityID.toString(), contentId, commentId, body);
  }

  Future<bool> deleteComment(
      String contentId, String commentId, String secondCommentId) async {
    final api = FirebaseAPI();

    api
        .deleteCommentOnCallFunction(
            _userService.uid.toString(),
            _userService.communityID.toString(),
            contentId,
            commentId,
            secondCommentId)
        .then((value) => {if (value) notifyListeners()});

    return true;
  }

  Future<bool> reportUser(String reportUser, String report) {
    final api = FirebaseAPI();

    return api.reportOnCallFunction(
        _userService.uid.toString(), reportUser, report);
  }

  void updateCommentMessage(bool state) {
    notifyListeners();
  }

  Future<bool> follow(String uid) async {
    final api = FirebaseAPI();
    final result =
        await api.followUserOnCallFunction(_userService.uid.toString(), uid);

    notifyListeners();
    return result;
  }

  Future<bool> unfollow(String uid) async {
    final api = FirebaseAPI();
    final result =
        await api.unfollowUserOnCallFunction(_userService.uid.toString(), uid);
    notifyListeners();

    return result;
  }

  void clearModel() {
    _itemService.removeListener(() {});
    _contentService.removeListener(() {});
    _pickupService.removeListener(() {});
    stopListeningToFollowers();
    stopListeningToFollowing();
    _model.clearModel();
    _model = MypageModel(); // 필요한 초기화 로직을 수행하도록 변경
    final config = RemoteConfigOptions.instance;

    final valueList = config.getCustomerServiceJsonMap();
    _model.setcustomer_email(valueList['email']);
    _model.setcustomer_time(valueList['time']);
  }
}
