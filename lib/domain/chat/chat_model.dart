import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:firebase_login/domain/chat/chatService.dart';
import 'package:firebase_login/domain/login/userService.dart';
import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:firebase_login/presentation/components/Encryptoring.dart';
import 'package:firebase_login/app/config/constant.dart';


class ChatMessage {
  late String msg_id;
  final String message;
  final String from;
  final String to;
  final DateTime time;
  bool read;
  final ChatMessageType type;

  ChatMessage(
      {required this.message,
      required this.type,
      required this.from,
      required this.to,
      required this.read,
      required this.time});

  factory ChatMessage.sent(
          {required message, required type, required from, required to}) =>
      ChatMessage(
          message: message,
          type: type,
          from: from,
          to: to,
          read: true,
          time: DateTime.now());

  // 이 메서드를 추가하여 DataSnapshot에서 Chat 객체로 변환
  factory ChatMessage.fromSnapshot(Map<dynamic, dynamic> data) {
    final userService = UserService.instance;

    final message = data['msg'] as String;
    final from = data['from'] as String;
    final to = data['to'] as String;
    final timestamp = DateTime.parse(data['created_at']);

    StringEncryptor encryptor = StringEncryptor.instance;

    final decryptText = encryptor.AES_decrypt(message);
    bool read = false;
    data['read_at'].toString() == "null" ? read = false : read = true;

    return ChatMessage(
      message: decryptText,
      type: from == userService.uid
          ? ChatMessageType.sent
          : ChatMessageType.received,
      from: from,
      to: to,
      read: from == userService.uid ? true : read,
      time: timestamp,
    );
  }

  static List<ChatMessage> generate() {
    return [];
  }
}

abstract class Formatter {
  Formatter._();

  static String formatDateTime(DateTime dateTime) {
    final DateFormat dateFormat = DateFormat('hh:mm a');
    return dateFormat.format(dateTime);
  }
}

// 채팅 룸 Member
class ChatMember {
  String nickname;
  String uid;
  String? photoUrl;
  String? profileUrl;
  String Keyword;
  String itemid;

  ChatMember(
      {required this.nickname,
      required this.uid,
      this.photoUrl,
      this.profileUrl,
      required this.Keyword,
      required this.itemid});
}

class ChatRoom {
  ChatMember user1;
  ChatMember user2;

  final String chatId;
  final String matchId;
  final String description;

  List<ChatMessage> messages = [];

  String date; // 마지막 Message time
  String create_at; // 채팅 룸 생성 시간
  bool isSelected;
  late ChatService chatMonitoring; // ChatMonitoring 객체
  late final Function(ChatMessage, String)
      onNewChatReceived; // Callback to handle new chat data

  /* Controllers */
  late final ScrollController scrollController = ScrollController();
  late final TextEditingController textEditingController =
      TextEditingController();
  late final FocusNode focusNode = FocusNode();

  ChatRoom(this.user1, this.user2, this.chatId, this.matchId, this.description,
      this.date, this.create_at, this.isSelected, this.onNewChatReceived) {
    chatMonitoring = ChatService(chatId, onNewChatReceived);
  }

  /* Intents */
  bool onFieldSubmitted(String chatid, String from, String to) {
    if (!isTextFieldEnable) return false;

    StringEncryptor encryptor = StringEncryptor.instance;

    final encryptText = encryptor.AES_encrypt(textEditingController.text);

    final api = FirebaseAPI();
    api.sendMessageOnCallFunction(chatid, encryptText, from, to);

    // 2. 스크롤 최적화 위치
    // 가장 위에 스크롤 된 상태에서 채팅을 입력했을 때 최근 submit한 채팅 메세지가 보이도록
    // 스크롤 위치를 가장 아래 부분으로 변경
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 30),
      curve: Curves.easeInOut,
    );

    textEditingController.text = '';
    return true;
  }

  /* Getters */
  bool get isTextFieldEnable => textEditingController.text.isNotEmpty;
}

class ChatModel {
  final List<ChatRoom> _chatroomList = [];

  // 아이템 정보 리스트를 직접 노출하지 않고 읽기 전용 getter를 제공합니다.
  List<ChatRoom> get chatroomList => _chatroomList.toList();

  // 아이템 정보 리스트를 설정하는 메서드
  void setChatRoomList(List<ChatRoom> rooms) {
    _chatroomList.clear(); // 기존 리스트 비우기
    _chatroomList.addAll(rooms); // 새로운 리스트 추가
  }

  void sortChatRoomsBycreate() {
    _chatroomList.sort((a, b) => a.create_at.compareTo(b.create_at));
  }

  // 아이템 정보를 추가하는 메서드
  void addChatRoom(ChatRoom room) {
    _chatroomList.add(room);
  }

  // 아이템 정보 리스트를 비우는 메서드
  void clearChatRoomList() {
    _chatroomList.clear();
  }

  void clearModel() {
    _chatroomList.clear();
  }
}
