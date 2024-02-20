import 'package:firebase_login/viewModel/chatViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_login/view/chat/components/chat_detail.dart';
import 'package:firebase_login/components/common_components.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  bool isEditing = false; // 편집 모드 상태
  final List<MenuItem> _MenuItem = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _buildMenuItems(BuildContext context) {
    if (_MenuItem.isEmpty) {
      _MenuItem.add(MenuItem(
          callback: () {
            setState(() {
              final ViewModel =
                  Provider.of<ChatViewModel>(context, listen: false);
              ViewModel.sortChatRoomsBycreate();
              Navigator.pop(context);
            });
          },
          Content: '최근 생성 순',
          textColor: Colors.white));
    }
  }

  @override
  Widget build(BuildContext context) {
    _buildMenuItems(context);

    return Consumer<ChatViewModel>(
      builder: (context, chatViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: isEditing // 편집 모드일 때 leading에 '완료' TextButton 배치
                ? TextButton(
                    child: const Text("완료",
                        style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 241, 240, 240))),
                    onPressed: () {
                      // 완료 버튼의 동작을 정의
                      isEditing = false;
                      chatViewModel.model.chatroomList.removeWhere((item) {
                        if (item.isSelected) {
                          chatViewModel
                              .leaveChatRoom(item.chatId)
                              .then((value) {
                            setState(() {
                              // 아이템 제거 후 상태 갱신
                              chatViewModel.model.chatroomList.remove(item);
                            });
                          });
                          return true; // 선택된 아이템이 제거되도록 true를 반환
                        }
                        return false; // 선택되지 않은 아이템은 그대로 유지되도록 false를 반환
                      });
                    },
                  )
                : null, // 편집 모드가 아닐 때는 leading을 null로 설정하여 아무것도 배치하지 않음
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
                icon: isEditing
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            isEditing = false;
                            chatViewModel.model.chatroomList
                                .removeWhere((item) {
                              if (item.isSelected) {
                                chatViewModel
                                    .leaveChatRoom(item.chatId)
                                    .then((value) {
                                  setState(() {
                                    // 아이템 제거 후 상태 갱신
                                    chatViewModel.model.chatroomList
                                        .remove(item);
                                  });
                                });
                                return true; // 선택된 아이템이 제거되도록 true를 반환
                              }
                              return false; // 선택되지 않은 아이템은 그대로 유지되도록 false를 반환
                            });
                          });
                        },
                        icon: const Icon(Icons.delete_rounded))
                    : ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Color.fromARGB(255, 151, 152, 152), // 필터 색상을 지정
                          BlendMode.dstIn, // 필터 모드를 지정
                        ),
                        child: Image.asset('assets/components/menu.png'),
                      ),
              ),
              if (!isEditing)
                IconButton(
                  onPressed: () => showOptions(context, '채팅방 정렬', _MenuItem),
                  icon: const Icon(Icons.more_vert),
                ),
            ],
            centerTitle: isEditing, // 편집 모드일 때만 title을 가운데 정렬
            title: Text(
              isEditing ? '편집' : '채팅',
              style: const TextStyle(
                  fontSize: 18, // 원하는 크기로 조정
                  fontFamily: "SUIT",
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 240, 244, 248)),
            ),
            iconTheme: const IconThemeData(
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            backgroundColor: const Color.fromARGB(255, 20, 22, 25),
          ),
          body: chatViewModel.model.chatroomList.isEmpty == true
              ? const Center(
                  child: Text("대화 상대가 없습니다."), // 업데이트 중 표시
                )
              : ChatRoomListView(
                  updateChatRoom: (item) {
                    setState(() {
                      chatViewModel.model.chatroomList.remove(item);
                    });
                  },
                  isEditing: isEditing,
                  rooms: chatViewModel.model.chatroomList,
                  viewmodel: chatViewModel),
        );
      },
    );
  }
}
