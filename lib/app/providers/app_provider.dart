// يهيئ مزودي الحالة الذين تشاركهم شاشات التطبيق.
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scarvs/features/auth/presentation/providers/auth_provider.dart';
import 'package:scarvs/features/cart/presentation/providers/cart_provider.dart';
import 'package:scarvs/features/notifications/presentation/providers/notification_provider.dart';
import 'package:scarvs/features/orders/presentation/providers/order_provider.dart';
import 'package:scarvs/features/owner/presentation/providers/owner_provider.dart';
import 'package:scarvs/features/catalog/presentation/providers/product_provider.dart';
import 'package:scarvs/features/catalog/presentation/providers/size_provider.dart';
import 'package:scarvs/app/providers/theme_provider.dart';
import 'package:scarvs/features/profile/presentation/providers/profile_provider.dart';

class AppProvider {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => ThemeNotifier()),
    ChangeNotifierProvider(create: (_) => AuthenticationNotifier()),
    ChangeNotifierProvider(create: (_) => UserNotifier()),
    ChangeNotifierProvider(create: (_) => ProductNotifier()),
    ChangeNotifierProvider(create: (_) => SizeNotifier()),
    ChangeNotifierProvider(create: (_) => CartNotifier()),
    ChangeNotifierProvider(create: (_) => OrderNotifier()),
    ChangeNotifierProvider(create: (_) => OwnerNotifier()),
    ChangeNotifierProvider(create: (_) => NotificationNotifier()),
  ];
}
