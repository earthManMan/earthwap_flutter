import 'package:firebase_login/presentation/sell/sellViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_login/presentation/sell/components/sell_detail.dart';
import 'package:firebase_login/presentation/components/theme.dart';
import 'package:firebase_login/domain/login/userService.dart';
import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:firebase_login/presentation/components/category_widget.dart';
import 'package:firebase_login/presentation/components/item/keyword_input_widget.dart';
import 'package:firebase_login/presentation/components/popup_widget.dart';
import 'package:firebase_login/presentation/components/item/value_select_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/presentation/common/widgets/toastwidget.dart';
import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/app/config/constant.dart';

class SellView extends StatefulWidget {
  const SellView({super.key});

  @override
  _SellViewState createState() => _SellViewState();
}

class _SellViewState extends State<SellView> {
  late TextEditingController textEditingController;
  List<Widget> categoryList = [];
  List<bool> previousSelectedCategories = List.generate(14, (index) => false);
  XFile? coverImage;
  List<XFile?> pickedImages = [];
  final FocusNode _focusNode = FocusNode();
  bool isRegisteringItem = false;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController(text: "");

    // FocusNode에 이벤트 리스너 추가
    _focusNode.addListener(sellViewListen);
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

  Future<void> addImage(
      XFile? image, int index, SellViewModel viewmodel) async {
    final userService = UserService.instance;
    if (image != null) {
      setState(() {
        upload_Other_Image(userService.uid.toString(), image, viewmodel);
        pickedImages.add(image);
      });
    } else {
      setState(() {
        pickedImages.removeAt(index - 1);
      });
    }
  }

  Future<void> getDataBase(String imageURL, SellViewModel viewmodel) async {
    final userService = UserService.instance;
    viewmodel.getImageUploadResult(imageURL).then((value) => {
          setState(() {
            //      categoryList.clear();
            //      String str = viewmodel.model.getcategory().toString();
            //      categoryList.add(CategoryItem(text: str));
          })
        });
  }

  Future<void> uploadImage(XFile image, SellViewModel viewmodel) async {
    viewmodel.uploadImage(UploadType.cover, "", image).then((result) {
      if (result != null) {
        String url = result['url'] ?? ''; // null 체크 추가
        String uniqueFileName = result['uniqueFileName'] ?? '';
        getDataBase(uniqueFileName, viewmodel);
        viewmodel.model.setcoverImage(url);
      } else {
        // 에러 처리 또는 실패 처리를 수행할 수 있음
        print('Error uploading image or result is null');
      }
    });
  }

  Future<void> addCoverImages(
      XFile? cover, int index, SellViewModel viewmodel) async {
    if (cover != null) uploadImage(cover, viewmodel);
    setState(() {
      coverImage = cover;
    });
  }

  Future<void> upload_Other_Image(
      String uid, XFile image, SellViewModel viewmodel) async {
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
      categoryList.clear();
      for (String item in selectedCategories) {
        //viewmodel.categorymodel.addselected(item);

        categoryList.add(
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
    coverImage = null;
    pickedImages.clear();
    textEditingController.clear();
    viewmodel.model.resetModel();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellViewModel>(builder: (context, sellViewModel, child) {
      return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/main');
                resetStateAndNavigate(sellViewModel);
              },
              child: const Text(
                "취소",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ColorStyles.primary,
                ),
              ),
            ),
            title: const Text('내 물건 업로드',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromARGB(255, 241, 240, 240))),
            iconTheme: const IconThemeData(
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            actions: [
              isRegisteringItem == true
                  ? PlatformCircularProgressIndicator(
                      cupertino: (context, platform) {
                        return CupertinoProgressIndicatorData(
                          color: AppColor.primary,
                        );
                      },
                    )
                  : TextButton(
                      onPressed: () async {
                        if (coverImage == null || categoryList.isEmpty) {
                          if (coverImage == null) {
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
                          } else if (categoryList.isEmpty) {
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
                            isRegisteringItem = true;
                          });

                          sellViewModel.registerItem().then((result) {
                            if (result.isEmpty) {
                              showtoastMessage(
                                  '물건 등록을 실패 했습니다.', toastStatus.error);
                            } else {
                              sellViewModel
                                  .getRegisterItem(result)
                                  .then((value) => {
                                        setState(() {
                                          isRegisteringItem = false;
                                          Navigator.of(context)
                                              .pushNamed('/main');
                                          resetStateAndNavigate(sellViewModel);
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
                          color: coverImage == null || categoryList.isEmpty
                              ? const Color.fromARGB(255, 79, 79, 79)
                              : ColorStyles.primary,
                        ),
                      ),
                    ),
            ],
            backgroundColor: const Color.fromARGB(255, 20, 22, 25),
          ),
          backgroundColor: const Color.fromARGB(255, 20, 22, 25),
          resizeToAvoidBottomInset: true,
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
                  //const SizedBox(width: 30, height: 10.0),
                  _buildImageList(sellViewModel),
                  //const SizedBox(height: 20.0),
                  _buildDescription(sellViewModel, _focusNode),
                  _buildKeyword(sellViewModel),
                  _buildCategory(sellViewModel),
                  _buildValueRange(sellViewModel),
                ],
              ),
            ),
          ));
    });
  }

  Widget _buildImageList(SellViewModel viewmodel) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              height: MediaQuery.of(context).size.height / 7,
              child: ListView.builder(
                cacheExtent: 1000,
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount:
                    pickedImages.length < 4 ? pickedImages.length + 2 : 6,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ImageAddButton(
                        title: "커버 등록",
                        num: index,
                        imageCount: "0/1",
                        viewModel: viewmodel,
                        onImageSelected: addCoverImages,
                      ),
                    );
                  } else if (index == 1) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ImageAddButton(
                        title: "사진 추가",
                        num: index,
                        imageCount: "0/5",
                        viewModel: viewmodel,
                        onImageSelected: addImage,
                      ),
                    );
                  } else if (index == pickedImages.length + 1) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ImageAddButton(
                        title: "사진 추가",
                        num: index,
                        viewModel: viewmodel,
                        imageCount: "${pickedImages.length + 1}/5",
                        onImageSelected: addImage,
                      ),
                    );
                  } else {
                    final imageIndex = index - 1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ImageAddButton(
                        title: "사진 추가",
                        num: index,
                        viewModel: viewmodel,
                        imageCount: "${imageIndex + 1}/5",
                        onImageSelected: addImage,
                      ),
                    );
                  }
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
        if (coverImage == null) {
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
              colverImage: coverImage!.path.toString(),
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
                  categories: [],//viewmodel.categorymodel.categories,
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
              children: categoryList,
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
