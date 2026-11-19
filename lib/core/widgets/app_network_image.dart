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
          color: Colors.grey.withValues(alpha: 0.08),
          child: const Icon(
            Icons.image_not_supported_outlined,
            size: 32,
            color: Colors.grey,
          ),
        );
  }
}
