// يوفر نظاماً موحداً لعرض رسائل التنبيه المؤقتة (العادية والنجاح والخطأ والمعلومات والإشعارات).
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

  /// رسالة نجاح خضراء
  static void success(BuildContext? context, String text) {
    show(
      context,
      text,
      backgroundColor: const Color(0xFF1E8E3E),
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
    );
  }

  /// رسالة خطأ حمراء
  static void error(BuildContext? context, String text) {
    show(
      context,
      text,
      backgroundColor: const Color(0xFFD93025),
      icon: const Icon(Icons.error_rounded, color: Colors.white, size: 22),
    );
  }

  /// رسالة تنبيه أو معلومة زرقاء
  static void info(BuildContext? context, String text) {
    show(
      context,
      text,
      backgroundColor: const Color(0xFF1A73E8),
      icon: const Icon(Icons.info_rounded, color: Colors.white, size: 22),
    );
  }

  /// رسالة انقطاع الاتصال بالإنترنت
  static void showNetworkError(BuildContext? context) {
    error(context, 'يرجى التحقق من اتصالك بالإنترنت');
  }

  /// تنبيه منبثق للإشعارات اللحظية بعنوان ونص مختصر
  static void showNotification(
    BuildContext? context, {
    required String title,
    required String message,
  }) {
    if (context == null || !context.mounted) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor:
              isDark ? const Color(0xff2c384e) : AppColors.rawSienna,
          behavior: SnackBarBehavior.floating,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
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
      backgroundColor: backgroundColor ??
          (isDark ? const Color(0xff2c384e) : AppColors.rawSienna),
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
