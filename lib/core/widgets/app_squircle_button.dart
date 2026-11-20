// زر أيقونة بتصميم Squircle ناعم متناسق مع هوية التطبيق وثيماته.
import 'package:flutter/material.dart';
import 'package:scarvs/core/theme/app_colors.dart';

class AppSquircleButton extends StatelessWidget {
  final IconData icon;
  final bool themeFlag;
  final VoidCallback onTap;
  final Color? color;
  final Widget? badge;
  final String? tooltip;
  final bool isOutLine;
  final double size;

  const AppSquircleButton({
    Key? key,
    required this.icon,
    required this.themeFlag,
    required this.onTap,
    this.color,
    this.badge,
    this.tooltip,
    this.isOutLine = false,
    this.size = 42,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultColor = themeFlag ? AppColors.creamColor : AppColors.mirage;
    final bgColor = isOutLine
        ? Colors.transparent
        : (themeFlag ? Colors.white.withOpacity(0.08) : Colors.white);

    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: isOutLine
                ? Border.all(
                    color: themeFlag ? Colors.white24 : Colors.grey.shade400,
                    width: 1.2,
                  )
                : null,
            color: bgColor,
            boxShadow: isOutLine
                ? null
                : [
                    BoxShadow(
                      color: themeFlag
                          ? Colors.black.withOpacity(0.25)
                          : const Color(0xfff0f0f0),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(icon, color: color ?? defaultColor, size: 22),
              if (badge != null) badge!,
            ],
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

