
import 'package:firebase_login/presentation/sell/sellViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_login/presentation/common/widgets/image_add_widget.dart';
import 'package:firebase_login/presentation/components/category_widget.dart';
import 'package:firebase_login/presentation/common/widgets/keyword_input_widget.dart';

import 'package:firebase_login/presentation/components/item/value_select_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/presentation/common/widgets/toast_widget.dart';
import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/app/config/constant.dart';
import 'package:firebase_login/app/util/localStorage_util.dart';
import 'package:firebase_login/presentation/common/widgets/custom_popup_widget.dart';
import 'package:firebase_login/app/config/remote_options.dart';

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

  String _description = "";
  String _mainKeyword = "";
  String _subKeyword = "";
  String _Keyword_description = "";
  String _item_hint_description = "";

  int _userPrice = 0;
  int _price_start = -1000;
  int _price_end = 1000;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final config = RemoteConfigOptions.instance;

    final valueList = config.getSellModelJsonMap();
    _Keyword_description = valueList['keywordDescription'];
    _item_hint_description = valueList['description'];
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Future<bool> isKeyword() async {
    final result = await _storage.getitem(KEY_KEYWORDPOPUP);
    if (result.toString().isNotEmpty) {
      bool state = false;
      result.toString() == 'true' ? state = true : state = false;
      return state;
    } else {
      return false;
    }
  }

  Future<void> addCoverImages(XFile? cover) async {
    final viewmodel = Provider.of<SellViewModel>(context, listen: false);
    if (cover != null) viewmodel.uploadImage(UploadType.cover, cover);
    setState(() {
      _coverImage = cover;
    });
  }

  Future<void> addImage(XFile? image) async {
    final viewmodel = Provider.of<SellViewModel>(context, listen: false);
    if (image != null) viewmodel.uploadImage(UploadType.other, image);
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

  void handleCategoriesSelected(List<String> selectedCategories) {
    final viewmodel = Provider.of<SellViewModel>(context, listen: false);

    setState(() {
      viewmodel.clearselectedCategory();
      _categoryWidget.clear();
      for (String item in selectedCategories) {
        viewmodel.addselectedCategory(item);
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
    viewmodel.clearModel();
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

                        viewmodel
                            .registerItem(
                                _description,
                                _mainKeyword,
                                _subKeyword,
                                _userPrice,
                                _price_start,
                                _price_end)
                            .then((result) {
                          if (result.isEmpty) {
                            showtoastMessage(
                                '물건 등록을 실패 했습니다.', toastStatus.error);
                          } else {
                            setState(() {
                              _isLoading = false;
                              Navigator.of(context).pushNamed('/main');
                              resetStateAndNavigate(viewmodel);
                            });
                            //TODO : 등록된 Item의 id를 받아와서 업데이트 된 후 Main Page로 이동하는 부분 추가
                            /*
                            viewmodel.getRegisterItem(result).then((value) => {
                                  setState(() {
                                    _isLoading = false;
                                    Navigator.of(context).pushNamed('/main');
                                    resetStateAndNavigate(viewmodel);
                                  })
                                });*/
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
        body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildImageList(viewmodel),
                _buildDescription(viewmodel),
                _buildKeyword(viewmodel),
                _buildCategory(viewmodel),
                _buildValueRange(viewmodel),
              ],
            ),);
  }

  void _buildinitImgWidget() {
    final viewmodel = Provider.of<SellViewModel>(context, listen: false);

    if (_imgwidgets.isEmpty) {
      _coverWidget = ImageAddButton(
        title: "커버 등록",
        subtitle: "0/1",
        onImageSelected: addCoverImages,
        onImageClear: (p0) {
          viewmodel.clearCoverimage();
          _coverImage = null;
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
            _description = textEditingController.text;
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
                hintText: _item_hint_description,
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
              textAlignVertical: TextAlignVertical.top,
              placeholder: _item_hint_description,
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
                    width: 0.5, // Adjust the width as needed
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKeyword(SellViewModel viewModel) {
    return KeyWordInputButton(
      text: '키워드 추가',
      MainKeyword: _mainKeyword,
      SubKeyword: _subKeyword,
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
              mainKeyword: _mainKeyword,
              subKeyword: _subKeyword,
              mainColor: viewModel.getMainColor(),
              subColor: viewModel.getSubColor(),
              colverImage: _coverImage!.path.toString(),
              call: (value, value2) {
                if (value.isNotEmpty || value2.isNotEmpty) {
                  Navigator.of(context).pop();
                  setState(() {
                    if (value.isNotEmpty) {
                      _mainKeyword = (value);
                    }
                    if (value2.isNotEmpty) {
                      _subKeyword = (value2);
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
                      return KeyWordPopup(description: _Keyword_description);
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
              platformPageRoute(
                context: context,
                builder: (context) => CategorySelectionPage(
                  onPressed: handleCategoriesSelected,
                  categories: viewmodel.getCategories(),
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
      userPrice: _userPrice,
      priceStart: _price_start,
      priceEnd: _price_end,
      text: '가격범위',
      call: (price, start, end) {
        _userPrice = price;
        _price_start = start;
        _price_end = end;
        Navigator.of(context).pop();
        setState(() {});
      },
    );
  }
}
