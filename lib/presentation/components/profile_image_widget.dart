import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/app/style/app_color.dart';

class ProfileImg extends StatelessWidget {
  final double borderRadius;
  final String imageUrl;
  final double width;
  final double height;
  final Color backgroundColor;
  final VoidCallback callback;

  const ProfileImg({
    super.key,
    required this.borderRadius,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: imageUrl.isEmpty == true
          ? IconButton(
              onPressed: callback,
              icon: ClipOval(
                  child: Container(
                      width: width,
                      height: height,
                      color: backgroundColor,
                      child: Container(
                        width: width,
                        height: height,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 255, 255, 255),
                          image: DecorationImage(
                            image:
                                AssetImage("assets/images/default_Profile.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ))))
          : IconButton(
              icon: ClipOval(
                child: Container(
                  width: width,
                  height: height,
                  color: backgroundColor,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: width,
                    height: height,
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
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
              onPressed: callback,
            ),
    );
  }
}
