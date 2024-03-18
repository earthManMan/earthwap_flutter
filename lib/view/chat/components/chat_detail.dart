import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:firebase_login/service/userService.dart';
import 'package:firebase_login/viewModel/chatViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';

import 'package:firebase_login/model/chatModel.dart';
//import 'package:extended_image/extended_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_login/components/profile_image_widget.dart';
import 'package:firebase_login/components/user_profile_widget.dart';
import 'package:firebase_login/components/theme.dart';

import 'package:firebase_login/application_options.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ChatRoomListView extends StatefulWidget {
  final Function(ChatRoom) updateChatRoom;
  final bool _isEditing;
  final List<ChatRoom> _roomList;
  final ChatViewModel _viewmodel;

  const ChatRoomListView(
      {super.key,
      required this.updateChatRoom,
      required bool isEditing,
      required List<ChatRoom> rooms,
      required ChatViewModel viewmodel})
      : _isEditing = isEditing,
        _roomList = rooms,
        _viewmodel = viewmodel;

  @override
  _ChatRoomListViewState createState() => _ChatRoomListViewState();
}

class _ChatRoomListViewState extends State<ChatRoomListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      cacheExtent: 1000,
      itemCount: widget._roomList.length,
      itemBuilder: (context, index) {
        ChatRoom room = widget._roomList[index];
        return Slidable(
            key: Key(room.user1.Keyword),
            startActionPane: null,
            endActionPane: ActionPane(
              extentRatio: 0.25,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => removeItem(room),
                  backgroundColor: const Color.fromARGB(255, 255, 0, 77),
                  foregroundColor: Colors.white,
                  icon: Icons.delete_forever,
                ),
              ],
            ),
            child: CustomListItem(
              room: room,
              edit: widget._isEditing,
              isSelected: room.isSelected,
              viewmodel: widget._viewmodel,
            ));
      },
    );
  }

  void removeItem(ChatRoom item) {
    //UserModel user = Provider.of<UserModel>(context, listen: false);
    final user = UserService.instance;
    final api = FirebaseAPI();
    api.leaveChatOnCallFunction(item.chatId, user.uid!).then((value) {
      setState(() {
        // 아이템 제거 후 상태 갱신
        widget._roomList.remove(item);
        widget.updateChatRoom(item);
      });
    });
  }
}

class CustomListItem extends StatefulWidget {
  final ChatRoom room;
  final bool edit;
  late bool isSelected;
  final ChatViewModel viewmodel;

  CustomListItem({
    super.key,
    required this.room,
    required this.edit,
    required this.isSelected,
    required this.viewmodel,
  });

  @override
  _CustomListItemState createState() => _CustomListItemState();
}

class _CustomListItemState extends State<CustomListItem> {
  int countNotRead = 0;

  int countUnreadMessages(List<ChatMessage> messages) {
    int unreadCount = 0;

    messages.sort((a, b) => a.time.compareTo(b.time));
    bool foundLastSentMessage = false; // 마지막 보낸 메시지가 나인 경우

    for (int i = 0; i < messages.length; i++) {
      if (i == messages.length) {
        if (messages[i].from == UserService.instance.uid) {
          foundLastSentMessage = true;
        }
      }
      if ((messages[i].from != UserService.instance.uid) && !messages[i].read) {
        unreadCount++;
      }
    }

    // 마지막으로 내가 보낸 메시지가 있다면 모든 메시지가 읽힌 것으로 간주
    if (foundLastSentMessage) {
      unreadCount = 0;
    }

    return unreadCount;
  }

  @override
  void initState() {
    super.initState();

    // ChatViewModel의 변경을 구독하고, 변경 시 위젯을 다시 빌드
    widget.viewmodel.addListener(_handleViewModelChange);

    // 초기 데이터 가져오기 또는 다른 작업 수행
  }

  @override
  void dispose() {
    super.dispose();
    if (mounted) {
      // 리스너를 제거하여 누수 방지
      widget.viewmodel.removeListener(_handleViewModelChange);
    }
  }

  void _handleViewModelChange() {
    // ChatViewModel의 변경이 감지될 때 실행할 로직
    // setState()를 호출하거나 다시 빌드하는 등의 작업 수행
    if (mounted) {
      setState(() {
        countNotRead = countUnreadMessages(widget.room.messages);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!widget.edit) {
          for (int i = 0; i < widget.room.messages.length; i++) {
            if (widget.room.messages[i].read == false) {
              widget.room.messages[i].read = true;
              widget.viewmodel.viewUpdateField(
                  widget.room.chatId, widget.room.messages[i].msg_id);
            }
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChatScreen(info: widget.room, viewmodel: widget.viewmodel),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            if (widget.edit)
              Checkbox(
                value: widget.isSelected,
                onChanged: (value) {
                  // Handle checkbox state change here
                  setState(() {
                    widget.isSelected = value!;
                    widget.room.isSelected = value;
                  });
                },
              ),
            widget.room.user1.photoUrl!.isEmpty
                ? const Text('이미지 없음')
                : ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      width: 56,
                      height: 56,
                      imageUrl: widget.room.user1.photoUrl!,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>  Center(
                        child: PlatformCircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.room.user1.Keyword} vs ${widget.room.user2.Keyword}",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 240, 244, 248),
                        fontFamily: "SUIT",
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(widget.room.description,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 154, 154, 154),
                        fontFamily: "SUIT",
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            Column(
              children: [
                Text(widget.room.date,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 154, 154, 154),
                      fontFamily: "SUIT",
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    )),
                if (countNotRead != 0)
                  SizedBox(
                      width: 25,
                      height: 25,
                      child: Badge(
                        backgroundColor: ColorStyles.primary,
                        label: Text(
                          countNotRead.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        alignment: Alignment.topCenter,
                      ))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final ChatRoom _room;
  final ChatViewModel _viewmodel;
  const ChatScreen(
      {super.key, required ChatRoom info, required ChatViewModel viewmodel})
      : _room = info,
        _viewmodel = viewmodel;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewmodel, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            centerTitle: true,
            title: const Text("채팅",
                style: TextStyle(
                  color: Color.fromARGB(255, 240, 244, 248),
                  fontFamily: "SUIT",
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
            backgroundColor: const Color.fromARGB(255, 20, 20, 20),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // 뒤로가기 버튼이 눌렸을 때의 동작
                Navigator.of(context).pop();
              },
            ),
            // TODO : 채팅방 옵션 나중에 추가
            /*
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // 설정 아이콘이 눌렸을 때의 동작
                },
              ),
            ],
            */
          ),
          body: Container(
            color: const Color.fromARGB(255, 20, 20, 20),
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: NotificationMessage(room: _room)),
                ChatListView(room: _room, viewmodel: _viewmodel),
                Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child:
                        BottomInputField(room: _room, viewmodel: _viewmodel)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NotificationMessage extends StatefulWidget {
  final ChatRoom room;

  const NotificationMessage({
    super.key,
    required this.room,
  });

  @override
  _NotificationMessageState createState() => _NotificationMessageState();
}

class _NotificationMessageState extends State<NotificationMessage> {
  bool isExpanded = false;

  void toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleExpanded,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 15), // Add padding to left and right
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20), // Set your desired radius
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isExpanded ? '매칭된 물건 보기' : '매칭된 물건 보기',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.arrow_upward_sharp
                            : Icons.arrow_downward_sharp,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                child: CachedNetworkImage(
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.fill,
                                  imageUrl: widget.room.user1.photoUrl!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) =>  Center(
                                    child: PlatformCircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                                /* ExtendedImage.network(
                                  widget.room.user1.photoUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.fill,
                                  cache: true,
                                  loadStateChanged: (ExtendedImageState state) {
                                    switch (state.extendedImageLoadState) {
                                      case LoadState.loading:
                                        return Center(
                                            child: CircularProgressIndicator());
                                      case LoadState.completed:
                                        return null;
                                      case LoadState.failed:
                                        return Icon(Icons.error);
                                    }
                                  },
                                ),*/
                              ),
                              Positioned(
                                left: 40, // 이미지 간격 조절
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  child: CachedNetworkImage(
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.fill,
                                    imageUrl: widget.room.user2.photoUrl!,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) =>  Center(
                                      child: PlatformCircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                  /*ExtendedImage.network(
                                    widget.room.user2.photoUrl!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.fill,
                                    cache: true,
                                    loadStateChanged:
                                        (ExtendedImageState state) {
                                      switch (state.extendedImageLoadState) {
                                        case LoadState.loading:
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        case LoadState.completed:
                                          return null;
                                        case LoadState.failed:
                                          return Icon(Icons.error);
                                      }
                                    },
                                  ),*/
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 4), // Add padding to the bottom
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: '나의 물건 : ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: widget.room.user1.Keyword),
                                    ],
                                  ),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: '매칭 물건 : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: widget.room.user2.Keyword),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatListView extends StatefulWidget {
  final ChatRoom room;
  final ChatViewModel viewmodel;
  const ChatListView({
    super.key,
    required this.room,
    required this.viewmodel,
  });

  @override
  _ChatListViewState createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  bool isOutUser = false;
  @override
  void initState() {
    super.initState();
    if (widget.room.user1.uid.isEmpty) isOutUser = true;
    if (widget.room.user2.uid.isEmpty) isOutUser = true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewmodel, child) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              widget.room.focusNode.unfocus();
            },
            child: Align(
              alignment: Alignment.topCenter,
              child: ListView.separated(
                cacheExtent: 1000,
                shrinkWrap: true,
                reverse: true,
                padding: const EdgeInsets.only(top: 12, bottom: 20) +
                    const EdgeInsets.symmetric(horizontal: 12),
                separatorBuilder: (_, __) => const SizedBox(
                  height: 12,
                ),
                controller: widget.room.scrollController,
                itemCount: isOutUser == true
                    ? widget.room.messages.length + 1
                    : widget.room.messages.length,
                itemBuilder: (context, index) {
                  if (isOutUser == true) {
                    if (index == 0) {
                      // This is where you display the exit message
                      return const ListTile(
                          title: Center(child: Text("상대방이 채팅방을 나갔습니다.")));
                    }
                  }

                  final user = UserService.instance;
                  String profile = "";
                  String uid = "";
                  user.uid.toString() == widget.room.user1.uid
                      ? {
                          profile = widget.room.user2.profileUrl.toString(),
                          uid = widget.room.user2.uid
                        }
                      : {
                          profile = widget.room.user1.profileUrl.toString(),
                          uid = widget.room.user1.uid
                        };

                  if (isOutUser == true) {
                    return Bubble(
                        chat: widget.room.messages.reversed.toList()[index - 1],
                        profile: profile,
                        uid: uid);
                  } else {
                    return Bubble(
                        chat: widget.room.messages.reversed.toList()[index],
                        profile: profile,
                        uid: uid);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class BottomInputField extends StatefulWidget {
  final ChatRoom room;
  final ChatViewModel viewmodel;

  const BottomInputField({
    super.key,
    required this.room,
    required this.viewmodel,
  });

  @override
  _BottomInputFieldState createState() => _BottomInputFieldState();
}

class _BottomInputFieldState extends State<BottomInputField> {
  bool isOutUser = false;
  String sendImage = "";

  @override
  void initState() {
    super.initState();
    isOutUser = isOutUserCheck();

    final options = RemoteConfigService.instance;
    sendImage = options.getimages()["common_send"];
  }

  bool isOutUserCheck() {
    return widget.room.user1.uid.isEmpty || widget.room.user2.uid.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 30),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 20, 20, 20),
          border: Border(
            top: BorderSide(
              color: Color.fromARGB(255, 20, 22, 25),
            ),
          ),
        ),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IgnorePointer(
                      ignoring: isOutUser,
                      child: TextField(
                        enableInteractiveSelection: true,
                        focusNode: widget.room.focusNode,
                        onChanged: widget.viewmodel.onFieldChanged,
                        controller: widget.room.textEditingController,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(
                            right: 42,
                            left: 16,
                            top: 18,
                          ),
                          hintText: '메시지 보내기',
                          hintStyle: const TextStyle(
                            fontFamily: "SUIT",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 154, 154, 154),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: "SUIT",
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 10,
              child: IconButton(
                icon: CachedNetworkImage(
                  width: 32,
                  height: 32,
                  imageUrl: sendImage,
                  fit: BoxFit.cover,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) =>  Center(
                    child: PlatformCircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                onPressed: () {
                  final user = UserService.instance;
                  if (!isOutUser) {
                    widget.viewmodel
                        .sendChatMessage(
                      widget.room,
                      user.uid.toString(),
                      (user.uid.toString() == widget.room.user1.uid)
                          ? widget.room.user2.uid
                          : widget.room.user1.uid,
                    )
                        .then((value) {
                      setState(() {
                        widget.viewmodel.onFieldChanged;
                      });
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Bubble extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final ChatMessage chat;
  final String profile;
  final String uid;

  const Bubble({
    super.key,
    this.margin,
    required this.profile,
    required this.uid,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignmentOnType,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chat.type == ChatMessageType.received)
          ProfileImg(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: 999,
            callback: () {
              // TODO: User Click 시 User info Page로
              // 이미지를 누르면 Image 상세 정보를 나타내는 페이지로 이동
              if (UserService.instance.uid != uid) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserProfile(uid: uid),
                  ),
                );
              }
            },
            height: 60,
            width: 60,
            imageUrl: profile,
          ),
        Container(
          margin: margin ?? EdgeInsets.zero,
          child: PhysicalShape(
            clipper: clipperOnType,
            elevation: 2,
            color: bgColorOnType,
            shadowColor: Colors.grey.shade200,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: paddingOnType,
              child: Column(
                crossAxisAlignment: crossAlignmentOnType,
                children: [
                  Text(
                    chat.message,
                    style: TextStyle(color: textColorOnType),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    Formatter.formatDateTime(chat.time),
                    style: TextStyle(
                        fontFamily: "SUIT",
                        fontWeight: FontWeight.bold,
                        color: textColorOnType,
                        fontSize: 12),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color get textColorOnType {
    switch (chat.type) {
      case ChatMessageType.sent:
        return Colors.white;
      case ChatMessageType.received:
        return const Color(0xFF0F0F0F);
    }
  }

  Color get bgColorOnType {
    switch (chat.type) {
      case ChatMessageType.received:
        return const Color(0xFFE7E7ED);
      case ChatMessageType.sent:
        return const Color(0xFF007AFF);
    }
  }

  CustomClipper<Path> get clipperOnType {
    switch (chat.type) {
      case ChatMessageType.sent:
        return ChatBubbleClipper1(type: BubbleType.sendBubble);
      case ChatMessageType.received:
        return ChatBubbleClipper1(type: BubbleType.receiverBubble);
    }
  }

  CrossAxisAlignment get crossAlignmentOnType {
    switch (chat.type) {
      case ChatMessageType.sent:
        return CrossAxisAlignment.end;
      case ChatMessageType.received:
        return CrossAxisAlignment.start;
    }
  }

  MainAxisAlignment get alignmentOnType {
    switch (chat.type) {
      case ChatMessageType.received:
        return MainAxisAlignment.start;

      case ChatMessageType.sent:
        return MainAxisAlignment.end;
    }
  }

  EdgeInsets get paddingOnType {
    switch (chat.type) {
      case ChatMessageType.sent:
        return const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 24);
      case ChatMessageType.received:
        return const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 24,
          right: 10,
        );
    }
  }
}
