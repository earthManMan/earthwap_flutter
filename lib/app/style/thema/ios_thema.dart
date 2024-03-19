import 'package:flutter/cupertino.dart';
import 'package:firebase_login/app/style/app_color.dart';

class IosAppThema {
  CupertinoThemeData themeData() {
    return CupertinoThemeData(
      primaryColor: AppColor.primary,
      
      textTheme: CupertinoTextThemeData(
        textStyle: const TextStyle(fontSize: 14.0, fontFamily: "SUIT"),
        actionTextStyle: TextStyle(fontSize: 14.0, fontFamily: 'Syncopate'),
        navTitleTextStyle: TextStyle(fontSize: 24.0, fontFamily: "SUIT"),
        tabLabelTextStyle: TextStyle(fontSize: 14.0, fontFamily: "SUIT"),
      ),
    );
  }
}
