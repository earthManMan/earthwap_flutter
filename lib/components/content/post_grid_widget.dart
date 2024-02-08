import 'package:firebase_login/components/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/model/postItemModel.dart';
import 'package:firebase_login/components/content/post_item_widget.dart';
import 'package:firebase_login/components/content/post_detail_widget.dart';
import 'package:firebase_login/viewModel/worldViewModel.dart';
import 'package:provider/provider.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'dart:async';

class PostGridView extends StatefulWidget {
  List<PostItemModel> contents;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool noUpdate;

  PostGridView({
    super.key,
    required this.scaffoldKey,
    required this.contents,
    required this.noUpdate,
  });

  @override
  _PostGridViewState createState() => _PostGridViewState();
}

class _PostGridViewState extends State<PostGridView> {
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

// 추가 데이터 가져올때 하단 인디케이터 표시용
  bool isMoreRequesting = false;

  double _dragDistance = 0;

  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    widget.contents.sort((a, b) => b.date.compareTo(a.date));
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController!.dispose();
    _refreshIndicatorKey.currentState?.dispose();

    // 타이머나 애니메이션을 여기에서 종료하십시오.
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final Completer<bool> completer = Completer<bool>();
    final ViewModel = Provider.of<WorldViewModel>(context, listen: false);
    ViewModel.update_postItem().then((value) => {completer.complete(value)});

    setState(() {});

    return completer.future.then((value) {
      ScaffoldMessenger.of(widget.scaffoldKey.currentState!.context)
          .showSnackBar(
        SnackBar(
          content: Text(
            value ? "Refresh complete" : "Refresh 된 게시글이 없습니다.",
            style: TextStyle(fontFamily: "SUIT", fontWeight: FontWeight.bold),
          ),
        ),
      );
    });
  }

  scrollNotification(notification) {
    // 스크롤 최대 범위
    var containerExtent = notification.metrics.viewportDimension;

    if (notification is ScrollStartNotification) {
      // 스크롤을 시작하면 발생(손가락으로 리스트를 누르고 움직이려고 할때)
      // 스크롤 거리값을 0으로 초기화함
      _dragDistance = 0;
    } else if (notification is OverscrollNotification) {
      // 안드로이드에서 동작
      // 스크롤을 시작후 움직일때 발생(손가락으로 리스트를 누르고 움직이고 있을때 계속 발생)
      // 스크롤 움직인 만큼 빼준다.(notification.overscroll)
      _dragDistance -= notification.overscroll;
    } else if (notification is ScrollUpdateNotification) {
      // ios에서 동작
      // 스크롤을 시작후 움직일때 발생(손가락으로 리스트를 누르고 움직이고 있을때 계속 발생)
      // 스크롤 움직인 만큼 빼준다.(notification.scrollDelta)
      _dragDistance -= notification.scrollDelta!;
    } else if (notification is ScrollEndNotification) {
      // 스크롤이 끝났을때 발생(손가락을 리스트에서 움직이다가 뗐을때 발생)

      // 지금까지 움직인 거리를 최대 거리로 나눈다.
      var percent = _dragDistance / (containerExtent);
      // 해당 값이 -0.4(40프로 이상) 아래서 위로 움직였다면
      if (percent <= -0.4) {
        // maxScrollExtent는 리스트 가장 아래 위치 값
        // pixels는 현재 위치 값
        // 두 같이 같다면(스크롤이 가장 아래에 있다)
        if (notification.metrics.maxScrollExtent ==
            notification.metrics.pixels) {
          setState(() {
            // 서버에서 데이터를 더 가져오는 효과를 주기 위함
            // 하단에 프로그레스 서클 표시용
            isMoreRequesting = true;
          });

          // 서버에서 데이터 가져온다.
          requestMore().then((value) {
            setState(() {
              // 다 가져오면 하단 표시 서클 제거
              isMoreRequesting = false;
            });
          });
        }
      }
    }
  }

  // 서버에서 추가 데이터 가져올 때
  Future<void> requestMore() async {
    final Completer<bool> completer = Completer<bool>();
    final ViewModel = Provider.of<WorldViewModel>(context, listen: false);
    ViewModel.update_postItem().then((value) => {completer.complete(value)});

    setState(() {});

    return completer.future.then((value) {
      print("update_postItem$value");
    });
  }

  @override
  Widget build(BuildContext context) {
    final ViewModel = Provider.of<WorldViewModel>(context, listen: false);

    return widget.noUpdate == false
        ? ListView.builder(
            cacheExtent: 1000,
            itemCount: widget.contents.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  // 이미지를 누르면 Image 상세 정보를 나타내는 페이지로 이동
                  ViewModel.viewUpCount(widget.contents[index].contentID);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Consumer<WorldViewModel>(
                        builder: (context, viewModel, child) {
                          return PostDetailPage(
                            item: widget.contents[index],
                            onDeleteItemCallback: (item) {
                              setState(() {
                                widget.contents.remove(item);
                              });
                            },
                            onUpdateItemCallback: (item) {
                              setState(() {
                                widget.contents[index] = item;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
                child: PostItemWidget(item: widget.contents[index]),
              );
            },
          )
        : NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              /*
                 스크롤 할때 발생되는 이벤트
                 해당 함수에서 어느 방향으로 스크롤을 했는지를 판단해
                 리스트 가장 밑에서 아래서 위로 40프로 이상 스크롤 했을때 
                 서버에서 데이터를 추가로 가져오는 루틴이 포함됨.
                */
              scrollNotification(notification);
              return false;
            },
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _handleRefresh,
              backgroundColor: ColorStyles.primary,
              color: ColorStyles.background,
              child: Stack(
                children: <Widget>[
                  ListView.builder(
                    cacheExtent: 1000,
                    itemCount: widget.contents.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          // 이미지를 누르면 Image 상세 정보를 나타내는 페이지로 이동
                          ViewModel.viewUpCount(
                              widget.contents[index].contentID);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Consumer<WorldViewModel>(
                                builder: (context, viewModel, child) {
                                  return PostDetailPage(
                                    item: widget.contents[index],
                                    onDeleteItemCallback: (item) {
                                      setState(() {
                                        widget.contents.remove(item);
                                      });
                                    },
                                    onUpdateItemCallback: (item) {
                                      setState(() {
                                        widget.contents[index] = item;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        child: PostItemWidget(item: widget.contents[index]),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: isMoreRequesting ? 50.0 : 0,
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 40.0, // Adjust the width as needed
                              height: 40.0, // Adjust the height as needed
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    ColorStyles.primary, // Outer circle color
                              ),
                            ),
                            SizedBox(
                              width: 24.0, // Adjust the size as needed
                              height: 24.0, // Adjust the size as needed
                              child: CircularProgressIndicator(
                                strokeWidth:
                                    2.0, // Adjust the strokeWidth as needed
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black), // Inner circle color
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
