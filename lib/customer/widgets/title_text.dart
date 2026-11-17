// عنصر نصي موحد للعناوين مبني على خط Cairo العربي.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scarvs/core/theme/app_colors.dart';

class TitleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TitleText({
    super.key,
    required this.text,
    this.fontSize = 18,
    this.color,
    this.fontWeight = FontWeight.bold,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? AppColors.creamColor : AppColors.mirage;

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.cairo(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? defaultColor,
        textStyle: const TextStyle(
          fontFamilyFallback: ['Cairo', 'Segoe UI', 'Roboto', 'sans-serif'],
        ),
      ),
    );
  }
}

