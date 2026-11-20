// ثوابت المسافات الهندسية الموحدة للتطبيق (8-point Grid System).
import 'package:flutter/material.dart';

class AppSpacing {
  // الأبعاد الأساسية
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // فواصل عمودية جاهزة (SizedBox Heights)
  static const SizedBox gapH4 = SizedBox(height: xs);
  static const SizedBox gapH8 = SizedBox(height: sm);
  static const SizedBox gapH12 = SizedBox(height: 12.0);
  static const SizedBox gapH16 = SizedBox(height: md);
  static const SizedBox gapH24 = SizedBox(height: lg);
  static const SizedBox gapH32 = SizedBox(height: xl);
  static const SizedBox gapH48 = SizedBox(height: xxl);

  // فواصل أفقية جاهزة (SizedBox Widths)
  static const SizedBox gapW4 = SizedBox(width: xs);
  static const SizedBox gapW8 = SizedBox(width: sm);
  static const SizedBox gapW12 = SizedBox(width: 12.0);
  static const SizedBox gapW16 = SizedBox(width: md);
  static const SizedBox gapW24 = SizedBox(width: lg);
  static const SizedBox gapW32 = SizedBox(width: xl);

  // هوامش شائعة (EdgeInsets)
  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets paddingAllSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingAllMd = EdgeInsets.all(md);
  static const EdgeInsets paddingAllLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingCard = EdgeInsets.all(md);

  // نصف قطر الحواف الموحد (Border Radius)
  static const double radiusSm = 8.0;
  static const double radiusMd = 13.0;
  static const double radiusLg = 18.0;
  static const double radiusXl = 24.0;
}

