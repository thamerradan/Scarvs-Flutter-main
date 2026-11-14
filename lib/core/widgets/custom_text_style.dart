// يوفر أنماط نصية مشتركة لواجهات التطبيق.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// نظام أنماط النصوص الموحد للمتجر، مبني على خط "Cairo" المخصص للغة العربية
/// متوافق تماماً مع جميع المقاسات والأوزان البصرية المستخدمة في الشاشات
class CustomTextWidget {
  static TextStyle bodyTextB2({required Color color}) {
    return GoogleFonts.cairo(
      color: color,
      fontWeight: FontWeight.w700,
      fontSize: 20.0,
      height: 1.35,
    );
  }
}
