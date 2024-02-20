import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_login/model/chatModel.dart';
import 'dart:async';

class ChatService {
  StreamSubscription<DatabaseEvent>? _chatListener;

  late final String chatRoomId;
  late final DatabaseReference chatDB;
  late final Function(ChatMessage, String)
      onNewChatReceived; // Callback to handle new chat data

  ChatService(this.chatRoomId, this.onNewChatReceived) {
    final firebaseApp = Firebase.app();
    final rtdb = FirebaseDatabase.instanceFor(
        app: firebaseApp,
        databaseURL:
            'https://earthuswap-dev-chat.asia-southeast1.firebasedatabase.app/');
    try {
      chatDB = rtdb.ref("chats").child(chatRoomId).child('messages');

      _startMonitoring();
    } catch (e) {
      print(e);
    }
  }

  void _startMonitoring() {
    _chatListener?.cancel();
    _chatListener = chatDB.onChildAdded.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final chatData = ChatMessage.fromSnapshot(data);
      chatData.msg_id = event.snapshot.key.toString();
      onNewChatReceived(chatData, chatRoomId);
    });
  }

  void stopMonitoring() {
    _chatListener?.cancel();
  }
}
