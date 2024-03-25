import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/app/util/localStorage_util.dart';
import 'package:firebase_login/app/config/constant.dart';

class CustomAlertDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool? visibleConfirm;
  final bool? visibleCancel;

  CustomAlertDialog({
    Key? key,
    required this.message,
    this.onConfirm,
    this.onCancel,
    this.visibleConfirm = true,
    this.visibleCancel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformAlertDialog(
      actions: _buildActions(context),
      title: Text(
        message,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    List<Widget> actions = [];
    if (visibleConfirm!) {
      actions.add(
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onConfirm != null) {
              onConfirm!();
            }
          },
          child: Text(
            '확인',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    if (visibleCancel!) {
      actions.add(
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onCancel != null) {
              onCancel!();
            }
          },
          child: Text(
            '취소',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return actions;
  }
}

class KeyWordPopup extends StatelessWidget {
  final String description;

  const KeyWordPopup({required this.description, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double width = mediaQuery.size.width;

    return PlatformAlertDialog(
      material: (context, platform) {
        return MaterialAlertDialogData(
          backgroundColor: AppColor.gray1C.withOpacity(0.5),
        );
      },
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100.0),
          _buildActionButton(
            text: 'TIP',
            width: 100,
            backgroundColor: AppColor.gray1C,
            onPressed: () {},
          ),
          SizedBox(height: 24.0),
          _buildDescription(description),
          SizedBox(height: 50.0),
          _buildActionButton(
            width: width,
            text: '확인',
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: AppColor.primary,
          ),
          SizedBox(height: 10),
          _buildActionButton(
            width: width,
            text: '오늘 그만 보기',
            backgroundColor: AppColor.gray1C,
            onPressed: () async {
              final _storage = LocalStorage();
              await _storage.saveitem(KEY_KEYWORDPOPUP, 'true');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required double width,
    required Function() onPressed,
    Color? backgroundColor,
  }) {
    return SizedBox(
      width: width,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColor.gray1C,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: AppColor.grayF9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColor.gray1C),
        ),
      ),
    );
  }
}
