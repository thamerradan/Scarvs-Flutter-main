// ويدجت موحد لصفوف عرض التفاصيل (أيقونة، عنوان، قيمة) داخل البطاقات.
import 'package:flutter/material.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_spacing.dart';

class AppInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool isBoldValue;
  final double fontSize;
  final bool isBetween;

  const AppInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.isBoldValue = false,
    this.fontSize = 12.0,
    this.isBetween = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? AppColors.creamColor : AppColors.mirage;
    final mutedColor = defaultTextColor.withValues(alpha: 0.65);

    if (isBetween) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: fontSize + 4, color: mutedColor),
                  AppSpacing.gapW8,
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: mutedColor,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w600,
                color: valueColor ?? defaultTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: fontSize + 4, color: mutedColor),
          AppSpacing.gapW8,
        ],
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: mutedColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? defaultTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
