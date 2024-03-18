import 'package:firebase_login/components/item/image_grid_widget.dart';
import 'package:firebase_login/components/content/post_grid_widget.dart';
import 'package:firebase_login/view/mypage/components/setting_detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_login/components/theme.dart';
import 'package:firebase_login/components/profile_image_widget.dart';
import 'package:firebase_login/service/userService.dart';
import 'package:firebase_login/view/mypage/components/mypage_detail.dart';
import 'package:firebase_login/viewModel/mypageViewModel.dart';
import 'package:firebase_login/components/common_components.dart';

class MypageView extends StatefulWidget {
  final bool isMyPage; // isMyPage 속성 추가

  const MypageView(
      {this.isMyPage = true, // 기본값은 true (자신의 Mypage)
      super.key});

  @override
  State<MypageView> createState() => _MypageViewState();
}

class _MypageViewState extends State<MypageView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool initMyPage = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // vsync를 this로 설정
    final userService = UserService.instance;

    userService.addListener(mypageViewListen);
  }

  void mypageViewListen() async {
    final userService = UserService.instance;
    if (userService.nickname!.isNotEmpty) {
      if (mounted) {
        setState(() {
          initMyPage = true;
        });
      }
    }
  }

  void fllowListen() {
    final mypage = Provider.of<MypageViewModel>(context, listen: false);
    if (mypage.notification_followers || mypage.notification_following) {
      mypage.notification_followers = false;
      mypage.notification_following = false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    final userService = UserService.instance;
    userService.removeListener(mypageViewListen);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService.instance;

    return Consumer<MypageViewModel>(
        builder: (context, mypageViewModel, child) {
      /*if (initMyPage == false && userService.nickname!.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }*/

      fllowListen();

      return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              // TODO : 다음 Version에 추가.
              /*
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PremiumPage(isPremium: true),
                    ),
                  );
                },
                icon: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    ColorStyles.primary,
                    BlendMode.dstIn,
                  ),
                  child: Image.asset('assets/components/premium.png'),
                ),
              ),*/
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => settingLayout(),
                    ),
                  );
                },
                icon: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    ColorStyles.primary,
                    BlendMode.dstIn,
                  ),
                  child: Image.asset('assets/components/Menu_1.png'),
                ),
              ),
            ],
            centerTitle: false,
            title: Text(
              userService.nickname.toString(),
              style: const TextStyle(
                  fontFamily: "SUIT",
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            iconTheme: const IconThemeData(
              color: Color.fromARGB(255, 240, 244, 248),
            ),
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: const Color.fromARGB(255, 20, 22, 25),
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
              physics:
                  ClampingScrollPhysics(), // Add this line to prevent overscrolling errors
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          if (userService.profileImage!.isEmpty)
                            Container(
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
                          else
                            ProfileImg(
                              borderRadius: 50,
                              imageUrl: userService.profileImage.toString(),
                              width: 100,
                              height: 100,
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              callback: () {},
                            ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        userService.university.toString(),
                                        style: const TextStyle(
                                            fontFamily: "SUIT",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    )),
                                const SizedBox(
                                    height: 8), // 간격 조절을 위한 SizedBox 추가
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FollowerPage(
                                                userService: userService,
                                                viewModel: mypageViewModel),
                                          ),
                                        );
                                      },
                                      child: Text(
                                          "팔로워 ${mypageViewModel.model.Followers?.length ?? 0}",
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 240, 244, 248),
                                              fontFamily: "SUIT",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                    ),
                                    const SizedBox(
                                        width: 16), // 간격 조절을 위한 SizedBox 추가
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FollowingPage(
                                              userService: userService,
                                              viewModel: mypageViewModel,
                                              callback: (uid) {
                                                setState(() {
                                                  mypageViewModel
                                                      .model.Following!
                                                      .map((userProfile) =>
                                                          userProfile
                                                              .itemInfoList)
                                                      .expand((i) => i)
                                                      .toList()
                                                      .removeWhere((element) =>
                                                          element
                                                              .item_owner_id ==
                                                          uid);
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                          "팔로잉 ${mypageViewModel.model.Following?.length ?? 0}",
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 240, 244, 248),
                                              fontFamily: "SUIT",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(userService.description.toString(),
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 240, 244, 248),
                                    fontFamily: "SUIT",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileEditPage(
                                        userService: userService,
                                        viewModel: mypageViewModel),
                                  ),
                                ).then((updatedData) {
                                  if (updatedData == true) {
                                    // 여기에서 setState를 호출하고 updatedData를 사용하여 상태를 업데이트합니다.
                                    setState(() {
                                      // 상태를 업데이트하는 코드를 추가하세요.
                                    });
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(44, 47, 51, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                minimumSize: Size(
                                  MediaQuery.of(context).size.width * 0.45,
                                  40,
                                ),
                              ),
                              child: const Text(
                                "프로필 편집",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 240, 244, 248),
                                    fontFamily: "SUIT",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TrashCollectionPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(44, 47, 51, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                minimumSize: Size(
                                  MediaQuery.of(context).size.width * 0.45,
                                  40,
                                ),
                              ),
                              child: const Text("수거 신청 내역",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 240, 244, 248),
                                      fontFamily: "SUIT",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                      TabBar(
                        unselectedLabelColor:
                            const Color.fromARGB(255, 130, 130, 130),
                        labelStyle: const TextStyle(
                            fontFamily: "SUIT",
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        labelColor: const Color.fromARGB(255, 240, 244, 248),
                        indicatorColor: ColorStyles.primary,
                        //indicatorPadding: EdgeInsets.only(left: 30, right: 30),
                        controller: _tabController,
                        tabs: const [
                          Tab(text: '어스왑'),
                          Tab(text: '좋아요'),
                          Tab(text: '게시글'),
                        ],
                      ),
                      Expanded(
                          child: TabBarView(
                        controller: _tabController,
                        children: [
                          ImageGridView(
                            itemInfo: mypageViewModel.model.getItemList(),
                            onItemRemoveCallback: (itemId) async {
                              final value =
                                  await mypageViewModel.deleteItem(itemId);
                              if (value == true) {
                                // 삭제 성공 시 Navigator를 통해 뒤로 이동
                                setState(() {
                                  showSnackbar(context, '해당 item을 삭제하였습니다.');
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(true);
                                });
                              }
                            },
                          ),

                          mypageViewModel.model.Following!.isEmpty == true
                              ? Center(
                                  child: Text("구독한 유저가 없습니다."),
                                )
                              : ImageGridView(
                                  itemInfo: mypageViewModel.model.Following!
                                      .map((userProfile) =>
                                          userProfile.itemInfoList)
                                      .expand((i) => i)
                                      .toList(),
                                  onItemRemoveCallback: (itemId) {}),
                          // 게시글 페이지 내용을 여기에 배치

                          PostGridView(
                              contents: mypageViewModel.model.getPostItemList(),
                              scaffoldKey: _scaffoldKey,
                              noUpdate: false),
                        ],
                      )),
                    ],
                  ))));
    });
  }
}
