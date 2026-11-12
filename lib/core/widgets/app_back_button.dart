// يوفر زري رجوع مخصصين للتنقل وإغلاق الشاشة.
import 'package:flutter/material.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/utils/auth_guard.dart';

/// زر رجوع ذكي متوافق تماماً مع اتجاه اللغة العربية (RTL).
/// في الواجهة العربية، يشير السهم لليمين (اتجاه الرجوع الطبيعي) مع توسيط بصري دقيق وتأثير لمس ناعم.
class AppBackButton extends StatelessWidget {
  final String route;
  final bool themeFlag;
  final VoidCallback? onCustomBack;
  final double size;

  const AppBackButton({
    super.key,
    required this.route,
    required this.themeFlag,
    this.onCustomBack,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final iconColor = themeFlag ? AppColors.creamColor : AppColors.mirage;
    final bgColor = themeFlag
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);
    final borderColor = themeFlag
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.06);

    return Tooltip(
      message: 'رجوع',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (onCustomBack != null) {
              onCustomBack!();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed(route);
            }
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            alignment: Alignment.center,
            child: Transform.translate(
              // ضبط إزاحة بكسل واحد لموازنة انحناء سهم iOS بدقة بصرية
              offset: Offset(isRtl ? -1 : 1, 0),
              child: Icon(
                isRtl
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_rounded,
                color: iconColor,
                size: size * 0.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// زر رجوع سريع (Pop) منبثق متوافق مع الاتجاه العربي
class AppBackPop extends StatelessWidget {
  final bool themeFlag;
  final VoidCallback? onPop;
  final double size;

  const AppBackPop({
    super.key,
    required this.themeFlag,
    this.onPop,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final iconColor = themeFlag ? AppColors.creamColor : AppColors.mirage;
    final bgColor = themeFlag
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);
    final borderColor = themeFlag
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.06);

    return Tooltip(
      message: 'رجوع',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (onPop != null) {
              onPop!();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              final isOwner = AuthGuard.isOwner;
              Navigator.of(context).pushReplacementNamed(
                isOwner
                    ? AppRouter.ownerDashboardRoute
                    : AppRouter.customerHomeRoute,
              );
            }
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(isRtl ? -1 : 1, 0),
              child: Icon(
                isRtl
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_rounded,
                color: iconColor,
                size: size * 0.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
