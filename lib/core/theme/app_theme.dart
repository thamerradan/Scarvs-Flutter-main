// يعرف إعدادات السمات الفاتحة والداكنة للتطبيق.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

final darkTheme = ThemeData(
  useMaterial3: false,
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: Colors.white,
    secondary: Colors.white,
    brightness: Brightness.dark,
    surface: AppColors.mirage,
  ),
  dividerColor: Colors.white24,
  fontFamily: GoogleFonts.cairo().fontFamily,
  textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
);

final lightTheme = ThemeData(
  useMaterial3: false,
  brightness: Brightness.light,
  primaryColor: AppColors.rawSienna,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: AppColors.rawSienna,
    secondary: AppColors.rawSienna,
    brightness: Brightness.light,
    surface: AppColors.creamColor,
  ),
  dividerColor: Colors.black12,
  fontFamily: GoogleFonts.cairo().fontFamily,
  textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme),
);
