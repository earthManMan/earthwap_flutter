import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/presentation/components/item/image_grid_widget.dart';
import 'package:firebase_login/presentation/components/content/post_grid_widget.dart';
import 'package:firebase_login/presentation/mypage/components/setting_detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_login/presentation/components/theme.dart';
import 'package:firebase_login/presentation/components/profile_image_widget.dart';
import 'package:firebase_login/domain/login/userService.dart';
import 'package:firebase_login/presentation/mypage/components/mypage_detail.dart';
import 'package:firebase_login/presentation/mypage/mypageViewModel.dart';
import 'package:firebase_login/presentation/common/widgets/toast_widget.dart';
import 'package:firebase_login/app/config/constant.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/presentation/common/widgets/profile_top_widget.dart';
import 'package:firebase_login/presentation/common/widgets/profile_body_widget.dart';

class MyPageScreen extends StatefulWidget {
  final bool isMyPage; // isMyPage 속성 추가

  const MyPageScreen(
      {this.isMyPage = true, // 기본값은 true (자신의 Mypage)
      super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool initMyPage = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

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
    final userService = UserService.instance;
    userService.removeListener(mypageViewListen);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService.instance;
    final viewmodel = Provider.of<MypageViewModel>(context, listen: false);
    fllowListen();

    return PlatformScaffold(
        key: _scaffoldKey,
        appBar: PlatformAppBar(
          automaticallyImplyLeading: false,
          title: Text(
            userService.nickname.toString(),
            style: const TextStyle(
                fontFamily: "SUIT", fontWeight: FontWeight.bold, fontSize: 18),
          ),
          trailingActions: [
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
                  AppColor.primary,
                  BlendMode.dstIn,
                ),
                child: Image.asset('assets/components/premium.png'),
              ),
            ),
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
                  AppColor.primary,
                  BlendMode.dstIn,
                ),
                child: Image.asset('assets/components/Menu_1.png'),
              ),
            ),
          ],
          cupertino: (context, platform) {
            return CupertinoNavigationBarData(
              backgroundColor: Colors.transparent,
            );
          },
          material: (context, platform) {
            return MaterialAppBarData(
              centerTitle: false,
              iconTheme: const IconThemeData(
                color: AppColor.grayF9,
              ),
            );
          },
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: AppColor.gray1C,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ProfileTopWidget(
              isMyPage: true,
              profileImageUrl: userService.profileImage.toString(),
              description: "2024년 3월 26일 오늘도 지나가리~",
              followersCount: viewmodel.model.Followers?.length ?? 0,
              followingCount: viewmodel.model.Following?.length ?? 0,
              follower_callback: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowerPage(
                        userService: userService, viewModel: viewmodel),
                  ),
                );
              },
              following_callback: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowingPage(
                      userService: userService,
                      viewModel: viewmodel,
                      callback: (uid) {
                        setState(() {
                          viewmodel.model.Following!
                              .map((userProfile) => userProfile.itemInfoList)
                              .expand((i) => i)
                              .toList()
                              .removeWhere(
                                  (element) => element.item_owner_id == uid);
                        });
                      },
                    ),
                  ),
                );
              },
              edit_callback: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileEditPage(
                        userService: userService, viewModel: viewmodel),
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
              trash_callback: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrashCollectionPage(),
                  ),
                );
              },
              follow_callback: () {},
            ),
            Expanded(
                child: ProfileBodyWidget(
              isMyPage: true,
              scaffoldKey: _scaffoldKey,
              itemInfo: viewmodel.model.getItemList(),
              post_itemInfo: viewmodel.model.getPostItemList(),
              follow_itemInfo: viewmodel.model.Following!
                  .map((userProfile) => userProfile.itemInfoList)
                  .expand((i) => i)
                  .toList(),
              delete_callback: (itemId) async {
                final value = await viewmodel.deleteItem(itemId);
                if (value == true) {
                  // 삭제 성공 시 Navigator를 통해 뒤로 이동
                  setState(() {
                    showtoastMessage('해당 item을 삭제하였습니다.', toastStatus.info);
                    Navigator.of(context, rootNavigator: true).pop(true);
                  });
                }
              },
            )),
          ],
        ));
  }
}
