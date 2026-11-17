// بطاقة عرض المنتج بتصميم متجر تنمى المرجعي الأنيق مع الهالة الدائرية خلف المنتج.
import 'package:flutter/material.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/customer/screens/shop/product_detail_screen.dart';
import 'package:scarvs/customer/widgets/title_text.dart';

class EcommerceProductCard extends StatelessWidget {
  final ProductItem product;
  final bool themeFlag;
  final VoidCallback? onFavoriteToggle;
  final bool isLiked;
  final String? heroTag;

  const EcommerceProductCard({
    super.key,
    required this.product,
    required this.themeFlag,
    this.onFavoriteToggle,
    this.isLiked = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = themeFlag ? AppColors.mirage : Colors.white;
    final shadowColor = themeFlag
        ? Colors.black.withOpacity(0.25)
        : const Color(0xfff0f0f0);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(
          color: themeFlag
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRouter.prodDetailRoute,
              arguments: ProductDetailsArgs(
                id: product.id,
                initialProduct: product,
                heroTag: heroTag,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // زر الإعجاب في الركن العلوي
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onFavoriteToggle ?? () {},
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: themeFlag
                            ? Colors.white.withOpacity(0.06)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isLiked ? Colors.redAccent : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),

                // شارة الخصم إن وجدت في الركن المقابل
                if (product.hasDiscount && product.discountPercentage != null)
                  PositionedDirectional(
                    end: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '-${product.discountPercentage}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: 18),
                    // صورة المنتج مع الهالة الدائرية خلفه
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: themeFlag
                                ? Colors.white.withOpacity(0.08)
                                : AppColors.rawSienna.withOpacity(0.08),
                          ),
                          heroTag != null && heroTag!.isNotEmpty
                              ? Hero(
                                  tag: heroTag!,
                                  child: product.mainImageUrl.isNotEmpty
                                      ? Image.network(
                                          product.mainImageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
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
                                )
                              : (product.mainImageUrl.isNotEmpty
                                  ? Image.network(
                                      product.mainImageUrl,
                                      fit: BoxFit.contain,
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
                                    )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // اسم المنتج
                    TitleText(
                      text: product.name,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),

                    // التصنيف
                    if (product.categoryName != null &&
                        product.categoryName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      TitleText(
                        text: product.categoryName!,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: themeFlag
                            ? AppColors.creamColor
                            : AppColors.rawSienna,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 4),

                    // السعر
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TitleText(
                          text: '${product.price.toStringAsFixed(0)} ر.س',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: themeFlag
                              ? AppColors.creamColor
                              : AppColors.mirage,
                        ),
                        if (product.hasDiscount && product.oldPrice != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '${product.oldPrice!.toStringAsFixed(0)} ر.س',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

