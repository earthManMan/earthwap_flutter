import 'dart:ui' as ui;
import 'package:firebase_login/domain/home/itemService.dart';
import 'package:firebase_login/domain/login/userService.dart';
import 'package:firebase_login/presentation/home/homeViewModel.dart';
import 'package:firebase_login/presentation/mypage/mypageViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';

import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flip_card/flip_card.dart';

import 'package:firebase_login/presentation/components/profile_image_widget.dart';
import 'package:firebase_login/presentation/components/theme.dart';
import 'package:firebase_login/presentation/components/common_components.dart';
import 'package:firebase_login/domain/home/home_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_login/presentation/components/user_profile_widget.dart';
import 'package:firebase_login/domain/alarm/alarmService.dart';
import 'dart:async';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/presentation/common/widgets/toastwidget.dart';
import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/app/config/constant.dart';
class CombinedFlipAndSwipe extends StatefulWidget {
  List<ItemInfo> items = [];

  CombinedFlipAndSwipe({required this.items, super.key});

  @override
  State<CombinedFlipAndSwipe> createState() => _CombinedFlipAndSwipeState();
}

class _CombinedFlipAndSwipeState extends State<CombinedFlipAndSwipe> {
  final CardSwiperController controller = CardSwiperController();
  List<FrontCard> _Frontcards = [];
  List<BackCard> _Backcards = [];
  bool _registerItem = false;
  bool _updateInfoCard = true;

  @override
  void initState() {
    super.initState();

    final itemSevice = ItemService.instance;

    itemSevice.addListener(() {
      if (itemSevice.itemList!.isNotEmpty) {
        if (mounted) {
          setState(() {
            _registerItem = true;
          });
        }
      }
    });
  }

  void _initializeData() {
    final ViewModel = Provider.of<HomeViewModel>(context, listen: false);
    final myViewmodel = Provider.of<MypageViewModel>(context, listen: false);

    _Frontcards = widget.items
        .map((item) => FrontCard(
              item,
              viewModel: ViewModel,
            ))
        .toList();
    _Backcards = widget.items
        .map((item) => BackCard(
              item,
              viewModel: ViewModel,
              myviewmodel: myViewmodel,
            ))
        .toList();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isNotEmpty) _initializeData();

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _registerItem == false
              ? Align(
                  alignment: Alignment.center,
                  child: Text(
                    "내 물건을 등록해주세요.\n 매칭 될 물건을 찾아드립니다!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: "SUIT",
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Flexible(
                  child: _Frontcards.length < 2
                      ? Align(
                          alignment: Alignment.center,
                          child: Text(
                            "매칭 될 물건을 못찾았습니다\n 내 물건을 더 등록해주세요!",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: "SUIT",
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : CardSwiper(
                          controller: controller,
                          cardsCount: _Frontcards.length,
                          onSwipe: _onSwipe,
                          numberOfCardsDisplayed: _Frontcards.isEmpty ? 0 : 2,
                          allowedSwipeDirection: AllowedSwipeDirection.only(
                              left: true, right: true),
                          backCardOffset: const Offset(0, -40),
                          padding: const EdgeInsets.all(24.0),
                          cardBuilder: (
                            context,
                            index,
                            horizontalThresholdPercentage,
                            verticalThresholdPercentage,
                          ) =>
                              FlipCard(
                            direction: FlipDirection.HORIZONTAL,
                            side: CardSide.FRONT,
                            speed: 1000,
                            onFlipDone: (status) {},
                            onFlip: () {
                              //widget._controller.ShowCardToggle();
                            },
                            front: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF006666),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                              child: index >= _Frontcards.length
                                  ? null
                                  : _Frontcards[index],
                            ),
                            back: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF006666),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                              child: index >= _Backcards.length
                                  ? null
                                  : _Backcards[index],
                            ),
                          ),
                        ),
                ),
        ],
      ),
    );
  }

  Future<bool> _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) async {
    final ViewModel = Provider.of<HomeViewModel>(context, listen: false);

    String onwerID = "";
    String matchID = "";

    if (previousIndex >= 0 && previousIndex < _Frontcards.length) {
      onwerID = _Frontcards[previousIndex]._itemInfo.match_id;
      matchID = _Frontcards[previousIndex]._itemInfo.item_id;
    }

    // 약 60% 소진 했을때
    // 카드 갱신 호출
    double threshold = 0.6 * _Frontcards.length;
    if (currentIndex! >= threshold.toInt() && _updateInfoCard) {
      _updateInfoCard = false;
      ViewModel.updateItemInfo().then((value) => {
            _updateInfoCard = true,
          });
    }

    // TODO : direction Action Call
    if (direction == CardSwiperDirection.left) {
      debugPrint(
        '${direction.name}.',
      );
      ViewModel.dislikeItem(onwerID, matchID);
    } else if (direction == CardSwiperDirection.right) {
      debugPrint(
        'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
      );
      ViewModel.likeItem(onwerID, matchID);
    }
    setState(() {});
    return true;
  }

  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint(
      'The card $currentIndex was undod from the ${direction.name}',
    );
    return true;
  }
}

class BackCard extends StatefulWidget {
  final ItemInfo _itemInfo;
  final HomeViewModel _viewModel;
  final MypageViewModel _mypageViewModel;

  late bool isSubscribed = false;
  final _pageController = PageController(viewportFraction: 1.0, keepPage: true);
  int _pageindex = 0;

  BackCard(this._itemInfo,
      {required HomeViewModel viewModel,
      required MypageViewModel myviewmodel,
      super.key})
      : _viewModel = viewModel,
        _mypageViewModel = myviewmodel;

  @override
  _BackCardState createState() => _BackCardState();
}

class _BackCardState extends State<BackCard> {
  final List<MenuItem> _menuItems;

  @override
  void initState() {
    super.initState();

    if (mounted) {
      widget._mypageViewModel.addListener(checkListen);
    }
  }

  @override
  void dispose() {
    if (mounted) {
      widget._mypageViewModel.removeListener(checkListen);
    }
    super.dispose();
  }

  void checkListen() {
    bool isFollowing = widget._mypageViewModel.model.Following!
        .any((following) => following.uid == widget._itemInfo.item_owner_id);

    setState(() {
      widget.isSubscribed = isFollowing;
    });
  }

  _BackCardState() : _menuItems = [] {
    _menuItems.add(
      MenuItem(
        callback: report_function,
        Content: '프로필 신고하기',
        textColor: Colors.white,
      ),
    );
  }

  void report_function() async {
    await widget._viewModel
        .reportUser(widget._itemInfo.item_owner_id.toString(), "사용자가 신고함.");
  }

  bool IsUserbySubscribe(BuildContext context, String id) {
    final mypage = Provider.of<MypageViewModel>(context, listen: false);
    for (int i = 0; i < mypage.model.getFollowings().length; i++) {
      if (mypage.model.getFollowings()[i].uid == id) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    //widget.isSubscribed =
    //    IsUserbySubscribe(context, widget._itemInfo.item_owner_id);

    final pages = List.generate(
      widget._itemInfo.otherImagesLocation.length + 1,
      (pageindex) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.contain,
            image: pageindex == 0
                ? NetworkImage(widget._itemInfo.item_cover_img)
                : NetworkImage(
                    widget._itemInfo.otherImagesLocation[pageindex - 1]),
          ),
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade300,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );

    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 20, 22, 25),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _buildTopRow(),
                _buildUserInfo(),
                SizedBox(height: 10),
                _buildCoverImage(pages),
                SmoothPageIndicator(
                  controller: widget._pageController,
                  count: pages.length,
                  effect: const WormEffect(
                    dotHeight: 10,
                    dotWidth: 10,
                    activeDotColor: ColorStyles.primary,
                    type: WormType.thinUnderground,
                  ),
                ),
                // TODO : 물건 좋아요 한 List 출력
                //_buildActionButtons(),
                _buildDescription(),
              ],
            ),
          ),
        ));
  }

  Widget _buildTopRow() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 20, 22, 25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(
            onPressed: null,
            iconPath: 'assets/components/Arrow - Left 1.png',
          ),
          _buildIconButton(
            onPressed: () => showOptions(context, '옵션', _menuItems),
            iconPath: 'assets/components/more.png',
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({VoidCallback? onPressed, required String iconPath}) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        onPressed: onPressed,
        icon: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            ColorStyles.primary,
            BlendMode.dstIn,
          ),
          child: Image.asset(iconPath),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ProfileImg(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: 999,
              callback: () {
                // TODO: User Click 시 User info Page로
                print("User Info Page로 이동 ");
                // 이미지를 누르면 Image 상세 정보를 나타내는 페이지로 이동
                if (UserService.instance.uid !=
                    widget._itemInfo.item_owner_id) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          UserProfile(uid: widget._itemInfo.item_owner_id),
                    ),
                  );
                }
              },
              height: 60,
              width: 60,
              imageUrl: widget._itemInfo.item_profile_img,
            ),
            const SizedBox(width: 5),
            Container(
              width: MediaQuery.of(context).size.width * 0.3, // 조정 가능한 값
              alignment: Alignment.center,
              child: Text(
                widget._itemInfo.item_owner_Kickname,
                textAlign: TextAlign.left,
                maxLines: 2, // 최대 2줄로 제한
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: "SUIT",
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12),
              ),
            ),
          ],
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isSubscribed == true
                ? Colors.green
                : ColorStyles.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          onPressed: () {
            if (widget.isSubscribed) {
              widget.isSubscribed = !widget.isSubscribed;
              widget._viewModel.unfollow(widget._itemInfo.item_owner_id);
              setState(() {
                showtoastMessage('해당 사용자를 언팔로우 했습니다.', toastStatus.success);
              });
            } else {
              widget.isSubscribed = !widget.isSubscribed;
              widget._viewModel.follow(widget._itemInfo.item_owner_id);
              setState(() {
                showtoastMessage('해당 사용자를 팔로우 했습니다.', toastStatus.success);
              });
            }
          },
          child: Row(
            children: [
              Icon(
                widget.isSubscribed ? Icons.check : Icons.add,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isSubscribed ? "팔로잉" : "팔로우",
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "SUIT",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoverImage(List<Container> pages) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.3,
      child: InstaImageViewer(
        child: PageView.builder(
          controller: widget._pageController,
          onPageChanged: (index) => setState(() {
            widget._pageindex = index;
          }),
          itemBuilder: (_, pageindex) {
            return pages[pageindex % pages.length];
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 31, 31, 31),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          onPressed: () async {},
          child: const Text("+ 23k Likes"),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.2,
        child: Card(
          color: const Color.fromARGB(255, 31, 31, 31),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              widget._itemInfo.description,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class FrontCard extends StatelessWidget {
  late final HomeViewModel _viewmodel;
  final Color _currentColor;

  final ItemInfo _itemInfo;

  FrontCard(this._itemInfo, {required HomeViewModel viewModel, super.key})
      : _currentColor = _itemInfo.sub_color,
        _viewmodel = viewModel;

  String getImagePath(BuildContext context, String id) {
    final mypage = Provider.of<MypageViewModel>(context, listen: false);
    for (int i = 0; i < mypage.model.getItemList().length; i++) {
      if (mypage.model.getItemList()[i].item_id == id) {
        return mypage.model.getItemList()[i].item_cover_img;
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final containerHeight = constraints.maxHeight;

        return Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_itemInfo.main_color, _itemInfo.sub_color]),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Center(
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                _currentColor.withOpacity(
                                    (_currentColor.computeLuminance() + 0.2)
                                        .clamp(0.2, 1.0)),
                                BlendMode.softLight,
                              ),
                              child: ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return ui.Gradient.linear(
                                    const Offset(0, 0),
                                    Offset(0, bounds.height),
                                    [
                                      _currentColor.withOpacity(0),
                                      _currentColor.withOpacity(
                                          (_currentColor.computeLuminance() +
                                                  0.2)
                                              .clamp(0.2, 1.0)),
                                    ],
                                    [0.5, 1],
                                  );
                                },
                                blendMode: BlendMode.srcOver,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: CachedNetworkImage(
                                    width: containerWidth,
                                    height: containerHeight,
                                    fit: BoxFit.fill,
                                    imageUrl: _itemInfo.item_cover_img,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill,
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
                              ),
                            ),
                          ),
                          Positioned(
                            top: 30,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(30),
                                    bottomRight: Radius.circular(30)),
                                child: getImagePath(context, _itemInfo.match_id)
                                            .isEmpty ==
                                        true
                                    ? const Icon(Icons.error)
                                    : CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        width: containerWidth / 4,
                                        height: containerHeight / 8,
                                        imageUrl: getImagePath(
                                            context, _itemInfo.match_id),
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        placeholder: (context, url) => Center(
                                          child:
                                              PlatformCircularProgressIndicator(
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
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _itemInfo.main_Keyword,
                                      style: TextStyle(
                                        color: _itemInfo.main_color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                      ),
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _itemInfo.sub_Keyword,
                                        style: TextStyle(
                                          color: _itemInfo.sub_color,
                                          fontSize: 25,
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ],
        );
      }),
    );
  }
}

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '알림센터',
          style: TextStyle(
              fontFamily: "SUIT", fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final alram = AlarmService.instance;
            alram.setReadMessage();

            Navigator.pop(context);
          },
        ),
      ),
      body: const NotificationList(),
    );
  }
}

class NotificationList extends StatelessWidget {
  const NotificationList({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AlarmService.instance;
    final filteredAlarms =
        service.alarms!.where((alarm) => !alarm.read!).toList();

    return ListView.builder(
      cacheExtent: 1000,
      itemCount: filteredAlarms.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Text(
            "📢",
            style: TextStyle(fontSize: 24),
          ),
          title: Text(filteredAlarms[index].title.toString()),
          subtitle: Text(filteredAlarms[index].body.toString()),
        );
      },
    );
  }
}
