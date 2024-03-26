import 'package:flutter/material.dart';
import 'package:firebase_login/presentation/components/item/image_grid_widget.dart';
import 'package:firebase_login/presentation/components/content/post_grid_widget.dart';
import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/domain/home/home_model.dart';
import 'package:firebase_login/domain/postitem/postItem_model.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: widget.isMyPage == true ? 3 : 2,
        vsync: this); // vsync를 this로 설정
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          unselectedLabelColor: AppColor.gray48,
          labelStyle: const TextStyle(
              fontFamily: "SUIT", fontSize: 16, fontWeight: FontWeight.bold),
          labelColor: AppColor.grayF9,
          indicatorColor: AppColor.primary,
          controller: _tabController,
          tabs: [
            Tab(text: '어스왑'),
            if (widget.isMyPage == true) Tab(text: '좋아요'),
            Tab(text: '게시글'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ImageGridView(
                itemInfo: widget.itemInfo,
                onItemRemoveCallback: widget.delete_callback,
              ),
              widget.follow_itemInfo.isEmpty == true
                  ? Center(
                      child: Text("구독한 유저가 없습니다."),
                    )
                  : ImageGridView(
                      itemInfo: widget.follow_itemInfo,
                      onItemRemoveCallback: (item_id) {},
                    ),
              PostGridView(
                contents: widget.post_itemInfo,
                scaffoldKey: widget.scaffoldKey,
                noUpdate: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
