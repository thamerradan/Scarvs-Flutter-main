// شريحة تصنيف أفقية مطابقة لتصميم المتجر المرجعي.
import 'package:flutter/material.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/customer/widgets/title_text.dart';
import 'package:scarvs/core/widgets/app_network_image.dart';

class CategoryChipItem {
  final String? id;
  final String name;
  final String? imageUrl;
  final IconData? icon;

  const CategoryChipItem({
    this.id,
    required this.name,
    this.imageUrl,
    this.icon,
  });
}

class EcommerceCategoryChip extends StatelessWidget {
  final CategoryChipItem model;
  final bool isSelected;
  final ValueChanged<CategoryChipItem> onSelected;
  final bool themeFlag;

  const EcommerceCategoryChip({
    super.key,
    required this.model,
    required this.isSelected,
    required this.onSelected,
    required this.themeFlag,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveBorder = themeFlag
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.grey.shade300;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSelected(model),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? (themeFlag ? Colors.white : AppColors.rawSienna)
                  : (themeFlag ? Colors.white.withValues(alpha: 0.04) : Colors.transparent),
              border: Border.all(
                color: isSelected
                    ? (themeFlag ? Colors.white : AppColors.rawSienna)
                    : inactiveBorder,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (themeFlag ? Colors.white : AppColors.rawSienna)
                            .withValues(alpha: themeFlag ? 0.25 : 0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (model.imageUrl != null && model.imageUrl!.isNotEmpty) ...[
                  AppNetworkImage(
                    url: model.imageUrl!,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    borderRadius: 6,
                    cacheWidth: 80,
                    errorWidget: Icon(
                      model.icon ?? Icons.category_outlined,
                      size: 20,
                      color: isSelected
                          ? (themeFlag ? AppColors.mirage : Colors.white)
                          : (themeFlag ? Colors.white70 : Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else if (model.icon != null) ...[
                  Icon(
                    model.icon,
                    size: 20,
                    color: isSelected
                        ? (themeFlag ? AppColors.mirage : Colors.white)
                        : (themeFlag ? Colors.white70 : Colors.grey.shade600),
                  ),
                  const SizedBox(width: 8),
                ],
                TitleText(
                  text: model.name,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (themeFlag ? AppColors.mirage : Colors.white)
                      : (themeFlag ? AppColors.creamColor : AppColors.mirage),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

