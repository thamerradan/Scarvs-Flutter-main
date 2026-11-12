// يهيئ مزودي الحالة الذين تشاركهم شاشات التطبيق.
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scarvs/providers/auth_provider.dart';
import 'package:scarvs/providers/cart_provider.dart';
import 'package:scarvs/providers/notification_provider.dart';
import 'package:scarvs/providers/order_provider.dart';
import 'package:scarvs/providers/owner_provider.dart';
import 'package:scarvs/providers/catalog_provider.dart';
import 'package:scarvs/providers/size_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/providers/user_provider.dart';

class AppProvider {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => ThemeNotifier()),
    ChangeNotifierProvider(create: (_) => AuthenticationNotifier()),
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => CatalogProvider()),
    ChangeNotifierProvider(create: (_) => SizeNotifier()),
    ChangeNotifierProvider(create: (_) => CartNotifier()),
    ChangeNotifierProvider(create: (_) => OrderNotifier()),
    ChangeNotifierProvider(create: (_) => OwnerNotifier()),
    ChangeNotifierProvider(create: (_) => NotificationNotifier()),
  ];
}
