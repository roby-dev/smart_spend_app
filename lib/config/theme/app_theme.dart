import 'package:flutter/material.dart';
import 'package:smart_spend_app/constants/app_colors.dart';

class AppTHeme {
  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.gray100,
      );
}
