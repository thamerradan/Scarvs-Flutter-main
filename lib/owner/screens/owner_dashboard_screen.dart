// تعرض لوحة تحكم المالك ومؤشرات أداء المتجر.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/providers/auth_provider.dart';
import 'package:scarvs/providers/notification_provider.dart';
import 'package:scarvs/providers/owner_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/widgets/app_loader.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final VoidCallback? onSwitchToStore;
  const OwnerDashboardScreen({Key? key, this.onSwitchToStore}) : super(key: key);

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OwnerNotifier>(context, listen: false)
          .fetchDashboard(context: context);
      final notifNotifier =
          Provider.of<NotificationNotifier>(context, listen: false);
      notifNotifier.fetchNotifications(context: context);
      notifNotifier.initRealtime(context);
    });
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج من لوحة التحكم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'تسجيل خروج',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await Provider.of<AuthenticationNotifier>(context, listen: false)
          .signOut(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final ownerNotifier = Provider.of<OwnerNotifier>(context);
    final stats = ownerNotifier.stats;

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: RefreshIndicator(
          onRefresh: () async {
            await ownerNotifier.fetchDashboard(context: context);
            if (context.mounted) {
              await Provider.of<NotificationNotifier>(context, listen: false)
                  .fetchNotifications(context: context);
            }
          },
          child: Column(
            children: [
              // الهيدر
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'لوحة التحكم ',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: themeFlag
                                        ? AppColors.creamColor
                                        : AppColors.mirage,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.rawSienna,
                        side: const BorderSide(
                            color: AppColors.rawSienna, width: 1.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                      ),
                      icon: const Icon(Icons.storefront_outlined, size: 18),
                      label: const Text(
                        'عرض المتجر',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if (widget.onSwitchToStore != null) {
                          widget.onSwitchToStore!();
                        } else if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRouter.customerHomeRoute,
                            (route) => false,
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                    Consumer<NotificationNotifier>(
                      builder: (context, notifNotifier, _) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined),
                              color: themeFlag
                                  ? AppColors.creamColor
                                  : AppColors.mirage,
                              tooltip: 'إشعارات المتجر',
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  AppRouter.ownerNotificationsRoute,
                                );
                              },
                            ),
                            if (notifNotifier.unreadCount > 0)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: themeFlag
                                          ? AppColors.mirage
                                          : AppColors.creamColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    notifNotifier.unreadCount > 99
                                        ? '99+'
                                        : '${notifNotifier.unreadCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      tooltip: 'تسجيل الخروج',
                      onPressed: () => _confirmSignOut(context),
                    ),
                  ],
                ),
              ),

              // المحتوى الرئيسي
              Expanded(
                child: ownerNotifier.isLoading
                    ? AppLoader(themeFlag: themeFlag)
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildManagementGrid(context, stats, themeFlag),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementGrid(BuildContext context, stats, bool themeFlag) {
    return Column(
      children: [
        _buildMenuActionTile(
          context: context,
          title: 'إدارة الطلبات',
          subtitle:
              '${stats.totalOrders} إجمالي الطلبات (${stats.pendingOrders} جديدة)',
          icon: Icons.local_shipping_outlined,
          badgeCount: stats.pendingOrders,
          color: AppColors.rawSienna,
          themeFlag: themeFlag,
          onTap: () =>
              Navigator.of(context).pushNamed(AppRouter.ownerOrdersRoute),
        ),
        const SizedBox(height: 12),
        _buildMenuActionTile(
          context: context,
          title: 'إدارة المنتجات',
          subtitle: '${stats.totalProducts} منتج مسجل في المتجر',
          icon: Icons.inventory_2_outlined,
          color: AppColors.rawSienna,
          themeFlag: themeFlag,
          onTap: () =>
              Navigator.of(context).pushNamed(AppRouter.ownerProductsRoute),
        ),
        const SizedBox(height: 12),
        _buildMenuActionTile(
          context: context,
          title: 'إدارة المخزون والكميات',
          subtitle: 'مراقبة وتعديل مقاسات الأحذية فورياً',
          icon: Icons.analytics_outlined,
          badgeCount: stats.outOfStockCount > 0 ? stats.outOfStockCount : null,
          color: AppColors.rawSienna,
          themeFlag: themeFlag,
          onTap: () =>
              Navigator.of(context).pushNamed(AppRouter.ownerInventoryRoute),
        ),
        const SizedBox(height: 12),
        _buildMenuActionTile(
          context: context,
          title: 'إدارة التصنيفات',
          subtitle: 'إضافة وتعديل ماركات وأقسام الأحذية',
          icon: Icons.category_outlined,
          color: AppColors.rawSienna,
          themeFlag: themeFlag,
          onTap: () =>
              Navigator.of(context).pushNamed(AppRouter.ownerCategoriesRoute),
        ),
        const SizedBox(height: 12),
        _buildMenuActionTile(
          context: context,
          title: 'إعدادات المتجر والشحن',
          subtitle: 'الاسم، رسوم التوصيل، الشحن المجاني، التواصل',
          icon: Icons.storefront_outlined,
          color: AppColors.rawSienna,
          themeFlag: themeFlag,
          onTap: () =>
              Navigator.of(context).pushNamed(AppRouter.ownerSettingsRoute),
        ),
      ],
    );
  }

  Widget _buildMenuActionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    int? badgeCount,
    required bool themeFlag,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: themeFlag ? AppColors.mirage : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeFlag ? Colors.white10 : Colors.black.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: themeFlag ? AppColors.creamColor : AppColors.mirage,
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                .withOpacity(0.6),
          ),
        ),
        trailing: Icon(
          Icons.chevron_left,
          color: themeFlag ? AppColors.creamColor : AppColors.mirage,
        ),
        onTap: onTap,
      ),
    );
  }
}
