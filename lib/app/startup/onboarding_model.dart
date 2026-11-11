// يمثل بيانات صفحة واحدة من صفحات التعريف الأولي بالتطبيق.
import 'package:flutter/material.dart';

class OnBoardingModel {
  final String? title;
  final String? image;
  final Color bgColor;
  final Color textColor;

  OnBoardingModel({
    this.title,
    this.image,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
  });
}
