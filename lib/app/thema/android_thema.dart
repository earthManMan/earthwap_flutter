import 'package:flutter/material.dart';
import 'package:firebase_login/app/config/app_color.dart';

class AndroidAppThema {
  ThemeData themeData() {
    return ThemeData(
      fontFamily: 'SUIT',
      colorScheme: const ColorScheme.highContrastDark(
        primary: AppColor.primary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 24.0, fontFamily: "SUIT"),
        titleLarge: TextStyle(fontSize: 14.0, fontFamily: "SUIT"),
        bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Syncopate'),
        labelLarge: TextStyle(fontSize: 14.0, fontFamily: "SUIT"),
      ),
    );
  }
}
