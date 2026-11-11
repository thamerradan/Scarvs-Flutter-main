// يوفر أنماط نصية مشتركة لواجهات التطبيق.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// نظام أنماط النصوص الموحد للمتجر، مبني على خط "Cairo" المخصص للغة العربية
/// متوافق تماماً مع جميع المقاسات والأوزان البصرية المستخدمة في الشاشات
class CustomTextWidget {
  static TextStyle bodyTextUltra({required Color color}) {
    return GoogleFonts.cairo(
      color: color,
      fontWeight: FontWeight.w900,
      fontSize: 28.0,
      height: 1.3,
    );
  }

  static TextStyle bodyTextB1({required Color color}) {
    return GoogleFonts.cairo(
      color: color,
      fontWeight: FontWeight.w800,
      fontSize: 24.0,
      height: 1.3,
    );
  }

  static TextStyle bodyTextB2({required Color color}) {
    return GoogleFonts.cairo(
      color: color,
      fontWeight: FontWeight.w700,
      fontSize: 20.0,
      height: 1.35,
    );
  }

  static TextStyle bodyTextB3({required Color color}) {
    return GoogleFonts.cairo(
      color: color,
      fontWeight: FontWeight.w700,
      fontSize: 16.0,
      height: 1.35,
    );
  }

  static TextStyle bodyTextB4({required Color color}) {
    return GoogleFonts.cairo(
      color: color,
      fontWeight: FontWeight.w700,
      fontSize: 14.0,
      height: 1.35,
    );
  }

  static TextStyle bodyText1({required Color color}) {
    return GoogleFonts.cairo(
      color: color,
      fontWeight: FontWeight.w600,
      fontSize: 18.0,
      height: 1.4,
    );
  }

  static TextStyle bodyText2({required Color color}) {
    return GoogleFonts.cairo(
      color: color,
      fontWeight: FontWeight.w500,
      fontSize: 16.0,
      height: 1.4,
    );
  }

  static TextStyle bodyText3({required Color color}) {
    return GoogleFonts.cairo(
      color: color,
      fontWeight: FontWeight.w400,
      fontSize: 14.0,
      height: 1.4,
    );
  }

  /// نمط مخصص للأسعار مع دعم الأرقام الإنجليزية/العربية
  static TextStyle priceText({required Color color, double fontSize = 16.0}) {
    return GoogleFonts.cairo(
      color: color,
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
      letterSpacing: 0.5,
    );
  }

  /// نمط للنصوص التوضيحية الصغيرة
  static TextStyle caption({required Color color}) {
    return GoogleFonts.cairo(
      color: color,
      fontWeight: FontWeight.normal,
      fontSize: 12.0,
      height: 1.3,
    );
  }
}
