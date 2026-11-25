// بطاقة عرض المنتج بتصميم متجر تمنى المرجعي الأنيق مع الهالة الدائرية خلف المنتج.
import 'package:flutter/material.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_spacing.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/customer/screens/shop/product_detail_screen.dart';
import 'package:scarvs/customer/widgets/title_text.dart';
import 'package:scarvs/core/widgets/app_network_image.dart';
import 'package:scarvs/core/widgets/app_card.dart';

class EcommerceProductCard extends StatelessWidget {
  final ProductItem product;
  final bool themeFlag;
  final String? heroTag;

  const EcommerceProductCard({
    super.key,
    required this.product,
    required this.themeFlag,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderRadius: AppSpacing.radiusLg,
      padding: EdgeInsets.zero,
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
            // شارة الخصم إن وجدت في الركن العلوي
            if (product.hasDiscount && product.discountPercentage != null)
              PositionedDirectional(
                end: 0,
                top: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
                AppSpacing.gapH16,
                // صورة المنتج مع الهالة الدائرية خلفه
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: themeFlag
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.rawSienna.withValues(alpha: 0.08),
                      ),
                      heroTag != null && heroTag!.isNotEmpty
                          ? Hero(
                              tag: heroTag!,
                              child: AppNetworkImage.card(
                                url: product.mainImageUrl,
                              ),
                            )
                          : AppNetworkImage.card(
                              url: product.mainImageUrl,
                            ),
                    ],
                  ),
                ),
                AppSpacing.gapH8,

                // اسم المنتج
                TitleText(
                  text: product.name,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),

                // الصنف
                if (product.categoryName != null &&
                    product.categoryName!.isNotEmpty) ...[
                  AppSpacing.gapH4,
                  TitleText(
                    text: product.categoryName!,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        themeFlag ? AppColors.creamColor : AppColors.rawSienna,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                AppSpacing.gapH4,

                // السعر
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TitleText(
                      text: '${product.price.toStringAsFixed(0)} ر.س',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color:
                          themeFlag ? AppColors.creamColor : AppColors.mirage,
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
    );
  }
}
