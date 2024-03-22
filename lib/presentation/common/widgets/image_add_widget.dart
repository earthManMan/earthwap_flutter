import 'package:firebase_login/app/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageAddButton extends StatefulWidget {
  final String title;
  final bool visible;
  final Function(XFile?) onImageSelected; // Callback function
  final Function(ImageAddButton?) onImageClear;

  const ImageAddButton({
    super.key,
    required this.title,
    required this.visible,
    required this.onImageSelected,
    required this.onImageClear,
  });

  @override
  _ImageAddButtonState createState() => _ImageAddButtonState();
}

class _ImageAddButtonState extends State<ImageAddButton> {
  XFile? _pickedImage;

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PlatformListTile(
                leading: Icon(Icons.image),
                title: Text(
                  '앨범에서 선택',
                  style: TextStyle(
                      fontFamily: "SUIT", fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context); // 바텀 시트 닫기
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text(
                  '카메라로 찍기',
                  style: TextStyle(
                      fontFamily: "SUIT", fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context); // 바텀 시트 닫기
                  _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = pickedImage;
      });

      widget.onImageSelected(pickedImage);
    }
  }

  void _clearImage() {
    setState(() {
      _pickedImage = null;
    });
    widget.onImageClear(widget);
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
            side: const BorderSide(color: AppColor.grayF9, width: 2.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: _pickedImage != null
              ? Image.file(
                  File(_pickedImage!.path),
                  width: MediaQuery.of(context).size.width / 4,
                  height: MediaQuery.of(context).size.height / 7,
                  fit: BoxFit.cover,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      color: AppColor.grayF9,
                    ),
                    Text(
                      widget.title,
                      style: const TextStyle(color: AppColor.grayF9),
                    ),
                  ],
                ),
        ),
        if (widget.title == '커버 등록')
          if (_pickedImage != null)
            const Positioned(
                top: -0,
                left: -0,
                child: Icon(Icons.star_outlined, color: AppColor.primary)),
        if (_pickedImage != null)
          if (widget.visible)
            Positioned(
              top: -10.0,
              right: -10.0,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColor.grayF9),
                onPressed: _clearImage,
              ),
            )
      ],
    );
  }
}
