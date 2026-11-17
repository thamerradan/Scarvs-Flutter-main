// يعرض البحث عن المنتجات ونتائج الاستعلام.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/constants/app_assets.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/providers/catalog_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/customer/widgets/category_widget.dart';
import 'package:scarvs/core/widgets/app_loader.dart';
import 'package:scarvs/core/widgets/dimensions_widget.dart';
import 'package:scarvs/core/widgets/shimmer_effects.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchProductController = TextEditingController();
  bool isExecuted = false;

  @override
  void dispose() {
    searchProductController.dispose();
    super.dispose();
  }

  void _executeSearch() {
    if (searchProductController.text.trim().isNotEmpty) {
      setState(() {
        isExecuted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'البحث عن المنتجات 🔍',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                ),
              ),
              vSizedBox1,
              Container(
                decoration: BoxDecoration(
                  color: themeFlag ? Colors.white.withOpacity(0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchProductController,
                        textInputAction: TextInputAction.search,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.start,
                        cursorColor:
                            themeFlag ? Colors.white : AppColors.rawSienna,
                        onSubmitted: (_) => _executeSearch(),
                        style: TextStyle(
                          color:
                              themeFlag ? AppColors.creamColor : AppColors.mirage,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'ابحث عن اسم المنتج، الماركة...',
                          hintStyle: TextStyle(
                            color: (themeFlag
                                    ? AppColors.creamColor
                                    : AppColors.mirage)
                                .withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    if (searchProductController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        color: Colors.grey,
                        onPressed: () {
                          searchProductController.clear();
                          setState(() {
                            isExecuted = false;
                          });
                        },
                      ),
                    IconButton(
                      onPressed: _executeSearch,
                      icon: Icon(
                        Icons.search,
                        color: themeFlag ? Colors.white : AppColors.rawSienna,
                      ),
                    ),
                  ],
                ),
              ),
              vSizedBox2,
              Expanded(
                child: isExecuted
                    ? searchData(themeFlag: themeFlag)
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_outlined,
                              size: 70,
                              color: (themeFlag
                                      ? AppColors.creamColor
                                      : AppColors.mirage)
                                  .withOpacity(0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'اكتب اسم الملابس أو الماركة للبحث',
                              style: TextStyle(
                                fontSize: 15,
                                color: (themeFlag
                                        ? AppColors.creamColor
                                        : AppColors.mirage)
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchData({required bool themeFlag}) {
    return Consumer<CatalogProvider>(
      builder: (context, notifier, _) {
        return FutureBuilder(
          future: notifier.searchProduct(
            context: context,
            productName: searchProductController.text.trim(),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ShimmerEffects.buildCategoryShimmer(context: context);
            }
            if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return AppLoader(themeFlag: themeFlag, text: 'لم يتم العثور على نتائج للبحث!', lottieAsset: AppAssets.error);
            }
            final list = snapshot.data as List;
            return showDataInGrid(
              height: 120,
              snapshot: list,
              themeFlag: themeFlag,
              context: context,
            );
          },
        );
      },
    );
  }
}
