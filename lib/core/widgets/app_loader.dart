// يعرض مؤشر تحميل مخصصاً أثناء انتظار البيانات.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:scarvs/core/theme/app_colors.dart';

/// مؤشر تحميل أنيق متوافق مع الثيم الداكن والفاتح ومع الخطوط العربية
class AppLoader extends StatelessWidget {
  final bool themeFlag;
  final String? lottieAsset;
  final String? text;
  final double size;

  const AppLoader({
    super.key,
    required this.themeFlag,
    this.lottieAsset,
    this.text,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    if (lottieAsset != null && lottieAsset!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 220,
                  maxWidth: 240,
                ),
                child: Lottie.asset(
                  lottieAsset!,
                  fit: BoxFit.contain,
                ),
              ),
              if (text != null && text!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  text!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: themeFlag ? Colors.white : AppColors.rawSienna,
              strokeWidth: 3,
            ),
          ),
          if (text != null && text!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              text!,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
