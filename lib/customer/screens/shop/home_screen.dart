// يعرض الصفحة الرئيسية وأقسام اكتشاف المنتجات.
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/providers/catalog_provider.dart';
import 'package:scarvs/providers/notification_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/providers/user_provider.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/customer/screens/cart/cart_screen.dart';
import 'package:scarvs/customer/screens/shop/product_screen.dart';
import 'package:scarvs/customer/screens/profile/profile_screen.dart';
import 'package:scarvs/customer/screens/shop/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CatalogProvider>(context, listen: false).initRealtime();
      if (AuthGuard.isLoggedIn) {
        Provider.of<UserProvider>(context, listen: false)
            .getUserData(context: context);
        final notifNotifier =
            Provider.of<NotificationNotifier>(context, listen: false);
        notifNotifier.fetchNotifications(context: context);
        notifNotifier.initRealtime(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    var themeFlag = themeNotifier.darkTheme;
    final isOwner = AuthGuard.isOwner;

    final navIcons = [
      SalomonBottomBarItem(
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home),
        title: const Text("الرئيسية"),
        selectedColor: AppColors.rawSienna,
      ),
      SalomonBottomBarItem(
        icon: const Icon(Icons.search_outlined),
        activeIcon: const Icon(Icons.search),
        title: const Text("البحث"),
        selectedColor: Colors.orange,
      ),
      if (isOwner)
        SalomonBottomBarItem(
          icon: const Icon(Icons.dashboard_outlined),
          activeIcon: const Icon(Icons.dashboard),
          title: const Text("لوحة التحكم"),
          selectedColor: Colors.deepOrange,
        )
      else
        SalomonBottomBarItem(
          icon: const Icon(EvaIcons.shoppingCartOutline),
          activeIcon: const Icon(EvaIcons.shoppingCart),
          title: const Text("السلة"),
          selectedColor: Colors.teal,
        ),
      SalomonBottomBarItem(
        icon: const Icon(EvaIcons.personOutline),
        activeIcon: const Icon(EvaIcons.person),
        title: const Text("حسابي"),
        selectedColor: Colors.purple,
      ),
    ];

    final currentScreens = [
      const ProductScreen(),
      const SearchScreen(),
      if (isOwner)
        const SizedBox.shrink()
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
      canPop: !isOwner,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (isOwner) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacementNamed(AppRouter.ownerDashboardRoute);
          }
        }
      },
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: currentScreens[_currentIndex],
        bottomNavigationBar: SalomonBottomBar(
          selectedItemColor:
              themeFlag ? AppColors.rawSienna : const Color(0xff4B7191),
          unselectedItemColor:
              themeFlag ? Colors.white70 : const Color(0xff777777),
          currentIndex: _currentIndex,
          onTap: (i) {
            if (isOwner && i == 2) {
              Navigator.of(context).pushNamed(AppRouter.ownerDashboardRoute);
              return;
            }
            setState(() => _currentIndex = i);
          },
          items: navIcons,
        ),
      ),
    );
  }
}
