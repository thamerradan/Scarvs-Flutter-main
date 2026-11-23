// يعرض قائمة طلبات المستخدم.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_spacing.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/order_model.dart';
import 'package:scarvs/providers/order_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/core/widgets/app_buttons.dart';
import 'package:scarvs/core/widgets/app_card.dart';
import 'package:scarvs/core/widgets/app_page_header.dart';
import 'package:scarvs/core/widgets/app_state_view.dart';
import 'package:scarvs/core/widgets/app_status_badge.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthGuard.isLoggedIn) {
        Provider.of<OrderNotifier>(context, listen: false)
            .fetchUserOrders(context: context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final orderNotifier = Provider.of<OrderNotifier>(context);

    return SafeArea(
      child: AuthProtected(
        returnRoute: AppRouter.ordersRoute,
        message: 'سجّل دخولك لعرض قائمة طلباتك ومتابعتها',
        child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppPageHeader(
              title: 'طلباتي',
              fallbackRoute: AppRouter.customerHomeRoute,
              actions: [
                AppRefreshButton(
                  onPressed: () =>
                      orderNotifier.fetchUserOrders(context: context),
                  isLoading: orderNotifier.isLoading,
                ),
              ],
            ),
            Expanded(
              child: AppStateView(
                isLoading: orderNotifier.isLoading,
                isEmpty: orderNotifier.orders.isEmpty,
                emptyMessage:
                    'لا توجد لديك طلبات سابقة!\nعند قيامك بطلب أي منتج سيظهر هنا لتتابع حالته',
                emptyIcon: Icons.shopping_bag_outlined,
                onRetry: () => orderNotifier.fetchUserOrders(context: context),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: orderNotifier.orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orderNotifier.orders[index];
                    return _buildOrderCard(
                      context: context,
                      order: order,
                      themeFlag: themeFlag,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildOrderCard({
    required BuildContext context,
    required OrderModel order,
    required bool themeFlag,
  }) {
    final dateStr =
        '${order.createdAt.year}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.day.toString().padLeft(2, '0')}';

    return AppCard(
      borderRadius: AppSpacing.radiusLg,
      padding: AppSpacing.paddingCard,
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRouter.orderDetailRoute,
          arguments: order.id,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              AppStatusBadge(
                text: order.orderStatusArabic,
                color: order.statusColor,
                icon: order.statusIcon,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'تاريخ الطلب: $dateStr',
            style: TextStyle(
              fontSize: 12,
              color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                  .withValues(alpha: 0.6),
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.items.length} قطع في الطلب',
                style: const TextStyle(fontSize: 13),
              ),
              Row(
                children: [
                  Text(
                    'الإجمالي: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: (themeFlag
                              ? AppColors.creamColor
                              : AppColors.mirage)
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '${order.total.toStringAsFixed(0)} ر.س',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeFlag ? Colors.white : AppColors.rawSienna,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_left, size: 20),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
