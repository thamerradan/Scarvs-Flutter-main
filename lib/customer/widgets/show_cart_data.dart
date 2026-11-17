// يعرض عناصر سلة التسوق بتصميم المتجر المرجعي الأنيق مع ملخص الحساب.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/cart_item_model.dart';
import 'package:scarvs/providers/cart_provider.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/customer/widgets/title_text.dart';

Widget showCartData({
  required dynamic snapshot,
  required bool themeFlag,
  required BuildContext context,
  required double height,
}) {
  final cartNotifier = Provider.of<CartNotifier>(context);
  final List<CartItemModel> list = cartNotifier.cartItems;

  return Column(
    children: [
      // شريط الشحن المجاني التفاعلي
      if (cartNotifier.freeShippingLimit > 0)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: cartNotifier.isFreeShipping
                ? Colors.green.withOpacity(0.12)
                : (themeFlag ? Colors.white.withOpacity(0.08) : AppColors.rawSienna.withOpacity(0.08)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: cartNotifier.isFreeShipping
                  ? Colors.green.withOpacity(0.3)
                  : (themeFlag ? Colors.white.withOpacity(0.2) : AppColors.rawSienna.withOpacity(0.2)),
            ),
          ),
          child: Row(
            children: [
              Icon(
                cartNotifier.isFreeShipping
                    ? Icons.local_shipping
                    : Icons.info_outline,
                color: cartNotifier.isFreeShipping
                    ? Colors.green
                    : (themeFlag ? Colors.white : AppColors.rawSienna),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cartNotifier.isFreeShipping
                      ? 'تهانينا! حصلت على توصيل مجاني لطلبك 🚚'
                      : 'أضف منتجات بقيمة ${(cartNotifier.freeShippingLimit - cartNotifier.subtotal).toStringAsFixed(0)} ر.س إضافية للحصول على شحن مجاني!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cartNotifier.isFreeShipping
                        ? Colors.green
                        : (themeFlag ? Colors.white : AppColors.rawSienna),
                  ),
                ),
              ),
            ],
          ),
        ),

      // قائمة عناصر السلة
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          physics: const BouncingScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = list[index];
            return _buildCartItemCard(
              context: context,
              item: item,
              themeFlag: themeFlag,
              cartNotifier: cartNotifier,
            );
          },
        ),
      ),

      // بطاقة ملخص الحساب والإجمالي في الأسفل
      _buildCartSummary(
        context: context,
        themeFlag: themeFlag,
        cartNotifier: cartNotifier,
      ),
    ],
  );
}

Widget _buildCartItemCard({
  required BuildContext context,
  required CartItemModel item,
  required bool themeFlag,
  required CartNotifier cartNotifier,
}) {
  final cardBg = themeFlag ? AppColors.mirage : Colors.white;
  final imgBg = themeFlag ? Colors.white.withOpacity(0.06) : const Color(0xfff5f5f5);

  return Container(
    decoration: BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: !item.isStockSufficient
            ? Colors.redAccent.withOpacity(0.5)
            : (themeFlag ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
      ),
      boxShadow: [
        BoxShadow(
          color: themeFlag ? Colors.black.withOpacity(0.25) : const Color(0xfff0f0f0),
          blurRadius: 10,
          spreadRadius: 1,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    padding: const EdgeInsets.all(12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // صورة المنتج المتراكبة
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: imgBg,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: item.productImage.isNotEmpty
                    ? Image.network(
                        item.productImage,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 30,
                        ),
                      )
                    : const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: 30,
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),

        // التفاصيل والاسم والمقاس والسعر
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleText(
                text: item.productName,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              if (item.productSize.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: themeFlag
                        ? Colors.white.withOpacity(0.12)
                        : AppColors.rawSienna.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'مقاس: ${item.productSize}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: themeFlag ? Colors.white : AppColors.rawSienna,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],

              TitleText(
                text: '${item.productPrice.toStringAsFixed(0)} ر.س',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: themeFlag ? Colors.white : AppColors.rawSienna,
              ),

              if (!item.isStockSufficient)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'المتبقي في المخزون: ${item.stockQuantity} فقط!',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // أزرار التحكم بالكمية وزر الحذف
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _confirmDeleteDialog(context, item, themeFlag),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: themeFlag ? Colors.white.withOpacity(0.08) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: themeFlag ? Colors.white12 : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () =>
                        cartNotifier.decrementQuantity(item, context: context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Icon(Icons.remove_rounded, size: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: TitleText(
                      text: '${item.quantity}',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () =>
                        cartNotifier.incrementQuantity(item, context: context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Icon(Icons.add_rounded, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildCartSummary({
  required BuildContext context,
  required bool themeFlag,
  required CartNotifier cartNotifier,
}) {
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 85),
    decoration: BoxDecoration(
      color: themeFlag ? AppColors.mirage : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 15,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TitleText(
              text: '${cartNotifier.totalItemsCount} عناصر بالسلّة',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: themeFlag ? Colors.white70 : Colors.grey.shade600,
            ),
            TitleText(
              text: '${cartNotifier.subtotal.toStringAsFixed(0)} ر.س',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TitleText(
              text: 'رسوم الشحن والتوصيل',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: themeFlag ? Colors.white70 : Colors.grey.shade600,
            ),
            TitleText(
              text: cartNotifier.actualShippingFee == 0
                  ? 'مجاناً 🎉'
                  : '${cartNotifier.actualShippingFee.toStringAsFixed(0)} ر.س',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: cartNotifier.actualShippingFee == 0
                  ? Colors.green
                  : (themeFlag ? AppColors.creamColor : AppColors.mirage),
            ),
          ],
        ),
        const Divider(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TitleText(
              text: 'الإجمالي النهائي',
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
            TitleText(
              text: '${cartNotifier.total.toStringAsFixed(0)} ر.س',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: themeFlag ? Colors.white : AppColors.rawSienna,
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeFlag ? Colors.white : AppColors.rawSienna,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            onPressed: () {
              AuthGuard.requireAuth(
                context: context,
                returnRoute: AppRouter.checkoutRoute,
                customMessage:
                    'لإتمام الطلب ومتابعة الشراء، يرجى تسجيل الدخول برقم الهاتف',
                onAuthenticated: () {
                  Navigator.of(context).pushNamed(AppRouter.checkoutRoute);
                },
              );
            },
            child: TitleText(
              text: 'متابعة الشراء وإتمام الطلب 🛍️',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: themeFlag ? AppColors.mirage : Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

void _confirmDeleteDialog(
  BuildContext context,
  CartItemModel item,
  bool themeFlag,
) {
  final cartNotifier = Provider.of<CartNotifier>(context, listen: false);

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('حذف من السلة', textAlign: TextAlign.right),
      content: Text(
        'هل أنت متأكد من رغبتك في إزالة "${item.productName}" من سلة المشتريات؟',
        textAlign: TextAlign.right,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            Navigator.of(ctx).pop();
            cartNotifier.deleteCartItem(item.id, context: context);
          },
          child: const Text('حذف', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
