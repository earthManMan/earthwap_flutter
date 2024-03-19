import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String phone;
  final String nickname;
  final String profileImg;
  final String description;

  final List<dynamic> myitems;
  final List<dynamic> myPosts;
  final List<dynamic> likedPosts;
  final List<dynamic> followings;
  final int followers;

  final DocumentReference reference;

  // 생성자
  UserModel({
    required this.uid,
    required this.phone,
    required this.nickname,
    required this.profileImg,
    required this.description,
    required this.myitems,
    required this.myPosts,
    required this.likedPosts,
    required this.followings,
    required this.followers,
    required this.reference,
  });

  // Map에서 UserModel 객체 생성
  factory UserModel.fromMap(Map<String, dynamic> map,
      {DocumentReference<Object>? reference}) {
    return UserModel(
      uid: map[KEY_UID],
      phone: map[KEY_PHONE],
      nickname: map[KEY_NICKNAME],
      profileImg: map[KEY_PROFILEIMG],
      description: map[KEY_DESCRIPTION],
      myitems: map[KEY_MYITEMS],
      myPosts: map[KEY_MYPOSTS],
      likedPosts: map[KEY_LIKEDPOSTS],
      followings: map[KEY_FOLLOWINGS],
      followers: map[KEY_FOLLOWERS],
      reference: reference!,
    );
  }
// DocumentSnapshot에서 UserModel 객체 생성
  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    return UserModel.fromMap(snapshot.data() as Map<String, dynamic>,
        reference: snapshot.reference as DocumentReference<Object>?);
  }

  // 새로운 사용자를 생성하기 위한 Map 생성
  static Map<String, dynamic> getMapForCreateUser(String email) {
    return {
      KEY_PROFILEIMG: "", // 프로필 이미지
      KEY_USERNAME: email.split("@")[0], // 유저네임은 이메일 주소의 @ 이전 부분으로 설정
      KEY_EMAIL: email, // 이메일
      KEY_LIKEDPOSTS: [], // 좋아요한 포스트 목록
      KEY_FOLLOWERS: 0, // 팔로워 수
      KEY_FOLLOWINGS: [], // 팔로잉한 유저 목록
      KEY_MYPOSTS: [], // 내가 작성한 포스트 목록
    };
  }
}

// 상수 키들
const String KEY_UID = 'uid';
const String KEY_PHONE = 'phone';
const String KEY_NICKNAME = 'nickname';
const String KEY_PROFILEIMG = 'profileImg';
const String KEY_DESCRIPTION = 'description';
const String KEY_MYITEMS = 'myitems';
const String KEY_MYPOSTS = 'myPosts';
const String KEY_LIKEDPOSTS = 'likedPosts';
const String KEY_FOLLOWINGS = 'followings';
const String KEY_FOLLOWERS = 'followers';
const String KEY_USERNAME = 'username';
const String KEY_EMAIL = 'email';
