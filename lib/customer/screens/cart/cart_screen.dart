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

  Widget _buildSquircleIcon({
    required IconData icon,
    required bool themeFlag,
    required VoidCallback onTap,
    Color? color,
    String? tooltip,
  }) {
    final defaultColor =
        themeFlag ? AppColors.creamColor : AppColors.mirage;

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: themeFlag ? Colors.white.withOpacity(0.08) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: themeFlag
                      ? Colors.black.withOpacity(0.25)
                      : const Color(0xfff0f0f0),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: color ?? defaultColor, size: 20),
          ),
        ),
      ),
    );
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
                                  ? Colors.white.withOpacity(0.12)
                                  : AppColors.rawSienna.withOpacity(0.12),
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
                        _buildSquircleIcon(
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
                                          .withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: themeFlag
                                          ? Colors.white
                                          : AppColors.rawSienna,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 22, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    icon: Icon(Icons.shopping_bag_outlined,
                                        color: themeFlag
                                            ? AppColors.mirage
                                            : Colors.white,
                                        size: 20),
                                    label: Text(
                                      'تصفح أحدث الملابس',
                                      style: TextStyle(
                                        color: themeFlag
                                            ? AppColors.mirage
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pushNamedAndRemoveUntil(
                                        AppRouter.customerHomeRoute,
                                        (route) => false,
                                      );
                                    },
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
