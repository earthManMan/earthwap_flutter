import 'package:firebase_login/presentation/sell/sellViewModel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageAddButton extends StatefulWidget {
  final String title;
  final String imageCount;
  final SellViewModel viewModel;
  final int num;
  final Function(XFile?, int count, SellViewModel model)
      onImageSelected; // Callback function
  const ImageAddButton({
    super.key,
    required this.title,
    required this.imageCount,
    required this.num,
    required this.viewModel,
    required this.onImageSelected,
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
              ListTile(
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

      widget.onImageSelected(pickedImage, widget.num, widget.viewModel);
    }
  }

  void _clearImage() {
    setState(() {
      _pickedImage = null;
    });
    widget.onImageSelected(null, widget.num, widget.viewModel);
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
                  width: MediaQuery.of(context).size.width / 4,
                  height: MediaQuery.of(context).size.height / 7,
                  fit: BoxFit.cover,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
                    Text(
                      widget.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      widget.imageCount,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
        ),
        if (widget.title == '커버 등록')
          if (_pickedImage != null)
            const Positioned(
                top: -0,
                left: -0,
                child: Icon(Icons.star_outlined, color: Colors.blue)),
        if (_pickedImage != null)
          Positioned(
            top: -10.0,
            right: -10.0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _clearImage,
            ),
          )
      ],
    );
  }
}
