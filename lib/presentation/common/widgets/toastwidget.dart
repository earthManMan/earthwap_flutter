import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_login/app/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/app/config/constant.dart';


// 하단에 잠시 출력 되었다가 사라지는 Widget
void showtoastMessage(String message, toastStatus status) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: status == toastStatus.info
          ? AppColor.gray8E
          : status == toastStatus.error
              ? AppColor.systemError
              : AppColor.primary,
      textColor: Colors.white,
      fontSize: 18.0);
}
