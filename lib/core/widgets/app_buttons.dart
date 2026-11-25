// أزرار موحدة للتطبيق تدعم حالات التحميل والوضع الليلي والأيقونات مع حماية تامة ضد الـ Overflow.
import 'package:flutter/material.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_spacing.dart';

class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double? width;
  final double borderRadius;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;

  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 50.0,
    this.width,
    this.borderRadius = AppSpacing.radiusMd,
    this.fontSize = 15.0,
    this.padding,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = backgroundColor ??
        (isDark ? Colors.white : AppColors.rawSienna);
    final fg = textColor ??
        (isDark ? AppColors.mirage : Colors.white);

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: fg),
                    AppSpacing.gapW8,
                  ],
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double? width;
  final double borderRadius;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final Color? textColor;

  const AppOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 50.0,
    this.width,
    this.borderRadius = AppSpacing.radiusMd,
    this.fontSize = 14.0,
    this.padding,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final border = borderColor ??
        (isDark ? Colors.white30 : AppColors.mirage.withValues(alpha: 0.25));
    final fg = textColor ??
        (isDark ? AppColors.creamColor : AppColors.mirage);

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: border, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 10),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: fg),
                    AppSpacing.gapW8,
                  ],
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class AppDangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double? width;
  final double borderRadius;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const AppDangerButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 46.0,
    this.width,
    this.borderRadius = AppSpacing.radiusMd,
    this.fontSize = 14.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: Colors.white),
                    AppSpacing.gapW8,
                  ],
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// زر تحديث موحد لأشرطة العناوين والإجراءات يدعم حالة التحميل والوضع الليلي
class AppRefreshButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String tooltip;
  final bool isLoading;

  const AppRefreshButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'تحديث',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.creamColor : AppColors.mirage;

    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : const Icon(Icons.refresh_rounded),
        color: color,
        onPressed: isLoading ? null : onPressed,
      ),
    );
  }
}

/// زر إضافة عائم موحد (FloatingActionButton) بأسلوب التطبيق الموحد
class AppFloatingAddButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final Object? heroTag;

  const AppFloatingAddButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.white : AppColors.rawSienna;
    final fg = isDark ? AppColors.mirage : Colors.white;

    return FloatingActionButton.extended(
      heroTag: heroTag,
      elevation: 4,
      backgroundColor: bg,
      foregroundColor: fg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      icon: Icon(icon, color: fg, size: 20),
      label: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
    );
  }
}

/// زر نصي موحد للإجراءات الثانوية وأزرار الإلغاء في الحوارات
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double fontSize;
  final Color? textColor;

  const AppTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.fontSize = 14.0,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = textColor ?? (isDark ? AppColors.creamColor : AppColors.mirage);

    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: fg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: fg),
            AppSpacing.gapW8,
          ],
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


