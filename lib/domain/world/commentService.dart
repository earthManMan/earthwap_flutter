import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_login/API/firebaseAPI.dart';

import 'package:firebase_login/domain/postitem/postItem_model.dart';
import 'package:firebase_login/domain/login/userService.dart';
import 'dart:async';

class CommentService {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _commentListener;

  late final String communityId;
  late final String contentId;
  late final Function(CommentModel, String) onNewCommentReceived;
  late final Function(CommentModel, String, String) onNewCommentReplies;

  CommentService(this.communityId, this.contentId, this.onNewCommentReceived,
      this.onNewCommentReplies) {
    final userDocRef = FirebaseFirestore.instance
        .collection('communities')
        .doc(communityId)
        .collection('contents')
        .doc(contentId)
        .collection('comments');

    _commentListener?.cancel();
    _commentListener = userDocRef.snapshots().listen((event) {
      // Firestore 컬렉션의 변화를 감지하고 이벤트 처리
      event.docChanges.forEach((change) async {
        if (change.type == DocumentChangeType.added) {
          final api = FirebaseAPI();
          final user = UserService.instance;

          // 새로운 댓글이 추가된 경우
          var commentData = change.doc.data();
          String commentid = change.doc.id;
          String body = commentData!['body'].toString();
          String ownerid = commentData['owner_id'].toString();
          final timestamp = (commentData['created_at'] as Timestamp).toDate();
          DateTime now = DateTime.now();
          DateTime localTimestamp =
              timestamp.toLocal(); // UTC 시간을 현재 위치의 시간대로 변환

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

          final userinfo = await api.getUserInfoOnCallFunction(ownerid);

          if (userinfo != null) {
            String profileImg = "";
            profileImg = userinfo["profile_picture_url"] ??
                ""; //"assets/images/default_Profile.png";

            final item = CommentModel(
                owner_id: ownerid,
                community_id: communityId,
                content_id: contentId,
                comment_id: commentid,
                parent_id: "",
                comment: body,
                profileImage: profileImg,
                time: formattedDate,
                replies: [],
                user_nickName: userinfo["nickname"],
                onNewCommentreplies: onNewCommentReplies);

            onNewCommentReceived(item, contentId);
          }
        }
      });
    });
  }

  void stopListeningToComment() {
    // Cancel the listener when it's no longer needed
    _commentListener!.cancel();
  }
}
