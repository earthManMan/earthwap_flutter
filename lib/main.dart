import 'package:firebase_login/app/style/thema/android_thema.dart';
import 'package:firebase_login/app/style/thema/ios_thema.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

// common
import 'package:firebase_login/domain/world/TrashPickupService.dart';
import 'package:firebase_login/domain/alarm/alarmService.dart';
import 'package:firebase_login/domain/world/contentService.dart';
import 'package:firebase_login/domain/chat/matchService.dart';
import 'package:firebase_login/presentation/chat/chatView.dart';
import 'package:firebase_login/presentation/login/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app/config/firebase_options.dart';
import 'package:firebase_login/presentation/components/theme.dart';

// view model

import 'package:firebase_login/presentation/home/homeViewModel.dart';
import 'package:firebase_login/presentation/login/login_viewmodel.dart';
import 'package:firebase_login/presentation/mypage/mypageViewModel.dart';
import 'package:firebase_login/presentation/sell/sellViewModel.dart';
import 'package:firebase_login/presentation/world/worldViewModel.dart';
import 'package:firebase_login/presentation/chat/chatViewModel.dart';
import 'package:firebase_login/presentation/register/old/registerViewModel.dart';
import 'package:firebase_login/presentation/password/passwordViewModel.dart';

// View
import 'package:firebase_login/presentation/splash/splash_screen.dart';
import 'package:firebase_login/presentation/start/start_screen.dart';
import 'presentation/login/old/loginView.dart';
import 'presentation/home/homeView.dart';
import 'presentation/mypage/mypageView.dart';
import 'presentation/world/worldView.dart';
import 'presentation/sell/sellView.dart';
import 'presentation/register/old/registerView.dart';
import 'presentation/password/passwordView.dart';
import 'presentation/main/mainView.dart';
import 'domain/login/userService.dart';
import 'domain/home/itemService.dart';
import 'presentation/register/register_screen.dart';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_login/app/config/remote_options.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_login/di/provider_setup.dart';

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

  final providers = await getProviders();

  final remote = RemoteConfigOptions.instance;
  // initialize 메서드 호출 후 완료될 때까지 기다림
  await remote.initialize().then((value) => {
        if (value)
          runApp(
            MultiProvider(
              providers: providers,
              child: MainApp(),
            ),
          )
      });
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true, // 텍스트 크기를 자동으로 조절하여 화면에 맞추는 기능을 활성화
      useInheritedMediaQuery: true, // 분활 화면 모드를 활성화
      builder: (_, child) {
        return PlatformTheme(
          themeMode: ThemeMode.light,
          materialLightTheme: AndroidAppThema().themeData(),
          materialDarkTheme: AndroidAppThema().themeData(),
          cupertinoLightTheme: IosAppThema().themeData(),
          cupertinoDarkTheme: IosAppThema().themeData(),
          matchCupertinoSystemChromeBrightness: true,
          builder: (context) => PlatformApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
            ],
            title: 'EarthWap',
            routes: {
              '/': (BuildContext context) {
                return SplashScreen();
              },
              '/splash': (context) => const SplashScreen(),
              '/start': (context) => const StartScreen(),
              '/registerAuth': (context) => const RegisterScreen(),
              '/login': (context) => const LoginScreen(),
              '/main': (context) => const MainScreens(),
              '/mypage': (context) => const MypageView(),
              '/password': (context) => const PasswordView(),
            },
            initialRoute: '/splash',
          ),
        );
      },
    );
  }
}
