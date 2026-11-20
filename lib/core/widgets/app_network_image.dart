// يوفر عنصراً موحداً لعرض الصور الشبكية مع التحجيم التلقائي وإدارة التخزين المؤقت وحالات الأخطاء.
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int cacheWidth;
  final int? cacheHeight;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.cacheWidth = 400,
    this.cacheHeight,
    this.borderRadius = 0.0,
    this.placeholder,
    this.errorWidget,
  });

  /// صور البطاقات في قوائم وشبكة المنتجات
  const AppNetworkImage.card({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.cacheWidth = 400,
    this.cacheHeight,
    this.borderRadius = 14.0,
    this.placeholder,
    this.errorWidget,
  });

  /// صور مصغرة للقوائم والسلة وعناصر الطلبات
  const AppNetworkImage.thumbnail({
    super.key,
    required this.url,
    this.width = 52.0,
    this.height = 52.0,
    this.fit = BoxFit.cover,
    this.cacheWidth = 150,
    this.cacheHeight,
    this.borderRadius = 8.0,
    this.placeholder,
    this.errorWidget,
  });

  /// صور كبيرة لشاشة تفاصيل المنتج ومعرض الصور
  const AppNetworkImage.detail({
    super.key,
    required this.url,
    this.width,
    this.height = 200.0,
    this.fit = BoxFit.contain,
    this.cacheWidth = 800,
    this.cacheHeight,
    this.borderRadius = 0.0,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return _buildError();
    }

    Widget image = Image.network(
      url.trim(),
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth > 0 ? cacheWidth : null,
      cacheHeight: cacheHeight,
      filterQuality: FilterQuality.low,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.image_outlined,
                size: (height != null && height! < 50) ? 16 : 28,
                color: Colors.grey.withValues(alpha: 0.35),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildError();
      },
    );

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image,
      );
    }
    return image;
  }

  Widget _buildError() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(
            Icons.image_not_supported_outlined,
            size: (height != null && height! < 50) ? 16 : 28,
            color: Colors.grey.shade400,
          ),
        );
  }
}
