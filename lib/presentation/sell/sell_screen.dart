import 'package:firebase_login/presentation/sell/sellViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_login/presentation/common/widgets/image_add_widget.dart';
import 'package:firebase_login/domain/login/userService.dart';
import 'package:firebase_login/presentation/components/category_widget.dart';
import 'package:firebase_login/presentation/common/widgets/keyword_input_widget.dart';
import 'package:firebase_login/presentation/components/popup_widget.dart';
import 'package:firebase_login/presentation/components/item/value_select_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/presentation/common/widgets/toast_widget.dart';
import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/app/config/constant.dart';
import 'package:firebase_login/app/util/localStorage_util.dart';
import 'package:firebase_login/presentation/common/widgets/custom_popup_widget.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  _SellScreenState createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _storage = LocalStorage();
  final TextEditingController textEditingController =
      TextEditingController(text: "");

  List<Widget> _categoryWidget = [];
  XFile? _coverImage; //선택 된 cover Image
  late ImageAddButton _coverWidget;
  List<ImageAddButton> _imgwidgets = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Future<bool> isKeyword() async {
    return false;
    final result = await _storage.getitem(KEY_KEYWORDPOPUP);
    if (result.toString().isNotEmpty) {
      bool state = false;
      result.toString() == 'true' ? state = true : state = false;
      return state;
    } else {
      return false;
    }
  }

  void _buildinitImgWidget() {
    final viewmodel = Provider.of<SellViewModel>(context, listen: false);

    if (_imgwidgets.isEmpty) {
      _coverWidget = ImageAddButton(
        title: "커버 등록",
        subtitle: "0/1",
        onImageSelected: addCoverImages,
        onImageClear: (p0) {
          viewmodel.model.setcoverImage("");
        },
      );
      _imgwidgets.add(_coverWidget);
      _imgwidgets.add(ImageAddButton(
        title: "사진 등록",
        subtitle: "0/5",
        onImageSelected: addImage,
        onImageClear: (p0) {
          setState(() {
            _imgwidgets.remove(p0);
          });
        },
      ));
    }
  }

  Future<void> addCoverImages(XFile? cover) async {
    if (cover != null) uploadImage(UploadType.cover, cover);
    setState(() {
      _coverImage = cover;
    });
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

  Future<void> addImage(XFile? image) async {
    if (image != null) uploadImage(UploadType.other, image);
    if (_imgwidgets.length < 6) {
      final count = (_imgwidgets.length.toInt() - 1).toString();
      final widget = ImageAddButton(
        title: "사진 등록",
        subtitle: "$count/5",
        onImageSelected: addImage,
        onImageClear: (p0) {
          setState(() {
            _imgwidgets.remove(p0);
          });
        },
      );
      setState(() {
        _imgwidgets.add(widget);
      });
    }
  }

  Future<void> uploadImage(UploadType type, XFile image) async {
    final viewmodel = Provider.of<SellViewModel>(context, listen: false);
    final user = UserService.instance;

    if (type == UploadType.cover) {
      viewmodel.uploadImage(type, user.uid!, image).then((result) {
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
    } else {
      viewmodel.uploadImage(type, user.uid!, image).then((url) {
        if (url != null) {
          viewmodel.model.addotherImage(url);
        }
      });
    }
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
    _imgwidgets.clear();
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
                _buildDescription(viewmodel),
                _buildKeyword(viewmodel),
                _buildCategory(viewmodel),
                _buildValueRange(viewmodel),
              ],
            ),
          ),
        ));
  }

  Widget _buildImageList(SellViewModel viewmodel) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              height: MediaQuery.of(context).size.height / 7,
              child: ListView.builder(
                cacheExtent: 1000,
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(right: 10),
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

  Widget _buildDescription(SellViewModel viewmodel) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: AppColor.gray3A,
        ),
      ),
      constraints: const BoxConstraints(maxHeight: 200),
      child: PlatformScrollbar(
        child: PlatformTextField(
          keyboardType: TextInputType.multiline,
          enableInteractiveSelection: true,
          onChanged: (value) {
            viewmodel.model.setdescription(value);
          },
          controller: textEditingController,
          style: const TextStyle(fontSize: 17),
          material: (context, platform) {
            return MaterialTextFieldData(
              decoration: InputDecoration(
                border: InputBorder.none, // 밑줄 제거
                filled: true,
                fillColor: Colors.transparent,
                hintMaxLines: 3,
                hintText: viewmodel.model.getDescriptionHint().toString(),
                hintStyle: TextStyle(
                  color: AppColor.grayF9,
                  fontSize: 16,
                  fontFamily: "SUIT",
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.clip,
                ),
              ),
            );
          },
          cupertino: (context, platform) {
            return CupertinoTextFieldData(
              maxLines: 3,
              placeholder:
                  viewmodel.model.getDescriptionHint().toString(), // iOS에서 힌트 텍스트로 사용됨
                  placeholderStyle: TextStyle(
                  color: AppColor.grayF9,
                  fontSize: 16,
                  fontFamily: "SUIT",
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.clip,
                ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColor.grayF9,
                    width: 0.5, // 조정 가능한 너비
                  ),
                ),
              ),
              style: const TextStyle(fontSize: 17),
              onChanged: (value) {
                viewmodel.model.setdescription(value);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildKeyword(SellViewModel viewModel) {
    final viewmodel = Provider.of<SellViewModel>(context, listen: false);

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
          platformPageRoute(
            context: context,
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
                      return KeyWordPopup(
                          description: viewmodel.model.getKeywordDescription());
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
