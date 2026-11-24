// يوفر دوال موحدة لعرض رسائل التنبيه المؤقتة.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scarvs/core/theme/app_colors.dart';

class SnackUtil {
  static void show(
    BuildContext? context,
    String text, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    Widget? icon,
  }) {
    if (context == null || !context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        stylishSnackBar(
          text: text,
          context: context,
          backgroundColor: backgroundColor,
          duration: duration,
          icon: icon,
        ),
      );
  }

  static void showNetworkError(BuildContext? context) {
    show(context, 'يرجى التحقق من اتصالك بالإنترنت');
  }

  static SnackBar stylishSnackBar({
    required String text,
    required BuildContext context,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    Widget? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SnackBar(
      backgroundColor: backgroundColor ?? (isDark ? const Color(0xff2c384e) : AppColors.rawSienna),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      duration: duration,
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
