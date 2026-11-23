// ويدجت موحد لإدارة حالات الشاشة: جاري التحميل، فارغة، خطأ، أو جاهزة.
import 'package:flutter/material.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_spacing.dart';
import 'package:scarvs/core/widgets/shimmer_effects.dart';

class AppStateView extends StatelessWidget {
  final bool isLoading;
  final bool isEmpty;
  final bool hasError;
  final String? errorMessage;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final VoidCallback? onRetry;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget child;

  const AppStateView({
    super.key,
    required this.isLoading,
    this.isEmpty = false,
    this.hasError = false,
    this.errorMessage,
    this.emptyMessage,
    this.emptyIcon,
    this.onRetry,
    this.loadingWidget,
    this.emptyWidget,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.creamColor : AppColors.mirage;

    // 1. حالة جاري التحميل
    if (isLoading) {
      return loadingWidget ??
          Padding(
            padding: AppSpacing.paddingAllMd,
            child: ShimmerEffects.loadShimmer(context: context),
          );
    }

    // 2. حالة الخطأ
    if (hasError) {
      return Center(
        child: Padding(
          padding: AppSpacing.paddingAllLg,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.redAccent.withValues(alpha: 0.8),
              ),
              AppSpacing.gapH16,
              Text(
                errorMessage ?? 'تعذر تحميل البيانات، يرجى المحاولة مرة أخرى',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onRetry != null) ...[
                AppSpacing.gapH16,
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    side: BorderSide(
                      color: isDark ? Colors.white30 : AppColors.rawSienna,
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      );
    }

    // 3. حالة القائمة الفارغة
    if (isEmpty) {
      if (emptyWidget != null) return emptyWidget!;

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                emptyIcon ?? Icons.inbox_outlined,
                size: 64,
                color: textColor.withValues(alpha: 0.35),
              ),
              AppSpacing.gapH16,
              Text(
                emptyMessage ?? 'لا توجد بيانات متاحة حالياً',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. المحتوى الطبيعي الجاهز
    return child;
  }
}

