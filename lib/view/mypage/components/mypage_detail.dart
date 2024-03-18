import 'package:firebase_login/components/profile_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/components/theme.dart';
import 'package:firebase_login/service/userService.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_login/API/firebaseAPI.dart';

import 'package:firebase_login/viewModel/mypageViewModel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_login/model/mypageModel.dart';
import 'package:firebase_login/components/user_profile_widget.dart';
import 'package:firebase_login/components/common_components.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class PremiumPage extends StatelessWidget {
  bool isPremium;
  PremiumPage({super.key, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: isPremium ? true : false,
        title: isPremium ? const Text("어스왑 Premium") : null,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/components/background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: isPremium ? _buildRegularLayout() : _buildPremiumLayout(),
        ),
      ),
      floatingActionButton: isPremium
          ? null
          : FloatingActionButton.extended(
              backgroundColor: ColorStyles.primary,
              onPressed: () {},
              label: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: const Center(
                  child: Text(
                    'Premium 결제하기',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPremiumLayout() {
    // 프리미엄 사용자 레이아웃을 생성합니다.
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Image.asset('assets/images/Premium_0.png'),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Image.asset('assets/images/Premium_1.png'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Image.asset('assets/images/Premium_2.png'),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(25),
          child: Center(
            child: CheckButton(
              title: "1개월 구독 이용권",
              subTitle: "₩50,000 / 1개월",
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(25),
          child: Center(
            child: CheckButton(
              title: "3개월 구독 이용권",
              subTitle: "₩50,000 / 3개월",
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(25),
          child: Center(
            child: CheckButton(
              title: "6개월 구독 이용권",
              subTitle: "₩50,000 / 6개월",
            ),
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        // 여기에 프리미엄 혜택과 관련된 내용을 추가합니다.
        // 예를 들어, 프로필 이미지, 닉네임, 프리미엄 결제일 등을 표시할 수 있습니다.
      ],
    );
  }

  Widget _buildRegularLayout() {
    final userService = UserService.instance;

    // 일반 사용자 레이아웃을 생성합니다.
    // 여기에 일반 사용자에게 보여줄 내용을 추가합니다.
    return Column(
      children: [
        Center(
          child: ProfileImg(
            borderRadius: 80,
            imageUrl: userService.profileImage.toString(),
            width: 200,
            height: 200,
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            callback: () {},
          ),
        ),
        Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: null,
              icon: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  ColorStyles.primary,
                  BlendMode.dstIn,
                ),
                child: Image.asset('assets/components/premium.png'),
              ),
            ),
            Text(
              userService.nickname.toString(),
              style: const TextStyle(fontSize: 20),
            )
          ],
        )),
        const Center(
            child: Text(
          "Premium 결제일 : 2023년 09월 12일",
          style: TextStyle(
              fontSize: 15, color: Color.fromARGB(255, 130, 130, 130)),
        )),
        Card(
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("지금까지 이용한 어스왑 Premium 혜택",
                        style: TextStyle(
                            fontSize: 20, color: ColorStyles.primary)),
                    const SizedBox(height: 10),
                    _buildRowIconText(
                        "assets/components/Trash.png", "광고없는 Swipe", "60시간"),
                    const SizedBox(height: 10),
                    _buildRowIconText("assets/components/Heart.png",
                        "좋아요 한 물건 확인 횟수", "500회"),
                    const SizedBox(height: 10),
                    _buildRowIconText(
                        "assets/components/Trash2.png", "상위 노출 횟수", "36회"),
                  ],
                ))),
        Card(
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("이용중인 이용권",
                        style: TextStyle(
                            fontSize: 20, color: ColorStyles.primary)),
                    const SizedBox(height: 10),
                    _buildRowText("연간 무한 이용권", "50,000/연간"),
                    const SizedBox(height: 10),
                    _buildRowText("다음 결제 예정일", "2024년 09월 12일"),
                  ],
                ))),
      ],
    );
  }

  Widget _buildRowIconText(String IconPath, String Title, String Content) {
    return Row(
      children: [
        Image.asset(
          IconPath,
          width: 50,
          height: 50,
          fit: BoxFit.fill,
        ),
        const SizedBox(width: 8),
        Text(Title, style: const TextStyle(fontSize: 20, color: Colors.white)),
        const Spacer(),
        Text(Content,
            style: const TextStyle(fontSize: 15, color: Colors.white)),
      ],
    );
  }

  Widget _buildRowText(String Title, String Content) {
    return Row(
      children: [
        Text(Title, style: const TextStyle(fontSize: 20, color: Colors.white)),
        const Spacer(),
        Text(Content,
            style: const TextStyle(fontSize: 15, color: Colors.white)),
      ],
    );
  }
}

class CheckButton extends StatefulWidget {
  final String title;
  final String subTitle;

  const CheckButton({super.key, required this.title, required this.subTitle});

  @override
  _CheckButtonState createState() => _CheckButtonState();
}

class _CheckButtonState extends State<CheckButton> {
  bool isChecked = true;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          //isChecked = !isChecked;
        });
      },
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(0), // Remove button elevation
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Add some border radius
            side: BorderSide(
              color: isChecked ? Colors.blue : Colors.transparent,
              width: 2.0, // Add outline width
            ),
          ),
        ),
        backgroundColor: MaterialStateProperty.all(
          const Color.fromARGB(170, 27, 30, 34),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Left-align text widgets
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: "SUIT",
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 133, 255),
                    ),
                  ),
                  Text(
                    widget.subTitle,
                    style: const TextStyle(
                      fontFamily: "SUIT",
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )),
          Checkbox(
            value: isChecked,
            onChanged: (value) {
              setState(() {
                isChecked = value!;
              });
            },
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('거래내역'),
        centerTitle: true,
      ),
      body: ListView.builder(
        cacheExtent: 1000,
        itemCount: yourTransactionList.length, // 거래내역 아이템 수
        itemBuilder: (context, index) {
          final transaction = yourTransactionList[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                transaction.imageUrl, // 이미지 URL 또는 AssetImage 사용
                width: 60,
                height: 60,
                fit: BoxFit.fill,
              ),
            ),
            title: Text(transaction.title),
            subtitle: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color:
                    const Color.fromARGB(255, 44, 47, 51), // 상태에 따라 색상을 조정하세요.
              ),
              //padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                transaction.status,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            trailing: Text(
              transaction.date, // 날짜 형식을 적절히 포맷하십시오.
            ),
          );
        },
      ),
    );
  }
}

class Transaction {
  final String imageUrl; // 이미지 URL 또는 AssetImage 사용
  final String title;
  final String status;
  final String date;

  Transaction({
    required this.imageUrl,
    required this.title,
    required this.status,
    required this.date,
  });
}

// 거래내역 데이터 예시
List<Transaction> yourTransactionList = [
  Transaction(
    imageUrl: 'assets/images/sample_0.jpg',
    title: '자전거 풀세트 vs 전기 자전거',
    status: '교환완료',
    date: '2023-09-13',
  ),
  Transaction(
    imageUrl: 'assets/images/sample_1.jpg',
    title: '플스 4 vs 전기 자전거',
    status: '진행중',
    date: '2023-09-14',
  ),
  // 여기에 더 많은 거래내역을 추가할 수 있습니다.
];

class TrashCollectionPage extends StatefulWidget {
  const TrashCollectionPage({super.key});

  @override
  _TrashCollectionPageState createState() => _TrashCollectionPageState();
}

class _TrashCollectionPageState extends State<TrashCollectionPage> {
  late MypageViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<MypageViewModel>(context, listen: false);
  }

  void onReturnTrashCollection(TrashCollection value, int index) {
    setState(() {
      value.status = "CANCELLED";
      viewModel.model.TrashList![index] = value;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '수거 신청 내역',
          style: TextStyle(
            fontFamily: "SUIT",
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        cacheExtent: 1000,
        itemCount: viewModel.model.TrashList!.length,
        itemBuilder: (context, index) {
          TrashCollection collection = viewModel.model.TrashList![index];
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TrashDetailPage(
                    collection: collection,
                    onReturnTrashCollection: (value) {
                      onReturnTrashCollection(value, index);
                    },
                  ),
                ),
              );
            },
            child: Card(
              color: ColorStyles.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("assets/components/delivery.png"),
                      Text(
                        "상태 : ${viewModel.model.TrashList![index].status}",
                        style: const TextStyle(
                          fontSize: 20,
                          color: ColorStyles.primary,
                        ),
                      ),
                      Text(
                        viewModel.model.TrashList![index].date,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TrashDetailPage extends StatefulWidget {
  final TrashCollection collection;
  final Function(TrashCollection) onReturnTrashCollection;

  const TrashDetailPage({
    super.key,
    required this.collection,
    required this.onReturnTrashCollection,
  });

  @override
  _TrashDetailPageState createState() => _TrashDetailPageState();
}

class _TrashDetailPageState extends State<TrashDetailPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('이용내역 상세',
            style: TextStyle(
                fontFamily: "SUIT", fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
                color: ColorStyles.background,
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('주소',
                          style: TextStyle(fontSize: 30, color: Colors.white)),
                      subtitle: Text(widget.collection.address),
                    ),
                    ListTile(
                      title: const Text('상세 주소',
                          style: TextStyle(fontSize: 30, color: Colors.white)),
                      subtitle: Text(widget.collection.address_detail),
                    ),
                    ListTile(
                      title: const Text('공동현관 출입번호',
                          style: TextStyle(fontSize: 30, color: Colors.white)),
                      subtitle: Text(widget.collection.door),
                    ),
                    ListTile(
                      title: const Text('추가 요청사항',
                          style: TextStyle(fontSize: 30, color: Colors.white)),
                      subtitle: Text(widget.collection.comment),
                    ),
                  ],
                )),
            Card(
              color: ColorStyles.background,
              margin: const EdgeInsets.all(16),
              child: ListTile(
                title: const Text('날짜',
                    style: TextStyle(fontSize: 30, color: Colors.white)),
                subtitle: Text(widget.collection.date),
              ),
            ),
            Card(
              color: ColorStyles.background,
              margin: const EdgeInsets.all(16),
              child: ListTile(
                title: const Text('연락처',
                    style: TextStyle(fontSize: 30, color: Colors.white)),
                subtitle: Text(widget.collection.phone),
              ),
            ),
            const Card(
              color: ColorStyles.background,
              margin: EdgeInsets.all(16),
              child: ListTile(
                title: Text('결제 금액',
                    style: TextStyle(fontSize: 30, color: Colors.white)),
                subtitle: Text("4500원"),
              ),
            ),
          ],
        ),
      )),
      bottomSheet: widget.collection.status != 'CANCELLED'
          ? SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.07,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorStyles.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        final api = FirebaseAPI();
                        final user = UserService.instance;

                        bool cancle = await api.cancelPaymentOnCallFunction(
                            user.uid!, widget.collection.order_id, "");
                        if (cancle) {
                          showSnackbar(
                              context, '해당 주문취소를 완료 하였습니다. 계좌를 확인 해 주세요!');
                          widget.onReturnTrashCollection(widget.collection);
                        } else {
                          showSnackbar(
                              context, '해당 주문취소를 실패 하였습니다. 고객센터에 문의 바랍니다!');
                        }
                        setState(() {
                          _isLoading = false;
                        });
                      },
                child: _isLoading
                    ? PlatformCircularProgressIndicator(
                        material: (context, platform) {
                          return MaterialProgressIndicatorData(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          );
                        },
                      )
                    : const Text(
                        '취소하기',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
              ),
            )
          : null,
    );
  }
}

class ImageAddButton extends StatefulWidget {
  final String title;
  final String imageCount;
  final int num;
  final String imagePath;
  final Function(XFile?, int) onImageSelected; // Callback function

  const ImageAddButton({
    super.key,
    required this.title,
    required this.imageCount,
    required this.num,
    required this.imagePath,
    required this.onImageSelected,
  });

  @override
  _ImageAddButtonState createState() => _ImageAddButtonState();
}

class _ImageAddButtonState extends State<ImageAddButton> {
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    // 이미지 경로가 제공된 경우 XFile 대신 이미지 경로를 사용
    // 이미지 경로가 제공되는 경우 이미지가 화면에 표시됩니다.
    _pickedImage = null;
  }

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
              : widget.imagePath != null
                  ? Image.network(
                      widget.imagePath,
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
                        const SizedBox(height: 12.0),
                        Text(
                          widget.imageCount,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 12.0),
                      ],
                    ),
        ),
        if (_pickedImage != null || widget.imagePath != null)
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

class FollowerPage extends StatefulWidget {
  final UserService _user;
  final MypageViewModel _viewModel;

  const FollowerPage({
    required UserService userService,
    required MypageViewModel viewModel,
    super.key,
  })  : _user = userService,
        _viewModel = viewModel;

  @override
  _FollowerPageState createState() => _FollowerPageState();
}

class _FollowerPageState extends State<FollowerPage> {
  @override
  void initState() {
    super.initState();
    if (mounted) {
      widget._viewModel.addListener(checkListen);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget._viewModel.removeListener(checkListen);
  }

  void checkListen() {
    if (widget._viewModel.notification_followers ||
        widget._viewModel.notification_following) {
      widget._viewModel.notification_followers = false;
      widget._viewModel.notification_following = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "팔로워",
          style: TextStyle(
            fontFamily: "SUIT",
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        cacheExtent: 1000,
        itemCount: widget._viewModel.model.Followers!.length,
        itemBuilder: (context, index) {
          String targetUid = widget._viewModel.model.Followers![index].uid;
          bool isFollowing = widget._viewModel.model.Following!
              .any((following) => following.uid == targetUid);

          return ListTile(
            leading: ProfileImg(
              borderRadius: 1,
              imageUrl: widget._viewModel.model.Followers![index].profileImage,
              width: 60,
              height: 60,
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              callback: () {
                // 이미지를 누르면 Image 상세 정보를 나타내는 페이지로 이동
                if (UserService.instance.uid !=
                    widget._viewModel.model.Followers![index].uid) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserProfile(
                        uid: widget._viewModel.model.Followers![index].uid,
                      ),
                    ),
                  );
                }
              },
            ),
            title: Text(widget._viewModel.model.Followers![index].nickname),
            subtitle:
                Text(widget._viewModel.model.Followers![index].description),
            trailing: ElevatedButton(
              onPressed: () {
                // Check if the user is already following
                if (isFollowing) {
                  isFollowing = !isFollowing;
                  // If following, perform unfollow action
                  widget._viewModel.unfollow(targetUid);
                  setState(() {});
                } else {
                  isFollowing = !isFollowing;
                  widget._viewModel.follow(targetUid);
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorStyles.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFollowing ? Icons.check : Icons.add,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isFollowing ? "팔로잉" : "팔로우",
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "SUIT",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FollowingPage extends StatefulWidget {
  final UserService _user;
  final MypageViewModel _viewModel;
  final Function(String) _callback;

  const FollowingPage({
    required UserService userService,
    required MypageViewModel viewModel,
    required callback,
    super.key,
  })  : _user = userService,
        _viewModel = viewModel,
        _callback = callback;

  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "팔로잉",
          style: TextStyle(
            fontFamily: "SUIT",
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        cacheExtent: 1000,
        itemCount: widget._viewModel.model.Following!.length,
        itemBuilder: (context, index) {
          bool isFollowing = widget._viewModel.model.Following!.any(
              (following) =>
                  following.uid ==
                  widget._viewModel.model.Following![index].uid);

          return ListTile(
            leading: ProfileImg(
              borderRadius: 50,
              imageUrl: widget._viewModel.model.Following![index].profileImage,
              width: 60,
              height: 60,
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              callback: () {
                // 이미지를 누르면 Image 상세 정보를 나타내는 페이지로 이동
                if (UserService.instance.uid !=
                    widget._viewModel.model.Following![index].uid) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserProfile(
                          uid: widget._viewModel.model.Following![index].uid),
                    ),
                  );
                }
              },
            ),
            title: Text(widget._viewModel.model.Following![index].nickname),
            subtitle:
                Text(widget._viewModel.model.Following![index].description),
            trailing: ElevatedButton(
              onPressed: () {
                // 팔로잉을 언팔로우하는 로직을 추가
                if (isFollowing) {
                  widget._viewModel
                      .unfollow(widget._viewModel.model.Following![index].uid);
                  widget
                      ._callback(widget._viewModel.model.Following![index].uid);
                  widget._viewModel.model.Following!.removeAt(index);
                } else {
                  // Handle logic for following
                  // You can add your follow logic here
                }
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorStyles.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFollowing ? Icons.check : Icons.add,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isFollowing ? "팔로잉" : "팔로우",
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "SUIT",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfileEditPage extends StatefulWidget {
  final UserService _user;
  final MypageViewModel _viewModel;

  const ProfileEditPage({
    required UserService userService,
    required MypageViewModel viewModel,
    super.key,
  })  : _user = userService,
        _viewModel = viewModel;

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  String? _image;
  final picker = ImagePicker();
  bool isPick = false;
  @override
  void initState() {
    super.initState();
    // 이미지 경로를 가져와서 이미지 파일을 로드
    final imagePath = widget._user.profileImage;
    if (imagePath != null) {
      _image = imagePath;
    }
  }

  Future getImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 30);

    if (pickedFile != null) {
      _image = pickedFile.path;
      isPick = true;
      widget._viewModel
          .uploadImage(
              UploadType.profile, widget._user.nickname.toString(), pickedFile)
          .then((url) {
        if (url != null) {
          setState(() {
            widget._user.setProfileImage(url);
          });
        }
      });
    } else {
      print('No image selected.');
    }
  }

  void _saveProfile() async {
    Navigator.of(context).pop(true);
    widget._viewModel.updateProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('프로필 편집',
            style: TextStyle(
                fontFamily: "SUIT", fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: getImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _image!.isEmpty
                    ? const AssetImage("assets/images/default_Profile.png")
                    : isPick
                        ? FileImage(File(_image!))
                        : NetworkImage(_image!) as ImageProvider<Object>,
                child: _image == null
                    ? const Icon(
                        Icons.camera_alt,
                        size: 60,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              enableInteractiveSelection: true,
              decoration: const InputDecoration(
                labelText: '닉네임',
              ),
              controller:
                  TextEditingController(text: widget._user.nickname.toString()),
              onChanged: (value) {
                widget._user.setNickname(value);
              },
            ),
            const SizedBox(height: 20.0),
            TextField(
              enableInteractiveSelection: true,
              decoration: const InputDecoration(
                labelText: '자기소개',
              ),
              controller: TextEditingController(
                text: widget._user.description
                    .toString(), // 초기값은 _controller에서 가져오기
              ),
              onChanged: (value) {
                // onChanged 콜백 함수 내에서 _controller를 업데이트
                widget._user.setDescription(value);
              },
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _saveProfile();
                });
              },
              child: const Text(
                '저장',
                style: TextStyle(
                    fontFamily: "SUIT",
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
