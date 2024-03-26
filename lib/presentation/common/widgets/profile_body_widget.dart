import 'package:flutter/material.dart';
import 'package:firebase_login/presentation/components/item/image_grid_widget.dart';
import 'package:firebase_login/presentation/components/content/post_grid_widget.dart';
import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/domain/home/home_model.dart';
import 'package:firebase_login/domain/postitem/postItem_model.dart';

class ProfileBodyWidget extends StatefulWidget {
  final bool isMyPage; // isMyPage 속성 추가
  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<ItemInfo> itemInfo;
  final List<ItemInfo> follow_itemInfo;
  final List<PostItemModel> post_itemInfo;
  final dynamic Function(String) delete_callback;

  const ProfileBodyWidget({
    this.isMyPage = true, // 기본값은 true (자신의 Mypage)
    required this.scaffoldKey,
    required this.itemInfo,
    required this.follow_itemInfo,
    required this.post_itemInfo,
    required this.delete_callback,
    Key? key,
  }) : super(key: key);

  @override
  _ProfileBodyWidgetState createState() => _ProfileBodyWidgetState();
}

class _ProfileBodyWidgetState extends State<ProfileBodyWidget>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _pageController.animateToPage(
                    0,
                    duration: Duration(milliseconds: 300), // 애니메이션 지속 시간 설정
                    curve: Curves.ease, // 애니메이션 커브 설정
                  );
                },
                child: Text(
                  '어스왑',
                  style: TextStyle(
                      color: _currentPageIndex == 0
                          ? AppColor.primary // 선택된 페이지에 대한 색상
                          : AppColor.grayF9,
                      fontFamily: "SUIT",
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // 버튼 색상 투명으로 설정
                  elevation: 0, // 그림자 제거
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  side: BorderSide(
                    color: Colors.transparent,
                    width: 1.0, // 밑줄 두께 조정
                  ),
                ),
              ),
            ),
            if (widget.isMyPage)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.animateToPage(
                      1,
                      duration: Duration(milliseconds: 300), // 애니메이션 지속 시간 설정
                      curve: Curves.ease, // 애니메이션 커브 설정
                    );
                  },
                  child: Text(
                    '좋아요',
                    style: TextStyle(
                        color: _currentPageIndex == 1
                            ? AppColor.primary // 선택된 페이지에 대한 색상
                            : AppColor.grayF9,
                        fontFamily: "SUIT",
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // 버튼 색상 투명으로 설정
                    elevation: 0, // 그림자 제거
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    side: BorderSide(
                      color: Colors.transparent,
                      width: 1.0, // 밑줄 두께 조정
                    ),
                  ),
                ),
              ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _pageController.animateToPage(
                    2,
                    duration: Duration(milliseconds: 300), // 애니메이션 지속 시간 설정
                    curve: Curves.ease, // 애니메이션 커브 설정
                  );
                },
                child: Text(
                  '게시글',
                  style: TextStyle(
                      color: _currentPageIndex == 2
                          ? AppColor.primary // 선택된 페이지에 대한 색상
                          : AppColor.grayF9,
                      fontFamily: "SUIT",
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // 버튼 색상 투명으로 설정
                  elevation: 0, // 그림자 제거
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  side: BorderSide(
                    color: Colors.transparent,
                    width: 1.0, // 밑줄 두께 조정
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                height: 1.0,
                color: _currentPageIndex == index
                    ? AppColor.primary
                    : Colors.transparent,
              ),
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemCount: 3, // 페이지 수 설정
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return ImageGridView(
                    itemInfo: widget.itemInfo,
                    onItemRemoveCallback: widget.delete_callback,
                  );
                case 1:
                  return widget.follow_itemInfo.isEmpty
                      ? Center(
                          child: Text("구독한 유저가 없습니다."),
                        )
                      : ImageGridView(
                          itemInfo: widget.follow_itemInfo,
                          onItemRemoveCallback: (item_id) {},
                        );
                case 2:
                  return PostGridView(
                    contents: widget.post_itemInfo,
                    scaffoldKey: widget.scaffoldKey,
                    noUpdate: false,
                  );
                default:
                  return Container(); // 예기치 않은 경우 빈 컨테이너 반환
              }
            },
          ),
        ),
      ],
    );
  }
}
