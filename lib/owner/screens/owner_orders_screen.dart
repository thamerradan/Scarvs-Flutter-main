// تعرض طلبات المتجر وتتيح للمالك متابعة معالجتها.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/order_model.dart';
import 'package:scarvs/providers/owner_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/widgets/app_back_button.dart';
import 'package:scarvs/core/widgets/app_loader.dart';

class OwnerOrdersScreen extends StatefulWidget {
  const OwnerOrdersScreen({Key? key}) : super(key: key);

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen> {
  final List<Map<String, String>> _statusFilters = [
    {'key': 'all', 'label': 'الكل'},
    {'key': 'pending', 'label': 'قيد الانتظار ⏳'},
    {'key': 'preparing', 'label': 'جاري التجهيز 📦'},
    {'key': 'shipped', 'label': 'قيد التوصيل 🚚'},
    {'key': 'delivered', 'label': 'تم التوصيل ✅'},
    {'key': 'cancelled', 'label': 'ملغي ❌'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OwnerNotifier>(context, listen: false)
          .fetchOrders(context: context);
    });
  }

  void _showChangeStatusDialog(BuildContext context, OrderModel order) {
    final ownerNotifier = Provider.of<OwnerNotifier>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'تعديل حالة الطلب #${order.orderNumber}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...[
                {'key': 'pending', 'label': 'قيد الانتظار', 'color': Colors.amber},
                {'key': 'preparing', 'label': 'جاري التجهيز', 'color': Colors.blue},
                {'key': 'shipped', 'label': 'قيد التوصيل', 'color': Colors.purple},
                {'key': 'delivered', 'label': 'تم التوصيل بنجاح', 'color': Colors.green},
                {'key': 'cancelled', 'label': 'إلغاء الطلب', 'color': Colors.red},
              ].map((item) {
                final isCurrent = order.orderStatus == item['key'];
                final color = item['color'] as Color;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isCurrent ? color : Colors.grey.withOpacity(0.2),
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    tileColor: isCurrent ? color.withOpacity(0.08) : null,
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.2),
                      radius: 12,
                      child: isCurrent ? Icon(Icons.check, size: 14, color: color) : null,
                    ),
                    title: Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? color : null,
                      ),
                    ),
                    trailing: isCurrent
                        ? const Text('الحالية', style: TextStyle(fontSize: 12, color: Colors.grey))
                        : null,
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      if (!isCurrent) {
                        await ownerNotifier.updateOrderStatus(
                          order.id,
                          item['key'] as String,
                          context: context,
                        );
                      }
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final ownerNotifier = Provider.of<OwnerNotifier>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: Column(
          children: [
            // الهيدر
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  AppBackButton(
                    themeFlag: themeFlag,
                    fallbackRoute: AppRouter.ownerDashboardRoute,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'إدارة الطلبات 📦',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                    onPressed: () => ownerNotifier.fetchOrders(context: context),
                  ),
                ],
              ),
            ),

            // شريط فلاتر الحالات
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _statusFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _statusFilters[index];
                  final isSelected = ownerNotifier.selectedStatus == filter['key'];

                  return ChoiceChip(
                    label: Text(filter['label']!),
                    selected: isSelected,
                    selectedColor: AppColors.rawSienna,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (themeFlag ? AppColors.creamColor : AppColors.mirage),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    backgroundColor: themeFlag ? Colors.white10 : Colors.white,
                    onSelected: (selected) {
                      if (selected) {
                        ownerNotifier.fetchOrders(
                          statusFilter: filter['key'],
                          context: context,
                        );
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // قائمة الطلبات
            Expanded(
              child: ownerNotifier.isLoading
                  ? AppLoader(themeFlag: themeFlag)
                  : ownerNotifier.orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                                    .withOpacity(0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'لا توجد طلبات في هذا القسم حالياً',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => ownerNotifier.fetchOrders(context: context),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: ownerNotifier.orders.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final order = ownerNotifier.orders[index];
                              return _buildOwnerOrderCard(order, themeFlag);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerOrderCard(OrderModel order, bool themeFlag) {
    final dateStr =
        '${order.createdAt.year}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.day.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: themeFlag ? AppColors.mirage : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeFlag ? Colors.white12 : Colors.black.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.orderNumber}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: order.statusColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: order.statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    order.statusArabic,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: order.statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // بيانات العميل والتوصيل
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: 'العميل',
                  value: order.customerName != null && order.customerName!.isNotEmpty
                      ? '${order.customerName!} (${order.phone})'
                      : (order.phone.isNotEmpty ? '${order.city} - ${order.phone}' : order.city),
                  themeFlag: themeFlag,
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'العنوان',
                  value: order.shippingAddress,
                  themeFlag: themeFlag,
                ),
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildInfoRow(
                    icon: Icons.notes_outlined,
                    label: 'ملاحظات',
                    value: order.notes!,
                    themeFlag: themeFlag,
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.items.length} منتجات في الطلب',
                      style: TextStyle(
                        fontSize: 13,
                        color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                            .withOpacity(0.7),
                      ),
                    ),
                    Text(
                      'الإجمالي: ${order.total.toStringAsFixed(2)} ر.س',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.rawSienna,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // أزرار التحكم بالطلب
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: themeFlag ? AppColors.creamColor : AppColors.mirage,
                      side: BorderSide(
                        color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                            .withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                    label: const Text('تفاصيل الطلب'),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRouter.orderDetailRoute,
                        arguments: order.id,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rawSienna,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.edit_note, size: 20, color: Colors.white),
                    label: const Text(
                      'تعديل الحالة',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _showChangeStatusDialog(context, order),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool themeFlag,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: (themeFlag ? AppColors.creamColor : AppColors.mirage).withOpacity(0.6),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: (themeFlag ? AppColors.creamColor : AppColors.mirage).withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: themeFlag ? AppColors.creamColor : AppColors.mirage,
            ),
          ),
        ),
      ],
    );
  }
}
