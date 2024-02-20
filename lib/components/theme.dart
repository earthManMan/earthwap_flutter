import 'package:flutter/material.dart';

/*
TextTheme textTheme() {
  return TextTheme(
    titleLarge: GoogleFonts.syncopate(fontSize: 18.0, color: Colors.black),
    titleMedium: GoogleFonts.openSans(
        fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold),
    bodyText1: GoogleFonts.openSans(fontSize: 16.0, color: Colors.black),
    bodyText2: GoogleFonts.openSans(fontSize: 14.0, color: Colors.grey),
    subtitle1: GoogleFonts.openSans(fontSize: 15.0, color: Colors.black),
  );
}

// 기존 코드 수정
AppBarTheme appTheme() {
  return AppBarTheme(
    centerTitle: false,
    color: Colors.white,
    elevation: 0.0,
    titleTextStyle: textTheme().headline6,
  );
}

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    textTheme: textTheme(),
    appBarTheme: appTheme(),
  );
}
*/
class ColorStyles {
  static const Color primary = Color.fromARGB(255, 0, 133, 255);
  static const Color background = Color.fromARGB(255, 40, 40, 40);
  static const Color content = Color.fromARGB(255, 29, 31, 34);
  static const Color text = Color.fromARGB(255, 130, 130, 130);
  static const Color notice = Color.fromARGB(255, 0, 133, 255);
  static const Color negative = Color.fromARGB(255, 0, 133, 255);
}

/*
class EllasNotesThemeData {
  static ThemeData lightThemeData = themeData(); // 실제 쓸 때는 요걸로 쓸 거임

  static ThemeData themeData() {
    // 실제 ThemeData 만듬
    final base = ThemeData.light();
    return base.copyWith(
      textTheme: _buildEllasNotesTextTheme(base.textTheme),
      // ...
      // textTheme 외에도 appBarTheme, primaryTheme, colorScheme 등 override 할 수 있는 항목 매우 많음
    );
  }

  static TextTheme _buildEllasNotesTextTheme(TextTheme base) {
    // TextTheme 생성
    return base.copyWith(
      titleLarge:
          GoogleFonts.robotoSlab(textStyle: base.titleLarge), // main text
      bodyMedium: GoogleFonts.nanumGothic(textStyle: base.bodyMedium), // note
      // ...
    );
  }
}
*/
