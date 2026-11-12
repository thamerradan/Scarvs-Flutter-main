// يعرض قائمة المنتجات في الكتالوج.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/constants/app_assets.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/providers/notification_provider.dart';
import 'package:scarvs/providers/catalog_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/providers/user_provider.dart';
import 'package:scarvs/widgets/brands_widget.dart';
import 'package:scarvs/widgets/recommended_widget.dart';
import 'package:scarvs/core/widgets/dimensions_widget.dart';
import 'package:scarvs/core/widgets/shimmer_effects.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CatalogProvider>(context, listen: false)
          .loadInitialData(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final userData = Provider.of<UserProvider>(context);
    final userName = userData.getUserName ?? 'عميلنا العزيز';
    final productNotifier = Provider.of<CatalogProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: RefreshIndicator(
          onRefresh: () => productNotifier.loadInitialData(
            refresh: true,
            context: context,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أهلاً بك، $userName 👋',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ماذا تحب أن ترتدي اليوم؟',
                            style: TextStyle(
                              fontSize: 14,
                              color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      Consumer<NotificationNotifier>(
                        builder: (context, notif, _) {
                          return Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined, size: 28),
                                color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                                onPressed: () {
                                  Navigator.of(context).pushNamed(AppRouter.notificationsRoute);
                                },
                              ),
                              if (notif.unreadCount > 0)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '${notif.unreadCount}',
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
                    ],
                  ),
                  vSizedBox2,
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          AppColors.rawSienna,
                          AppColors.mediumPurple,
                          AppColors.fuchsiaPink,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.rawSienna.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    height: 160,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'دلّل قدميك ✨',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'أحدث التشكيلات العالمية الأصلية',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 110,
                          width: 140,
                          child: Image.asset(
                            AppAssets.homeJordan,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  vSizedBox2,
                  const BrandWidget(),
                  vSizedBox2,
                  Text(
                    'أحدث الأحذية المميزة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                    ),
                  ),
                  vSizedBox1,
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: Consumer<CatalogProvider>(
                      builder: (context, notifier, _) {
                        if (notifier.isLoading && notifier.products.isEmpty) {
                          return ShimmerEffects.loadShimmer(context: context);
                        }
                        if (notifier.products.isEmpty) {
                          return Center(
                            child: Text(
                              'لا توجد منتجات حالياً',
                              style: TextStyle(
                                color: themeFlag
                                    ? AppColors.creamColor
                                    : AppColors.mirage,
                              ),
                            ),
                          );
                        }
                        return productForYou(
                          snapshot: notifier.products,
                          themeFlag: themeFlag,
                          context: context,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
