import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:firebase_login/service/contentService.dart';
import 'package:firebase_login/service/matchService.dart';
import 'package:firebase_login/service/TrashPickupService.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'itemService.dart';

class UserService with ChangeNotifier {
  String _uid = "";
  String _email = "";
  String _profileImage = "";
  String _nickname = "";
  String _university = "";
  String _description = "";

  bool _isPremium = false;
  String _communityID = "";

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDataListener;

  // user 정보로 부터 Data Setting
  void startListeningToUserDataChanges(String uid) async {
    if (uid.isNotEmpty) {
      final userDocRef =
          FirebaseFirestore.instance.collection('/users/').doc(uid);

      // Cancel the existing listener if there is one
      _userDataListener?.cancel();

      _userDataListener = userDocRef.snapshots().listen((event) async {
        if (event.exists) {
          final itemService = ItemService.instance;
          final contentService = ContentService.instance;
          final matchService = MatchService.instance;
          final pickupService = TrashPickupService.instance;

          final api = FirebaseAPI();

          // User data has changed, update your local user data accordingly
          final userData = event.data() as Map<String, dynamic>;

          List<dynamic> contents = userData["contents"] ?? [];
          List<dynamic> items = userData["items"] ?? [];
          List<dynamic> matitems = userData["matches"] ?? [];
          List<dynamic> picks = userData["pickups"] ?? [];

          final commuID =
              await api.getUniversityInfoOnCallFunction(userData['university']);

          if (commuID.isNotEmpty) {
            setUserData(
              uid: uid,
              isPremium: userData['access_grant']?.toString() == 'basic'
                  ? false
                  : true,
              email: userData['email'] ?? "",
              university: userData['university'] ?? "",
              profileImage: userData['profile_picture_url'] ?? "",
              description: userData['description'] ?? "",
              nickname: userData['nickname'] ?? "",
              communityID: commuID,
            );
          }
          notifyListeners(); // _itemList 변경 알림

          itemService.ClearItems();
          contentService.ClearContents();
          matchService.clearMatchs();
          pickupService.clearTrash();

          // Setvice 해당 되는 Item 등록
          itemService.setItemList(
              (items ?? []).map((item) => item.toString()).toList());
          contentService.setContents(
              (contents ?? []).map((item) => item.toString()).toList());
          matchService.setMatchItemList(
              (matitems ?? []).map((item) => item.toString()).toList());
          pickupService.setPickups(
              (picks ?? []).map((item) => item.toString()).toList());
        }
      });
    }
  }

  void stopListeningToUserDataChanges() {
    // Cancel the listener when it's no longer needed
    _userDataListener?.cancel();
  }

  // 생성자를 private으로 선언하여 외부에서 인스턴스를 직접 생성하지 못하게 합니다.
  UserService._privateConstructor();

  // 싱글톤 인스턴스를 저장하기 위한 정적 필드
  static final UserService _instance = UserService._privateConstructor();

  // 외부에서 싱글톤 인스턴스에 접근할 수 있는 getter 메서드
  static UserService get instance => _instance;

  // 사용자 데이터를 설정하는 메서드
  void setUserData({
    String? uid,
    String? email,
    String? university,
    bool? isPremium,
    String? nickname,
    String? profileImage,
    String? communityID,
    String? description,
  }) {
    _uid = uid!;
    _email = email!;
    _nickname = nickname!;
    _university = university!;
    _description = description!;
    _isPremium = isPremium!;
    _profileImage = profileImage!;
    _communityID = communityID!;
  }

  // 사용자의 UID를 가져오는 메서드
  String? get uid => _uid;

  // 사용자의 이메일을 가져오는 메서드
  String? get email => _email;
  String? get university => _university;

  String? get profileImage => _profileImage;
  String? get nickname => _nickname;
  String? get description => _description;

  // 사용자의 프리미엄 여부를 가져오는 메서드
  bool? get isPremium => _isPremium;

  // 사용자의 커뮤니티 목록을 가져오는 메서드
  String? get communityID => _communityID;

  // 사용자의 UID를 설정하는 메서드
  void setUid(String uid) {
    _uid = uid;
  }

  // 사용자의 이메일을 설정하는 메서드
  void setEmail(String email) {
    _email = email;
  }

  // 사용자의 대학 정보를 설정하는 메서드
  void setUniversity(String university) {
    _university = university;
  }

  // 사용자의 프로필 이미지 URL을 설정하는 메서드
  void setProfileImage(String profileImage) {
    _profileImage = profileImage;
  }

  // 사용자의 닉네임을 설정하는 메서드
  void setNickname(String nickname) {
    _nickname = nickname;
  }

  // 사용자의 자기소개를 설정하는 메서드
  void setDescription(String description) {
    _description = description;
  }

  // 사용자의 프리미엄 여부를 설정하는 메서드
  void setIsPremium(bool isPremium) {
    _isPremium = isPremium;
  }

  // 사용자의 커뮤니티 ID를 설정하는 메서드
  void setCommunityID(String communityID) {
    _communityID = communityID;
  }
}
