// يعرض منتجات تصنيف محدد ويستقبل بيانات التصنيف.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/constants/app_assets.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/providers/catalog_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/customer/widgets/category_widget.dart';
import 'package:scarvs/core/widgets/app_back_button.dart';
import 'package:scarvs/core/widgets/app_loader.dart';
import 'package:scarvs/core/widgets/custom_text_style.dart';
import 'package:scarvs/core/widgets/dimensions_widget.dart';
import 'package:scarvs/core/widgets/shimmer_effects.dart';

class CategoryScreen extends StatefulWidget {
  final CategoryScreenArgs categoryScreenArgs;

  const CategoryScreen({Key? key, required this.categoryScreenArgs})
      : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<ProductItem>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadCategoryProducts();
  }

  Future<List<ProductItem>> _loadCategoryProducts() {
    return Provider.of<CatalogProvider>(context, listen: false)
        .fetchProductCategory(
      context: context,
      categoryName: widget.categoryScreenArgs.categoryName,
      categoryId: widget.categoryScreenArgs.categoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  AppBackPop(themeFlag: themeFlag),
                  const SizedBox(width: 8),
                  Text(
                    widget.categoryScreenArgs.categoryName.toString(),
                    style: CustomTextWidget.bodyTextB2(
                      color:
                          themeFlag ? AppColors.creamColor : AppColors.mirage,
                    ),
                  ),
                ],
              ),
            ),
            vSizedBox1,
            Expanded(
              child: FutureBuilder<List<ProductItem>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ShimmerEffects.buildCategoryShimmer(context: context);
                  } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                    return customLoader(
                      context: context,
                      themeFlag: themeFlag,
                      text: 'لا توجد منتجات متوفرة حالياً في هذا التصنيف',
                      lottieAsset: AppAssets.error,
                    );
                  } else {
                    final list = snapshot.data!;
                    return showDataInGrid(
                      height: 120,
                      snapshot: list,
                      themeFlag: themeFlag,
                      context: context,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryScreenArgs {
  final dynamic categoryName;
  final String? categoryId;
  const CategoryScreenArgs({required this.categoryName, this.categoryId});
}
