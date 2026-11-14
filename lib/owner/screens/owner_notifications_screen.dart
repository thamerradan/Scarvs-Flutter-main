// تعرض إشعارات المتجر والطلبات الواردة للمالك.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/notification_model.dart';
import 'package:scarvs/providers/notification_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/widgets/app_back_button.dart';
import 'package:scarvs/core/widgets/app_loader.dart';

class OwnerNotificationsScreen extends StatefulWidget {
  const OwnerNotificationsScreen({super.key});

  @override
  State<OwnerNotificationsScreen> createState() => _OwnerNotificationsScreenState();
}

class _OwnerNotificationsScreenState extends State<OwnerNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifNotifier =
          Provider.of<NotificationNotifier>(context, listen: false);
      notifNotifier.fetchNotifications(context: context);
      notifNotifier.initRealtime(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final notifNotifier = Provider.of<NotificationNotifier>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: Column(
          children: [
            // الهيدر
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  AppBackButton(
                    themeFlag: themeFlag,
                    fallbackRoute: AppRouter.ownerDashboardRoute,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'إشعارات المتجر 🔔',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                    ),
                  ),
                  if (notifNotifier.unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${notifNotifier.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (notifNotifier.notifications.isNotEmpty)
                    TextButton(
                      onPressed: () => notifNotifier.markAllAsRead(),
                      child: const Text(
                        'تحديد الكل كمقروء',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            // قائمة الإشعارات
            Expanded(
              child: notifNotifier.isLoading
                  ? AppLoader(themeFlag: themeFlag)
                  : notifNotifier.notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none_outlined,
                                size: 64,
                                color: (themeFlag
                                        ? AppColors.creamColor
                                        : AppColors.mirage)
                                    .withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'لا توجد إشعارات جديدة للمتجر حالياً',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: (themeFlag
                                          ? AppColors.creamColor
                                          : AppColors.mirage)
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'ستظهر هنا إشعارات الطلبات الجديدة وإلغاءات الطلبات فور حدوثها.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: (themeFlag
                                            ? AppColors.creamColor
                                            : AppColors.mirage)
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => notifNotifier.fetchNotifications(
                              context: context),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: notifNotifier.notifications.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final notif = notifNotifier.notifications[index];
                              return _buildNotificationCard(
                                context: context,
                                notif: notif,
                                themeFlag: themeFlag,
                                notifNotifier: notifNotifier,
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required NotificationModel notif,
    required bool themeFlag,
    required NotificationNotifier notifNotifier,
  }) {
    final dateStr =
        '${notif.createdAt.year}/${notif.createdAt.month.toString().padLeft(2, '0')}/${notif.createdAt.day.toString().padLeft(2, '0')} - ${notif.createdAt.hour.toString().padLeft(2, '0')}:${notif.createdAt.minute.toString().padLeft(2, '0')}';

    final isOrderNotification = notif.type == 'order';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (!notif.isRead) {
          notifNotifier.markAsRead(notif.id);
        }
        // الانتقال المباشر لشاشة إدارة طلبات المتجر عند النقر على إشعار طلب
        if (notif.orderId != null && notif.orderId!.isNotEmpty) {
          Navigator.of(context).pushNamed(AppRouter.ownerOrdersRoute);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead
              ? (themeFlag ? AppColors.mirage : Colors.white)
              : (themeFlag
                  ? Colors.white12
                  : AppColors.rawSienna.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead
                ? (themeFlag
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.06))
                : AppColors.rawSienna.withValues(alpha: 0.4),
            width: notif.isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notif.isRead
                    ? (themeFlag
                        ? Colors.white10
                        : Colors.grey.withValues(alpha: 0.12))
                    : AppColors.rawSienna.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOrderNotification
                    ? Icons.shopping_bag_outlined
                    : Icons.notifications_active,
                color: notif.isRead ? Colors.grey : AppColors.rawSienna,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                notif.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: themeFlag
                                ? AppColors.creamColor
                                : AppColors.mirage,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: (themeFlag
                              ? AppColors.creamColor
                              : AppColors.mirage)
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: (themeFlag
                                  ? AppColors.creamColor
                                  : AppColors.mirage)
                              .withValues(alpha: 0.45),
                        ),
                      ),
                      if (notif.orderId != null && notif.orderId!.isNotEmpty)
                        Row(
                          children: const [
                            Text(
                              'عرض الطلبات',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.rawSienna,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.arrow_back_ios_new,
                              size: 10,
                              color: AppColors.rawSienna,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

