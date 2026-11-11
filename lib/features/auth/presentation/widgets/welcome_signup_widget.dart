// يعرض نصوص الترحيب التوضيحية في شاشة إنشاء الحساب.
import 'package:flutter/material.dart';
import 'package:scarvs/app/theme/app_colors.dart';
import 'package:scarvs/shared/widgets/dimensions_widget.dart';

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
