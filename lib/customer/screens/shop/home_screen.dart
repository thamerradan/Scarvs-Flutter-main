// يعرض الصفحة الرئيسية وأقسام اكتشاف المنتجات مع شريط التنقل السفلي المنحني.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/providers/cart_provider.dart';
import 'package:scarvs/providers/notification_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/providers/user_provider.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/customer/screens/cart/cart_screen.dart';
import 'package:scarvs/customer/screens/shop/product_screen.dart';
import 'package:scarvs/customer/screens/profile/profile_screen.dart';
import 'package:scarvs/customer/screens/shop/search_screen.dart';
import 'package:scarvs/customer/widgets/custom_bottom_nav_bar.dart';
import 'package:scarvs/owner/screens/owner_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthGuard.isLoggedIn) {
        Provider.of<UserProvider>(context, listen: false)
            .loadIfNeeded(context: context);
        // تحميل الإشعارات والسلة مخصص للعميل فقط، فالمالك يديرها في لوحة التحكم
        if (!AuthGuard.isOwner) {
          final notifNotifier =
              Provider.of<NotificationNotifier>(context, listen: false);
          notifNotifier.fetchUnreadCountOnly();
          notifNotifier.initRealtime(context);
          Provider.of<CartNotifier>(context, listen: false)
              .loadIfNeeded(context: context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final isOwner = AuthGuard.isOwner;
    final cartNotifier = Provider.of<CartNotifier>(context);

    final navItems = [
      const NavItemData(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: "الرئيسية",
      ),
      const NavItemData(
        icon: Icons.search_rounded,
        activeIcon: Icons.search_rounded,
        label: "البحث",
      ),
      if (isOwner)
        const NavItemData(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard_rounded,
          label: "لوحة التحكم",
        )
      else
        NavItemData(
          icon: Icons.shopping_bag_outlined,
          activeIcon: Icons.shopping_bag_rounded,
          label: "السلة",
          badgeCount: cartNotifier.totalItemsCount,
        ),
      const NavItemData(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: "حسابي",
      ),
    ];

    final currentScreens = [
      const ProductScreen(),
      const SearchScreen(),
      if (isOwner)
        OwnerDashboardScreen(
          onSwitchToStore: () => setState(() => _currentIndex = 0),
        )
      else
        AuthProtected(
          returnRoute: AppRouter.cartRoute,
          message: 'سجّل دخولك لعرض سلة المشتريات ومتابعة التسوق',
          child: const CartScreen(),
        ),
      AuthProtected(
        returnRoute: AppRouter.profileRoute,
        message: 'سجّل دخولك لعرض ملفك الشخصي وإدارة طلباتك',
        child: const ProfileScreen(),
      ),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor:
            themeFlag ? AppColors.mirage : const Color(0xfffbfbfb),
        body: Stack(
          children: [
            currentScreens[_currentIndex],
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: EcommerceBottomNavigationBar(
                selectedIndex: _currentIndex,
                themeFlag: themeFlag,
                items: navItems,
                onItemSelected: (i) {
                  setState(() => _currentIndex = i);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
