// يعرف مسارات التنقل وينشئ الشاشات المرتبطة بها.
// ignore_for_file: body_might_complete_normally_nullable

import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/screens/cart/cart_screen.dart';
import 'package:scarvs/screens/shop/category_screen.dart';
import 'package:scarvs/screens/checkout/checkout_screen.dart';
import 'package:scarvs/screens/shop/home_screen.dart';
import 'package:scarvs/screens/auth/login_screen.dart';
import 'package:scarvs/screens/notifications/notifications_screen.dart';
import 'package:scarvs/screens/startup/onboarding_screen.dart';
import 'package:scarvs/screens/orders/order_detail_screen.dart';
import 'package:scarvs/screens/orders/orders_screen.dart';
import 'package:scarvs/screens/owner/owner_categories_screen.dart';
import 'package:scarvs/screens/owner/owner_dashboard_screen.dart';
import 'package:scarvs/screens/owner/owner_inventory_screen.dart';
import 'package:scarvs/screens/owner/owner_orders_screen.dart';
import 'package:scarvs/screens/owner/owner_product_form_screen.dart';
import 'package:scarvs/screens/owner/owner_products_screen.dart';
import 'package:scarvs/screens/owner/owner_settings_screen.dart';
import 'package:scarvs/screens/auth/phone_auth_screen.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/screens/shop/product_detail_screen.dart';
import 'package:scarvs/screens/shop/product_screen.dart';
import 'package:scarvs/screens/profile/account_information_screen.dart';
import 'package:scarvs/screens/profile/settings_screen.dart';
import 'package:scarvs/screens/profile/change_password_screen.dart';
import 'package:scarvs/screens/profile/edit_profile_screen.dart';
import 'package:scarvs/screens/profile/profile_screen.dart';
import 'package:scarvs/screens/shop/search_screen.dart';
import 'package:scarvs/screens/auth/signup_screen.dart';
import 'package:scarvs/screens/startup/splash_screen.dart';

class AppRouter {
  static const String splashRoute = "/splash";
  static const String onBoardRoute = "/onBoard";
  static const String productRoute = "/product";
  static const String loginRoute = "/login";
  static const String signUpRoute = "/signup";
  static const String appSettingsRoute = "/appSettings";
  static const String homeRoute = "/home";
  static const String cartRoute = "/cart";
  static const String searchRoute = "/search";
  static const String profileRoute = "/profile";
  static const String accountInfo = "/accountInfo";
  static const String categoryRoute = "/category";
  static const String prodDetailRoute = "/productDetail";
  static const String editProfileRoute = "/editProfile";
  static const String changePassRoute = "/changePassword";
  static const String checkoutRoute = "/checkout";
  static const String ordersRoute = "/orders";
  static const String orderDetailRoute = "/orderDetail";
  static const String ownerDashboardRoute = "/ownerDashboard";
  static const String ownerOrdersRoute = "/ownerOrders";
  static const String ownerProductsRoute = "/ownerProducts";
  static const String ownerProductFormRoute = "/ownerProductForm";
  static const String ownerInventoryRoute = "/ownerInventory";
  static const String ownerCategoriesRoute = "/ownerCategories";
  static const String ownerSettingsRoute = "/ownerSettings";
  static const String notificationsRoute = "/notifications";
  static const String phoneAuthRoute = "/phoneAuth";

  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case editProfileRoute:
        {
          return MaterialPageRoute(
            builder: (_) => EditProfileScreen(),
          );
        }
      case appSettingsRoute:
        {
          return MaterialPageRoute(
            builder: (_) => const SettingsScreen(),
          );
        }
      case homeRoute:
        {
          return MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          );
        }
      case splashRoute:
        {
          return ConcentricPageRoute(
            fullscreenDialog: true,
            builder: (_) => const SplashScreen(),
          );
        }
      case onBoardRoute:
        {
          return MaterialPageRoute(
            builder: (_) => OnBoardingScreen(),
          );
        }
      case productRoute:
        {
          return MaterialPageRoute(
            builder: (_) => const ProductScreen(),
          );
        }
      case loginRoute:
        {
          return MaterialPageRoute(
            builder: (_) => LoginScreen(),
          );
        }
      case signUpRoute:
        {
          return MaterialPageRoute(
            builder: (_) => SignUpScreen(),
          );
        }
      case prodDetailRoute:
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
        {
          return MaterialPageRoute(
            builder: (_) => const CartScreen(),
          );
        }
      case searchRoute:
        {
          return MaterialPageRoute(
            builder: (_) => const SearchScreen(),
          );
        }
      case profileRoute:
        {
          return MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
          );
        }
      case categoryRoute:
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
        {
          return MaterialPageRoute(
            builder: (_) => const AccountInformationScreen(),
          );
        }
      case changePassRoute:
        {
          return MaterialPageRoute(
            builder: (_) => ChangePasswordScreen(),
          );
        }
      case checkoutRoute:
        {
          return MaterialPageRoute(
            builder: (_) => const CheckoutScreen(),
          );
        }
      case ordersRoute:
        {
          return MaterialPageRoute(
            builder: (_) => const OrdersScreen(),
          );
        }
      case orderDetailRoute:
        {
          final orderId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: orderId),
            settings: settings,
          );
        }
      case ownerDashboardRoute:
        {
          return MaterialPageRoute(
            builder: (_) => const OwnerDashboardScreen(),
          );
        }
      case ownerOrdersRoute:
        {
          return MaterialPageRoute(
            builder: (_) => const OwnerOrdersScreen(),
          );
        }
      case ownerProductsRoute:
        {
          return MaterialPageRoute(
            builder: (_) => const OwnerProductsScreen(),
          );
        }
      case ownerProductFormRoute:
        {
          final product = settings.arguments as ProductItem?;
          return MaterialPageRoute(
            builder: (_) => OwnerProductFormScreen(product: product),
          );
        }
      case ownerInventoryRoute:
        {
          return MaterialPageRoute(
            builder: (_) => const OwnerInventoryScreen(),
          );
        }
      case ownerCategoriesRoute:
        {
          return MaterialPageRoute(
            builder: (_) => const OwnerCategoriesScreen(),
          );
        }
      case ownerSettingsRoute:
        {
          return MaterialPageRoute(
            builder: (_) => const OwnerSettingsScreen(),
          );
        }
      case notificationsRoute:
        {
          return MaterialPageRoute(
            builder: (_) => const NotificationsScreen(),
          );
        }
      case phoneAuthRoute:
        {
          final args = settings.arguments as PhoneAuthArgs?;
          return MaterialPageRoute(
            builder: (_) =>
                PhoneAuthScreen(args: args ?? const PhoneAuthArgs()),
          );
        }
    }
  }
}
