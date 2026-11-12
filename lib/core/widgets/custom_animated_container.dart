// يوفر حاوية واجهة مخصصة ذات حركة انتقالية.
import 'package:flutter/material.dart';

/// حاوية متحركة مخصصة مع انتقالات ناعمة وحواف دائرية عصرية
class CustomAnimatedContainer extends StatelessWidget {
  final double height;
  final double width;
  final Color color;
  final Curve curve;
  final Duration duration;
  final BorderRadiusGeometry? borderRadius;
  final Widget? child;

  const CustomAnimatedContainer({
    super.key,
    required this.height,
    required this.width,
    required this.color,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 350),
    this.borderRadius,
    this.child,
  });

  /// دالة مساعدة متوافقة 100% مع الاستدعاءات الحالية
  static Widget customAnimatedContainer({
    required double height,
    required double width,
    required BuildContext context,
    required Color color,
    required Curve curve,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return CustomAnimatedContainer(
      height: height,
      width: width,
      color: color,
      curve: curve,
      duration: duration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(14),
      ),
      curve: curve,
      child: child,
    );
  }
}
