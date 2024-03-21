import 'package:firebase_login/presentation/home/homeViewModel.dart';
import 'package:firebase_login/presentation/mypage/mypageViewModel.dart';

import 'package:flutter/material.dart';
import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:firebase_login/presentation/components/theme.dart';
import 'package:firebase_login/domain/home/home_model.dart';
import 'package:firebase_login/presentation/components/item/image_grid_widget.dart';
import 'package:firebase_login/presentation/components/content/post_grid_widget.dart';
import 'package:firebase_login/presentation/components/profile_image_widget.dart';
import 'package:firebase_login/domain/postitem/postItem_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/presentation/common/widgets/toastwidget.dart';
import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/app/config/constant.dart';
class UserProfile extends StatefulWidget {
  final String uid;

  const UserProfile({
    super.key,
    required this.uid,
  });

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  String nickName = "";
  String profileImg = "";
  String university = "";
  String description = "";
  late TabController _tabController;
  List<ItemInfo> items = [];
  List<PostItemModel> contents = [];
  bool isSubscribed = false;
  bool updateSubscribed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // vsync를 this로 설정
    final mypage = Provider.of<MypageViewModel>(context, listen: false);
    isSubscribed =
        mypage.model.getFollowings().any((user) => user.uid == widget.uid);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (PostItemModel element in contents) {
      element.commentService.stopListeningToComment();
      for (CommentModel comment in element.comments) {
        comment.stopListeningToComment();
        for (CommentModel replies in comment.replies) {
          replies.stopListeningToComment();
          replies.replies.clear();
        }
      }
    }

    contents.clear();
    items.clear();
    super.dispose();
  }

  void updateCommentMessage(bool state) {
    setState(() {});
  }

  void updateCommentMRepiles(
      CommentModel Message, String contentId, String commentId) {
    for (int i = 0; i < contents.length; i++) {
      if (contents[i].contentID == contentId) {
        for (int z = 0; z < contents[i].comments.length; z++) {
          if (contents[i].comments[z].comment_id == commentId) {
            contents[i].comments[z].replies.add(Message);
          }
        }
      }
    }
  }

  Future<void> loadUserInfo() async {
    if (!updateSubscribed) {
      final api = FirebaseAPI();
      final userinfo = await api.getUserInfoOnCallFunction(widget.uid);

      if (userinfo != null) {
        nickName = userinfo["nickname"];
        profileImg = userinfo["profile_picture_url"];

        university = userinfo["university"];
        description = userinfo["description"];

        final itemIds = (userinfo["items"] as List<dynamic>?)
                ?.map((item) => item.toString()) ??
            [];
        final contentIds = (userinfo["contents"] as List<dynamic>?)
                ?.map((item) => item.toString()) ??
            [];

        items.clear();
        contents.clear();

        for (final itemId in itemIds) {
          final re = await api.readItemInfoOnCallFunction(itemId);
          if (re != null) {
            final itemData = re.data['item'];
            final mainColor = itemData['main_colour'];
            final subColor = itemData['sub_colour'];
            final mainKeyword = itemData['main_keyword'];
            final subKeyword = itemData['sub_keyword'];

            final item = ItemInfo(
              item_id: itemId,
              item_profile_img: "",
              item_owner_Kickname: nickName,
              item_owner_id: widget.uid,
              category: itemData['category_id'].toString(),
              item_cover_img: itemData['cover_image_location'].toString(),
              otherImagesLocation: List<String>.from(
                  itemData['other_images_location']
                      .map((item) => item.toString())),
              description: itemData['description'].toString(),
              isPremium: itemData['is_premium'] as bool,
              isTraded: itemData['is_traded'] as bool,
              likes: itemData['likes'].toString(),
              dislikes: itemData['dislikes'].toString(),
              main_color: Color(int.parse("0x$mainColor")),
              sub_color: Color(int.parse("0x$subColor")),
              main_Keyword: mainKeyword.toString(),
              sub_Keyword: subKeyword.toString(),
              matchItems: "",
              userPrice: 0,
              priceEnd: itemData['price_end'] as int,
              priceStart: itemData['price_start'] as int,
              create_time: itemData['created_at'].toString(),
              update_time: itemData['updated_at'].toString(),
              match_id: "",
              match_owner_id: "",
              match_img: itemData['cover_image_location'].toString(),
            );
            items.add(item);
          }
        }

        for (final contentId in contentIds) {
          final parts = contentId.toString().split('/');
          if (parts.length >= 4) {
            final communityId = parts[1];
            final contentId = parts[3];
            final result =
                await api.readContentOnCallFunction(communityId, contentId);
            if (result != null) {
              final item = PostItemModel(
                communityID: communityId,
                title: result['title'].toString(),
                onwerId: widget.uid,
                contentID: result['id'].toString(),
                contentImg: result['images']
                    .toString()
                    .replaceAll(RegExp(r'[\[\]]'), ''),
                date: result['created_at']['_seconds'].toString(),
                description: result['body'],
                nickName: nickName,
                likes: 0,
                views: 0,
                profileImg: profileImg,
                onNewComment: updateCommentMessage,
              );
              contents.add(item);
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadUserInfo(), // 비동기 작업
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // loadUserInfo()가 완료된 경우
          return buildProfile();
        } else {
          // 아직 로딩 중인 경우 로딩 표시 또는 다른 처리를 추가할 수 있습니다.
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              centerTitle: true,
              title: const Text("프로필 화면",
                  style: TextStyle(
                      fontFamily: "SUIT",
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            body: Center(
              child: PlatformCircularProgressIndicator(
                cupertino: (context, platform) {
                  return CupertinoProgressIndicatorData(
                    color: AppColor.primary,
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildProfile() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("프로필 화면",
            style: TextStyle(
                fontFamily: "SUIT", fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Card(
            color: ColorStyles.background,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: profileImg.isEmpty == true
                          ? Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(255, 255, 255, 255),
                                image: DecorationImage(
                                  image: AssetImage(
                                      "assets/images/default_Profile.png"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : ProfileImg(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: 999,
                              callback: () {},
                              height: 100,
                              width: 100,
                              imageUrl: profileImg,
                            ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "$nickName\n",
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: university,
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            description,
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSubscribed == true
                                  ? Colors.green
                                  : ColorStyles.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            onPressed: () async {
                              // Toggle the button state when pressed.
                              setState(() {
                                updateSubscribed = true;
                                isSubscribed = !isSubscribed;
                                final mypage = Provider.of<HomeViewModel>(
                                    context,
                                    listen: false);
                                if (isSubscribed) {
                                  mypage.follow(widget.uid).then((value) => {
                                        showtoastMessage('해당 사용자를 팔로우 했습니다.',
                                            toastStatus.success)
                                      });
                                } else {
                                  mypage.unfollow(widget.uid).then((value) => {
                                        showtoastMessage('해당 사용자를 언팔로우 했습니다.',
                                            toastStatus.success)
                                      });
                                }
                              });
                            },
                            child: Text(
                              isSubscribed ? "언팔로우" : "팔로우",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: "SUIT",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ))
                    ])
              ],
            ),
          ),
          TabBar(
            labelStyle: const TextStyle(
                fontFamily: "SUIT", fontSize: 16, fontWeight: FontWeight.bold),
            indicatorColor: ColorStyles.primary,
            controller: _tabController,
            tabs: const [
              Tab(text: '어스왑'),
              Tab(text: '게시글'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ImageGridView(
                    itemInfo: items, onItemRemoveCallback: (value) {}),
                PostGridView(
                    contents: contents,
                    scaffoldKey: _scaffoldKey,
                    noUpdate: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
