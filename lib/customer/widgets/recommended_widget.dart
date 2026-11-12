// يعرض المنتجات المقترحة في قائمة أفقية.
import 'package:flutter/material.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/customer/screens/shop/product_detail_screen.dart';

Widget productForYou({
  required dynamic snapshot,
  required bool themeFlag,
  required BuildContext context,
}) {
  final List<ProductItem> list = List<ProductItem>.from(snapshot);

  if (list.isEmpty) {
    return Center(
      child: Text(
        'لا توجد منتجات متوفرة حالياً',
        style: TextStyle(
          color: themeFlag ? AppColors.creamColor : AppColors.mirage,
          fontSize: 15,
        ),
      ),
    );
  }

  return ListView.builder(
    physics: const BouncingScrollPhysics(),
    shrinkWrap: true,
    itemCount: list.length,
    scrollDirection: Axis.horizontal,
    itemBuilder: (context, index) {
      final ProductItem prod = list[index];
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.prodDetailRoute,
            arguments: ProductDetailsArgs(
              id: prod.id,
              initialProduct: prod,
            ),
          );
        },
        child: Container(
          width: 175,
          margin: const EdgeInsets.only(left: 12, bottom: 8),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: themeFlag
                    ? Colors.white.withOpacity(0.08)
                    : Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            elevation: 4,
            color: themeFlag ? AppColors.mirage : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: 'prod_${prod.id}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Container(
                          height: 125,
                          width: double.infinity,
                          color: themeFlag
                              ? Colors.black26
                              : Colors.grey.shade100,
                          child: prod.mainImageUrl.isNotEmpty
                              ? Image.network(
                                  prod.mainImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                )
                              : const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                    ),
                    if (prod.hasDiscount)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'خصم ${prod.discountPercentage}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prod.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: themeFlag
                              ? AppColors.creamColor
                              : AppColors.mirage,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${prod.price.toStringAsFixed(0)} ر.س',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.rawSienna,
                            ),
                          ),
                          if (prod.oldPrice != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '${prod.oldPrice!.toStringAsFixed(0)} ر.س',
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 11,
                                color: (themeFlag
                                        ? AppColors.creamColor
                                        : AppColors.mirage)
                                    .withOpacity(0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
