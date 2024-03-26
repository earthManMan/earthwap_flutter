import 'package:firebase_login/presentation/home/components/home_detail.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/presentation/components/profile_image_widget.dart';
import 'package:firebase_login/app/style/app_color.dart';

class ProfileTopWidget extends StatelessWidget {
  final bool isMyPage;

  final String description;

  final String profileImageUrl;
  final int followersCount;
  final int followingCount;

  final VoidCallback follower_callback;
  final VoidCallback following_callback;
  final VoidCallback edit_callback;
  final VoidCallback trash_callback;
  final VoidCallback follow_callback;

  const ProfileTopWidget({
    required this.isMyPage,
    required this.description,
    required this.profileImageUrl,
    required this.followersCount,
    required this.followingCount,
    required this.follower_callback,
    required this.following_callback,
    required this.edit_callback,
    required this.trash_callback,
    required this.follow_callback,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            child: _buildProfile(profileImageUrl),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildFollowWidget(
                          '팔로워 $followersCount', follower_callback),
                      const SizedBox(width: 16),
                      _buildFollowWidget(
                          '팔로잉 $followingCount', following_callback),
                    ],
                  ),
                  _buildDescription(description),
                ],
              ),
            ),
          ),
        ]),
        _buildActionButton(),
      ],
    );
  }

  Widget _buildProfile(String url) {
    return ProfileImg(
      borderRadius: 50,
      imageUrl: url,
      width: 80,
      height: 80,
      backgroundColor: AppColor.grayF9,
      callback: () {},
    );
  }

  Widget _buildFollowWidget(String text, VoidCallback callback) {
    return TextButton(
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColor.grayF9,
                fontFamily: "SUIT",
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        onPressed: callback);
  }

  Widget _buildDescription(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(text,
              style: const TextStyle(
                  color: AppColor.grayF9,
                  fontFamily: "SUIT",
                  fontWeight: FontWeight.bold,
                  fontSize: 13))),
    );
  }

  Widget _buildActionButton() {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: isMyPage == true
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: edit_callback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(44, 47, 51, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text(
                      "프로필 편집",
                      style: TextStyle(
                          color: Color.fromARGB(255, 240, 244, 248),
                          fontFamily: "SUIT",
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: trash_callback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(44, 47, 51, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text("수거 신청 내역",
                        style: TextStyle(
                            color: Color.fromARGB(255, 240, 244, 248),
                            fontFamily: "SUIT",
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: follow_callback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(44, 47, 51, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text(
                      " + 팔로우",
                      style: TextStyle(
                          color: Color.fromARGB(255, 240, 244, 248),
                          fontFamily: "SUIT",
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ],
              ));
  }
}
