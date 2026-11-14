// يعرض تفاصيل المنتج وخياراته قبل إضافته إلى السلة.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/constants/app_assets.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/providers/catalog_provider.dart';
import 'package:scarvs/providers/size_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/customer/widgets/product_detail_ui.dart';
import 'package:scarvs/core/widgets/app_back_button.dart';
import 'package:scarvs/core/widgets/app_loader.dart';

class ProductDetail extends StatefulWidget {
  final ProductDetailsArgs productDetailsArguements;
  const ProductDetail({
    Key? key,
    required this.productDetailsArguements,
  }) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late Future<ProductItem?> _detailFuture;
  ProductItem? _product;
  bool _initializedSize = false;

  @override
  void initState() {
    super.initState();
    // إذا تم تمرير بيانات المنتج مبدئياً نعرضها مباشرة دون أي تأخير
    if (widget.productDetailsArguements.initialProduct != null) {
      _product = widget.productDetailsArguements.initialProduct;
      _initSizeForProduct(_product!);
    }
    _detailFuture = _fetchProductDetails();
  }

  void _initSizeForProduct(ProductItem prod) {
    if (!_initializedSize) {
      _initializedSize = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<SizeNotifier>(context, listen: false)
              .initForProduct(prod.variants);
        }
      });
    }
  }

  Future<ProductItem?> _fetchProductDetails() async {
    final notifier = Provider.of<CatalogProvider>(context, listen: false);
    final fetched = await notifier.fetchProductDetail(
      context: context,
      id: widget.productDetailsArguements.id.toString(),
    );

    if (fetched != null && mounted) {
      setState(() {
        _product = fetched;
      });
      _initSizeForProduct(fetched);
    }
    return fetched ?? _product;
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppBackPop(themeFlag: themeFlag),
                  Text(
                    'تفاصيل الحذاء',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                    ),
                  ),
                  const SizedBox(width: 48), // لموازنة زر الرجوع
                ],
              ),
            ),
            Expanded(
              child: _product != null
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        child: productUI(
                          context: context,
                          themeFlag: themeFlag,
                          snapshot: _product!,
                        ),
                      ),
                    )
                  : FutureBuilder<ProductItem?>(
                      future: _detailFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: AppLoader(themeFlag: themeFlag, lottieAsset: AppAssets.onBoardingOne, text: 'جاري تحميل تفاصيل المنتج...'),
                          );
                        } else if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data == null) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppLoader(themeFlag: themeFlag, text: 'تعذر تحميل بيانات المنتج', lottieAsset: AppAssets.error),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.rawSienna,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _initializedSize = false;
                                        _detailFuture = _fetchProductDetails();
                                      });
                                    },
                                    child: const Text('إعادة المحاولة'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final prod = snapshot.data!;
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                            child: productUI(
                              context: context,
                              themeFlag: themeFlag,
                              snapshot: prod,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailsArgs {
  final dynamic id;
  final ProductItem? initialProduct;
  const ProductDetailsArgs({required this.id, this.initialProduct});
}
