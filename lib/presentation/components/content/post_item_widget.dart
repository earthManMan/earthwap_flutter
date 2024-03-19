import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_login/presentation/components/theme.dart';
import 'package:firebase_login/domain/postitem/postItem_model.dart';
import 'package:firebase_login/presentation/world/worldViewModel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

String getCurrentTime(String seconds) {
  int unixSeconds = int.parse(seconds);
  // Unix 시간 형식으로 저장된 _seconds 값을 사용하여 DateTime 객체 생성
  DateTime pastTime = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);

  // 현재 시간을 얻습니다.
  DateTime currentTime = DateTime.now();

  // 현재 시간과 과거 시간의 차이를 계산합니다.
  Duration difference = currentTime.difference(pastTime);

  // 차이를 분 단위로 계산합니다.
  int minutesDifference = difference.inMinutes;

  if (minutesDifference >= 60) {
    // 1시간 이상 차이가 나면 시간 단위로 반환
    int hoursDifference = difference.inHours;
    if (hoursDifference >= 24) {
      int daysDifference = difference.inDays;
      return "$daysDifference일 전";
    } else {
      return "$hoursDifference시간 전";
    }
  } else {
    // 1시간 미만이면 분 단위로 반환
    return "$minutesDifference분 전";
  }
}

class PostItemWidget extends StatefulWidget {
  late PostItemModel itemModel;

  PostItemWidget({
    required PostItemModel item,
    super.key,
  }) : itemModel = item;

  @override
  _PostItemWidgetState createState() => _PostItemWidgetState();
}

class _PostItemWidgetState extends State<PostItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 29, 31, 34),
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "\n${getCurrentTime(widget.itemModel.date)}",
                    style: const TextStyle(
                      fontSize: 12.0, // 원하는 폰트 크기로 조절
                      fontWeight: FontWeight.normal, // 일반 텍스트 스타일로 설정
                    ),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width *
                            0.6), // 원하는 최대 폭
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        widget.itemModel.title,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  ),
                  if (widget
                      .itemModel.contentImg.isNotEmpty) // 이미지 데이터가 있는 경우에만 표시
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CachedNetworkImage(
                        imageUrl: widget.itemModel.contentImg,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        placeholder: (context, url) =>  Center(
                          child: PlatformCircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                      /*ExtendedImage.network(
                        widget.itemModel.contentImg,
                        cache: true,
                        width: 80,
                        fit: BoxFit.fitWidth,
                        loadStateChanged: (ExtendedImageState state) {
                          switch (state.extendedImageLoadState) {
                            case LoadState.loading:
                              return Center(child: CircularProgressIndicator());
                            case LoadState.completed:
                              return null;
                            case LoadState.failed:
                              return Icon(Icons.error);
                          }
                        },
                      ),*/
                    )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  widget.itemModel.description,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Color.fromARGB(255, 147, 147, 147),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10), // 간격 조절
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                onPressed: () {
                  final world =
                      Provider.of<WorldViewModel>(context, listen: false);
                  world
                      .contentLike(widget.itemModel.contentID.toString())
                      .then((value) => {
                            if (value)
                              setState(() {
                                widget.itemModel.likes =
                                    widget.itemModel.likes.toInt() + 1;
                              })
                          });
                },
                icon:
                    const Icon(Icons.favorite_border, color: ColorStyles.text),
                label: Text(
                  widget.itemModel.likes.toString(),
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat_outlined, color: ColorStyles.text),
                label: Text(
                  widget.itemModel.comments.length.toString(), // 댓글 수로 변경
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.remove_red_eye_outlined,
                    color: ColorStyles.text),
                label: Text(
                  widget.itemModel.views.toString(),
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // 간격 조절
        ],
      ),
    );
  }
}
