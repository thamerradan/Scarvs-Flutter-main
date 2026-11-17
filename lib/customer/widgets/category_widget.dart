// يعرض المنتجات المرتبطة بتصنيف أو نتائج البحث في شبكة بطاقات متناسقة مع التصميم المرجعي.
import 'package:flutter/material.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/customer/widgets/product_card.dart';

Widget showDataInGrid({
  required dynamic snapshot,
  required bool themeFlag,
  required BuildContext context,
  required double height,
}) {
  final List<ProductItem> list = List<ProductItem>.from(snapshot);

  if (list.isEmpty) {
    return Center(
      child: Text(
        'لا توجد منتجات متوفرة حالياً',
        style: TextStyle(
          color: themeFlag ? AppColors.creamColor : AppColors.mirage,
          fontSize: 16,
        ),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: GridView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final ProductItem prod = list[index];
        return EcommerceProductCard(
          product: prod,
          themeFlag: themeFlag,
          heroTag: 'cat_${prod.id}_$index',
        );
      },
    ),
  );
}
