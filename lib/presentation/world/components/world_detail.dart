import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:firebase_login/domain/world/contentService.dart';
import 'package:firebase_login/presentation/world/worldViewModel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_login/presentation/components/theme.dart';
import 'package:firebase_login/domain/login/userService.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_login/presentation/mypage/components/mypage_detail.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:remedi_kopo/remedi_kopo.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:bootpay/bootpay.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart';
import 'package:firebase_login/app/config/remote_options.dart';
import 'package:firebase_login/presentation/components/content/post_grid_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/presentation/common/widgets/toastwidget.dart';
import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/app/config/constant.dart';

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

class CommunityPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CommunityPage({
    required this.scaffoldKey,
    super.key,
  });

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ViewModel = Provider.of<WorldViewModel>(context, listen: false);

    return ViewModel.model.communityItemList.isEmpty
        ? _isLoading
            ? Center(
                child: PlatformCircularProgressIndicator(
                  cupertino: (context, platform) {
                    return CupertinoProgressIndicatorData(
                      color: AppColor.primary,
                    );
                  },
                ),
              )
            : Center(child: Text('게시글이 없습니다.\n 게시글을 등록해주세요!'))
        : PostGridView(
            contents: ViewModel.model.communityItemList,
            scaffoldKey: widget.scaffoldKey,
            noUpdate: true,
          );
  }
}

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("서비스 페이지 커밍순"),
    );
  }
}

class BiddingPage extends StatelessWidget {
  const BiddingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("비딩 페이지 커밍순"),
    );
  }
}

class ReCyclePage extends StatefulWidget {
  const ReCyclePage({super.key});

  @override
  _ReCyclePageState createState() => _ReCyclePageState();
}

class _ReCyclePageState extends State<ReCyclePage> {
  final List<String> _images = [];

  @override
  void initState() {
    final options = RemoteConfigOptions.instance;
    _images.add(options.getimages()["world_trash_0"]);
    _images.add(options.getimages()["world_trash_1"]);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: CachedNetworkImage(
                imageUrl: _images[0],
                imageBuilder: (context, imageProvider) => Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                placeholder: (context, url) => Center(
                  child: PlatformCircularProgressIndicator(
                    cupertino: (context, platform) {
                      return CupertinoProgressIndicatorData(
                        color: AppColor.primary,
                      );
                    },
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: CachedNetworkImage(
              imageUrl: _images[1],
              imageBuilder: (context, imageProvider) => Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              placeholder: (context, url) => Center(
                child: PlatformCircularProgressIndicator(
                  cupertino: (context, platform) {
                    return CupertinoProgressIndicatorData(
                      color: AppColor.primary,
                    );
                  },
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Center(
              child: Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: Colors.yellow,
                    size: 32,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '이용요금',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(25),
            child: Center(
              child: CheckButton(
                title: "1회 이용권",
                subTitle: "₩4500원",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreatePostPage extends StatefulWidget {
  final WorldViewModel _viewmodel;

  const CreatePostPage({required WorldViewModel model, super.key})
      : _viewmodel = model;

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final List<XFile?> _pickedImages = [];
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool isRegisteringPost = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _addImage(XFile? image, int index) async {
    setState(() {
      upload_image(image!);
    });

    if (image != null) {
    } else {}
  }

  Future<void> upload_image(XFile image) async {
    final api = FirebaseAPI();
    final userService = UserService.instance;

    await api
        .uploadImage(UploadType.community, userService.uid, image)
        ?.then((url) {
      if (url != null) {
        widget._viewmodel.addImagePath(url);
      } else {
        // 에러 처리 또는 실패 처리를 수행할 수 있음
        print('Error uploading image or url is null');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 20, 22, 25),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop(); // 페이지 닫기
          },
        ),
        title: const Text(
          "게시글 올리기",
          style: TextStyle(
              fontFamily: "SUIT", fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          isRegisteringPost == true
              ? PlatformCircularProgressIndicator(
                  cupertino: (context, platform) {
                    return CupertinoProgressIndicatorData(
                      color: AppColor.primary,
                    );
                  },
                )
              : TextButton(
                  onPressed: () async {
                    final content = ContentService.instance;

                    if (_titleController.text.isEmpty ||
                        _contentController.text.isEmpty) {
                      showtoastMessage("게시글을 작성 해주세요.", toastStatus.info);
                    } else {
                      setState(() {
                        isRegisteringPost = true;
                      });
                      widget._viewmodel.createPostItem().then((value) => {
                            widget._viewmodel
                                .getRegisterPostItem(value)
                                .then((value) => {
                                      setState(() {
                                        isRegisteringPost = false;
                                        Navigator.of(context).pop(); // 페이지 닫기
                                      })
                                    })
                          });
                    }
                  },
                  child:
                      const Text("완료", style: TextStyle(color: Colors.white)),
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: ColorStyles.background, width: 0.5),
                  bottom: BorderSide(color: ColorStyles.background, width: 0.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: TextField(
                enableInteractiveSelection: true,
                controller: _titleController, // 제목을 저장할 컨트롤러 연결
                onChanged: (value) => widget._viewmodel.model.title = value,
                decoration: const InputDecoration(
                  hintText: "제목을 입력하세요",
                  hintStyle: TextStyle(fontSize: 18),
                  border: InputBorder.none, // 아래 줄을 없애는 부분
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: TextField(
                enableInteractiveSelection: true,
                controller: _contentController, // 내용을 저장할 컨트롤러 연결
                onChanged: (value) => widget._viewmodel.model.content = value,
                decoration: const InputDecoration(
                  hintText: "내용을 입력하세요\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
                  hintStyle: TextStyle(fontSize: 14),
                  border: InputBorder.none, // 아래 줄을 없애는 부분
                ),
                maxLines: null, // 여러 줄의 텍스트를 입력할 수 있도록 함
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: ColorStyles.background, width: 0.5),
                  bottom: BorderSide(color: ColorStyles.background, width: 0.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: 150,
                width: 150, // 원하는 높이로 설정
                child: ImageAddButton(
                  title: "사진 추가",
                  num: 0,
                  imageCount: "${0 + 1}/5",
                  onImageSelected: _addImage,
                ),
                /*child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // 5개의 Container를 생성
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ImageAddButton(
                        title: "사진 추가",
                        num: index,
                        imageCount: "${index + 1}/5",
                        onImageSelected: _addImage,
                      ),
                    );
                  },
                ),*/
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
class PostItem extends StatefulWidget {
  late PostItemModel itemModel;
  PostItem({
    required PostItemModel item,
    Key? key,
  })  : itemModel = item,
        super(key: key);

  @override
  _PostItemPageState createState() => _PostItemPageState();
}

class _PostItemPageState extends State<PostItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = Provider.of<WorldViewModel>(context, listen: false);

    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.itemModel.profileImg.isEmpty)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    image: DecorationImage(
                      image: AssetImage("assets/images/default_Profile.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                ProfileImg(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: 999,
                    callback: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              UserProfile(uid: widget.itemModel.onwerId),
                        ),
                      );
                    },
                    height: 60,
                    width: 60,
                    imageUrl: widget.itemModel.profileImg),
              const SizedBox(width: 10), // 간격 조절
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.itemModel.nickName,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "\n" + getCurrentTime(widget.itemModel.date),
                      style: const TextStyle(
                        fontSize: 12.0, // 원하는 폰트 크기로 조절
                        fontWeight: FontWeight.normal, // 일반 텍스트 스타일로 설정
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      widget.itemModel.title,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (widget
                      .itemModel.contentImg.isNotEmpty) // 이미지 데이터가 있는 경우에만 표시
                    CachedNetworkImage(
                      fit: BoxFit.fill,
                      width: 80,
                      height: 80,
                      imageUrl: widget.itemModel.contentImg,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  /*ExtendedImage.network(
                      widget.itemModel
                          .contentImg, // Replace this with your image path
                      fit: BoxFit.fill,
                      width: 80,
                      height: 80,
                      cache: true,
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
                    )*/
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  viewmodel.contentLike(widget.itemModel.contentID.toString());
                },
                icon: Icon(Icons.favorite_border, color: ColorStyles.content),
                label: Text(
                  widget.itemModel.likes.toString(),
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.chat_outlined, color: ColorStyles.content),
                label: Text(
                  widget.itemModel.comments.length.toString(),
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.remove_red_eye_outlined,
                    color: ColorStyles.content),
                label: Text(
                  widget.itemModel.views.toString(),
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
*/
class ImageAddButton extends StatefulWidget {
  final String title;
  final String imageCount;
  final int num;
  final Function(XFile?, int count) onImageSelected; // Callback function

  const ImageAddButton({
    super.key,
    required this.title,
    required this.imageCount,
    required this.num,
    required this.onImageSelected,
  });

  @override
  _ImageAddButtonState createState() => _ImageAddButtonState();
}

class _ImageAddButtonState extends State<ImageAddButton> {
  XFile? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = pickedImage;
      });

      widget.onImageSelected(pickedImage, widget.num);
    }
  }

  void _clearImage() {
    setState(() {
      _pickedImage = null;
    });
    widget.onImageSelected(null, widget.num);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        OutlinedButton(
          onPressed: () {
            _pickImage();
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white, width: 2.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: _pickedImage != null
              ? Image.file(
                  File(_pickedImage!.path),
                  width: 150,
                  height: 150,
                  fit: BoxFit.fill,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20.0),
                    const Icon(
                      Icons.camera_alt_outlined,
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      widget.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
        ),
        if (_pickedImage != null)
          Positioned(
            top: -10.0,
            right: -10.0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _clearImage,
            ),
          ),
      ],
    );
  }
}

class TrashRequestForm extends StatefulWidget {
  final WorldViewModel viewmodel;
  const TrashRequestForm({required this.viewmodel, super.key});

  @override
  State<TrashRequestForm> createState() => _TrashRequestFormState();
}

class _TrashRequestFormState extends State<TrashRequestForm> {
  final TextEditingController _AddressController = TextEditingController();
  final TextEditingController _Address_detailController =
      TextEditingController();
  final TextEditingController _doorController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool isAddressComplete = false;
  bool isCalendarComplete = false;

  String webApplicationId = "";
  String androidApplicationId = "";
  String iosApplicationId = "";

  @override
  void initState() {
    super.initState();
    final config = RemoteConfigOptions.instance;
    final values = config.getbootPay();
    webApplicationId = values["webApplicationId"];
    androidApplicationId = values["androidApplicationId"];
    iosApplicationId = values["iosApplicationId"];
  }

  @override
  void dispose() {
    _AddressController.dispose();
    _Address_detailController.dispose();
    _doorController.dispose();
    _commentController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          if (isCalendarComplete) {
            setState(() {
              isCalendarComplete = false;
            });
            return;
          } else if (isAddressComplete) {
            setState(() {
              isAddressComplete = false;
            });
            return;
          } else {
            Navigator.of(context).pop();
          }
        },
        child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/components/background.png'), // 배경 이미지
              ),
            ),
            child: Scaffold(
              appBar: AppBar(
                title: const Text(
                  '수거 신청서 작성',
                  style: TextStyle(
                      fontFamily: "SUIT",
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: ListView(
                    cacheExtent: 1000,
                    children: [
                      if (!isAddressComplete) AddressPage(),
                      if (!isCalendarComplete && isAddressComplete)
                        CalendarPage(),
                      if (isCalendarComplete && isAddressComplete)
                        PaymentPage(),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorStyles.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              if (isAddressComplete == false) {
                                if (_AddressController.text.isEmpty ||
                                    _Address_detailController.text.isEmpty) {
                                  showtoastMessage(
                                      '주소를 입력해주세요.', toastStatus.info);
                                } else if (_phoneController.text.isEmpty) {
                                  showtoastMessage(
                                      '연락처를 입력해주세요.', toastStatus.info);
                                } else {
                                  widget.viewmodel.model.address =
                                      _AddressController.text;
                                  widget.viewmodel.model.addressdetail =
                                      _Address_detailController.text;
                                  widget.viewmodel.model.doorpass =
                                      _doorController.text;
                                  widget.viewmodel.model.comment =
                                      _commentController.text;
                                  widget.viewmodel.model.phone =
                                      _phoneController.text;

                                  isAddressComplete = true;
                                }
                              } else if (isAddressComplete == true &&
                                  isCalendarComplete == false) {
                                if (widget.viewmodel.model.day.isEmpty) {
                                  showtoastMessage(
                                      '날짜를 선택 해주세요.', toastStatus.info);
                                } else {
                                  isCalendarComplete = true;
                                }
                              } else if (isAddressComplete == true &&
                                  isCalendarComplete == true) {
                                bootpayTest(context);
                              }
                            });
                          },
                          child: Text(
                            isCalendarComplete == false ? '다음' : '결제하기',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }

  Widget AddressPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 20),
          child: Text(
            "수거/배송 정보",
            style: TextStyle(fontSize: 20),
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            _addressAPI(); // 카카오 주소 API
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "주소",
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 10), // 제목과 입력 필드 사이의 간격
                  Expanded(
                    child: TextFormField(
                      enableInteractiveSelection: true,
                      enabled: false,
                      decoration: const InputDecoration(
                        hintText: '도로명, 건물명 또는 지번 검색',
                        isDense: false,
                      ),
                      controller: _AddressController,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "상세 주소",
          style: TextStyle(fontSize: 16),
        ),
        TextField(
          enableInteractiveSelection: true,
          enabled: true,
          decoration: const InputDecoration(
            hintText: '건물,아파트, 동/호수 입력',
            isDense: false,
          ),
          controller: _Address_detailController,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "공동현관 출입번호",
          style: TextStyle(fontSize: 16),
        ),
        TextField(
          enableInteractiveSelection: true,
          enabled: true,
          decoration: const InputDecoration(
            hintText: '예:#1234&, 열쇠#1234',
            isDense: false,
          ),
          controller: _doorController,
          style: const TextStyle(fontSize: 20),
          keyboardType: TextInputType.number, // Set numeric keyboard
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "연락처",
          style: TextStyle(fontSize: 16),
        ),
        TextField(
          enableInteractiveSelection: true,
          enabled: true,
          decoration: const InputDecoration(
            hintText: '핸드폰 번호를 입력해 주세요.',
            isDense: false,
          ),
          controller: _phoneController,
          style: const TextStyle(fontSize: 20),
          keyboardType: TextInputType.number, // Set numeric keyboard
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "추가 요청사항",
          style: TextStyle(fontSize: 16),
        ),
        TextField(
          enableInteractiveSelection: true,
          enabled: true,
          decoration: const InputDecoration(
            hintText: '추가로 요청하실 내용이 있다면 작성해주세요',
            isDense: false,
          ),
          controller: _commentController,
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  Widget CalendarPage() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "수거 날짜",
              style: TextStyle(fontSize: 20),
            ),
            if (_selectedDay != null)
              Text(
                DateFormat('MM월 dd일').format(_selectedDay!),
                style: const TextStyle(fontSize: 20),
              ),
          ],
        ),
        TableCalendar(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2023, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              widget.viewmodel.model.day =
                  DateFormat('MM월 dd일').format(_selectedDay!);
            });
          },
        ),
      ],
    );
  }

  Widget PaymentPage() {
    final ViewModel = Provider.of<WorldViewModel>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "결제 정보",
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Card(
                color: ColorStyles.background,
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 30, left: 30, bottom: 30, right: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "상세 정보",
                          style: TextStyle(
                              fontSize: 20, color: ColorStyles.primary),
                        ),
                        SizedBox(height: 10),
                        Text("주소 : ${widget.viewmodel.model.address}",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white)),
                        SizedBox(height: 10),
                        Text("상세 주소 : ${widget.viewmodel.model.addressdetail}",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white)),
                        SizedBox(height: 10),
                        Text("수거 날짜 : ${widget.viewmodel.model.day}",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white)),
                        SizedBox(height: 10),
                        const Text("결제 금액 : 4500원",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    )))),
        const SizedBox(height: 20),
        Card(
            color: ColorStyles.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30, left: 30),
                  child: Text(
                    "결재 정보 유의사항",
                    style: TextStyle(fontSize: 20, color: ColorStyles.primary),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: List.generate(
                      ViewModel.model.paymentsinfoList.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                            bottom: 10.0), // 여기에 적절한 spacing 값을 넣어주세요.
                        child: Text(
                          '${index + 1} : ${ViewModel.model.paymentsinfoList[index]}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ))
      ],
    );
  }

  _addressAPI() async {
    KopoModel? model = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => RemediKopo(),
      ),
    );

    if (model != null) {
      // model 처리
      _AddressController.text =
          '${model.zonecode!} ${model.address!} ${model.buildingName!}';
    }
  }

  void bootpayTest(BuildContext context) async {
    Payload payload = getPayload();

    Bootpay().requestPayment(
      context: context,
      payload: payload,
      showCloseButton: false,
      // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
      onCancel: (String data) {
        print('------- onCancel: $data');
      },
      onError: (String data) {
        print('------- onError: $data');
      },
      onClose: () {
        print('------- onClose');
        Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
        //TODO - 원하시는 라우터로 페이지 이동
      },
      onIssued: (String data) {
        print('------- onIssued: $data');
      },
      onConfirm: (String data) {
        print('------- onConfirm: $data');
        /**
            1. 바로 승인하고자 할 때
            return true;
         **/
        /***
            2. 비동기 승인 하고자 할 때
            checkQtyFromServer(data);
            return false;
         ***/
        /***
            3. 서버승인을 하고자 하실 때 (클라이언트 승인 X)
            return false; 후에 서버에서 결제승인 수행
         */
        // checkQtyFromServer(data);

        return true;
      },
      onDone: (String data) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        print('------- onDone: $data');
        widget.viewmodel
            .checkPayment(widget.viewmodel.model.orderID)
            .then((value) => {widget.viewmodel.createPickup()});
      },
    );
  }

  Payload getPayload() {
    UserService userservice = UserService.instance;
    Payload payload = Payload();
    String qid = DateTime.now().millisecondsSinceEpoch.toString();

    Item item1 = Item();
    item1.name = "수거신청${userservice.uid}"; // 주문정보에 담길 상품명
    item1.qty = 1; // 해당 상품의 주문 수량
    item1.id = qid; // 해당 상품의 고유 키
    item1.price = 4500; // 상품의 가격

    List<Item> itemList = [item1];

    payload.webApplicationId = webApplicationId; // web application id
    payload.androidApplicationId =
        androidApplicationId; // android application id
    payload.iosApplicationId = iosApplicationId; // ios application id

    payload.pg = '나이스페이';
    // payload.method = '카드';
    // payload.methods = ['card', 'phone', 'vbank', 'bank', 'kakao'];
    payload.orderName = "수거신청"; //결제할 상품명
    payload.price = 4500.0; //정기결제시 0 혹은 주석

    payload.orderId = "${qid}_${userservice.uid}"; //주문번호, 개발사에서 고유값으로 지정해야함
    widget.viewmodel.model.orderID = "${qid}_${userservice.uid}";
    payload.metadata = {
      "uid": userservice.uid!.toString(),
    }; // 전달할 파라미터, 결제 후 되돌려 주는 값

    payload.items = itemList; // 상품정보 배열

    User user = User(); // 구매자 정보
    user.username = userservice.uid;
    user.email = userservice.email;
    user.area = widget.viewmodel.model.address;
    user.addr =
        widget.viewmodel.model.address + widget.viewmodel.model.addressdetail;
    user.phone = widget.viewmodel.model.phone;

    Extra extra = Extra(); // 결제 옵션
    extra.appScheme = 'bootpayFlutter';
    extra.cardQuota = '3';
    // extra.openType = 'popup';

    // extra.carrier = "SKT,KT,LGT"; //본인인증 시 고정할 통신사명
    // extra.ageLimit = 20; // 본인인증시 제한할 최소 나이 ex) 20 -> 20살 이상만 인증이 가능

    payload.user = user;
    payload.extra = extra;
    return payload;
  }
}
