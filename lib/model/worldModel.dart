import 'package:firebase_login/model/postItemModel.dart';
import 'package:intl/intl.dart';

class WorldModel {
  List<String> paymentsinfo = [];

  String _title = "";
  final List<String> _imagePath = [];
  String _content = "";
  List<PostItemModel> _communityItemList = [];

  String _address = "";
  String _addressdetail = "";
  String _doorPassword = "";
  String _comment = "";
  String _phoneNumber = "";
  String _date = "";
  String _orderID = "";

  int _world_days = 10;
  DateTime _world_since = DateTime.now().subtract(Duration(days: 10));
  DateTime _world_till = DateTime.now();

  void update_world_days() {
    _world_days = _world_days + 10;
    _world_since = DateTime.now().subtract(Duration(days: _world_days));
  }

  DateTime getworld_since() {
    return _world_since;
  }

  DateTime getworld_till() {
    return _world_till;
  }

  void refeshWorld_till() {
    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(_world_till);
    print("Current DateTime: $formattedDate");
    _world_till = DateTime.now();
    formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(_world_till);
    print("Current DateTime: $formattedDate");
  }

  void sortPostItemsBycreate() {
    _communityItemList.sort((a, b) => b.date.compareTo(a.date));
  }

  void sortPostItemsBylike() {
    _communityItemList.sort((a, b) => b.likes.compareTo(a.likes));
  }

  void sortPostItemsByview() {
    _communityItemList.sort((a, b) => b.views.compareTo(a.views));
  }

  void addPaymentinfo(String text) {
    paymentsinfo.add(text);
  }

  List<String> get paymentsinfoList {
    return paymentsinfo;
  }

  List<PostItemModel> get communityItemList {
    return _communityItemList;
  }

  set communityItemList(List<PostItemModel> model) {
    _communityItemList = model;
  }

  String get title {
    return _title;
  }

  set title(String str) {
    _title = str;
  }

  String get content {
    return _content;
  }

  List<String> get images {
    return _imagePath;
  }

  set content(String str) {
    _content = str;
  }

  void addImagePath(String str) {
    _imagePath.clear();
    _imagePath.add(str);
  }

  String get address {
    return _address;
  }

  set address(String val) {
    _address = val;
  }

  String get orderID {
    return _orderID;
  }

  set orderID(String val) {
    _orderID = val;
  }

  String get addressdetail {
    return _addressdetail;
  }

  set addressdetail(String val) {
    _addressdetail = val;
  }

  String get doorpass {
    return _doorPassword;
  }

  set doorpass(String val) {
    _doorPassword = val;
  }

  String get comment {
    return _comment;
  }

  set comment(String val) {
    _comment = val;
  }

  String get day {
    return _date;
  }

  set day(String val) {
    _date = val;
  }

  String get phone {
    return _phoneNumber;
  }

  set phone(String val) {
    _phoneNumber = val;
  }

  void clearModel() {
    for (var element in _communityItemList) {
      element.commentService.stopListeningToComment();

      for (var comment in element.comments) {
        comment.stopListeningToComment();
        for (var replie in comment.replies) {
          replie.stopListeningToComment();
          replie.replies.clear();
        }
      }
    }

    _communityItemList.clear();
    _title = "";
    _content = "";
    _imagePath.clear();
    _address = "";
    _addressdetail = "";
    _doorPassword = "";
    _comment = "";
    _phoneNumber = "";
    _date = "";
    _orderID = "";
    _communityItemList = [];
  }
}
