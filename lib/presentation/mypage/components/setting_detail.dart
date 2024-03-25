import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:firebase_login/domain/world/contentService.dart';
import 'package:firebase_login/presentation/start/start_screen.dart';

import 'package:flutter/material.dart';
import 'package:firebase_login/presentation/components/common_components.dart';
import 'package:firebase_login/domain/login/userService.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:async';
import 'package:firebase_login/app/config/remote_options.dart';
import 'package:firebase_login/app/config/constant.dart';
// view model
import 'package:firebase_login/presentation/home/homeViewModel.dart';
import 'package:firebase_login/presentation/mypage/mypageViewModel.dart';
import 'package:firebase_login/presentation/sell/sellViewModel.dart';
import 'package:firebase_login/presentation/world/worldViewModel.dart';
import 'package:firebase_login/presentation/chat/chatViewModel.dart';
import 'package:firebase_login/domain/alarm/alarmService.dart';
import 'package:firebase_login/presentation/components/popup_widget.dart';
import 'package:firebase_login/presentation/mypage/components/mypage_webview.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/presentation/common/widgets/toast_widget.dart';
import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/app/util/localStorage_util.dart';
import 'package:firebase_login/presentation/common/widgets/custom_popup_widget.dart';

class settingLayout extends StatefulWidget {
  const settingLayout({super.key});

  @override
  State<settingLayout> createState() => _settingLayoutState();
}

class _settingLayoutState extends State<settingLayout> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true, // 편집 모드일 때만 title을 가운데 정렬
        title: const Text(
          '설정',
          style: TextStyle(
              fontFamily: "SUIT",
              fontWeight: FontWeight.bold,
              fontSize: 20, // 원하는 크기로 조정
              color: Color.fromARGB(255, 241, 240, 240)),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        backgroundColor: const Color.fromARGB(255, 20, 22, 25),
      ),
      body: SettingItemList(),
    );
  }
}

class SettingItemList extends StatefulWidget {
  const SettingItemList({super.key});

  @override
  _SettingItemListState createState() => _SettingItemListState();
}

class _SettingItemListState extends State<SettingItemList> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    items.add({
      'title': '알림 설정',
      'hasIcon': true,
      'value': AlarmService.instance.getAlaramStatus() == true ? 'on' : 'off',
    });

    items.add(
      {'title': '고객센터', 'hasIcon': true},
    );
    items.add({'title': '이용약관', 'hasIcon': true});
    items.add({'title': '개인 정보 처리 방침', 'hasIcon': true});
    items.add({'title': '버전 정보', 'hasIcon': false, 'value': '1.0.0'});
    items.add({'title': '탈퇴하기', 'hasIcon': true});
    items.add({'title': '로그아웃', 'hasIcon': true});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      cacheExtent: 1000,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return SettingItem(
          title: item['title'],
          hasIcon: item['hasIcon'],
          value: item['value'],
          onValueChanged: (newValue) {
            setState(() {
              item['value'] = newValue;
              final alarm = AlarmService.instance;
              alarm.setNotificationEnabled(newValue == "off" ? false : true);
            });
          },
          onMainMove: (value) {
            Navigator.of(context).popAndPushNamed('/login');
          },
        );
      },
    );
  }
}

class SettingItem extends StatelessWidget {
  final String title;
  final bool hasIcon;
  final String? value;
  final ValueChanged<String> onValueChanged;
  final Function(bool) onMainMove;
  const SettingItem({
    super.key,
    required this.title,
    required this.hasIcon,
    required this.value,
    required this.onValueChanged,
    required this.onMainMove,
  });

  @override
  Widget build(BuildContext context) {
    final remote = RemoteConfigOptions.instance;

    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontFamily: "SUIT", fontWeight: FontWeight.bold),
      ),
      trailing: title == '알림 설정'
          ? Switch(
              value: value == 'on',
              onChanged: (bool newValue) {
                onValueChanged(newValue ? 'on' : 'off');
              },
            )
          : hasIcon
              ? const Icon(Icons.arrow_forward)
              : Text(value ?? ''),
      onTap: () {
        // Add actions for each item
        if (title == '고객센터') {
          _showCustomerServiceDialog(context);

          print('Navigate to customer service');
        } else if (title == '이용약관') {
          /*Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TermsOfServicePage(),
            ),
          );*/

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InAppWebViewScreen(
                      myUrl: Uri.parse(remote.getPrivacyPolicy().toString()),
                      title: "이용약관",
                    )),
          );
        } else if (title == '개인 정보 처리 방침') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InAppWebViewScreen(
                      myUrl: Uri.parse(remote.getPrivacyPolicy().toString()),
                      title: "개인 정보 처리 방침",
                    )),
          );
        } else if (title == '버전 정보') {
          showAppVersion(context, value!);
        } else if (title == '탈퇴하기') {
          showWithdrawalConfirmationDialog(context, () {
            final api = FirebaseAPI();
            final user = UserService.instance;
            api.deregisterUserOnCallFunction(user.uid!);
            Navigator.pushReplacementNamed(context, '/start');
            // 메인 화면으로 이동
            showtoastMessage('계정을 탈퇴 했습니다. ', toastStatus.success);
          });
        } else if (title == '로그아웃') {
          showLogoutConfirmationDialog(context, () {
            final user = UserService.instance;
            final content = ContentService.instance;
            final alaram = AlarmService.instance;
            final api = FirebaseAPI();

            final mypage = Provider.of<MypageViewModel>(context, listen: false);
            final world = Provider.of<WorldViewModel>(context, listen: false);
            final chat = Provider.of<ChatViewModel>(context, listen: false);
            final home = Provider.of<HomeViewModel>(context, listen: false);
            final sell = Provider.of<SellViewModel>(context, listen: false);

            mypage.clearModel();
            world.clearModel();
            chat.clearModel();
            home.clearModel();
            sell.clearModel();

            user.stopListeningToUserDataChanges();
            content.removeListener(() {});
            alaram.stopListeningToMessages();
            alaram.stopListeningToNotifications();

            // 로그 아웃 시 local에 저장된 token 및 자동 로그인 제거
            // Firebase Auth logout 처리
            final _storage = LocalStorage();
            _storage.deleteitem(KEY_AUTOLOGIN);
            _storage.deleteitem(KEY_TOKEN);
            api.logout();

            // 모든 화면을 dispose하고 StartView로 이동
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => StartScreen()),
              (route) => false,
            ); // 메인 화면으로 이동

            showtoastMessage('로그아웃 했습니다. ', toastStatus.success);
          });
        }
      },
    );
  }

// 이 함수를 로그아웃 버튼의 onPressed 콜백으로 사용합니다.
  void showLogoutConfirmationDialog(
      BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          message: "Logout 하시겠습니까?",
          onConfirm: onConfirm,
          visibleCancel: true,
          visibleConfirm: true,
        );
      },
    );
  }

// 이 함수를 탈퇴하기 버튼의 onPressed 콜백으로 사용합니다.
  void showWithdrawalConfirmationDialog(
      BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          message: "정말 탈퇴하시겠습니까?\n탈퇴하면 복구할 수 없습니다.",
          onConfirm: onConfirm,
          visibleCancel: true,
          visibleConfirm: true,
        );
      },
    );
  }

  void _showCustomerServiceDialog(BuildContext context) {
    final ViewModel = Provider.of<MypageViewModel>(context, listen: false);
    final remote = RemoteConfigOptions.instance;

    final valueList = remote.getCustomerServiceJsonMap();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final user = UserService.instance;
        return CustomAlertDialog(
          message:
              '${user.nickname}님\n\n${ViewModel.model.getcustomer_email().isEmpty == true ? valueList['email'] : ViewModel.model.getcustomer_email()}\n\n${ViewModel.model.getcustomer_time().isEmpty == true ? valueList['time'].toString() : ViewModel.model.getcustomer_time()}',
          visibleCancel: false,
          visibleConfirm: true,
        );

        /*
        return AlertDialog(
          backgroundColor: ColorStyles.background,
          alignment: Alignment.center,
          /*title: const Text(
            '고객센터',
            style: TextStyle(fontFamily: "SUIT", fontWeight: FontWeight.bold),
          ),*/
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${user.nickname}님\n\n${ViewModel.model.getcustomer_email().isEmpty == true ? valueList['email'] : ViewModel.model.getcustomer_email()}',
                style:
                    TextStyle(fontFamily: "SUIT", fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                  ViewModel.model.getcustomer_time().isEmpty == true
                      ? valueList['time']
                      : ViewModel.model.getcustomer_time(),
                  style: TextStyle(
                      fontFamily: "SUIT", fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                '확인',
                style:
                    TextStyle(fontFamily: "SUIT", fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      */
      },
    );
  }
}

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '이용약관',
          style: TextStyle(fontFamily: "SUIT", fontWeight: FontWeight.bold),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이용약관 내용 예시',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '1. 이 앱을 이용함으로써 약관에 동의하는 것으로 간주합니다.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '2. 회원은 이 앱을 부정 이용해서는 안 됩니다.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '3. 기타 앱 이용에 관한 상세한 내용은 앱 내 공지사항을 참고하세요.',
              style: TextStyle(fontSize: 16),
            ),
            // 추가적인 이용약관 내용을 필요에 따라 추가할 수 있습니다.
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인정보 처리방침'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '개인정보 처리방침 내용 예시',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '1. 수집하는 개인정보 항목',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '이 앱은 회원 가입, 로그인, 서비스 이용과정에서 필요한 최소한의 개인정보를 수집합니다. 수집하는 개인정보 항목은 다음과 같습니다:',
              style: TextStyle(fontSize: 16),
            ),
            Text('- 이메일 주소'),
            Text('- 사용자명'),
            Text(
              '2. 개인정보의 수집 및 이용목적',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '이 앱은 다음과 같은 목적으로 개인정보를 수집하고 있습니다:',
              style: TextStyle(fontSize: 16),
            ),
            Text('- 회원 가입 및 관리'),
            Text('- 서비스 제공 및 개선'),
            Text('- 고객 지원 및 문의 응대'),
            Text(
              '3. 개인정보의 보유 및 이용기간',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '회원의 개인정보는 회원 탈퇴 시 또는 정보의 필요성이 없어질 경우 지체 없이 파기됩니다. 단, 관련 법령에 따라 보존할 필요가 있는 경우에는 그 보유 기간을 준수합니다.',
              style: TextStyle(fontSize: 16),
            ),
            // 추가적인 내용을 필요에 따라 추가할 수 있습니다.
          ],
        ),
      ),
    );
  }
}

void showAppVersion(BuildContext context, String version) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog(
        message: "현재 앱 버전: $version",
        visibleCancel: false,
        visibleConfirm: true,
      );
    },
  );
}

class PDFScreen extends StatefulWidget {
  final String? path;
  final String? title;
  const PDFScreen({super.key, this.path, this.title});

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title!,
          style: TextStyle(fontFamily: "SUIT", fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation:
                false, // if set to true the link is handled in flutter
            onRender: (pages) {
              setState(() {
                pages = pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              print('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              print('page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? Center(
                      child: PlatformCircularProgressIndicator(
                        cupertino: (context, platform) {
                          return CupertinoProgressIndicatorData(
                            color: AppColor.primary,
                          );
                        },
                      ),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      ),
      floatingActionButton: FutureBuilder<PDFViewController>(
        future: _controller.future,
        builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton.extended(
              label: Text("Go to ${pages! ~/ 2}"),
              onPressed: () async {
                await snapshot.data!.setPage(pages! ~/ 2);
              },
            );
          }

          return Container();
        },
      ),
    );
  }
}
