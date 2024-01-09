import 'package:firebase_login/view/world/components/world_detail.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/viewModel/worldViewModel.dart';
import 'package:firebase_login/model/postItemModel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:firebase_login/API/firebaseAPI.dart';
import 'package:firebase_login/service/userService.dart';

class EditPostPage extends StatefulWidget {
  final PostItemModel post; // Assuming you have a Post model class

  final Function(PostItemModel, bool) onModifyItem;

  const EditPostPage(
      {required this.post, required this.onModifyItem, super.key});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String _pickedImages = "";
  late PostItemModel temp_itemModel;

  @override
  void initState() {
    super.initState();
    temp_itemModel = PostItemModel(
      onwerId: widget.post.onwerId,
      communityID: widget.post.communityID,
      contentID: widget.post.contentID,
      profileImg: widget.post.profileImg,
      nickName: widget.post.nickName,
      date: widget.post.date,
      title: widget.post.title,
      description: widget.post.description,
      contentImg: widget.post.contentImg,
      likes: widget.post.likes,
      views: widget.post.views,
      onNewComment: widget.post.onNewComment,
    );

    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.description);
    _pickedImages = widget.post.contentImg;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    temp_itemModel.commentService.stopListeningToComment();
    //widget.post.commentService.stopListeningToComment();
    super.dispose();
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
            widget.onModifyItem(temp_itemModel, false);
            Navigator.of(context).pop(); // Close the page
          },
        ),
        title: const Text("게시글 수정"),
        actions: [
          TextButton(
            onPressed: () {
              widget.onModifyItem(widget.post, true);
              Navigator.of(context).pop();
            },
            child: const Text("완료", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Similar to CreatePostPage, you can add UI elements here
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: TextField(
                enableInteractiveSelection: true,
                controller: _titleController,
                onChanged: (value) => widget.post.title = value,
                decoration: const InputDecoration(
                  hintText: "제목을 입력하세요",
                  hintStyle: TextStyle(fontSize: 18),
                  border: InputBorder.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: TextField(
                enableInteractiveSelection: true,
                controller: _contentController,
                onChanged: (value) => widget.post.description = value,
                decoration: const InputDecoration(
                  hintText: "내용을 입력하세요\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
                  hintStyle: TextStyle(fontSize: 14),
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
            ),
            _buildImage()
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        children: [
          if (widget.post.contentImg.isNotEmpty) ...[
            getImageWidget(widget.post.contentImg),
            // Cancel button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  removeCoverImage();
                },
                child: const Icon(Icons.close, color: Colors.red),
              ),
            ),
          ] else
            Positioned(
              child: GestureDetector(
                onTap: () async {
                  // 이미지를 가져오는 로직
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    // 가져온 이미지의 경로를 저장
                    setState(() {
                      widget.post.contentImg = pickedFile.path;
                    });
                  }
                },
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: ImageAddButton(
                      title: "사진 추가",
                      num: 0,
                      imageCount: "",
                      onImageSelected: _addImage),
                ),
              ),
            ),
        ],
      ),
    );
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
        widget.post.contentImg = url;
      } else {
        // 에러 처리 또는 실패 처리를 수행할 수 있음
        print('Error uploading image or url is null');
      }
    });
  }

  // 이미지 삭제 함수
  void removeCoverImage() {
    setState(() {
      widget.post.contentImg = "";
    });
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
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
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
                    const SizedBox(height: 12.0),
                    Text(
                      widget.imageCount,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12.0),
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
