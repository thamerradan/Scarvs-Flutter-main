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
  const OwnerDashboardScreen({Key? key}) : super(key: key);

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
                                  'لوحة تحكم المتجر',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.rawSienna.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '👑 المالك',
                                  style: TextStyle(
                                    color: AppColors.rawSienna,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'نظرة عامة وإدارة العمليات',
                            style: TextStyle(
                              fontSize: 12,
                              color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                                  .withOpacity(0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.rawSienna,
                        side: const BorderSide(color: AppColors.rawSienna, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      icon: const Icon(Icons.storefront_outlined, size: 18),
                      label: const Text(
                        'عرض المتجر',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRouter.customerHomeRoute);
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. بطاقات الإيرادات والمبيعات الكبرى
                            _buildRevenueBanner(stats, themeFlag),
                            const SizedBox(height: 16),

                            // 2. شبكة الإحصائيات السريعة
                            _buildStatsGrid(stats, themeFlag),
                            const SizedBox(height: 24),

                            // 3. أقسام إدارة المتجر (Quick Menu)
                            Text(
                              'أقسام الإدارة والتحكم',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildManagementGrid(context, stats, themeFlag),
                            const SizedBox(height: 24),
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

  Widget _buildRevenueBanner(stats, bool themeFlag) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.rawSienna,
            AppColors.rawSienna.withOpacity(0.8),
            const Color(0xffD97D3E),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.rawSienna.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'إجمالي الإيرادات المكتملة 💰',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.trending_up, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${stats.totalSales.toStringAsFixed(2)} ر.س',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSmallSalesMetric('مبيعات اليوم', '${stats.todaySales.toStringAsFixed(0)} ر.س'),
                Container(width: 1, height: 28, color: Colors.white24),
                _buildSmallSalesMetric('مبيعات الشهر', '${stats.monthSales.toStringAsFixed(0)} ر.س'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallSalesMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(stats, bool themeFlag) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'طلبات جديدة',
            value: '${stats.pendingOrders}',
            subtitle: 'بانتظار التأكيد',
            icon: Icons.hourglass_top,
            iconColor: Colors.amber[700]!,
            bgColor: Colors.amber.withOpacity(0.12),
            themeFlag: themeFlag,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _buildMetricCard(
            title: 'المخزون المنخفض',
            value: '${stats.lowStockCount + stats.outOfStockCount}',
            subtitle: '${stats.outOfStockCount} نفذ تماماً',
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.redAccent,
            bgColor: Colors.red.withOpacity(0.12),
            themeFlag: themeFlag,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required bool themeFlag,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeFlag ? AppColors.mirage : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeFlag ? Colors.white10 : Colors.black.withOpacity(0.06),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: (themeFlag ? AppColors.creamColor : AppColors.mirage).withOpacity(0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeFlag ? AppColors.creamColor : AppColors.mirage,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: iconColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementGrid(BuildContext context, stats, bool themeFlag) {
    return Column(
      children: [
        _buildMenuActionTile(
          context: context,
          title: 'عرض وتصفح المتجر 🛍️',
          subtitle: 'معاينة واجهة العميل والمنتجات والأقسام كما تظهر للزبائن',
          icon: Icons.storefront_outlined,
          color: Colors.indigo,
          themeFlag: themeFlag,
          onTap: () => Navigator.of(context).pushNamed(AppRouter.customerHomeRoute),
        ),
        const SizedBox(height: 12),
        _buildMenuActionTile(
          context: context,
          title: 'إدارة الطلبات',
          subtitle: '${stats.totalOrders} إجمالي الطلبات (${stats.pendingOrders} جديدة)',
          icon: Icons.local_shipping_outlined,
          badgeCount: stats.pendingOrders,
          color: Colors.blue,
          themeFlag: themeFlag,
          onTap: () => Navigator.of(context).pushNamed(AppRouter.ownerOrdersRoute),
        ),
        const SizedBox(height: 12),
        _buildMenuActionTile(
          context: context,
          title: 'إدارة المنتجات',
          subtitle: '${stats.totalProducts} منتج مسجل في المتجر',
          icon: Icons.inventory_2_outlined,
          color: Colors.teal,
          themeFlag: themeFlag,
          onTap: () => Navigator.of(context).pushNamed(AppRouter.ownerProductsRoute),
        ),
        const SizedBox(height: 12),
        _buildMenuActionTile(
          context: context,
          title: 'إدارة المخزون والكميات',
          subtitle: 'مراقبة وتعديل مقاسات الأحذية فورياً',
          icon: Icons.analytics_outlined,
          badgeCount: stats.outOfStockCount > 0 ? stats.outOfStockCount : null,
          color: Colors.deepOrange,
          themeFlag: themeFlag,
          onTap: () => Navigator.of(context).pushNamed(AppRouter.ownerInventoryRoute),
        ),
        const SizedBox(height: 12),
        _buildMenuActionTile(
          context: context,
          title: 'إدارة التصنيفات',
          subtitle: 'إضافة وتعديل ماركات وأقسام الأحذية',
          icon: Icons.category_outlined,
          color: Colors.purple,
          themeFlag: themeFlag,
          onTap: () => Navigator.of(context).pushNamed(AppRouter.ownerCategoriesRoute),
        ),
        const SizedBox(height: 12),
        _buildMenuActionTile(
          context: context,
          title: 'إعدادات المتجر والشحن',
          subtitle: 'الاسم، رسوم التوصيل، الشحن المجاني، التواصل',
          icon: Icons.storefront_outlined,
          color: Colors.brown,
          themeFlag: themeFlag,
          onTap: () => Navigator.of(context).pushNamed(AppRouter.ownerSettingsRoute),
        ),
        const SizedBox(height: 12),
        Consumer<NotificationNotifier>(
          builder: (context, notifNotifier, _) {
            return _buildMenuActionTile(
              context: context,
              title: 'إشعارات وتنبيهات المتجر',
              subtitle: notifNotifier.unreadCount > 0
                  ? '${notifNotifier.unreadCount} إشعار جديد بانتظار المتابعة'
                  : 'تنبيهات الطلبات الجديدة وتحديثات الشحنات',
              icon: Icons.notifications_active_outlined,
              badgeCount: notifNotifier.unreadCount > 0
                  ? notifNotifier.unreadCount
                  : null,
              color: Colors.amber.shade800,
              themeFlag: themeFlag,
              onTap: () => Navigator.of(context).pushNamed(
                AppRouter.ownerNotificationsRoute,
              ),
            );
          },
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
            color: (themeFlag ? AppColors.creamColor : AppColors.mirage).withOpacity(0.6),
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
