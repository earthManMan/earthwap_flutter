import 'package:firebase_login/presentation/sell/sellViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_login/presentation/common/widgets/image_add_widget.dart';
import 'package:firebase_login/domain/login/userService.dart';
import 'package:firebase_login/presentation/components/category_widget.dart';
import 'package:firebase_login/presentation/components/item/keyword_input_widget.dart';
import 'package:firebase_login/presentation/components/popup_widget.dart';
import 'package:firebase_login/presentation/components/item/value_select_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/presentation/common/widgets/toast_widget.dart';
import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/app/config/constant.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  _SellScreenState createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final TextEditingController textEditingController =
      TextEditingController(text: "");
  final FocusNode _focusNode = FocusNode();
  List<XFile?> _pickedImages = []; // 선택 된 나머지 Image

  List<Widget> _categoryWidget = [];
  XFile? _coverImage; //선택 된 cover Image
  List<Widget?> _imgwidgets = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // FocusNode에 이벤트 리스너 추가
    _focusNode.addListener(sellViewListen);
  }

  void _buildinitImgWidget() {
    if (_imgwidgets.isEmpty) {
      final mediaQuery = MediaQuery.of(context);
      _imgwidgets.add(SizedBox(
        height: mediaQuery.size.height / 7,
        child: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: ImageAddButton(
            title: "커버 등록",
            onImageSelected: addCoverImages,
            onImageClear: (p0) {},
            visible: true,
          ),
        ),
      ));
      _imgwidgets.add(SizedBox(
        height: mediaQuery.size.height / 7,
        child: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: ImageAddButton(
            title: "사진 등록",
            onImageSelected: addImage,
            onImageClear: (p0) {},
            visible: true,
          ),
        ),
      ));
    }
  }

  void sellViewListen() async {
    if (!_focusNode.hasFocus) {
      // Focus를 잃으면 키보드 숨기기
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _focusNode.removeListener(sellViewListen);
    super.dispose();
  }

  Future<void> addImage(XFile? image) async {
    final viewmodel = Provider.of<SellViewModel>(context, listen: false);

    final userService = UserService.instance;
    if (image != null) {
      setState(() {
        upload_Other_Image(userService.uid.toString(), image);
        _pickedImages.add(image);
      });
    } else {
      setState(() {
        _pickedImages.removeAt(_pickedImages.length - 1);
      });
    }
  }

  Future<void> getDataBase(String imageURL) async {
    final viewmodel = Provider.of<SellViewModel>(context, listen: false);
    viewmodel.getImageUploadResult(imageURL).then((value) => {
          if (value)
            setState(() {
              //      categoryList.clear();
              //      String str = viewmodel.model.getcategory().toString();
              //      categoryList.add(CategoryItem(text: str));
            })
        });
  }

  Future<void> uploadImage(XFile image) async {
    final viewmodel = Provider.of<SellViewModel>(context, listen: false);

    viewmodel.uploadImage(UploadType.cover, "", image).then((result) {
      if (result != null) {
        String url = result['url'] ?? ''; // null 체크 추가
        String uniqueFileName = result['uniqueFileName'] ?? '';
        getDataBase(uniqueFileName);
        viewmodel.model.setcoverImage(url);
      } else {
        // 에러 처리 또는 실패 처리를 수행할 수 있음
        print('Error uploading image or result is null');
      }
    });
  }

  Future<void> addCoverImages(XFile? cover) async {
    if (cover != null) uploadImage(cover);
    setState(() {
      _coverImage = cover;
    });
  }

  Future<void> upload_Other_Image(String uid, XFile image) async {
    final viewmodel = Provider.of<SellViewModel>(context, listen: false);
    viewmodel.uploadImage(UploadType.other, uid, image).then((url) {
      if (url != null) {
        viewmodel.model.addotherImage(url);
      }
    });
  }

  void handleCategoriesSelected(List<String> selectedCategories) {
    final viewmodel = Provider.of<SellViewModel>(context, listen: false);

    setState(() {
      //viewmodel.categorymodel.clearSelected();
      _categoryWidget.clear();
      for (String item in selectedCategories) {
        //viewmodel.categorymodel.addselected(item);

        _categoryWidget.add(
          Padding(
            padding: const EdgeInsets.all(5.0), // 원하는 패딩 값으로 설정
            child: CategoryItem(text: item),
          ),
        );
      }
      Navigator.of(context).pop();
    });
  }

  void resetStateAndNavigate(SellViewModel viewmodel) {
    _coverImage = null;
    _pickedImages.clear();
    textEditingController.clear();
    viewmodel.model.resetModel();
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = Provider.of<SellViewModel>(context, listen: false);
    _buildinitImgWidget();
    return PlatformScaffold(
        appBar: PlatformAppBar(
          material: (context, platform) {
            return MaterialAppBarData(
              centerTitle: true,
            );
          },
          automaticallyImplyLeading: false,
          leading: TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/main');
              resetStateAndNavigate(viewmodel);
            },
            child: const Text(
              "취소",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColor.primary,
              ),
            ),
          ),
          title: const Text('내 물건 업로드',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColor.grayF9)),
          trailingActions: [
            _isLoading == true
                ? PlatformCircularProgressIndicator(
                    cupertino: (context, platform) {
                      return CupertinoProgressIndicatorData(
                        color: AppColor.primary,
                      );
                    },
                  )
                : TextButton(
                    onPressed: () async {
                      if (_coverImage == null || _categoryWidget.isEmpty) {
                        if (_coverImage == null) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomAlertDialog(
                                message: "Cover Image를 등록 해 주세요.",
                                visibleCancel: false,
                                visibleConfirm: true,
                              );
                            },
                          );
                        } else if (_categoryWidget.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomAlertDialog(
                                message: "Category를 선택해 주세요.",
                                visibleCancel: false,
                                visibleConfirm: true,
                              );
                            },
                          );
                        }
                      } else {
                        setState(() {
                          _isLoading = true;
                        });

                        viewmodel.registerItem().then((result) {
                          if (result.isEmpty) {
                            showtoastMessage(
                                '물건 등록을 실패 했습니다.', toastStatus.error);
                          } else {
                            viewmodel.getRegisterItem(result).then((value) => {
                                  setState(() {
                                    _isLoading = false;
                                    Navigator.of(context).pushNamed('/main');
                                    resetStateAndNavigate(viewmodel);
                                  })
                                });
                          }
                        });
                      }
                    },
                    child: Text(
                      "완료",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _coverImage == null || _categoryWidget.isEmpty
                            ? AppColor.gray3A
                            : AppColor.primary,
                      ),
                    ),
                  ),
          ],
          backgroundColor: AppColor.gray1C,
        ),
        backgroundColor: AppColor.gray1C,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: GestureDetector(
            onTap: () {
              // 터치 이벤트 감지 시 키보드 숨기기
              FocusScope.of(context).unfocus();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildImageList(viewmodel),
                _buildDescription(viewmodel, _focusNode),
                _buildKeyword(viewmodel),
                _buildCategory(viewmodel),
                _buildValueRange(viewmodel),
              ],
            ),
          ),
        ));
  }

  Widget _buildImageList(SellViewModel viewmodel) {
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              width: mediaQuery.size.width / 4,
              height: mediaQuery.size.height / 7,
              child: ListView.builder(
                cacheExtent: 1000,
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: _imgwidgets.length,
                itemBuilder: (context, index) {
                  return _imgwidgets[index];
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(SellViewModel viewmodel, FocusNode focus) {
    return Container(
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
          focusNode: focus, // FocusNode 연결
          onChanged: (value) {
            viewmodel.model.setdescription(value);
          },
          controller: textEditingController,
          style: const TextStyle(fontSize: 17),
          keyboardType: TextInputType.multiline,
          maxLength: null,
          maxLines: null,
          decoration: InputDecoration(
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
            hintMaxLines: 3,
            hintText: viewmodel.model.getDescriptionHint().toString(),
            hintStyle: TextStyle(
              color: Color.fromARGB(255, 240, 244, 248),
              fontSize: 14,
              fontFamily: "SUIT",
              overflow: TextOverflow.clip,
            ),
          ),
        ),
      ),
    );
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

  Widget _buildKeyword(SellViewModel viewModel) {
    return KeyWordInputButton(
      text: '키워드 추가',
      MainKeyword: viewModel.model.getMainKeyword(),
      SubKeyword: viewModel.model.getSubKeyword(),
      onPressed: () {
        if (_coverImage == null) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                message: "Cover Image를 등록 해 주세요!!",
                visibleCancel: false,
                visibleConfirm: true,
              );
            },
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KeywordWorkPage(
              mainKeyword: viewModel.model.getMainKeyword(),
              subKeyword: viewModel.model.getSubKeyword(),
              mainColor: viewModel.model.getmain_color(),
              subColor: viewModel.model.getsub_color(),
              colverImage: _coverImage!.path.toString(),
              call: (value, value2) {
                if (value.isNotEmpty || value2.isNotEmpty) {
                  Navigator.of(context).pop();
                  setState(() {
                    if (value.isNotEmpty) {
                      viewModel.model.setMainKeyword(value);
                    }
                    if (value2.isNotEmpty) {
                      viewModel.model.setSubKeyword(value2);
                    }
                  });
                }
              },
            ),
          ),
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
    );
  }

  Widget _buildCategory(SellViewModel viewmodel) {
    return Column(
      children: [
        CategoryButton(
          text: '카테고리',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategorySelectionPage(
                  onPressed: handleCategoriesSelected,
                  categories: [], //viewmodel.categorymodel.categories,
                  selected: viewmodel.selected,
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
              children: _categoryWidget,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueRange(SellViewModel viewmodel) {
    return ValueRangeButton(
      userPrice: viewmodel.model.getUserPrice(),
      priceStart: viewmodel.model.getPriceStart(),
      priceEnd: viewmodel.model.getPriceEnd(),
      text: '가격범위',
      call: (price, start, end) {
        viewmodel.model.setUserPrice(price);
        viewmodel.model.setprice_start(start);
        viewmodel.model.setprice_end(end);
        Navigator.of(context).pop();
        setState(() {});
      },
    );
  }
}
