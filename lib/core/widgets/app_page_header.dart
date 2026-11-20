// شريط عنوان موحد لكل صفحات التطبيق يدعم الرجوع والإجراءات الإضافية.
import 'package:flutter/material.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_spacing.dart';
import 'package:scarvs/core/widgets/app_squircle_button.dart';

class AppPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final String? fallbackRoute;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Widget? leading;

  const AppPageHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.fallbackRoute,
    this.onBackPressed,
    this.actions,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.creamColor : AppColors.mirage;
    final canPop = Navigator.of(context).canPop();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // الجهة اليمنى: زر الرجوع أو عنصر البداية + العنوان
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                AppSpacing.gapW12,
              ] else if (showBackButton && (canPop || fallbackRoute != null)) ...[
                AppSquircleButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  themeFlag: isDark,
                  isOutLine: true,
                  onTap: onBackPressed ??
                      () {
                        if (canPop) {
                          Navigator.of(context).pop();
                        } else if (fallbackRoute != null) {
                          Navigator.of(context).pushReplacementNamed(fallbackRoute!);
                        }
                      },
                ),
                AppSpacing.gapW12,
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    AppSpacing.gapH4,
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: titleColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // الجهة اليسرى: أزرار العمليات الإضافية
          if (actions != null && actions!.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: actions!,
            ),
        ],
      ),
    );
  }
}

