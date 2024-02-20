import 'package:firebase_login/service/matchService.dart';
import 'package:firebase_login/service/userService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/model/chatModel.dart';
import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class ChatViewModel extends ChangeNotifier {
  ChatModel _model;
  final UserService _userService;
  final MatchService _matchService;

  ChatModel get model => _model;

  ChatViewModel(
    this._model,
    this._userService,
    this._matchService,
  ) {
    _matchService.addListener(() {
      if (_matchService.matchItemList!.isNotEmpty) {
        createChatRoom();
      }
    });
  }

  void updateChatMessage(ChatMessage chatMessage, String chatID) {
    for (ChatRoom room in _model.chatroomList) {
      if (room.chatId == chatID) {
        room.messages.add(chatMessage);
        updateChatRoomDate(chatID, chatMessage.time);
      }
    }
    notifyListeners();
  }

  // ViewModel의 초기화를 위한 팩토리 메서드
  factory ChatViewModel.initialize(UserService user, MatchService match) {
    final mypageModel = ChatModel(); // 필요한 초기화 로직을 수행하도록 변경
    return ChatViewModel(
      mypageModel,
      user,
      match,
    );
  }

  void updateChatRoomDate(String chatID, DateTime time) {
    DateTime now = DateTime.now();

    DateTime localTimestamp = time.toLocal(); // UTC 시간을 현재 위치의 시간대로 변환
    Duration difference = now.difference(localTimestamp);

    String formattedDate;

    if (difference.inDays == 0) {
      formattedDate =
          '${difference.inHours}시간 ${difference.inMinutes.remainder(60)}분 전';
    } else if (difference.inDays == 1) {
      // 어제
      formattedDate = '1일전';
    } else {
      // 그 외
      formattedDate = '${difference.inDays}일전';
    }

    for (ChatRoom room in _model.chatroomList) {
      if (room.chatId == chatID) {
        room.date = formattedDate;
      }
    }
  }

  Future<bool> createChatRoom() async {
    final api = FirebaseAPI();
    List<ChatRoom> existingChatRooms = _model.chatroomList; // 기존의 채팅 방 목록을 가져옴

    try {
      for (int i = 0; i < _matchService.matchItemList!.length; i++) {
        final matchItemId = _matchService.matchItemList![i].toString();

        // 이미 존재하는 채팅 방 중에서 현재 매치 아이템 ID와 같은 것이 있는지 확인
        if (existingChatRooms
            .any((chatRoom) => chatRoom.matchId == matchItemId)) {
          continue; // 이미 존재하는 경우, 다음 매치 아이템으로 넘어감
        }

        final respone = await api.getMatchInfoOnCallFunction(
            _matchService.matchItemList![i].toString(),
            _userService.uid.toString());

        if (respone != null) {
          String create = "";
          String chatID = respone.data['chat_id'].toString();
          String item1 = respone.data['item1'].toString();
          String item2 = respone.data['item2'].toString();
          String itemOwner = "";
          String item2Owner = "";
          final chatinfos = await api.readChatOnCallFunction(
              chatID, _userService.uid.toString());
          if (chatinfos != null) {
            itemOwner = chatinfos.data['user1'] ?? "";
            item2Owner = chatinfos.data['user2'] ?? "";
            create = chatinfos.data['created_at']['_seconds'].toString();
          }

          String item1Img = "";
          String item2Img = "";
          String item1Keyword = "";
          String item2Keyword = "";
          String item1Profile = "";
          String item2Profile = "";

          // 두개의 Item 정보 가져오기. Keyword 및 Cover Image 추출
          final itemResult = await api.readItemInfoOnCallFunction(item1);
          if (itemResult != null) {
            final itemData = itemResult.data['item'];
            item1Img = itemData['cover_image_location'];
            item1Keyword = itemData['main_keyword'] + itemData['sub_keyword'];
          } else {
            continue;
          }

          final item2Result = await api.readItemInfoOnCallFunction(item2);
          if (item2Result != null) {
            final itemData = item2Result.data['item'];
            item2Img = itemData['cover_image_location'];
            item2Keyword = itemData['main_keyword'] + itemData['sub_keyword'];
          } else {
            continue;
          }

          if (_userService.uid.toString() == itemOwner) {
            if (item2Owner.isNotEmpty) {
              final userinfo = await api.getUserInfoOnCallFunction(item2Owner);
              if (userinfo != null) {
                final itemProfileName = userinfo["profile_picture_url"] ??
                    ""; //"assets/images/default_Profile.png";
                item2Profile = itemProfileName;
              }
            }
          } else {
            if (itemOwner.isNotEmpty) {
              final userinfo = await api.getUserInfoOnCallFunction(itemOwner);
              if (userinfo != null) {
                final itemProfileName = userinfo["profile_picture_url"] ??
                    ""; //"assets/images/default_Profile.png";
                item1Profile = itemProfileName;
              }
            }
          }

          _model.addChatRoom(ChatRoom(
              ChatMember(
                  Keyword: item1Keyword,
                  itemid: item1,
                  nickname: "",
                  uid: itemOwner,
                  profileUrl: item1Profile,
                  photoUrl: item1Img),
              ChatMember(
                  Keyword: item2Keyword,
                  itemid: item2,
                  nickname: "",
                  uid: item2Owner,
                  profileUrl: item2Profile,
                  photoUrl: item2Img),
              chatID,
              _matchService.matchItemList![i].toString(),
              "",
              "",
              create,
              false,
              updateChatMessage));
          notifyListeners();
        }
      }

      return true; // 모든 작업이 성공적으로 완료된 경우 true를 반환
    } catch (e) {
      print('Error in createContentList: $e');
      return false; // 에러가 발생한 경우 false를 반환
    }
  }

  Future<bool> leaveChatRoom(String chatId) async {
    final api = FirebaseAPI();
    // ChatId와 일치하는 요소 찾기
    ChatRoom? chatRoomToRemove;
    for (var chatRoom in _model.chatroomList) {
      if (chatRoom.chatId == chatId) {
        chatRoomToRemove = chatRoom;
        break;
      }
    }

    // 찾은 요소의 리스너 해지
    if (chatRoomToRemove != null) {
      chatRoomToRemove.chatMonitoring.stopMonitoring();
    }

    // ChatId와 일치하는 요소 제거
    _model.chatroomList.removeWhere((element) => element.chatId == chatId);

    api.leaveChatOnCallFunction(chatId, _userService.uid.toString());
    notifyListeners();

    return true;
  }

  Future<bool> sendChatMessage(ChatRoom room, String From, String to) async {
    final result = room.onFieldSubmitted(room.chatId, From, to);
    if (result == true) {
      notifyListeners();
      return true; // ChatRoom을 성공적으로 제거한 경우 true 반환
    } else {
      return false;
    }
  }

  void onFieldChanged(String term) {
    notifyListeners();
  }

  void viewUpdateField(String chatRoomId, String msgId) async {
    final firebaseApp = Firebase.app();
    final rtdb = FirebaseDatabase.instanceFor(
        app: firebaseApp,
        databaseURL:
            'https://earthuswap-dev-chat.asia-southeast1.firebasedatabase.app/');

    DatabaseReference message =
        rtdb.ref("chats").child(chatRoomId).child('messages').child(msgId);

    // A post entry.
    final Data = {
      'read_at': DateTime.now().toString(),
    };

    message.update(Data);
    notifyListeners();
  }

  void sortChatRoomsBycreate() {
    model.sortChatRoomsBycreate();
    // 새로운 순서로 정렬된 리스트로 상태를 갱신
    notifyListeners();
  }

  void clearModel() {
    _matchService.removeListener(() {});
    for (var element in _model.chatroomList) {
      element.chatMonitoring.stopMonitoring();
    }

    _model.clearChatRoomList();
    _model.clearModel();
    _model = ChatModel();
  }
}
