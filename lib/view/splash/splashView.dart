import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_login/application_options.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

//TODO : 디바이스에 저장 된 정보를 읽어 와서 초기 상태를 설정한다.
// ex) user 로그인 정보 등등

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  String _logo = "";

  @override
  void initState() {
    if (mounted) {
      final options = RemoteConfigService.instance;
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
        // 백그라운드 이미지
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
        // Asset 이미지
        // Asset 이미지
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
            placeholder: (context, url) =>  Center(
              child: PlatformCircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ],
    );
  }
}
