import 'package:firebase_login/domain/home/home_model.dart';
import 'package:firebase_login/domain/alarm/alarmService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';
import 'package:firebase_login/presentation/home/components/home_detail.dart';
import 'package:firebase_login/presentation/home/homeViewModel.dart';
import 'package:firebase_login/presentation/components/category_widget.dart';
import 'package:firebase_login/presentation/components/common_components.dart';
import 'package:firebase_login/app/config/remote_options.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/app/style/app_color.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _homeViewState();
}

class _homeViewState extends State<HomeView> {
  final CardSwiperController controller = CardSwiperController();
  late BuildContext savedContext;

  String _appbar_menu = "";
  String _appbar_bell = "";
  List<ItemInfo> _data = [];

  @override
  void initState() {
    super.initState();
    savedContext = context;

    final options = RemoteConfigOptions.instance;
    _appbar_menu = options.getimages()["home_appbar_menu"];
    _appbar_bell = options.getimages()["home_appbar_bell"];

    final ViewModel = Provider.of<HomeViewModel>(context, listen: false);
    ViewModel.addListener(() {
      if (ViewModel.model.itemInfoList.isNotEmpty) {
        if (mounted) {
          setState(() {
            _data = ViewModel.model.itemInfoList;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleCategoriesSelected(List<String> selectedCategories) {
    final viewmodel = Provider.of<HomeViewModel>(context, listen: false);

    setState(() {
      viewmodel.categorymodel.clearSelected();
      for (String item in selectedCategories) {
        viewmodel.categorymodel.addselected(item);
      }
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final alram = AlarmService.instance;
    return Consumer<HomeViewModel>(builder: (context, homeViewModel, child) {
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
                fit: BoxFit.cover,
                image: AssetImage('assets/components/background.png'),
              ),
            ),
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategorySelectionPage(
                            onPressed: handleCategoriesSelected,
                            categories: homeViewModel.categorymodel.categories,
                            selected: homeViewModel.categorymodel.selected,
                          ),
                        ),
                      );
                    },
                    icon: CachedNetworkImage(
                      width: 32,
                      height: 32,
                      imageUrl: _appbar_menu,
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
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationPage(),
                        ),
                      );
                    },
                    icon: CachedNetworkImage(
                      width: 32,
                      height: 32,
                      imageUrl: _appbar_bell,
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) =>
                          alram.isNotReadMessage() == true
                              ? Badge(
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 62, 73),
                                  alignment: Alignment.topCenter,
                                  label: const Text("  "),
                                  child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )))
                              : Container(
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
                title: const Text(
                  'EARTHWAP',
                  style: TextStyle(
                      fontFamily: "Syncopate",
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                iconTheme: const IconThemeData(
                  color: Color.fromARGB(255, 240, 244, 248),
                ),
                backgroundColor: Colors.transparent,
              ),
              backgroundColor: Colors.transparent,
              body: CombinedFlipAndSwipe(items: _data),
            ),
          ));
    });
  }
}
