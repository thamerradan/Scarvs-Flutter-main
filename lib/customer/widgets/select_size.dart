// يعرض خيارات مقاسات المنتج ويحدّث المقاس المختار.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/models/product_variant_model.dart';
import 'package:scarvs/providers/size_provider.dart';

Widget selectSize({
  required bool themeFlag,
  required BuildContext context,
  required List<ProductVariant> variants,
}) {
  final sizeNotifier = Provider.of<SizeNotifier>(context);

  if (variants.isEmpty) {
    return const SizedBox.shrink();
  }

  return ListView.builder(
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(),
    itemCount: variants.length,
    itemBuilder: (context, index) {
      final v = variants[index];
      final isSelected = sizeNotifier.size == v.size;
      final isAvailable = v.inStock;

      return GestureDetector(
        onTap: isAvailable ? () => sizeNotifier.selectVariant(v) : null,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: !isAvailable
                ? Colors.grey.withOpacity(0.2)
                : isSelected
                    ? AppColors.rawSienna
                    : (themeFlag ? Colors.white10 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.rawSienna
                  : (isAvailable ? Colors.grey.shade300 : Colors.grey.shade400),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'مقاس ${v.size}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  decoration: isAvailable
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                  color: !isAvailable
                      ? Colors.grey
                      : isSelected
                          ? Colors.white
                          : (themeFlag
                              ? AppColors.creamColor
                              : AppColors.mirage),
                ),
              ),
              if (!isAvailable)
                const Text(
                  'نفد',
                  style: TextStyle(fontSize: 9, color: Colors.red),
                ),
            ],
          ),
        ),
      );
    },
  );
}
