// يعرض سلة التسوق وعناصرها وإجراءات تعديلها.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/constants/app_assets.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/providers/cart_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/customer/widgets/show_cart_data.dart';
import 'package:scarvs/core/widgets/app_loader.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthGuard.isLoggedIn) {
        Provider.of<CartNotifier>(context, listen: false)
            .loadCart(context: context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final cartNotifier = Provider.of<CartNotifier>(context);

    return SafeArea(
      child: AuthProtected(
        returnRoute: AppRouter.cartRoute,
        message: 'سجّل دخولك لعرض سلة المشتريات ومتابعة التسوق',
        child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'سلة المشتريات 🛍️',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: themeFlag
                              ? AppColors.creamColor
                              : AppColors.mirage,
                        ),
                      ),
                      if (cartNotifier.totalItemsCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.rawSienna,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${cartNotifier.totalItemsCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (cartNotifier.cartItems.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 22),
                      tooltip: 'تحديث السلة',
                      onPressed: () => cartNotifier.loadCart(context: context),
                    ),
                ],
              ),
            ),
            Expanded(
              child: cartNotifier.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : cartNotifier.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppLoader(themeFlag: themeFlag, text: '', lottieAsset: AppAssets.nodata),
                                const SizedBox(height: 12),
                                Text(
                                  'سلة التسوق فارغة حالياً!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: themeFlag
                                        ? AppColors.creamColor
                                        : AppColors.mirage,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'لم تقم بإضافة أي أحذية إلى سلتك بعد',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: (themeFlag
                                            ? AppColors.creamColor
                                            : AppColors.mirage)
                                        .withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.rawSienna,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushReplacementNamed(AppRouter.homeRoute);
                                  },
                                  child: const Text(
                                    'تصفح الأحذية الآن 👟',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : showCartData(
                          height: 100,
                          snapshot: cartNotifier.cartItems,
                          themeFlag: themeFlag,
                          context: context,
                        ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
