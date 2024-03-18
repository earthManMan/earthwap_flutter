import 'package:firebase_login/viewModel/mypageViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/model/postItemModel.dart';
import 'package:firebase_login/components/common_components.dart';
import 'package:firebase_login/service/userService.dart';
import 'package:firebase_login/components/profile_image_widget.dart';
import 'package:firebase_login/components/user_profile_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_login/components/theme.dart';
import 'package:firebase_login/viewModel/worldViewModel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_login/components/content/post_comment_widget.dart';
import 'package:firebase_login/components/content/edit_post_widget.dart';
import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

String getCurrentTime(String seconds) {
  int unixSeconds = int.parse(seconds);
  // Unix 시간 형식으로 저장된 _seconds 값을 사용하여 DateTime 객체 생성
  DateTime pastTime = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);

  // 현재 시간을 얻습니다.
  DateTime currentTime = DateTime.now();

  // 현재 시간과 과거 시간의 차이를 계산합니다.
  Duration difference = currentTime.difference(pastTime);

  // 차이를 분 단위로 계산합니다.
  int minutesDifference = difference.inMinutes;

  if (minutesDifference >= 60) {
    // 1시간 이상 차이가 나면 시간 단위로 반환
    int hoursDifference = difference.inHours;
    if (hoursDifference >= 24) {
      int daysDifference = difference.inDays;
      return "$daysDifference일 전";
    } else {
      return "$hoursDifference시간 전";
    }
  } else {
    // 1시간 미만이면 분 단위로 반환
    return "$minutesDifference분 전";
  }
}

// 시간 문자열을 DateTime으로 변환하는 함수
DateTime parseFormattedDate(String formattedDate) {
  if (formattedDate.contains('일전')) {
    // 일 전의 경우
    int daysAgo = int.parse(formattedDate.split('일')[0]);
    return DateTime.now().subtract(Duration(days: daysAgo));
  } else if (formattedDate.contains('시간') && formattedDate.contains('분')) {
    // 시간과 분 전의 경우
    int hoursAgo = int.parse(formattedDate.split('시간')[0]);
    int minutesAgo = int.parse(formattedDate.split('시간 ')[1].split('분')[0]);
    return DateTime.now()
        .subtract(Duration(hours: hoursAgo, minutes: minutesAgo));
  } else if (formattedDate.contains('1일전')) {
    // 어제인 경우
    return DateTime.now().subtract(const Duration(days: 1));
  } else {
    return DateTime.now();
  }
}

class PostDetailPage extends StatefulWidget {
  PostItemModel itemModel;

  bool isOwner = true;
  final Function(PostItemModel info) onUpdateItemCallback;
  final Function(PostItemModel info) onDeleteItemCallback;

  PostDetailPage({
    required PostItemModel item,
    required this.onUpdateItemCallback,
    required this.onDeleteItemCallback,
    super.key,
  }) : itemModel = item {
    final user = UserService.instance;
    if (user.uid != itemModel.onwerId) {
      // 상대방의 Item
      isOwner = false;
    }
  }

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  List<MenuItem> _menuItems = [];
  List<CommentModel> _comments = [];
  int visibleCommentsCount = 3; // 처음에 보여줄 댓글 수
  bool showAllComments = true; // 댓글 전체를 보여줄지 여부
  bool showBottomField = true;
  @override
  void initState() {
    super.initState();
    buildMenuItems(context);
    _comments = widget.itemModel.comments;

// _comments 리스트를 formattedDate를 기준으로 정렬
    _comments.sort((a, b) {
      DateTime timeA = parseFormattedDate(a.time);
      DateTime timeB = parseFormattedDate(b.time);

      return timeA.compareTo(timeB);
    });
  }

  void buildMenuItems(BuildContext context) {
    if (widget.isOwner) {
      _menuItems = [
        MenuItem(
            callback: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => EditPostPage(
                          post: widget.itemModel,
                          onModifyItem: (item, state) {
                            if (state) {
                              setState(() {
                                widget.itemModel = item;
                                final api = FirebaseAPI();
                                widget.onUpdateItemCallback(item);
                                api.updateContentOnCallFunction(
                                  widget.itemModel.onwerId,
                                  widget.itemModel.communityID,
                                  widget.itemModel.contentID,
                                  {
                                    'title': widget.itemModel.title,
                                    'body': widget.itemModel.description,
                                    'images': widget.itemModel.contentImg,
                                  },
                                );
                              });
                            } else {
                              setState(() {
                                widget.onUpdateItemCallback(item);
                                widget.itemModel = item;
                              });
                            }
                          },
                        )),
              );
            },
            Content: '수정 하기',
            textColor: Colors.white),
        MenuItem(
            callback: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();

              if (widget.itemModel.onwerId == UserService.instance.uid) {
                final viewmodel =
                    Provider.of<MypageViewModel>(context, listen: false);
                viewmodel.deleteContent(widget.itemModel.contentID);
              } else {
                final api = FirebaseAPI();
                api.deleteContentOnCallFunction(widget.itemModel.onwerId,
                    widget.itemModel.communityID, widget.itemModel.contentID);
              }
              widget.onDeleteItemCallback(widget.itemModel);
            },
            Content: '삭제 하기',
            textColor: Colors.white),
      ];
    } else {
      _menuItems = [
        MenuItem(
            callback: () {
              final api = FirebaseAPI();
              api.reportOnCallFunction(UserService.instance.uid!,
                  widget.itemModel.onwerId, "게시글을 신고하였습니다.");
            },
            Content: '신고 하기',
            textColor: Colors.white),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final ViewModel = Provider.of<WorldViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(size: 20, Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        backgroundColor: const Color.fromARGB(255, 20, 22, 25),
        actions: [
          IconButton(
            icon: const Icon(size: 20, Icons.more_vert),
            onPressed: () => showOptions(context, '게시글 옵션', _menuItems),
          )
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  if (widget.itemModel.profileImg.isEmpty)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 255, 255, 255),
                        image: DecorationImage(
                          image:
                              AssetImage("assets/images/default_Profile.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    ProfileImg(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: 999,
                      callback: () {
                        if (UserService.instance.uid !=
                            widget.itemModel.onwerId) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserProfile(uid: widget.itemModel.onwerId),
                            ),
                          );
                        }
                      },
                      height: 60,
                      width: 60,
                      imageUrl: widget.itemModel.profileImg,
                    ),
                  const SizedBox(width: 10), // 간격 조절
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.itemModel.nickName,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "\n${getCurrentTime(widget.itemModel.date)}",
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(context).size.width * 0.8), // 원하는 최대 폭
                child: Text(
                  widget.itemModel.title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                widget.itemModel.description,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Color.fromARGB(255, 147, 147, 147),
                ),
              ),
            ),
            if (widget.itemModel.contentImg.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(10),
                child: CachedNetworkImage(
                  width: 150,
                  height: 150,
                  fit: BoxFit.fill,
                  imageUrl: widget.itemModel.contentImg,
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
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () {
                    ViewModel.contentLike(widget.itemModel.contentID.toString())
                        .then((value) => {
                              if (value)
                                setState(() {
                                  widget.itemModel.likes =
                                      widget.itemModel.likes.toInt() + 1;
                                })
                            });
                  },
                  icon: const Icon(Icons.favorite_border,
                      color: ColorStyles.text),
                  label: Text(
                    widget.itemModel.likes.toString(),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon:
                      const Icon(Icons.chat_outlined, color: ColorStyles.text),
                  label: Text(
                    _comments.length.toString(), // 댓글 수로 변경
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.remove_red_eye_outlined,
                      color: ColorStyles.text),
                  label: Text(
                    widget.itemModel.views.toString(),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            Container(
              height: 0.5,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: ColorStyles.background,
                ),
              ),
            ),
            if (_comments.isNotEmpty)
              ListView.builder(
                cacheExtent: 1000,
                itemCount: _comments.length <= 3
                    ? _comments.length
                    : showAllComments
                        ? _comments.length
                        : visibleCommentsCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return CommentWidget(
                    onRepliesWidget: (state) {
                      setState(() {
                        showBottomField = !state;
                      });
                    },
                    comment: _comments[index],
                    onDeleteComment: (comment) {
                      setState(() {
                        widget.itemModel.comments.remove(comment);
                        _comments = widget.itemModel.comments;
                        widget.onUpdateItemCallback(widget.itemModel);
                      });
                    },
                    onDeleteCommentReplies: (comment, replies) {
                      setState(() {
                        for (var item in widget.itemModel.comments) {
                          if (item == comment) {
                            item.replies
                                .removeWhere((reply) => reply == replies);
                          }
                        }
                        _comments = widget.itemModel.comments;
                        widget.onUpdateItemCallback(widget.itemModel);
                      });
                    },
                  );
                },
              ),
            if (_comments.length > visibleCommentsCount)
              TextButton(
                onPressed: () {
                  setState(() {
                    showAllComments = !showAllComments;
                  });
                },
                child: Text(
                  showAllComments ? '댓글 접기' : '댓글 더보기(${_comments.length - 3})',
                  style:
                      const TextStyle(color: ColorStyles.primary, fontSize: 15),
                ),
              ),
          ],
        ),
      ),
      bottomSheet: showBottomField == true
          ? BottomInputField(
              contentid: widget.itemModel.contentID.toString(),
            )
          : null,
    );
  }
}
