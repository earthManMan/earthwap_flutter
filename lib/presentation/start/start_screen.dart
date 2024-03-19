import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:firebase_login/presentation/components/common_components.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/app/config/remote_options.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final List<String> _titles = [];
  final List<String> _subtitles = [];
  final List<String> _images = [];

  late List<CachedNetworkImage> _pages;

  int _pageindex = 0;
  final controller = PageController(viewportFraction: 1.0, keepPage: true);

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() {
    final config = RemoteConfigOptions.instance;
    final valueList = config.getStartModelJsonMap();
    for (final value in valueList) {
      _titles.add(value["infoTitle"].toString());
      _subtitles.add(value["infoSubTitle"].toString());
    }

    _images.add(config.getimages()["start_info_1"]);
    _images.add(config.getimages()["start_info_2"]);
    _images.add(config.getimages()["start_info_3"]);
  }

  @override
  Widget build(BuildContext context) {
    _infoPages();
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          showBackDialog(context);
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage('assets/components/background.png'), // 배경 이미지
            ),
          ),
          child: PlatformScaffold(
            backgroundColor: Colors.transparent, // 배경색을 투명으로 설정
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildPages(),
                    _registerbutton(),
                    _loginbutton(),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void _infoPages() {
    _pages = List.generate(
      _images.length,
      (pageindex) => CachedNetworkImage(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        imageUrl: _images[pageindex],
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
          child: PlatformCircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }

  Widget _buildPages() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // 이미지 출력
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Container(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                child: PageView.builder(
                  controller: controller,
                  onPageChanged: (index) => setState(() {
                    _pageindex = index % _pages.length;
                  }),
                  itemBuilder: (_, pageindex) {
                    return _pages[pageindex % _pages.length];
                  },
                ),
              ),
            ),
          ),
          // indicator
          SmoothPageIndicator(
            controller: controller,
            count: _pages.length,
            effect: WormEffect(
              dotHeight: 10,
              dotWidth: 10,
              activeDotColor: AppColor.primary,
              type: WormType.thinUnderground,
            ),
          ),
          // message
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Center(
                child: Text(
              _titles[_pageindex % _pages.length],
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: AppColor.grayF9),
            )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Center(
                child: Text(
              textAlign: TextAlign.center,
              _subtitles[_pageindex % _pages.length],
              style: const TextStyle(fontSize: 14, color: AppColor.text),
            )),
          )
        ]);
  }

  Widget _registerbutton() {
    return Padding(
        padding: const EdgeInsets.only(top: 40, bottom: 10),
        child: TextRoundButton(
          text: "START",
          enable: true,
          call: () {
            // RegisterAuth Page로 이동
            Navigator.of(context).pushNamed('/registerAuth');
          },
        ));
  }

  Widget _loginbutton() {
    return Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('이미 계정이 있으신가요? 바로',
                      style: TextStyle(color: AppColor.text)),
                  Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: TextButton(
                        onPressed: () {
                          // Login Page로 이동
                          Navigator.of(context).pushNamed('/login');
                        },
                        child: const Text('로그인하세요',
                            style: TextStyle(
                                fontFamily: "SUIT",
                                fontWeight: FontWeight.bold,
                                color: AppColor.primary))),
                  )
                ])));
  }
}
