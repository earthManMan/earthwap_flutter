import 'package:firebase_login/presentation/sell/sell_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/app/config/remote_options.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_login/presentation/home/homeView.dart';
import 'package:firebase_login/presentation/chat/chatView.dart';
import 'package:firebase_login/presentation/mypage/mypageView.dart';
import 'package:firebase_login/presentation/world/worldView.dart';
import 'package:firebase_login/presentation/components/theme.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/app/style/app_color.dart';

class MainScreens extends StatefulWidget {
  const MainScreens({super.key});

  @override
  _MainScreensState createState() => _MainScreensState();
}

class _MainScreensState extends State<MainScreens> {
  int _selectedIndex = 0;
  final Map<String, String> _images = {};

  @override
  void initState() {
    super.initState();

    if (mounted) {
      final options = RemoteConfigOptions.instance;
      _images.addAll({
        "home_active": options.getimages()["main_home_active"],
        "home_normal": options.getimages()["main_home_normal"]
      });
      _images.addAll({
        "chat_active": options.getimages()["main_chat_active"],
        "chat_normal": options.getimages()["main_chat_normal"]
      });
      _images.addAll({
        "sell_active": options.getimages()["main_sell_active"],
        "sell_normal": options.getimages()["main_sell_normal"]
      });
      _images.addAll({
        "world_active": options.getimages()["main_world_active"],
        "world_normal": options.getimages()["main_world_normal"]
      });
      _images.addAll({
        "my_active": options.getimages()["main_my_active"],
        "my_normal": options.getimages()["main_my_normal"]
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            const HomeView(),
            const ChatView(),
            const SellScreen(),
            const WorldView(),
            const MypageView(),
            //ValueView(),
          ],
        ),
        bottomNavigationBar: Container(
            height: 80,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                    color: Color.fromARGB(255, 255, 255, 255),
                    spreadRadius: 0,
                    blurRadius: 0.1),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: const Color.fromARGB(255, 20, 25, 25),
                currentIndex: _selectedIndex,
                selectedItemColor: ColorStyles.primary,
                unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
                iconSize: 24,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                items: [
                  BottomNavigationBarItem(
                    label: 'HOME',
                    tooltip: "홈페이지",
                    icon: CachedNetworkImage(
                      width: 24,
                      height: 24,
                      imageUrl: _images["home_normal"].toString(),
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                        child: PlatformCircularProgressIndicator(
                          cupertino: (context, platform) {
                            return CupertinoProgressIndicatorData(
                              color: AppColor.primary,
                            );
                          },
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    activeIcon: CachedNetworkImage(
                      width: 24,
                      height: 24,
                      imageUrl: _images["home_active"].toString(),
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                        child: PlatformCircularProgressIndicator(
                          cupertino: (context, platform) {
                            return CupertinoProgressIndicatorData(
                              color: AppColor.primary,
                            );
                          },
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: 'CHAT',
                    tooltip: "채팅페이지",
                    icon: CachedNetworkImage(
                      width: 24,
                      height: 24,
                      imageUrl: _images["chat_normal"].toString(),
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                        child: PlatformCircularProgressIndicator(
                          cupertino: (context, platform) {
                            return CupertinoProgressIndicatorData(
                              color: AppColor.primary,
                            );
                          },
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    activeIcon: CachedNetworkImage(
                      width: 24,
                      height: 24,
                      imageUrl: _images["chat_active"].toString(),
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                        child: PlatformCircularProgressIndicator(
                          cupertino: (context, platform) {
                            return CupertinoProgressIndicatorData(
                              color: AppColor.primary,
                            );
                          },
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: 'SELL',
                    tooltip: "물건등록페이지",
                    icon: CachedNetworkImage(
                      width: 24,
                      height: 24,
                      imageUrl: _images["sell_normal"].toString(),
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                        child: PlatformCircularProgressIndicator(
                          cupertino: (context, platform) {
                            return CupertinoProgressIndicatorData(
                              color: AppColor.primary,
                            );
                          },
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    activeIcon: CachedNetworkImage(
                      width: 24,
                      height: 24,
                      imageUrl: _images["sell_active"].toString(),
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                        child: PlatformCircularProgressIndicator(
                          cupertino: (context, platform) {
                            return CupertinoProgressIndicatorData(
                              color: AppColor.primary,
                            );
                          },
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: 'WORLD',
                    tooltip: "커뮤니티페이지",
                    icon: CachedNetworkImage(
                      width: 24,
                      height: 24,
                      imageUrl: _images["world_normal"].toString(),
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                        child: PlatformCircularProgressIndicator(
                          cupertino: (context, platform) {
                            return CupertinoProgressIndicatorData(
                              color: AppColor.primary,
                            );
                          },
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    activeIcon: CachedNetworkImage(
                      width: 24,
                      height: 24,
                      imageUrl: _images["world_active"].toString(),
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                        child: PlatformCircularProgressIndicator(
                          cupertino: (context, platform) {
                            return CupertinoProgressIndicatorData(
                              color: AppColor.primary,
                            );
                          },
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: 'MY',
                    tooltip: "마이페이지",
                    icon: CachedNetworkImage(
                      width: 24,
                      height: 24,
                      imageUrl: _images["my_normal"].toString(),
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                        child: PlatformCircularProgressIndicator(
                          cupertino: (context, platform) {
                            return CupertinoProgressIndicatorData(
                              color: AppColor.primary,
                            );
                          },
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    activeIcon: CachedNetworkImage(
                      width: 24,
                      height: 24,
                      imageUrl: _images["my_active"].toString(),
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                        child: PlatformCircularProgressIndicator(
                          cupertino: (context, platform) {
                            return CupertinoProgressIndicatorData(
                              color: AppColor.primary,
                            );
                          },
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ],
              ),
            )));
  }
}
