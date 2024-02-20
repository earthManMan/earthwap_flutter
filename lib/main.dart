// common
import 'package:firebase_login/service/TrashPickupService.dart';
import 'package:firebase_login/service/alarmService.dart';
import 'package:firebase_login/service/contentService.dart';
import 'package:firebase_login/service/matchService.dart';
import 'package:firebase_login/view/chat/chatView.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_login/components/theme.dart';

// view model
import 'package:firebase_login/viewModel/startViewModel.dart';
import 'package:firebase_login/viewModel/homeViewModel.dart';
import 'package:firebase_login/viewModel/loginViewModel.dart';
import 'package:firebase_login/viewModel/mypageViewModel.dart';
import 'package:firebase_login/viewModel/sellViewModel.dart';
import 'package:firebase_login/viewModel/worldViewModel.dart';
import 'package:firebase_login/viewModel/chatViewModel.dart';
import 'package:firebase_login/viewModel/registerViewModel.dart';
import 'package:firebase_login/viewModel/passwordViewModel.dart';

// View
import 'package:firebase_login/view/splash/splashView.dart';
import 'package:firebase_login/view/start/startView.dart';
import 'view/login/loginView.dart';
import 'view/home/homeView.dart';
import 'view/mypage/mypageView.dart';
import 'view/world/worldView.dart';
import 'view/sell/sellView.dart';
import 'view/register/registerView.dart';
import 'view/password/passwordView.dart';
import 'service/userService.dart';
import 'service/itemService.dart';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_login/application_options.dart';
//import 'package:device_preview/device_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomImageCache extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() {
    ImageCache imageCache = super.createImageCache();
    // Set your image cache size
    imageCache.maximumSizeBytes = 300 * 1024 * 1024; //300mb 이상->캐시클리어

    return imageCache;
  }
}

void main() async {
  // 캐싱 작업
  CustomImageCache();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  final alarmService = AlarmService.instance;
  alarmService.settingAlarm();
  final remote = RemoteConfigService.instance;
  // initialize 메서드 호출 후 완료될 때까지 기다림
  bool initialized = await remote.initialize();
  if (initialized) {
    print("Complete");
    runApp(MyApp());
  } else {
    print("Initialization failed");
  }
  // Debug용
  /*
  runApp(
    DevicePreview(
      enabled: true,
      tools: [...DevicePreview.defaultTools],
      builder: (context) => MyApp(),
    ),
  );*/
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = UserService.instance;
    final itemService = ItemService.instance;
    final contentService = ContentService.instance;
    final matchService = MatchService.instance;
    final pickupService = TrashPickupService.instance;
    final alarmService = AlarmService.instance;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<StartViewModel>(
          create: (_) =>
              StartViewModel.initialize(), // StartViewModel을 초기화하여 생성
          child: const StartView(),
        ),
        ChangeNotifierProvider<LoginViewModel>(
          create: (_) => LoginViewModel.initialize(
              userService), // StartViewModel을 초기화하여 생성
          child: const LoginView(),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => HomeViewModel.initialize(userService, itemService,
              alarmService), // StartViewModel을 초기화하여 생성
          child: const HomeView(),
        ),
        ChangeNotifierProvider<MypageViewModel>(
          create: (_) => MypageViewModel.initialize(userService, itemService,
              contentService, pickupService), // StartViewModel을 초기화하여 생성
          child: const MypageView(),
        ),
        ChangeNotifierProvider<WorldViewModel>(
          create: (_) => WorldViewModel.initialize(
              userService), // StartViewModel을 초기화하여 생성
          child: WorldView(),
        ),
        ChangeNotifierProvider<SellViewModel>(
          create: (_) =>
              SellViewModel.initialize(userService), // StartViewModel을 초기화하여 생성
          child: const SellView(),
        ),
        ChangeNotifierProvider<ChatViewModel>(
          create: (_) => ChatViewModel.initialize(
              userService, matchService), // StartViewModel을 초기화하여 생성
          child: const ChatView(),
        ),
        ChangeNotifierProvider<RegisterViewModel>(
          create: (_) =>
              RegisterViewModel.initialize(), // StartViewModel을 초기화하여 생성
          child: const RegisterView(),
        ),
        ChangeNotifierProvider<PasswordViewModel>(
          create: (_) =>
              PasswordViewModel.initialize(), // StartViewModel을 초기화하여 생성
          child: const PasswordView(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EarthWap',
        routes: {
          '/splash': (context) => const SplashView(),
          '/start': (context) => const StartView(),
          '/registerAuth': (context) => const RegisterView(),
          '/login': (context) => const LoginView(),
          '/main': (context) => const MainScreens(),
          '/mypage': (context) => const MypageView(),
          '/password': (context) => const PasswordView(),
        },
        theme: ThemeData(
          // Define the default font family.
          fontFamily: 'SUIT',
          colorScheme:
              const ColorScheme.highContrastDark(primary: ColorStyles.primary),
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 24.0, fontFamily: "SUIT"),
            titleLarge: TextStyle(fontSize: 14.0, fontFamily: "SUIT"),
            bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Syncopate'),
            labelLarge: TextStyle(fontSize: 14.0, fontFamily: "SUIT"),
          ),
        ),
        initialRoute: '/splash',
      ),
    );
  }
}

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
      final options = RemoteConfigService.instance;
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
            const SellView(),
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
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
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
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
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
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
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
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
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
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
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
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
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
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
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
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
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
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
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
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
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
