import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/presentation/components/popup_widget.dart';
import 'package:firebase_login/presentation/mypage/mypageViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/presentation/components/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_login/app/config/remote_options.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Bottom에서 올라오는 Widget
void showOptions(BuildContext context, String title, List<MenuItem> MenuList) {
  List<Widget> customTextButtons = MenuList.map((menuItem) {
    return CustomTextButtonWidget(
      callback: menuItem.callback,
      content: menuItem.Content,
      textColor: menuItem.textColor,
    );
  }).toList();

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 20, 22, 25), // 배경색 설정
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: ColorStyles.content, width: 0.5),
                      bottom:
                          BorderSide(color: ColorStyles.content, width: 0.5),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: customTextButtons,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

void showBackDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog(
        message: "앱을 종료 하시겠습니까?",
        visibleCancel: true,
        visibleConfirm: true,
        onConfirm: () {
          SystemNavigator.pop();
        },
      );
    },
  );
}

class CustomTextButtonWidget extends StatelessWidget {
  final VoidCallback callback;
  final String content;
  final Color textColor;

  const CustomTextButtonWidget({
    super.key,
    required this.callback,
    required this.content,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: callback,
      child: Text(
        content,
        style: TextStyle(color: textColor),
        textAlign: TextAlign.left,
      ),
    );
  }
}

class TextRoundButton extends StatelessWidget {
  final VoidCallback _callback;
  final String _title;
  final bool _isEnabled;
  const TextRoundButton(
      {required VoidCallback call,
      required String text,
      required bool enable,
      super.key})
      : _callback = call,
        _title = text,
        _isEnabled = enable;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.06,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorStyles.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: _isEnabled ? _callback : null,
        child: Text(
          _title,
          style: const TextStyle(
              fontFamily: 'Syncopate',
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white),
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final VoidCallback callback;
  final String Content;
  final Color textColor;

  const MenuItem({
    super.key,
    required this.callback,
    required this.Content,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback, // 클릭 시에 callback을 호출
      child: Text(
        Content,
        style: TextStyle(
            color: textColor,
            fontFamily: "SUIT",
            fontWeight: FontWeight.bold,
            fontSize: 18),
      ),
    );
  }
}

class BottomInputField extends StatefulWidget {
  final String contentid;

  const BottomInputField({required this.contentid, super.key});

  @override
  _BottomInputFieldState createState() => _BottomInputFieldState();
}

class _BottomInputFieldState extends State<BottomInputField> {
  final TextEditingController textEditingController = TextEditingController();
  String sendImage = "";

  @override
  void initState() {
    super.initState();

    final options = RemoteConfigOptions.instance;
    sendImage = options.getimages()["common_send"];
  }

  @override
  Widget build(BuildContext context) {
    final ViewModel = Provider.of<MypageViewModel>(context, listen: false);

    return SafeArea(
      bottom: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 20, 20, 20),
          border: Border(
            top: BorderSide(
              color: Color.fromARGB(255, 20, 22, 25),
            ),
          ),
        ),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        enableInteractiveSelection: true,
                        controller: textEditingController,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(
                            right: 42,
                            left: 16,
                            top: 18,
                          ),
                          hintText: '댓글을 남겨주세요',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 30,
              child: IconButton(
                icon: CachedNetworkImage(
                  width: 32,
                  height: 32,
                  imageUrl: sendImage,
                  fit: BoxFit.cover,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
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
                onPressed: () {
                  ViewModel.writeComment(
                      widget.contentid, "", textEditingController.text);
                  textEditingController.clear(); // 텍스트 필드를 지움
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
