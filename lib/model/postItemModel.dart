import 'dart:ffi';
import 'dart:ui';

import 'package:firebase_login/service/commentService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:firebase_login/service/userService.dart';
import 'dart:async';

class PostItemModel {
  late String onwerId;
  late String communityID;
  late String contentID;
  late String profileImg;
  late String nickName;
  late String date;
  late String title;
  late String description;
  late String contentImg;
  late int likes;
  late int views;

  List<CommentModel> comments = [];

  late CommentService commentService;
  late final Function(bool) onNewComment; // Callback to handle new chat data

  PostItemModel({
    required this.onwerId,
    required this.communityID,
    required this.contentID,
    required this.profileImg,
    required this.nickName,
    required this.date,
    required this.title,
    required this.description,
    required this.contentImg,
    required this.likes,
    required this.views,
    required this.onNewComment,
  }) {
    commentService =
        CommentService(communityID, contentID, add_comment, add_replies);
  }
  void add_comment(Comment, id) {
    comments.add(Comment);
    onNewComment(true);
  }

  void add_replies(Comment, contentId, commentId) {
    for (var comment in comments) {
      if (comment.comment_id == commentId) {
        comment.replies.add(Comment);
      }
    }
    onNewComment(true);
  }
}

class CommentModel {
  static const String defaultProfileImg = "";
  static final FirebaseAPI api = FirebaseAPI();
  static final UserService user = UserService.instance;

  String owner_id = "";
  String comment_id = "";
  String content_id = "";
  String community_id = "";
  String parent_id = "";
  String profileImage = "";
  String user_nickName = "";
  String comment = "";
  String time = "";
  late final Function(CommentModel, String, String) onNewCommentreplies;

  List<CommentModel> replies = [];
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _commentListener;

  CommentModel({
    required this.owner_id,
    required this.community_id,
    required this.comment_id,
    required this.content_id,
    required this.parent_id,
    required this.profileImage,
    required this.user_nickName,
    required this.comment,
    required this.time,
    required this.replies,
    required this.onNewCommentreplies,
  }) {
    _commentListener = _createCommentListener();
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      _createCommentListener() {
    final userDocRef = FirebaseFirestore.instance
        .collection('communities')
        .doc(community_id)
        .collection('contents')
        .doc(content_id)
        .collection('comments')
        .doc(comment_id)
        .collection('replies');

    return userDocRef.snapshots().listen((event) {
      event.docChanges.forEach((change) async {
        if (change.type == DocumentChangeType.added) {
          _handleAddedComment(change);
        }
      });
    });
  }

  void _handleAddedComment(DocumentChange<Map<String, dynamic>> change) {
    var commentData = change.doc.data();
    String commentid = change.doc.id;
    String body = commentData!['body'].toString();
    String ownerid = commentData['owner_id'].toString();
    final timestamp = (commentData['created_at'] as Timestamp).toDate();
    DateTime now = DateTime.now();
    DateTime localTimestamp = timestamp.toLocal();

    Duration difference = now.difference(localTimestamp);
    String formattedDate = _formatDateDifference(difference);

    final userinfo = api.getUserInfoOnCallFunction(ownerid);

    userinfo.then((userInfo) {
      if (userInfo != null) {
        String profileImg =
            userInfo["profile_picture_url"] ?? defaultProfileImg;

        final item = CommentModel(
          owner_id: ownerid,
          community_id: community_id,
          content_id: content_id,
          comment_id: commentid,
          comment: body,
          parent_id: comment_id,
          profileImage: profileImg,
          time: formattedDate,
          replies: [],
          user_nickName: userInfo["nickname"],
          onNewCommentreplies: onNewCommentreplies,
        );

        onNewCommentreplies(item, content_id, comment_id);
      }
    });
  }

  String _formatDateDifference(Duration difference) {
    if (difference.inDays == 0) {
      return '${difference.inHours}시간 ${difference.inMinutes.remainder(60)}분 전';
    } else if (difference.inDays == 1) {
      return '1일 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }

  void stopListeningToComment() {
    _commentListener.cancel();
    for (var reply in replies) {
      reply.stopListeningToComment();
    }
  }
}
