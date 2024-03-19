import 'package:firebase_login/domain/home/home_model.dart';
import 'package:flutter/material.dart';
//import 'package:extended_image/extended_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_login/presentation/components/item/image_detail_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ImageGridView extends StatefulWidget {
  List<ItemInfo> itemInfo;

  final Function(String item_id) onItemRemoveCallback; // Callback function

  ImageGridView({
    super.key,
    required this.itemInfo,
    required this.onItemRemoveCallback,
  });

  @override
  _ImageGridViewState createState() => _ImageGridViewState();
}

class _ImageGridViewState extends State<ImageGridView> {
  @override
  void initState() {
    super.initState();

    widget.itemInfo.sort((a, b) => b.create_time.compareTo(a.create_time));
  }

  @override
  void dispose() {
    // 타이머나 애니메이션을 여기에서 종료하십시오.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 열의 수
        crossAxisSpacing: 1.0, // 열 간의 간격
        mainAxisSpacing: 1.0, // 행 간의 간격
      ),
      itemCount: widget.itemInfo.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            List<String> images = [];
            ItemInfo info = widget.itemInfo[index];
            images.add(info.item_cover_img);
            for (String img in info.otherImagesLocation) {
              images.add(img);
            }

            // 이미지를 누르면 Image 상세 정보를 나타내는 페이지로 이동
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ImageDetailPage(
                  info: info,
                  onItemRemoveCallback: widget.onItemRemoveCallback,
                  onUpdateItemCallback: (item) {
                    setState(() {
                      widget.itemInfo[index] = item;
                    });
                  },
                ),
              ),
            );
          },
          child: widget.itemInfo[index].item_cover_img.isEmpty
              ? const Center(child: Icon(Icons.error))
              : CachedNetworkImage(
                  imageUrl: widget.itemInfo[index].item_cover_img,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Center(
                    child: PlatformCircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
          /*ExtendedImage.network(
            widget.itemInfo[index].item_cover_img,
            cache: true,
            fit: BoxFit.fill, // 이미지를 적절하게 확대 또는 축소하여 표시
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
        );
      },
    );
  }
}
