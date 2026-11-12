// يعرض المنتجات المرتبطة بتصنيف في شبكة بطاقات.
import 'package:flutter/material.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/screens/shop/product_detail_screen.dart';

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
        'لا توجد منتجات في هذا التصنيف حالياً',
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
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final ProductItem prod = list[index];
        return _showProducts(
          context: context,
          prod: prod,
          themeFlag: themeFlag,
          height: height,
        );
      },
    ),
  );
}

Widget _showProducts({
  required BuildContext context,
  required ProductItem prod,
  required bool themeFlag,
  required double height,
}) {
  return Card(
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
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRouter.prodDetailRoute,
          arguments: ProductDetailsArgs(
            id: prod.id,
            initialProduct: prod,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Hero(
              tag: 'prod_${prod.id}',
              child: Container(
                height: height,
                width: double.infinity,
                color: themeFlag ? Colors.black26 : Colors.grey.shade100,
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
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prod.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        themeFlag ? AppColors.creamColor : AppColors.mirage,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${prod.price.toStringAsFixed(0)} ر.س',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.rawSienna,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
