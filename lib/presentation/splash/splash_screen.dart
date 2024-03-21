import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_login/app/config/remote_options.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/app/style/app_color.dart';

// TODO : 자동 로그인 처리 필요
// 로컬에 저장 된 Login 정보 불러와 로그인 하도록 설정
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _logo = "";

  @override
  void initState() {
    if (mounted) {
      final options = RemoteConfigOptions.instance;
      _logo = options.getimages()["splash_logo"];

      Timer(const Duration(milliseconds: 3000), () {
        // Start View로 이동
        Navigator.of(context).pushNamed("/start");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/components/background.png"),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: CachedNetworkImage(
            imageUrl: _logo,
            imageBuilder: (context, imageProvider) => Container(
              width: 300,
              height: 150,
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
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ],
    );
  }
}
