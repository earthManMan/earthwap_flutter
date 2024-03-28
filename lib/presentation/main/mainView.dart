import 'package:firebase_login/presentation/mypage/mypage_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/app/config/remote_options.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_login/presentation/sell/sell_screen.dart';
import 'package:firebase_login/presentation/home/old/homeView.dart';
import 'package:firebase_login/presentation/chat/chatView.dart';
import 'package:firebase_login/presentation/world/worldView.dart';
import 'package:firebase_login/presentation/components/theme.dart';
import 'package:firebase_login/app/style/app_color.dart';

class MainScreens extends StatefulWidget {
  const MainScreens({Key? key}) : super(key: key);

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
        "home_active": options.getimages()["main_home_active"]!,
        "home_normal": options.getimages()["main_home_normal"]!
      });
      _images.addAll({
        "chat_active": options.getimages()["main_chat_active"]!,
        "chat_normal": options.getimages()["main_chat_normal"]!
      });
      _images.addAll({
        "sell_active": options.getimages()["main_sell_active"]!,
        "sell_normal": options.getimages()["main_sell_normal"]!
      });
      _images.addAll({
        "world_active": options.getimages()["main_world_active"]!,
        "world_normal": options.getimages()["main_world_normal"]!
      });
      _images.addAll({
        "my_active": options.getimages()["main_my_active"]!,
        "my_normal": options.getimages()["main_my_normal"]!
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeView(),
          ChatView(),
          SellScreen(),
          WorldView(),
          MyPageScreen(),
        ],
      ),
      bottomNavBar: PlatformNavBar(
        backgroundColor: AppColor.gray1C,
        height: MediaQuery.of(context).size.height * 0.08,
        material3: (context, platform) {
          return MaterialNavigationBarData(indicatorColor: Colors.transparent);
        },
        cupertino: (context, platform) {
          return CupertinoTabBarData(
              activeColor: AppColor.primary, backgroundColor: AppColor.gray1C);
        },
        items: [
          BottomNavigationBarItem(
            label: 'HOME',
            icon: _buildNavBarIcon("home_normal"),
            activeIcon: _buildNavBarIcon("home_active"),
            tooltip: "홈페이지",
          ),
          BottomNavigationBarItem(
            label: 'CHAT',
            icon: _buildNavBarIcon("chat_normal"),
            activeIcon: _buildNavBarIcon("chat_active"),
            tooltip: "채팅페이지",
          ),
          BottomNavigationBarItem(
            label: 'SELL',
            icon: _buildNavBarIcon("sell_normal"),
            activeIcon: _buildNavBarIcon("sell_active"),
            tooltip: "물건등록페이지",
          ),
          BottomNavigationBarItem(
            label: 'WORLD',
            icon: _buildNavBarIcon("world_normal"),
            activeIcon: _buildNavBarIcon("world_active"),
            tooltip: "커뮤니티페이지",
          ),
          BottomNavigationBarItem(
            label: 'MY',
            icon: _buildNavBarIcon("my_normal"),
            activeIcon: _buildNavBarIcon("my_active"),
            tooltip: "마이페이지",
          ),
        ],
        currentIndex: _selectedIndex,
        itemChanged: (p0) {
          setState(() {
            _selectedIndex = p0;
          });
        },
      ),
    );
  }

  Widget _buildNavBarIcon(String imageName) {
    return CachedNetworkImage(
      width: 24,
      height: 24,
      imageUrl: _images[imageName]!,
      fit: BoxFit.cover,
      placeholder: (context, url) => PlatformCircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
