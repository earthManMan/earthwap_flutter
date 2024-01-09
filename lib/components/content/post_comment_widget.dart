import 'package:firebase_login/components/theme.dart';
import 'package:firebase_login/service/userService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/model/postItemModel.dart';
import 'package:firebase_login/components/profile_image_widget.dart';
import 'package:firebase_login/components/user_profile_widget.dart';
import 'package:provider/provider.dart';
import 'package:firebase_login/viewModel/mypageViewModel.dart';

import 'package:firebase_login/application_options.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommentWidget extends StatefulWidget {
  final CommentModel comment;
  final Function(bool) onRepliesWidget;
  final Function(CommentModel) onDeleteComment;
  final Function(CommentModel, CommentModel) onDeleteCommentReplies;

  const CommentWidget(
      {super.key,
      required this.comment,
      required this.onRepliesWidget,
      required this.onDeleteComment,
      required this.onDeleteCommentReplies});

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool expanded = false;
  bool isCommenting = false;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String sendImage = "";

  @override
  void initState() {
    super.initState();

    final options = RemoteConfigService.instance;
    sendImage = options.getimages()["common_send"];
  }

  @override
  Widget build(BuildContext context) {
    final ViewModel = Provider.of<MypageViewModel>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildUserCommentTile(ViewModel),
        buildAdditionalActions(ViewModel),
        if (expanded) buildExpandedReplies(ViewModel),
      ],
    );
  }

  Widget buildUserCommentTile(MypageViewModel ViewModel) {
    // 사용자 정보와 댓글을 나타내는 ListTile
    return ListTile(
      leading: ProfileImg(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: 999,
        callback: () {
          if (UserService.instance.uid != widget.comment.owner_id) {
            // 이미지 클릭 시 해당 사용자 정보 페이지로 이동
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserProfile(uid: widget.comment.owner_id),
              ),
            );
          }
        },
        height: 60,
        width: 60,
        imageUrl: widget.comment.profileImage,
      ),
      title: RichText(
        // 사용자 닉네임과 시간을 나타내는 RichText
        text: TextSpan(
          children: [
            TextSpan(
              text: widget.comment.user_nickName,
              style: const TextStyle(/* 사용자 닉네임에 대한 스타일 설정 */),
            ),
            const TextSpan(text: ' • '), // 사용자 닉네임과 시간 사이의 공백 (선택적)
            TextSpan(
              text: widget.comment.time,
              style: const TextStyle(color: ColorStyles.content, fontSize: 10),
            ),
          ],
        ),
      ),
      subtitle: Text(widget.comment.comment), // 댓글 내용
      trailing: PopupMenuButton<String>(
        // 댓글에 대한 더보기 옵션 팝업 메뉴
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          if (widget.comment.owner_id == UserService.instance.uid!)
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('삭제 하기'),
            ),
          const PopupMenuItem<String>(
            value: 'report',
            child: Text('신고 하기'),
          ),
        ],
        onSelected: (String value) {
          // 팝업 메뉴에서 선택한 동작 수행
          if (value == 'delete') {
            ViewModel.deleteComment(
                    widget.comment.content_id, widget.comment.comment_id, "")
                .then((value) => {
                      setState(() {
                        // 아이템 제거 후 상태 갱신
                        widget.onDeleteComment(widget.comment);
                      }),
                    });
          } else if (value == 'report') {
            ViewModel.reportUser(widget.comment.owner_id, "댓글을 신고하였습니다.");
          }
        },
      ),
    );
  }

  Widget buildAdditionalActions(MypageViewModel ViewModel) {
    // 댓글에 대한 추가 동작을 수행할 수 있는 영역
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCommenting) buildCommentInputSection(ViewModel),
          if (!isCommenting) buildCommentButton(),
          if (widget.comment.replies.isNotEmpty) buildRepliesSection(),
        ],
      ),
    );
  }

  Widget buildCommentInputSection(MypageViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              isCommenting = false;
              widget.onRepliesWidget(isCommenting);
            });
          },
          child: const Text(
            '댓글 닫기',
            style: TextStyle(
              color: ColorStyles.content,
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    enableInteractiveSelection: true,
                    controller: _commentController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(
                        right: 42,
                        left: 16,
                        top: 18,
                      ),
                      hintText: '댓글을 입력하세요.',
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
                IconButton(
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
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  onPressed: () {
                    setState(() {
                      String comment = _commentController.text;
                      if (comment.isNotEmpty) {
                        viewModel.writeComment(
                          widget.comment.content_id,
                          widget.comment.comment_id,
                          comment,
                        );
                      }
                      isCommenting = false;
                      widget.onRepliesWidget(isCommenting);
                      _commentController.clear();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCommentButton() {
    // 댓글 입력 중이 아닌 경우에 표시되는 UI
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 16.0),
      child: TextButton(
        onPressed: () {
          setState(() {
            isCommenting = true;
            widget.onRepliesWidget(isCommenting);
          });
        },
        child: const Text(
          '댓글달기',
          style: TextStyle(
            color: ColorStyles.text,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget buildRepliesSection() {
    // 답글을 확장/축소하는 동작을 수행할 수 있는 GestureDetector
    return GestureDetector(
      onTap: () {
        setState(() {
          expanded = !expanded;
        });
      },
      child: Row(
        children: [
          Icon(
            expanded ? Icons.arrow_upward : Icons.arrow_downward,
            size: 10,
            color: ColorStyles.text,
          ),
          const SizedBox(width: 5),
          Text(
            expanded
                ? '답글 (${widget.comment.replies.length})'
                : '댓글 (${widget.comment.replies.length})개 모두 보기',
            style: const TextStyle(
              color: ColorStyles.text,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExpandedReplies(MypageViewModel ViewModel) {
    // 확장된 상태에서 답글을 나타내는 영역
    return Padding(
      padding: const EdgeInsets.only(left: 56.0, right: 16.0),
      child: Column(
        children: widget.comment.replies.map((reply) {
          return ListTile(
            leading: ProfileImg(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: 999,
              callback: () {
                if (UserService.instance.uid != reply.owner_id) {
                  // 이미지를 누르면 Image 상세 정보를 나타내는 페이지로 이동
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserProfile(uid: reply.owner_id),
                    ),
                  );
                }
              },
              height: 60,
              width: 60,
              imageUrl: reply.profileImage,
            ),

            title: RichText(
              // 사용자 닉네임과 시간을 나타내는 RichText
              text: TextSpan(
                children: [
                  TextSpan(
                    text: reply.user_nickName,
                    style: const TextStyle(/* 사용자 닉네임에 대한 스타일 설정 */),
                  ),
                  const TextSpan(text: ' • '), // 사용자 닉네임과 시간 사이의 공백 (선택적)
                  TextSpan(
                    text: reply.time,
                    style: const TextStyle(
                        color: ColorStyles.content, fontSize: 10),
                  ),
                ],
              ),
            ),
            subtitle: Text(reply.comment), // 댓글 내용
            trailing: PopupMenuButton<String>(
              // 댓글에 대한 더보기 옵션 팝업 메뉴
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                if (reply.owner_id == UserService.instance.uid!)
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('삭제 하기'),
                  ),
                const PopupMenuItem<String>(
                  value: 'report',
                  child: Text('신고 하기'),
                ),
              ],
              onSelected: (String value) {
                // 팝업 메뉴에서 선택한 동작 수행
                if (value == 'delete') {
                  ViewModel.deleteComment(
                          reply.content_id, reply.parent_id, reply.comment_id)
                      .then((value) => {
                            setState(() {
                              // 아이템 제거 후 상태 갱신
                              widget.onDeleteCommentReplies(
                                  widget.comment, reply);
                            }),
                          });
                } else if (value == 'report') {
                  ViewModel.reportUser(reply.owner_id, "댓글을 신고하였습니다.");
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
