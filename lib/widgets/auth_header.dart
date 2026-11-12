// يعرض نصوص الترحيب التوضيحية في شاشة تسجيل الدخول.
import 'package:flutter/material.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/widgets/dimensions_widget.dart';

Widget welcomeTextLogin({required bool themeFlag}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      vSizedBox4,
      vSizedBox1,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 8.0),
        child: Text(
          'مرحباً بك 👋',
          style: TextStyle(
            color: themeFlag ? AppColors.creamColor : AppColors.mirage,
            fontWeight: FontWeight.w900,
            fontSize: 34.0,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0),
        child: Text(
          'أهلاً بك في متجر سكارفس 🛒',
          style: TextStyle(
            color: themeFlag ? AppColors.creamColor : AppColors.mirage,
            fontWeight: FontWeight.w400,
            fontSize: 22.0,
          ),
        ),
      ),
      vSizedBox1,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0),
        child: Text(
          'سجّل الدخول للوصول إلى حسابك ومتابعة طلباتك',
          style: TextStyle(
            color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                .withOpacity(0.7),
            fontSize: 13.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}


// يعرض نصوص الترحيب التوضيحية في شاشة إنشاء الحساب.
Widget welcomeTextSignup({required bool themeFlag}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      vSizedBox2,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 8.0),
        child: Text(
          'حساب جديد ✨',
          style: TextStyle(
            color: themeFlag ? AppColors.creamColor : AppColors.mirage,
            fontWeight: FontWeight.w900,
            fontSize: 34.0,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0),
        child: Text(
          'انضم إلى متجر سكارفس 🛒',
          style: TextStyle(
            color: themeFlag ? AppColors.creamColor : AppColors.mirage,
            fontSize: 22.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      vSizedBox1,
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0),
        child: Text(
          'أنشئ حسابك وتسوق أفضل الأحذية بأفضل الأسعار',
          style: TextStyle(
            color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                .withOpacity(0.7),
            fontSize: 13.0,
          ),
        ),
      ),
      vSizedBox1,
    ],
  );
}
