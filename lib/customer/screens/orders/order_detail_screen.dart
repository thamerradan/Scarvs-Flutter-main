// يعرض تفاصيل طلب محدد وعناصره وحالته.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_spacing.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/order_model.dart';
import 'package:scarvs/models/order_item_model.dart';
import 'package:scarvs/providers/order_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/widgets/app_back_button.dart';
import 'package:scarvs/core/widgets/app_buttons.dart';
import 'package:scarvs/core/widgets/app_card.dart';
import 'package:scarvs/core/widgets/dimensions_widget.dart';
import 'package:scarvs/core/widgets/app_network_image.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderNotifier>(context, listen: false)
          .fetchOrderDetail(widget.orderId, context: context);
    });
  }

  void _showCancelConfirmation(OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إلغاء الطلب', textAlign: TextAlign.right),
        content: const Text(
          'هل أنت متأكد من رغبتك في إلغاء هذا الطلب؟ سيتم إرجاع المنتجات إلى المخزون.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('تراجع'),
          ),
          AppDangerButton(
            text: 'تأكيد الإلغاء',
            height: 40,
            width: 120,
            onPressed: () async {
              Navigator.of(ctx).pop();
              final orderNotifier =
                  Provider.of<OrderNotifier>(context, listen: false);
              await orderNotifier.cancelOrder(order.id, context: context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final orderNotifier = Provider.of<OrderNotifier>(context);
    final order = orderNotifier.currentOrder;

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: orderNotifier.isLoading || order == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppBackButton(
                          themeFlag: themeFlag,
                          fallbackRoute: AppRouter.ordersRoute,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تفاصيل الطلب: ${order.orderNumber}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: themeFlag
                                  ? AppColors.creamColor
                                  : AppColors.mirage,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    vSizedBox2,

                    // 1. حالة الطلب والمخطط الزمني
                    _buildStatusTimeline(order, themeFlag),

                    vSizedBox2,

                    // 2. قائمة المنتجات المشتراة
                    Text(
                      'المنتجات المطلوبة (${order.items.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    vSizedBox1,
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = order.items[index];
                        return _buildOrderItemTile(item, themeFlag);
                      },
                    ),

                    vSizedBox2,

                    // 3. بيانات الشحن والتوصيل
                    _buildSectionCard(
                      themeFlag: themeFlag,
                      title: 'بيانات التوصيل 📍',
                      children: [
                        _buildInfoRow('المدينة', order.city),
                        _buildInfoRow('العنوان', order.shippingAddress),
                        _buildInfoRow('رقم الهاتف', order.phone),
                        if (order.notes != null && order.notes!.isNotEmpty)
                          _buildInfoRow('ملاحظات', order.notes!),
                      ],
                    ),

                    vSizedBox2,

                    // 4. الدفع والحساب
                    _buildSectionCard(
                      themeFlag: themeFlag,
                      title: 'تفاصيل الدفع والحساب 🧾',
                      children: [
                        _buildInfoRow('طريقة الدفع', order.paymentMethodArabic),
                        _buildInfoRow('حالة الدفع', order.paymentStatusArabic),
                        const Divider(height: 16),
                        _buildInfoRow('المجموع الفرعي',
                            '${order.subtotal.toStringAsFixed(0)} ر.س'),
                        _buildInfoRow(
                          'رسوم التوصيل',
                          order.shippingFee == 0
                              ? 'مجاناً 🎉'
                              : '${order.shippingFee.toStringAsFixed(0)} ر.س',
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'المبلغ الإجمالي',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${order.total.toStringAsFixed(0)} ر.س',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeFlag ? Colors.white : AppColors.rawSienna,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // زر إلغاء الطلب إن كان قيد المراجعة
                    if (order.canCancel) ...[
                      vSizedBox3,
                      AppDangerButton(
                        text: 'إلغاء الطلب',
                        height: 48,
                        onPressed: () => _showCancelConfirmation(order),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatusTimeline(OrderModel order, bool themeFlag) {
    final status = order.orderStatus.toLowerCase();
    final isCancelled = status == 'cancelled';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: order.statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: order.statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(order.statusIcon, color: order.statusColor, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderStatusArabic,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: order.statusColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isCancelled
                        ? 'تم إلغاء هذا الطلب ولن يتم شحنه'
                        : 'طلبك قيد المتابعة مع فريق المتجر',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemTile(OrderItemModel item, bool themeFlag) {
    return AppCard(
      borderRadius: AppSpacing.radiusMd,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          AppNetworkImage.thumbnail(
            url: item.productImage ?? '',
            width: 55,
            height: 55,
            borderRadius: AppSpacing.radiusSm,
          ),
          AppSpacing.gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (item.size != null && item.size!.isNotEmpty)
                      Text(
                        'مقاس: ${item.size}   |   ',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    Text(
                      'الكمية: ${item.quantity}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${item.totalPrice.toStringAsFixed(0)} ر.س',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: themeFlag ? Colors.white : AppColors.rawSienna,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required bool themeFlag,
    required String title,
    required List<Widget> children,
  }) {
    return AppCard(
      borderRadius: AppSpacing.radiusLg,
      padding: AppSpacing.paddingCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.gapH12,
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
