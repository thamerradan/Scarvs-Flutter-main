// يعرض سلة التسوق بتصميم المتجر المرجعي المتوافق مع العربية.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/constants/app_assets.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/providers/cart_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/customer/widgets/title_text.dart';
import 'package:scarvs/customer/widgets/show_cart_data.dart';
import 'package:scarvs/core/widgets/app_loader.dart';
import 'package:scarvs/core/widgets/app_squircle_button.dart';
import 'package:scarvs/core/widgets/app_buttons.dart';
import 'package:scarvs/core/theme/app_spacing.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

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
          backgroundColor:
              themeFlag ? AppColors.mirage : const Color(0xfffbfbfb),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الهيدر بتصميم السطرين
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TitleText(
                          text: 'سلة ',
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: themeFlag
                              ? AppColors.creamColor
                              : AppColors.mirage,
                        ),
                        TitleText(
                          text: 'المشتريات',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: themeFlag ? Colors.white : AppColors.rawSienna,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (cartNotifier.totalItemsCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: themeFlag
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : AppColors.rawSienna.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${cartNotifier.totalItemsCount} عناصر',
                              style: TextStyle(
                                color: themeFlag ? Colors.white : AppColors.rawSienna,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        AppSquircleButton(
                          icon: Icons.refresh_rounded,
                          themeFlag: themeFlag,
                          tooltip: 'تحديث السلة',
                          onTap: () =>
                              cartNotifier.loadCart(context: context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: cartNotifier.isLoading
                    ? Center(
                        child: AppLoader(
                          themeFlag: themeFlag,
                          text: 'جاري تحديث السلة...',
                        ),
                      )
                    : cartNotifier.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppLoader(
                                    themeFlag: themeFlag,
                                    text: '',
                                    lottieAsset: AppAssets.nodata,
                                  ),
                                  const SizedBox(height: 12),
                                  TitleText(
                                    text: 'سلة التسوق فارغة حالياً!',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'لم تقم بإضافة أي ملابس إلى سلتك بعد',
                                    style: TextStyle(
                                      color: (themeFlag
                                              ? AppColors.creamColor
                                              : AppColors.mirage)
                                          .withValues(alpha: 0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                  AppSpacing.gapH24,
                                  SizedBox(
                                    width: 220,
                                    child: AppPrimaryButton(
                                      text: 'تصفح أحدث المنتجات',
                                      icon: Icons.shopping_bag_outlined,
                                      onPressed: () {
                                        Navigator.of(context).pushNamedAndRemoveUntil(
                                          AppRouter.customerHomeRoute,
                                          (route) => false,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : showCartData(
                            snapshot: cartNotifier.cartItems,
                            themeFlag: themeFlag,
                            context: context,
                            height: MediaQuery.of(context).size.height,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
