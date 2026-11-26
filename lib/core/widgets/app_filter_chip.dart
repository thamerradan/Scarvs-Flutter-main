// شريحة فلترة موحدة لحالات الطلبات والمخزون تدعم الوضعين الفاتح والداكن.
import 'package:flutter/material.dart';
import 'package:scarvs/core/theme/app_colors.dart';

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: isDark ? Colors.white : AppColors.rawSienna,
      labelStyle: TextStyle(
        color: selected
            ? (isDark ? AppColors.mirage : Colors.white)
            : (isDark ? AppColors.creamColor : AppColors.mirage),
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      backgroundColor: isDark ? Colors.white10 : Colors.white,
      onSelected: onSelected,
    );
  }
}

