// يعرض المنتجات في شبكة بطاقات مع روابط إلى تفاصيلها.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/cart_item_model.dart';
import 'package:scarvs/providers/cart_provider.dart';
import 'package:scarvs/core/utils/auth_guard.dart';

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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: cartNotifier.isFreeShipping
                ? Colors.green.withOpacity(0.12)
                : AppColors.rawSienna.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cartNotifier.isFreeShipping
                  ? Colors.green.withOpacity(0.3)
                  : AppColors.rawSienna.withOpacity(0.2),
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
                    : AppColors.rawSienna,
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
                        : AppColors.rawSienna,
                  ),
                ),
              ),
            ],
          ),
        ),

      // قائمة عناصر السلة
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: !item.isStockSufficient
            ? Colors.red.withOpacity(0.5)
            : themeFlag
                ? Colors.white.withOpacity(0.08)
                : Colors.grey.withOpacity(0.15),
        width: 1,
      ),
    ),
    elevation: 3,
    color: themeFlag ? AppColors.mirage : Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // صورة الحذاء
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: themeFlag ? Colors.black26 : Colors.grey.shade100,
              child: item.productImage.isNotEmpty
                  ? Image.network(
                      item.productImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // التفاصيل والاسم والمقاس
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item.productSize.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.rawSienna.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'مقاس: ${item.productSize}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.rawSienna,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  '${item.productPrice.toStringAsFixed(0)} ر.س',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.rawSienna,
                  ),
                ),
                if (!item.isStockSufficient)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'المتبقي في المخزون: ${item.stockQuantity} فقط!',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // أزرار التحكم بالكمية وحذف العنصر
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _confirmDeleteDialog(context, item, themeFlag),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: themeFlag ? Colors.white12 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () =>
                          cartNotifier.decrementQuantity(item, context: context),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(Icons.remove, size: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          cartNotifier.incrementQuantity(item, context: context),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(Icons.add, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildCartSummary({
  required BuildContext context,
  required bool themeFlag,
  required CartNotifier cartNotifier,
}) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: themeFlag ? Colors.black26 : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع الفرعي',
                style: TextStyle(
                  fontSize: 14,
                  color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                      .withOpacity(0.7),
                ),
              ),
              Text(
                '${cartNotifier.subtotal.toStringAsFixed(0)} ر.س',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'رسوم التوصيل',
                style: TextStyle(
                  fontSize: 14,
                  color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                      .withOpacity(0.7),
                ),
              ),
              Text(
                cartNotifier.actualShippingFee == 0
                    ? 'مجاناً 🎉'
                    : '${cartNotifier.actualShippingFee.toStringAsFixed(0)} ر.س',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: cartNotifier.actualShippingFee == 0
                      ? Colors.green
                      : null,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الإجمالي النهائي',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${cartNotifier.total.toStringAsFixed(0)} ر.س',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.rawSienna,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rawSienna,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
              ),
              onPressed: () {
                AuthGuard.requireAuth(
                  context: context,
                  returnRoute: AppRouter.checkoutRoute,
                  customMessage: 'لإتمام الطلب ومتابعة الشراء، يرجى تسجيل الدخول برقم الهاتف',
                  onAuthenticated: () {
                    Navigator.of(context).pushNamed(AppRouter.checkoutRoute);
                  },
                );
              },
              child: const Text(
                'متابعة الشراء وإتمام الطلب 🛍️',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
