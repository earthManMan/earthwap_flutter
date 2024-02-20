import 'package:firebase_login/model/homeModel.dart';
import 'package:firebase_login/model/postItemModel.dart';

class TrashCollection {
  final String order_id;
  final String address;
  final String address_detail;
  final String door;
  final String comment;
  final String phone;
  final String date;
  String status;

  TrashCollection({
    required this.order_id,
    required this.address,
    required this.address_detail,
    required this.door,
    required this.comment,
    required this.phone,
    required this.date,
    required this.status,
  });
}

class MypageModel {
  String customer_email = "";
  String customer_time = "";

  String _profileUrl = "";
  String _nickName = "";
  String _description = "";
  late final List<PostItemModel> _postItemList = [];
  late final List<ItemInfo> _ItemList = [];
  List<PostItemModel>? get postItemList => _postItemList;

  final List<TrashCollection> _TrashList = [];
  List<TrashCollection>? get TrashList => _TrashList;

  String get profileUrl => _profileUrl;

  List<AnotherUserProfile> _Following = []; // 팔로잉
  List<AnotherUserProfile> _Followers = []; // 팔로워

  List<AnotherUserProfile>? get Following => _Following;
  List<AnotherUserProfile>? get Followers => _Followers;

  set profileUrl(String url) {
    _profileUrl = url;
  }

  String get nickName => _nickName;

  set nickName(String name) {
    _nickName = name;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  void setcustomer_email(String value) {
    customer_email = value;
  }

  void setcustomer_time(String value) {
    customer_time = value;
  }

  String getcustomer_email() {
    return customer_email;
  }

  String getcustomer_time() {
    return customer_time;
  }

  void addPostItem(PostItemModel item) {
    _postItemList.add(item);
  }

  List<PostItemModel> getPostItemList() {
    return _postItemList;
  }

  void deletePostItem(String contentId) {
    _postItemList.removeWhere((item) => item.contentID == contentId);
  }

  void addItem(ItemInfo item) {
    _ItemList.add(item);
  }

  List<ItemInfo> getItemList() {
    return _ItemList;
  }

  // 사용자의 팔로잉 목록을 설정하는 메서드
  void addTrashItem(TrashCollection item) {
    _TrashList.add(item);
  }

  // 사용자의 팔로잉 목록을 설정하는 메서드
  void addFollowing(AnotherUserProfile following) {
    _Following.add(following);
  }

  // 사용자의 팔로워 목록을 설정하는 메서드
  void addFollowers(AnotherUserProfile followers) {
    _Followers.add(followers);
  }

  // 사용자의 팔로잉 목록을 설정하는 메서드
  void setFollowing(List<AnotherUserProfile> following) {
    _Following = following;
  }

  // 사용자의 팔로워 목록을 설정하는 메서드
  void setFollowers(List<AnotherUserProfile> followers) {
    _Followers = followers;
  }

  List<AnotherUserProfile> getFollowers() {
    return _Followers;
  }

  List<AnotherUserProfile> getFollowings() {
    return _Following;
  }

  void clearModel() {
    for (PostItemModel element in _postItemList) {
      element.commentService.stopListeningToComment();
      for (CommentModel comment in element.comments) {
        comment.stopListeningToComment();
        for (CommentModel replies in comment.replies) {
          replies.stopListeningToComment();
          replies.replies.clear();
        }
      }
    }

    _postItemList.clear();
    _ItemList.clear();
    _TrashList.clear();
    _Following.clear();
    _Followers.clear();
    _TrashList.clear();

    _profileUrl = "";
    _nickName = "";
    _description = "";
    customer_email = "";
    customer_time = "";
  }
}

class AnotherUserProfile {
  final String uid;
  final String email;
  final String nickname;
  final String description;
  final String profileImage;
  final List<String> itemList; // 예: 사용자가 가지고 있는 항목 목록
  List<ItemInfo> itemInfoList = [];

  AnotherUserProfile({
    required this.uid,
    required this.email,
    required this.nickname,
    required this.description,
    required this.profileImage,
    required this.itemList,
  });

  // 이 메서드를 사용하여 사용자의 정보를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nickname': nickname,
      'description': description,
      'profileImage': profileImage,
      'itemList': itemList,
    };
  }

  factory AnotherUserProfile.fromMap(Map<String, dynamic> data) {
    List<dynamic> items = data["items"] ?? [];

    return AnotherUserProfile(
      uid: data['uid'] ?? "",
      email: data['email'] ?? "",
      nickname: data['nickname'] ?? "",
      description: data['description'] ?? "",
      profileImage: data['profile_picture_url'] ?? "",
      itemList: (items ?? []).map((item) => item.toString()).toList(),
    );
  }

  void addItemInfoList(ItemInfo item) {
    itemInfoList.add(item);
  }
}
