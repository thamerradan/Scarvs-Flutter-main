// يعرف مسارات التنقل وينشئ الشاشات المرتبطة بها.
import 'package:flutter/material.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/customer/screens/cart/cart_screen.dart';
import 'package:scarvs/customer/screens/shop/category_screen.dart';
import 'package:scarvs/customer/screens/checkout/checkout_screen.dart';
import 'package:scarvs/customer/screens/shop/home_screen.dart';
import 'package:scarvs/customer/screens/notifications/notifications_screen.dart';
import 'package:scarvs/customer/screens/orders/order_detail_screen.dart';
import 'package:scarvs/customer/screens/orders/orders_screen.dart';
import 'package:scarvs/owner/screens/owner_categories_screen.dart';
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

  static Route<dynamic> generateRoute(RouteSettings settings) {
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

    // 2. حماية مسارات السلة وإتمام الطلب من المالك (المالك في وضع معاينة المتجر فقط):
    if (userRole == 'owner' && (route == cartRoute || route == checkoutRoute)) {
      return MaterialPageRoute(
        builder: (_) => const HomeScreen(initialIndex: 2),
        settings: settings,
      );
    }

    switch (settings.name) {
      // ==================== مسارات العميل ====================
      case customerHomeRoute:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case splashRoute:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case productRoute:
        return MaterialPageRoute(
          builder: (_) => const ProductScreen(),
          settings: settings,
        );

      case prodDetailRoute:
        return MaterialPageRoute(
          builder: (context) => ProductDetail(
            productDetailsArguements: ModalRoute.of(context)!
                .settings
                .arguments as ProductDetailsArgs,
          ),
          settings: settings,
        );

      case cartRoute:
        return MaterialPageRoute(
          builder: (_) => const CartScreen(),
          settings: settings,
        );

      case searchRoute:
        return MaterialPageRoute(
          builder: (_) => const SearchScreen(),
          settings: settings,
        );

      case profileRoute:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      case editProfileRoute:
        return MaterialPageRoute(
          builder: (_) => EditProfileScreen(),
          settings: settings,
        );

      case appSettingsRoute:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      case accountInfo:
        return MaterialPageRoute(
          builder: (_) => const AccountInformationScreen(),
          settings: settings,
        );

      case categoryRoute:
        return MaterialPageRoute(
          builder: (context) => CategoryScreen(
            categoryScreenArgs: ModalRoute.of(context)!.settings.arguments
                as CategoryScreenArgs,
          ),
          settings: settings,
        );

      case checkoutRoute:
        return MaterialPageRoute(
          builder: (_) => const CheckoutScreen(),
          settings: settings,
        );

      case ordersRoute:
        return MaterialPageRoute(
          builder: (_) => const OrdersScreen(),
          settings: settings,
        );

      case orderDetailRoute:
        final orderId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => OrderDetailScreen(orderId: orderId),
          settings: settings,
        );

      case notificationsRoute:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
          settings: settings,
        );

      case phoneAuthRoute:
        final args = settings.arguments as PhoneAuthArgs?;
        return MaterialPageRoute(
          builder: (_) =>
              PhoneAuthScreen(args: args ?? const PhoneAuthArgs()),
          settings: settings,
        );

      // ==================== مسارات المالك ====================
      case ownerDashboardRoute:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(initialIndex: 2),
          settings: settings,
        );

      case ownerOrdersRoute:
        return MaterialPageRoute(
          builder: (_) => const OwnerOrdersScreen(),
          settings: settings,
        );

      case ownerProductsRoute:
        return MaterialPageRoute(
          builder: (_) => const OwnerProductsScreen(),
          settings: settings,
        );

      case ownerProductFormRoute:
        final product = settings.arguments as ProductItem?;
        return MaterialPageRoute(
          builder: (_) => OwnerProductFormScreen(product: product),
          settings: settings,
        );

      case ownerInventoryRoute:
        return MaterialPageRoute(
          builder: (_) => const OwnerInventoryScreen(),
          settings: settings,
        );

      case ownerCategoriesRoute:
        return MaterialPageRoute(
          builder: (_) => const OwnerCategoriesScreen(),
          settings: settings,
        );

      case ownerSettingsRoute:
        return MaterialPageRoute(
          builder: (_) => const OwnerSettingsScreen(),
          settings: settings,
        );

      case ownerNotificationsRoute:
        return MaterialPageRoute(
          builder: (_) => const OwnerNotificationsScreen(),
          settings: settings,
        );

      // ==================== المسار الافتراضي ====================
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
    }
  }
}
