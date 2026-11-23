// ويدجت موحد لشارات الحالة (الطلبات، المخزون، المنتجات) بتنسيق لوني وأيقوني متناسق.
import 'package:flutter/material.dart';
import 'package:scarvs/core/theme/app_spacing.dart';

class AppStatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const AppStatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.fontSize = 12.0,
    this.padding,
    this.borderRadius = AppSpacing.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
