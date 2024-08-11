import 'package:flutter/material.dart';

class AppColors {
  //static const Color gray50 = Color(0xFFF5F5F5);
  static const Color gray100 = Color(0xFFF6F7F9);
  static const Color gray900 = Color(0xFF0E0E0F);
  static const Color gray500 = Color(0xFFB0B0B1);
  static const Color gray300 = Color(0xFFE2E3E5);
  static const Color gray200 = Color(0xFFEFF1F4);
  static const Color gray800 = Color(0xFF222225);
  static const Color gray700 = Color(0xFF616164);
  static const Color gray25 = Color(0xFFFCFCFD);
  static const Color gray50 = Color(0xFFFBFBFC);
  static const Color gray600 = Color(0xFF7E7E81);

  static const Color border1 = Color(0xFFD9D9D9);

  static const Color primary700 = Color(0xFFE10600);
  static const Color primary100 = Color(0xFFFDF3F2);
  static const Color primary400 = Color(0xFFF39B99);
  static const Color primary600 = Color(0xFFE73833);
  static const Color primary200 = Color(0xFFFCE6E5);
  static const Color primary50 = Color(0xFFFFF7F6);
  static const Color primary500 = Color(0xFFED6A66);
  static const Color primary25 = Color(0xFFFFFBFB);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color error500 = Color(0xFFF04438);
  static const Color success400 = Color(0xFF32D583);

  static const Color blueGray500 = Color(0xFF4E5BA6);

  static const Color inputReadOnly = gray600;
  static const Color input = gray800;
  static const Color inputHint = gray500;

  static const Gradient localLinearGrey = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF0F0FA),
      Color(0xFFFBFCFF),
    ],
  );

  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color.fromRGBO(16, 24, 40, 0.06),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(16, 24, 40, 0.10),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowXs = [
    BoxShadow(
      color: Color.fromRGBO(16, 24, 40, 0.05),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
}
