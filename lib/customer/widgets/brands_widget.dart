// يعرض قسم العلامات التجارية في واجهة المتجر.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/category_model.dart';
import 'package:scarvs/providers/catalog_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/customer/screens/shop/category_screen.dart';
import 'package:scarvs/core/widgets/custom_text_style.dart';
import 'package:scarvs/core/widgets/dimensions_widget.dart';

class BrandWidget extends StatelessWidget {
  const BrandWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    var themeFlag = themeNotifier.darkTheme;

    Widget buildCategoryCard(CategoryModel cat) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.categoryRoute,
            arguments: CategoryScreenArgs(
              categoryName: cat.name,
              categoryId: cat.id,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: themeFlag
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            elevation: 4,
            color: themeFlag ? AppColors.mirage : Colors.white,
            child: Container(
              width: 110,
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: cat.imageUrl != null && cat.imageUrl!.isNotEmpty
                          ? Image.network(
                              cat.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.sports_basketball,
                                size: 40,
                                color: Colors.grey,
                              ),
                            )
                          : const Icon(
                              Icons.sports_basketball,
                              size: 40,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color:
                          themeFlag ? AppColors.creamColor : AppColors.mirage,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التصنيفات المتاحة',
              style: CustomTextWidget.bodyTextB2(
                color: themeFlag ? AppColors.creamColor : AppColors.mirage,
              ),
            ),
          ],
        ),
        vSizedBox1,
        SizedBox(
          height: 120,
          child: Consumer<CatalogProvider>(
            builder: (context, notifier, _) {
              if (notifier.isLoading && notifier.categories.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final cats = notifier.categories;
              if (cats.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد تصنيفات حالياً',
                    style: TextStyle(
                      color:
                          themeFlag ? AppColors.creamColor : AppColors.mirage,
                    ),
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: cats.length,
                itemBuilder: (context, index) {
                  return buildCategoryCard(cats[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
