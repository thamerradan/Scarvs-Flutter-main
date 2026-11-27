// تعرض طلبات المتجر وتتيح للمالك متابعة معالجتها.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_spacing.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/order_model.dart';
import 'package:scarvs/providers/owner_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/widgets/app_buttons.dart';
import 'package:scarvs/core/widgets/app_card.dart';
import 'package:scarvs/core/widgets/app_filter_chip.dart';
import 'package:scarvs/core/widgets/app_info_row.dart';
import 'package:scarvs/core/widgets/app_page_header.dart';
import 'package:scarvs/core/widgets/app_state_view.dart';
import 'package:scarvs/core/widgets/app_status_badge.dart';

class OwnerOrdersScreen extends StatefulWidget {
  const OwnerOrdersScreen({super.key});

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen> {
  final List<Map<String, String>> _statusFilters = [
    {'key': 'all', 'label': 'الكل'},
    {'key': 'pending', 'label': 'قيد الانتظار'},
    {'key': 'preparing', 'label': 'جاري التجهيز'},
    {'key': 'shipped', 'label': 'قيد التوصيل'},
    {'key': 'delivered', 'label': 'تم التوصيل'},
    {'key': 'cancelled', 'label': 'ملغي'},
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
            child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              AppSpacing.gapH16,
              ...[
                {
                  'key': 'pending',
                  'label': 'قيد الانتظار',
                  'color': Colors.amber
                },
                {
                  'key': 'preparing',
                  'label': 'جاري التجهيز',
                  'color': Colors.blue
                },
                {
                  'key': 'shipped',
                  'label': 'قيد التوصيل',
                  'color': Colors.purple
                },
                {
                  'key': 'delivered',
                  'label': 'تم التوصيل بنجاح',
                  'color': Colors.green
                },
                {
                  'key': 'cancelled',
                  'label': 'إلغاء الطلب',
                  'color': Colors.red
                },
              ].map((item) {
                final isCurrent = order.orderStatus == item['key'];
                final color = item['color'] as Color;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isCurrent
                            ? color
                            : Colors.grey.withValues(alpha: 0.2),
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    tileColor: isCurrent ? color.withValues(alpha: 0.08) : null,
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.2),
                      radius: 12,
                      child: isCurrent
                          ? Icon(Icons.check, size: 14, color: color)
                          : null,
                    ),
                    title: Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? color : null,
                      ),
                    ),
                    trailing: isCurrent
                        ? const Text('الحالية',
                            style: TextStyle(fontSize: 12, color: Colors.grey))
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
              }),
            ],
          ),
        ));
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
            // شريط العنوان الموحد
            AppPageHeader(
              title: 'إدارة الطلبات',
              actions: [
                AppRefreshButton(
                  onPressed: () => ownerNotifier.fetchOrders(context: context),
                  isLoading: ownerNotifier.isOrdersLoading,
                ),
              ],
            ),

            // شريط فلاتر الحالات
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _statusFilters.length,
                separatorBuilder: (_, __) => AppSpacing.gapW8,
                itemBuilder: (context, index) {
                  final filter = _statusFilters[index];
                  final isSelected =
                      ownerNotifier.selectedStatus == filter['key'];

                  return AppFilterChip(
                    label: filter['label']!,
                    selected: isSelected,
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
            AppSpacing.gapH8,

            // قائمة الطلبات بحالات التحميل الموحدة
            Expanded(
              child: AppStateView(
                isLoading: ownerNotifier.isOrdersLoading,
                hasError: ownerNotifier.ordersError != null &&
                    ownerNotifier.orders.isEmpty,
                errorMessage: ownerNotifier.ordersError,
                isEmpty: ownerNotifier.orders.isEmpty,
                emptyMessage: 'لا توجد طلبات في هذا القسم حالياً',
                emptyIcon: Icons.inbox_outlined,
                onRetry: () => ownerNotifier.fetchOrders(context: context),
                child: RefreshIndicator(
                  onRefresh: () => ownerNotifier.fetchOrders(context: context),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: ownerNotifier.orders.length,
                    separatorBuilder: (_, __) => AppSpacing.gapH12,
                    itemBuilder: (context, index) {
                      final order = ownerNotifier.orders[index];
                      return _buildOwnerOrderCard(order, themeFlag);
                    },
                  ),
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

    return AppCard(
      borderRadius: AppSpacing.radiusLg,
      padding: EdgeInsets.zero,
      hasShadow: false,
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
                        color:
                            themeFlag ? AppColors.creamColor : AppColors.mirage,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: (themeFlag
                                ? AppColors.creamColor
                                : AppColors.mirage)
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                AppStatusBadge(
                  text: order.statusArabic,
                  color: order.statusColor,
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
                AppInfoRow(
                  icon: Icons.person_outline,
                  label: 'العميل',
                  value: order.customerName != null &&
                          order.customerName!.isNotEmpty
                      ? '${order.customerName!} (${order.phone})'
                      : (order.phone.isNotEmpty
                          ? '${order.city} - ${order.phone}'
                          : order.city),
                ),
                const SizedBox(height: 6),
                AppInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'العنوان',
                  value: order.shippingAddress,
                ),
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  AppInfoRow(
                    icon: Icons.notes_outlined,
                    label: 'ملاحظات',
                    value: order.notes!,
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
                        color: (themeFlag
                                ? AppColors.creamColor
                                : AppColors.mirage)
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      'الإجمالي: ${order.total.toStringAsFixed(2)} ر.س',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeFlag ? Colors.white : AppColors.rawSienna,
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
            padding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: AppOutlinedButton(
                    text: 'تفاصيل الطلب',
                    height: 40,
                    fontSize: 13,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    icon: Icons.remove_red_eye_outlined,
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRouter.orderDetailRoute,
                        arguments: order.id,
                      );
                    },
                  ),
                ),
                AppSpacing.gapW8,
                Expanded(
                  child: AppPrimaryButton(
                    text: 'تعديل الحالة',
                    height: 40,
                    fontSize: 13,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    icon: Icons.edit_note,
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
}
