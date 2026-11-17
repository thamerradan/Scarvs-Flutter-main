// يجمع ألوان الهوية البصرية الموحدة للتطبيق ولوحة التحكم.
import 'package:flutter/material.dart';

class AppColors {
  /// اللون الأساسي الموحد للتطبيق (الأسود الفاخر)
  static const Color black = Color(0xff111111);
  static const Color primary = Color(0xff111111);

  /// تم توجيه rawSienna إلى اللون الأسود لتطبيق اللون الأساسي فوراً وبشكل شامل في كامل أرجاء التطبيق
  static const Color rawSienna = Color(0xff111111);
  static const Color rawSiennaLight = Color(0xff2A2A2A);
  static const Color rawSiennaDark = Color(0xff000000);

  /// ألوان السطح والخلفيات المتناسقة مع الثيمين الداكن والفاتح
  static const Color mirage = Color(0xff1d273b);
  static const Color creamColor = Color(0xfff5f5ff);
  static const Color white = Colors.white;
}
