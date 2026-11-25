// يعرض منتجات تصنيف محدد ويستقبل بيانات الصنف.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/constants/app_assets.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_spacing.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/providers/catalog_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/customer/widgets/category_widget.dart';
import 'package:scarvs/core/widgets/app_loader.dart';
import 'package:scarvs/core/widgets/app_page_header.dart';
import 'package:scarvs/core/widgets/shimmer_effects.dart';

class CategoryScreen extends StatefulWidget {
  final CategoryScreenArgs categoryScreenArgs;

  const CategoryScreen({super.key, required this.categoryScreenArgs});

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
            AppPageHeader(
              title: widget.categoryScreenArgs.categoryName.toString(),
              fallbackRoute: AppRouter.customerHomeRoute,
            ),
            AppSpacing.gapH8,
            Expanded(
              child: FutureBuilder<List<ProductItem>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ShimmerEffects.buildCategoryShimmer(
                        context: context);
                  } else if (!snapshot.hasData ||
                      (snapshot.data as List).isEmpty) {
                    return AppLoader(
                        themeFlag: themeFlag,
                        text: 'لا توجد منتجات متوفرة حالياً في هذا الصنف',
                        lottieAsset: AppAssets.error);
                  } else {
                    final list = snapshot.data!;
                    return showDataInGrid(
                      snapshot: list,
                      themeFlag: themeFlag,
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
