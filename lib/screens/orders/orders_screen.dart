// يعرض قائمة طلبات المستخدم.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/constants/app_assets.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/order_model.dart';
import 'package:scarvs/providers/order_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/core/widgets/app_back_button.dart';
import 'package:scarvs/core/widgets/app_loader.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  AppBackPop(themeFlag: themeFlag),
                  const SizedBox(width: 8),
                  Text(
                    'طلباتي 📦',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color:
                          themeFlag ? AppColors.creamColor : AppColors.mirage,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () =>
                        orderNotifier.fetchUserOrders(context: context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: orderNotifier.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : orderNotifier.orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              customLoader(
                                context: context,
                                themeFlag: themeFlag,
                                text: '',
                                lottieAsset: AppAssets.nodata,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'لا توجد لديك طلبات سابقة!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: themeFlag
                                      ? AppColors.creamColor
                                      : AppColors.mirage,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'عند قيامك بطلب أي حذاء سيظهر هنا لتتابع حالته',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: (themeFlag
                                          ? AppColors.creamColor
                                          : AppColors.mirage)
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          physics: const BouncingScrollPhysics(),
                          itemCount: orderNotifier.orders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
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

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: themeFlag
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      elevation: 3,
      color: themeFlag ? AppColors.mirage : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.orderDetailRoute,
            arguments: order.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: order.statusColor.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(order.statusIcon,
                            size: 14, color: order.statusColor),
                        const SizedBox(width: 4),
                        Text(
                          order.orderStatusArabic,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: order.statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'تاريخ الطلب: $dateStr',
                style: TextStyle(
                  fontSize: 12,
                  color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                      .withOpacity(0.6),
                ),
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} أحذية في الطلب',
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
                              .withOpacity(0.7),
                        ),
                      ),
                      Text(
                        '${order.total.toStringAsFixed(0)} ر.س',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.rawSienna,
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
        ),
      ),
    );
  }
}
