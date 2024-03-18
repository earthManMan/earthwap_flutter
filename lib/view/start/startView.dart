import 'package:firebase_login/viewModel/startViewModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:firebase_login/components/theme.dart';
import 'package:firebase_login/components/common_components.dart';
import 'package:provider/provider.dart';

import 'package:firebase_login/view/start/components/startComp.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class StartView extends StatefulWidget {
  const StartView({super.key});

  @override
  State<StartView> createState() => _StartViewState();
}

class _StartViewState extends State<StartView> {
  final controller = PageController(viewportFraction: 1.0, keepPage: true);
  int _pageindex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<StartViewModel>(
      builder: (context, startViewModel, child) {
        final pages = List.generate(
          startViewModel.model.getImage().length,
          (pageindex) => CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            imageUrl: startViewModel.model.getImage()[pageindex],
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
                  image:
                      AssetImage('assets/components/background.png'), // 배경 이미지
                ),
              ),
              child: Platform.isAndroid ?  Scaffold(
                backgroundColor: Colors.transparent, // 배경색을 투명으로 설정
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
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
                                  _pageindex = index % pages.length;
                                }),
                                itemBuilder: (_, pageindex) {
                                  return pages[pageindex % pages.length];
                                },
                              ),
                            ),
                          ),
                        ),
                        SmoothPageIndicator(
                          controller: controller,
                          count: pages.length,
                          effect: const WormEffect(
                            dotHeight: 10,
                            dotWidth: 10,
                            activeDotColor: ColorStyles.primary,
                            type: WormType.thinUnderground,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Center(
                              child: Text(
                            startViewModel.model
                                .getTitle()[_pageindex % pages.length],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Color.fromARGB(255, 255, 255, 255)),
                          )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Center(
                              child: Text(
                            textAlign: TextAlign.center,
                            startViewModel.model
                                .getSubTitle()[_pageindex % pages.length],
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 189, 189, 189)),
                          )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40, bottom: 10),
                          child: TextRoundButton(
                            text: "START",
                            enable: true,
                            call: () {
                              // RegisterAuth Page로 이동
                              Navigator.of(context).pushNamed('/registerAuth');
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: LoginButton(),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            :
             CupertinoPageScaffold(
                backgroundColor: Colors.transparent, // 배경색을 투명으로 설정
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
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
                                  _pageindex = index % pages.length;
                                }),
                                itemBuilder: (_, pageindex) {
                                  return pages[pageindex % pages.length];
                                },
                              ),
                            ),
                          ),
                        ),
                        SmoothPageIndicator(
                          controller: controller,
                          count: pages.length,
                          effect: const WormEffect(
                            dotHeight: 10,
                            dotWidth: 10,
                            activeDotColor: ColorStyles.primary,
                            type: WormType.thinUnderground,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Center(
                              child: Text(
                            startViewModel.model
                                .getTitle()[_pageindex % pages.length],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Color.fromARGB(255, 255, 255, 255)),
                          )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Center(
                              child: Text(
                            textAlign: TextAlign.center,
                            startViewModel.model
                                .getSubTitle()[_pageindex % pages.length],
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 189, 189, 189)),
                          )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40, bottom: 10),
                          child: TextRoundButton(
                            text: "START",
                            enable: true,
                            call: () {
                              // RegisterAuth Page로 이동
                              Navigator.of(context).pushNamed('/registerAuth');
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: LoginButton(),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ));
      },
    );
  }
}
