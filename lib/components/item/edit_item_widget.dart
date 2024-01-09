import 'package:firebase_login/model/homeModel.dart';
import 'package:firebase_login/model/sellModel.dart';
import 'package:firebase_login/service/userService.dart';
import 'package:firebase_login/viewModel/sellViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/components/theme.dart';
import 'package:firebase_login/components/category_widget.dart';
import 'package:firebase_login/viewModel/mypageViewModel.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:firebase_login/components/item/keyword_input_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_login/components/popup_widget.dart';
import 'package:firebase_login/components/common_components.dart';
import 'package:firebase_login/components/item/value_select_widget.dart';
import 'package:firebase_login/API/firebaseAPI.dart';

class EditItemPage extends StatefulWidget {
  ItemInfo itemInfo;

  bool isModify = false;

  final Function(ItemInfo, bool) onModifyItem;

  EditItemPage({
    super.key,
    required this.itemInfo,
    required this.onModifyItem,
  });

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  List<Widget> categoryList = [];
  late ItemInfo Temp_itemInfo;

  @override
  void initState() {
    super.initState();
    initTempItemInfo();
    final viewmodel = Provider.of<MypageViewModel>(context, listen: false);

    categoryList.add(CategoryItem(text: widget.itemInfo.category));
    viewmodel.categorymodel.addselected(widget.itemInfo.category);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initTempItemInfo() {
    Temp_itemInfo = ItemInfo(
        item_id: widget.itemInfo.item_id,
        item_owner_id: widget.itemInfo.item_owner_id,
        item_owner_Kickname: widget.itemInfo.item_owner_Kickname,
        item_profile_img: widget.itemInfo.item_profile_img,
        category: widget.itemInfo.category,
        item_cover_img: widget.itemInfo.item_cover_img,
        otherImagesLocation: widget.itemInfo.otherImagesLocation,
        description: widget.itemInfo.description,
        isPremium: widget.itemInfo.isPremium,
        isTraded: widget.itemInfo.isTraded,
        likes: widget.itemInfo.likes,
        dislikes: widget.itemInfo.dislikes,
        main_color: widget.itemInfo.main_color,
        sub_color: widget.itemInfo.sub_color,
        main_Keyword: widget.itemInfo.main_Keyword,
        sub_Keyword: widget.itemInfo.sub_Keyword,
        matchItems: widget.itemInfo.matchItems,
        userPrice: widget.itemInfo.userPrice,
        priceEnd: widget.itemInfo.priceEnd,
        priceStart: widget.itemInfo.priceStart,
        create_time: widget.itemInfo.create_time,
        update_time: widget.itemInfo.update_time,
        match_id: widget.itemInfo.match_id,
        match_owner_id: widget.itemInfo.match_owner_id,
        match_img: widget.itemInfo.match_img);
  }

  void handleCategoriesSelected(List<String> selectedCategories) {
    final viewmodel = Provider.of<MypageViewModel>(context, listen: false);

    setState(() {
      viewmodel.categorymodel.clearSelected();
      categoryList.clear();
      for (String item in selectedCategories) {
        viewmodel.categorymodel.addselected(item);

        categoryList.add(
          Padding(
            padding: const EdgeInsets.all(5.0), // 원하는 패딩 값으로 설정
            child: CategoryItem(text: item),
          ),
        );
        widget.itemInfo.category = item;
        widget.isModify = true;
      }

      Navigator.of(context).pop();
    });
  }

  Future<bool> isKeyword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final popup = prefs.getBool('isKeywordPopup') ?? '';
    if (popup == "") {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ViewModel = Provider.of<MypageViewModel>(context, listen: false);
    final sellviewmodel = Provider.of<SellViewModel>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            '아이템 수정하기',
            style: TextStyle(
                fontFamily: "SUIT", fontWeight: FontWeight.bold, fontSize: 20),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.onModifyItem(Temp_itemInfo, false);
              // 뒤로 가기 버튼을 눌렀을 때 실행할 작업을 여기에 추가합니다.
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
                onPressed: () {
                  widget.onModifyItem(widget.itemInfo, widget.isModify);
                  Navigator.of(context).pop();
                },
                child: const Text("완료"))
          ],
        ),
        body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: GestureDetector(
              onTap: () {
                // 터치 이벤트 감지 시 키보드 숨기기
                FocusScope.of(context).unfocus();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ImageAddListWidget(itemInfo: widget.itemInfo),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: Scrollbar(
                        child: TextField(
                          enableInteractiveSelection: true,
                          onChanged: (value) {
                            widget.itemInfo.description = value;
                            widget.isModify = true;
                          },
                          controller: TextEditingController(
                              text: widget.itemInfo.description),
                          style: const TextStyle(fontSize: 17),
                          keyboardType: TextInputType.multiline,
                          maxLength: null,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                            hintMaxLines: 3,
                            hintText: sellviewmodel.model
                                .getDescriptionHint()
                                .toString(),
                            hintStyle: TextStyle(
                              color: ColorStyles.content,
                              fontSize: 17,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  KeyWordInputButton(
                    text: '키워드 추가',
                    MainKeyword: widget.itemInfo.main_Keyword,
                    SubKeyword: widget.itemInfo.sub_Keyword,
                    onPressed: () {
                      if (widget.itemInfo.item_cover_img.isEmpty) {
                        showSnackbar(context, 'Cover Image를 등록 해 주세요!!');
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => KeywordWorkPage(
                                colverImage: widget.itemInfo.item_cover_img,
                                mainColor: widget.itemInfo.main_color,
                                subColor: widget.itemInfo.sub_color,
                                mainKeyword: widget.itemInfo.main_Keyword,
                                subKeyword: widget.itemInfo.sub_Keyword,
                                call: (value, value2) {
                                  if (value.isNotEmpty || value2.isNotEmpty) {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      if (value.isNotEmpty) {
                                        widget.isModify = true;
                                        widget.itemInfo.main_Keyword = value;
                                      }
                                      if (value2.isNotEmpty) {
                                        widget.itemInfo.sub_Keyword = value2;
                                        widget.isModify = true;
                                      }
                                    });
                                  }
                                })),
                      );
                      isKeyword().then((value) => {
                            if (!value)
                              {
                                showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return const KeyWordPopup();
                                  },
                                )
                              }
                          });
                    },
                  ),
                  Column(
                    children: [
                      CategoryButton(
                        text: '카테고리',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategorySelectionPage(
                                onPressed: handleCategoriesSelected,
                                categories: ViewModel.categorymodel.categories,
                                selected: ViewModel.categorymodel.selected,
                                isSingleSelection: true,
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: categoryList,
                          ),
                        ),
                      ),
                      ValueRangeButton(
                        userPrice: widget.itemInfo.userPrice.toInt(),
                        priceStart: widget.itemInfo.priceStart,
                        priceEnd: widget.itemInfo.priceEnd,
                        text: '가격범위',
                        call: (price, start, end) {
                          widget.isModify = true;
                          widget.itemInfo.userPrice = price.toInt();
                          widget.itemInfo.priceStart = start;
                          widget.itemInfo.priceEnd = end;
                          Navigator.of(context).pop();
                          setState(() {
                            print("가격범위!!!");
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )));
  }
}

class ImageAddListWidget extends StatefulWidget {
  final ItemInfo itemInfo;

  const ImageAddListWidget({
    super.key,
    required this.itemInfo,
  });
  @override
  _ImageAddListWidgetState createState() => _ImageAddListWidgetState();
}

class _ImageAddListWidgetState extends State<ImageAddListWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView(
        cacheExtent: 1000,
        shrinkWrap: false,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          // Check if there are any images
          if (widget.itemInfo.item_cover_img.isEmpty)
            _buildAddCoverImageButton()
          else
            _buildCoverImage(),

          // Display other images
          for (var i = 0; i < widget.itemInfo.otherImagesLocation.length; i++)
            _buildImageContainer(i),

          // Add more images button (if less than 6 images)
          if (widget.itemInfo.otherImagesLocation.length < 5)
            _buildAddOtherImageButton(),
        ],
      ),
    );
  }

  Widget _buildAddCoverImageButton() {
    return SizedBox(
      width: 150,
      height: 150,
      child: OutlinedButton(
        onPressed: () {
          pickCoverImage();
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white, width: 2.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
            Text(
              "커버 등록",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        children: [
          getImageWidget(widget.itemInfo.item_cover_img),
          // Cancel button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                removeCoverImage();
              },
              child: const Icon(Icons.close, color: Colors.red),
            ),
          ),
          // Star button
          Positioned(
            top: 8,
            left: 8,
            child: GestureDetector(
              onTap: () {
                removeCoverImage();
              },
              child: const Icon(Icons.star_outlined, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer(int index) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        children: [
          getImageWidget(widget.itemInfo.otherImagesLocation[index]),
          // Cancel button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                removeImage(index);
              },
              child: const Icon(Icons.close, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOtherImageButton() {
    return SizedBox(
      width: 150,
      height: 150,
      child: OutlinedButton(
        onPressed: () {
          pickImage();
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white, width: 2.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
            const Text(
              "사진 추가",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "${widget.itemInfo.otherImagesLocation.length} / 5",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // 이미지 추가 함수
  void pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      uploadImage(UploadType.other, pickedFile);
    }
  }

  // 이미지 삭제 함수
  void removeImage(int index) {
    setState(() {
      widget.itemInfo.otherImagesLocation.removeAt(index);
    });
  }

  // 이미지 추가 함수
  void pickCoverImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      uploadImage(UploadType.cover, pickedFile);
    }
  }

  // 이미지 삭제 함수
  void removeCoverImage() {
    setState(() {
      widget.itemInfo.item_cover_img = "";
    });
  }

  Future<void> uploadImage(UploadType type, XFile image) async {
    final viewmodel = Provider.of<SellViewModel>(context, listen: false);
    final user = UserService.instance;

    viewmodel.uploadImage(type, user.uid!, image).then((result) {
      if (result != null) {
        if (type == UploadType.cover) {
          String url = result['url'] ?? ''; // null 체크 추가
          String uniqueFileName = result['uniqueFileName'] ?? '';
          setState(() {
            widget.itemInfo.item_cover_img = url;
          });
        } else if (type == UploadType.other) {
          setState(() {
            String url = result.toString(); // null 체크 추가
            widget.itemInfo.otherImagesLocation.add(url);
          });
        }
      } else {
        // 에러 처리 또는 실패 처리를 수행할 수 있음
        print('Error uploading image or result is null');
      }
    });
  }
}

Widget getImageWidget(String imagePath) {
  if (Uri.parse(imagePath).isAbsolute) {
    // URL인 경우
    return CachedNetworkImage(
      imageUrl: imagePath,
      width: 150,
      height: 150,
      fit: BoxFit.contain,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.contain,
          ),
        ),
      ),
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  } else {
    // 파일 경로인 경우
    return Image.file(
      File(imagePath),
      width: 150,
      height: 150,
      fit: BoxFit.contain,
    );
  }
}
