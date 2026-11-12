// يعرف مسارات التنقل وينشئ الشاشات المرتبطة بها.
// ignore_for_file: body_might_complete_normally_nullable

import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/customer/screens/cart/cart_screen.dart';
import 'package:scarvs/customer/screens/shop/category_screen.dart';
import 'package:scarvs/customer/screens/checkout/checkout_screen.dart';
import 'package:scarvs/customer/screens/shop/home_screen.dart';
import 'package:scarvs/customer/screens/notifications/notifications_screen.dart';
import 'package:scarvs/customer/screens/startup/onboarding_screen.dart';
import 'package:scarvs/customer/screens/orders/order_detail_screen.dart';
import 'package:scarvs/customer/screens/orders/orders_screen.dart';
import 'package:scarvs/owner/screens/owner_categories_screen.dart';
import 'package:scarvs/owner/screens/owner_dashboard_screen.dart';
import 'package:scarvs/owner/screens/owner_inventory_screen.dart';
import 'package:scarvs/owner/screens/owner_orders_screen.dart';
import 'package:scarvs/owner/screens/owner_product_form_screen.dart';
import 'package:scarvs/owner/screens/owner_products_screen.dart';
import 'package:scarvs/owner/screens/owner_settings_screen.dart';
import 'package:scarvs/owner/screens/owner_notifications_screen.dart';
import 'package:scarvs/customer/screens/auth/phone_auth_screen.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/customer/screens/shop/product_detail_screen.dart';
import 'package:scarvs/customer/screens/shop/product_screen.dart';
import 'package:scarvs/customer/screens/profile/account_information_screen.dart';
import 'package:scarvs/customer/screens/profile/settings_screen.dart';
import 'package:scarvs/customer/screens/profile/edit_profile_screen.dart';
import 'package:scarvs/customer/screens/profile/profile_screen.dart';
import 'package:scarvs/customer/screens/shop/search_screen.dart';
import 'package:scarvs/customer/screens/startup/splash_screen.dart';

class AppRouter {
  // مسارات العميل (Customer Routes)
  static const String customerHomeRoute = "/customer/home";
  static const String homeRoute = customerHomeRoute;
  static const String splashRoute = "/customer/splash";
  static const String onBoardRoute = "/customer/onBoard";
  static const String productRoute = "/customer/product";
  static const String appSettingsRoute = "/customer/appSettings";
  static const String cartRoute = "/customer/cart";
  static const String searchRoute = "/customer/search";
  static const String profileRoute = "/customer/profile";
  static const String accountInfo = "/customer/accountInfo";
  static const String categoryRoute = "/customer/category";
  static const String prodDetailRoute = "/customer/productDetail";
  static const String editProfileRoute = "/customer/editProfile";
  static const String checkoutRoute = "/customer/checkout";
  static const String ordersRoute = "/customer/orders";
  static const String orderDetailRoute = "/customer/orderDetail";
  static const String notificationsRoute = "/customer/notifications";
  static const String phoneAuthRoute = "/customer/phoneAuth";

  // مسارات المالك (Owner Routes)
  static const String ownerDashboardRoute = "/owner/dashboard";
  static const String ownerOrdersRoute = "/owner/orders";
  static const String ownerProductsRoute = "/owner/products";
  static const String ownerProductFormRoute = "/owner/productForm";
  static const String ownerInventoryRoute = "/owner/inventory";
  static const String ownerCategoriesRoute = "/owner/categories";
  static const String ownerSettingsRoute = "/owner/settings";
  static const String ownerNotificationsRoute = "/owner/notifications";

  static Route? generateRoute(RouteSettings settings) {
    final route = settings.name ?? '';
    final userRole = AuthGuard.currentUserRole;

    // 1. حماية مسارات الإدارة (Owner):
    // إذا لم يكن المستخدم مالكاً وحاول الوصول لأي مسار إدارة، يُعاد توجيهه مباشرة للرئيسية دون شاشة access_denied
    if (route.startsWith('/owner') && userRole != 'owner') {
      return MaterialPageRoute(
        builder: (_) => const HomeScreen(),
        settings: settings,
      );
    }

    // 2. حماية مسارات المتجر من المالك:
    // إذا كان المستخدم مالكاً وحاول فتح مسار عميل (متجر، سلة، شراء، حساب...)،
    // يُعاد توجيهه تلقائياً إلى لوحة الإدارة، باستثناء شاشات البدء والمصادقة
    final isCustomerRoute = route.startsWith('/customer') ||
        const [
          "/home",
          "/onBoard",
          "/product",
          "/appSettings",
          "/cart",
          "/search",
          "/profile",
          "/accountInfo",
          "/category",
          "/productDetail",
          "/editProfile",
          "/checkout",
          "/orders",
          "/orderDetail",
          "/notifications",
        ].contains(route);

    if (userRole == 'owner' &&
        isCustomerRoute &&
        route != splashRoute &&
        route != "/splash" &&
        route != phoneAuthRoute &&
        route != "/phoneAuth") {
      return MaterialPageRoute(
        builder: (_) => const OwnerDashboardScreen(),
        settings: settings,
      );
    }

    switch (settings.name) {
      case editProfileRoute:
      case "/editProfile":
        {
          return MaterialPageRoute(
            builder: (_) => EditProfileScreen(),
          );
        }
      case appSettingsRoute:
      case "/appSettings":
        {
          return MaterialPageRoute(
            builder: (_) => const SettingsScreen(),
          );
        }
      case homeRoute:
      case "/home":
        {
          return MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          );
        }
      case splashRoute:
      case "/splash":
        {
          return ConcentricPageRoute(
            fullscreenDialog: true,
            builder: (_) => const SplashScreen(),
          );
        }
      case onBoardRoute:
      case "/onBoard":
        {
          return MaterialPageRoute(
            builder: (_) => OnBoardingScreen(),
          );
        }
      case productRoute:
      case "/product":
        {
          return MaterialPageRoute(
            builder: (_) => const ProductScreen(),
          );
        }
      case prodDetailRoute:
      case "/productDetail":
        {
          return MaterialPageRoute(
            builder: (context) => ProductDetail(
              productDetailsArguements: ModalRoute.of(context)!
                  .settings
                  .arguments as ProductDetailsArgs,
            ),
            settings: settings,
          );
        }
      case cartRoute:
      case "/cart":
        {
          return MaterialPageRoute(
            builder: (_) => const CartScreen(),
          );
        }
      case searchRoute:
      case "/search":
        {
          return MaterialPageRoute(
            builder: (_) => const SearchScreen(),
          );
        }
      case profileRoute:
      case "/profile":
        {
          return MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
          );
        }
      case categoryRoute:
      case "/category":
        {
          return MaterialPageRoute(
            builder: (context) => CategoryScreen(
              categoryScreenArgs: ModalRoute.of(context)!.settings.arguments
                  as CategoryScreenArgs,
            ),
            settings: settings,
          );
        }
      case accountInfo:
      case "/accountInfo":
        {
          return MaterialPageRoute(
            builder: (_) => const AccountInformationScreen(),
          );
        }
      case checkoutRoute:
      case "/checkout":
        {
          return MaterialPageRoute(
            builder: (_) => const CheckoutScreen(),
          );
        }
      case ordersRoute:
      case "/orders":
        {
          return MaterialPageRoute(
            builder: (_) => const OrdersScreen(),
          );
        }
      case orderDetailRoute:
      case "/orderDetail":
        {
          final orderId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: orderId),
            settings: settings,
          );
        }
      case ownerDashboardRoute:
      case "/ownerDashboard":
        {
          return MaterialPageRoute(
            builder: (_) => const OwnerDashboardScreen(),
          );
        }
      case ownerOrdersRoute:
      case "/ownerOrders":
        {
          return MaterialPageRoute(
            builder: (_) => const OwnerOrdersScreen(),
          );
        }
      case ownerProductsRoute:
      case "/ownerProducts":
        {
          return MaterialPageRoute(
            builder: (_) => const OwnerProductsScreen(),
          );
        }
      case ownerProductFormRoute:
      case "/ownerProductForm":
        {
          final product = settings.arguments as ProductItem?;
          return MaterialPageRoute(
            builder: (_) => OwnerProductFormScreen(product: product),
          );
        }
      case ownerInventoryRoute:
      case "/ownerInventory":
        {
          return MaterialPageRoute(
            builder: (_) => const OwnerInventoryScreen(),
          );
        }
      case ownerCategoriesRoute:
      case "/ownerCategories":
        {
          return MaterialPageRoute(
            builder: (_) => const OwnerCategoriesScreen(),
          );
        }
      case ownerSettingsRoute:
      case "/ownerSettings":
        {
          return MaterialPageRoute(
            builder: (_) => const OwnerSettingsScreen(),
          );
        }
      case ownerNotificationsRoute:
      case "/ownerNotifications":
        {
          return MaterialPageRoute(
            builder: (_) => const OwnerNotificationsScreen(),
          );
        }
      case notificationsRoute:
      case "/notifications":
        {
          return MaterialPageRoute(
            builder: (_) => const NotificationsScreen(),
          );
        }
      case phoneAuthRoute:
      case "/phoneAuth":
        {
          final args = settings.arguments as PhoneAuthArgs?;
          return MaterialPageRoute(
            builder: (_) =>
                PhoneAuthScreen(args: args ?? const PhoneAuthArgs()),
          );
        }
    }
    return null;
  }
}
