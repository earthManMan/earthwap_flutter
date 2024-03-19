import 'package:firebase_login/presentation/components/popup_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_login/presentation/components/theme.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class KeyWordInputButton extends StatelessWidget {
  final String text;
  final String MainKeyword;
  final String SubKeyword;

  final VoidCallback onPressed;

  const KeyWordInputButton({
    super.key,
    required this.text,
    required this.MainKeyword,
    required this.SubKeyword,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: ColorStyles.text, width: 1.0),
          bottom: BorderSide(color: ColorStyles.text, width: 1.0),
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          backgroundColor: const Color.fromARGB(255, 20, 22, 25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            if (MainKeyword.isNotEmpty || SubKeyword.isNotEmpty)
              Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "$MainKeyword , $SubKeyword",
                    style: const TextStyle(fontSize: 16.0),
                  )),
            const Icon(Icons.arrow_forward, size: 20.0),
          ],
        ),
      ),
    );
  }
}

class KeywordWorkPage extends StatefulWidget {
  final Function(String, String) _onApply;
  final String mainKeyword;
  final String subKeyword;
  final String colverImage;
  final Color mainColor;
  final Color subColor;
  const KeywordWorkPage(
      {required Function(String, String) call,
      required this.mainKeyword,
      required this.subKeyword,
      required this.colverImage,
      required this.mainColor,
      required this.subColor,
      super.key})
      : _onApply = call;

  @override
  State<KeywordWorkPage> createState() => _KeywordWorkPageState();
}

class _KeywordWorkPageState extends State<KeywordWorkPage> {
  _KeywordWorkPageState();

  late TextEditingController _textField1Value;
  late TextEditingController _textField2Value;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _textField1Value = TextEditingController(text: widget.mainKeyword);
    _textField2Value = TextEditingController(text: widget.subKeyword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Handles the back button click event
          },
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 255, 255, 255), //색변경
        ),
        title: const Text('키워드 추가',
            style: TextStyle(
                color: Color.fromARGB(255, 241, 240, 240),
                fontFamily: "SUIT",
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 20, 22, 25),
        actions: [
          TextButton(
            onPressed: () {
              if (_textField1Value.text.isNotEmpty ||
                  _textField2Value.text.isNotEmpty) {
                widget._onApply(_textField1Value.text, _textField2Value.text);
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomAlertDialog(
                      message: "키워드를 모두 입력 해 주세요!",
                      visibleCancel: false,
                      visibleConfirm: true,
                    );
                  },
                );
              }
            },
            child: Text(
              "완료",
              style: TextStyle(
                  color: (_textField1Value.text.isNotEmpty ||
                          _textField2Value.text.isNotEmpty)
                      ? ColorStyles.primary // 활성화 상태일 때 색상
                      : const Color.fromARGB(255, 79, 79, 79)),
            ),
          ),
        ],
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(
          children: [
            Center(child: getImageWidget(widget.colverImage)),
            Positioned(
              bottom: 30,
              left: 50,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    enableInteractiveSelection: true,
                    cursorColor: Colors.red,
                    controller: _textField1Value,
                    onChanged: (str) => {setState(() {})},
                    maxLength: 10,
                    decoration: InputDecoration(
                      hintText: '1ST KEYWORD',
                      hintStyle: TextStyle(
                          fontFamily: "Syncopate",
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: widget.mainColor),
                      enabledBorder: InputBorder.none,
                    ),
                    style: TextStyle(
                        fontFamily: "Syncopate",
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: widget.mainColor),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              left: 100,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextField(
                    enableInteractiveSelection: true,
                    cursorColor: Colors.red,
                    controller: _textField2Value,
                    onChanged: (str) => {setState(() {})},
                    maxLength: 10,
                    decoration: InputDecoration(
                      hintText: '2ND KEYWORD',
                      hintStyle: TextStyle(
                          fontFamily: "Syncopate",
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: widget.subColor),
                      enabledBorder: InputBorder.none,
                    ),
                    style: TextStyle(
                        fontFamily: "Syncopate",
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: widget.subColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
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
        placeholder: (context, url) => Center(
          child: PlatformCircularProgressIndicator(),
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
}
