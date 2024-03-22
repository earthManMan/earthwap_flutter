import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_login/presentation/components/theme.dart';
import 'package:firebase_login/domain/home/home_model.dart';
import 'package:firebase_login/presentation/components/common_components.dart';
import 'package:firebase_login/presentation/components/item/edit_item_widget.dart';
import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:firebase_login/domain/login/userService.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/presentation/common/widgets/toast_widget.dart';
import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/app/config/constant.dart';
class ImageDetailPage extends StatefulWidget {
  ItemInfo info;
  final Function(String item_id) onItemRemoveCallback;
  final Function(ItemInfo info) onUpdateItemCallback;

  ImageDetailPage({
    super.key,
    required this.info,
    required this.onItemRemoveCallback,
    required this.onUpdateItemCallback,
  });

  @override
  _ImageDetailPageState createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  late List<String> imageUrls;
  List<MenuItem> _MenuItem = [];
  final _pageController = PageController(viewportFraction: 1.0, keepPage: true);
  int _pageIndex = 0;
  bool isOwner = true;

  @override
  void initState() {
    super.initState();

    // image 추가
    imageUrls = [widget.info.item_cover_img];
    imageUrls.addAll(widget.info.otherImagesLocation);

    // Login 한 유저의 Item인지 판단.
    final user = UserService.instance;
    if (user.uid != widget.info.item_owner_id) {
      // 상대방의 Item
      loadUserInfo();
      isOwner = false;
    }
  }

  void loadUserInfo() async {
    final api = FirebaseAPI();
    final userinfo =
        await api.getUserInfoOnCallFunction(widget.info.item_owner_id);
    if (userinfo != null) {
      final itemNickName = userinfo["nickname"];
      final itemProfileName = userinfo["profile_picture_url"] ??
          ""; //"assets/images/default_Profile.png";
    }
  }

  void buildMenuItems(BuildContext context) {
    if (isOwner) {
      _MenuItem = [
        MenuItem(
          callback: () {
            // 이미지를 누르면 Image 상세 정보를 나타내는 페이지로 이동
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EditItemPage(
                itemInfo: widget.info,
                onModifyItem: (item, modify) {
                  if (modify) {
                    setState(() {
                      widget.info = item;
                      imageUrls.clear();
                      // image 추가
                      imageUrls = [widget.info.item_cover_img];
                      imageUrls.addAll(widget.info.otherImagesLocation);
                      widget.onUpdateItemCallback(widget.info);
                      final api = FirebaseAPI();
                      api.updateItemInfoOnCallFunction(
                        item.item_owner_id,
                        item.item_id,
                        {
                          'main_keyword': item.main_Keyword,
                          'sub_keyword': item.sub_Keyword,
                          'description': item.description,
                          'price_end': item.priceStart,
                          'price_start': item.priceEnd,
                          'cover_image_location': item.item_cover_img,
                          'other_images_location': item.otherImagesLocation,
                        },
                      );
                    });
                  } else {
                    setState(() {
                      widget.info = item;
                      widget.onUpdateItemCallback(widget.info);
                    });
                  }
                },
              ),
            ));
          },
          Content: '수정 하기',
          textColor: Colors.white,
        ),
        MenuItem(
          callback: () {
            Navigator.of(context, rootNavigator: true).pop(true);
            widget.onItemRemoveCallback(widget.info.item_id);
          },
          Content: '삭제 하기',
          textColor: Colors.white,
        ),
      ];
    } else {
      _MenuItem = [
        MenuItem(
            callback: () {
              final api = FirebaseAPI();
              api
                  .reportOnCallFunction(UserService.instance.uid!,
                      widget.info.item_owner_id, "item을 신고하였습니다.")
                  .then((value) => {
                        if (value == true)
                          {
                            Navigator.of(context).pop(),
                            showtoastMessage(
                                '해당 item을 신고하였습니다.', toastStatus.success),
                          }
                      });
            },
            Content: '신고 하기',
            textColor: Colors.white),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    buildMenuItems(context);

    final pages = List.generate(
      imageUrls.length,
      (pageIndex) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade300,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: CachedNetworkImage(
          imageUrl: imageUrls[pageIndex],
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.contain,
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
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.info.main_Keyword + widget.info.sub_Keyword),
        actions: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                showOptions(context, '게시글 옵션', _MenuItem);
              },
              icon: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  ColorStyles.primary, // 필터 색상을 지정
                  BlendMode.dstIn, // 필터 모드를 지정
                ),
                child: Image.asset('assets/components/more.png'),
              ),
            ),
          ),
        ],
      ),
      body: Card(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 29, 31, 34),
            boxShadow: [
              BoxShadow(
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        isOwner == true
                            ? widget.info.priceStart.toString() +
                                " ~ " +
                                widget.info.priceEnd.toString() +
                                '원 | ' +
                                widget.info.category +
                                " | " +
                                widget.info.main_Keyword +
                                widget.info.sub_Keyword
                            : "${widget.info.category} | ${widget.info.main_Keyword}${widget.info.sub_Keyword}",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 130, 130, 130),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Container(
                  child: InstaImageViewer(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) => _pageIndex = index,
                      itemBuilder: (_, pageIndex) {
                        return pages[pageIndex % pages.length];
                      },
                    ),
                  ),
                ),
              ),
              SmoothPageIndicator(
                controller: _pageController,
                count: pages.length,
                effect: const WormEffect(
                  dotHeight: 10,
                  dotWidth: 10,
                  activeDotColor: ColorStyles.primary,
                  type: WormType.thinUnderground,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Card(
                    color: const Color.fromARGB(255, 29, 31, 34),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        widget.info.description,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
