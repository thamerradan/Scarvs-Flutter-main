// شاشة عرض المنتجات الرئيسية بتصميم متجر تنمى للملابس والأزياء المتنوعة والعصرية المتوافق مع العربية.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/providers/notification_provider.dart';
import 'package:scarvs/providers/catalog_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/customer/widgets/title_text.dart';
import 'package:scarvs/customer/widgets/product_card.dart';
import 'package:scarvs/customer/widgets/product_icon.dart';
import 'package:scarvs/core/widgets/shimmer_effects.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CatalogProvider>(context, listen: false)
          .loadInitialData(context: context);
    });
  }

  Widget _buildSquircleIcon({
    required IconData icon,
    required bool themeFlag,
    required VoidCallback onTap,
    Color? color,
    Widget? badge,
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
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(icon, color: color ?? defaultColor, size: 22),
                if (badge != null) badge,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool themeFlag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // عنوان الشاشة في الـ AppBar على شكل Row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TitleText(
                text: 'منتجاتنا ',
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: themeFlag ? AppColors.creamColor : AppColors.mirage,
              ),
              TitleText(
                text: 'المميزة ✨',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: themeFlag ? Colors.white : AppColors.rawSienna,
              ),
            ],
          ),

          // أيقونة الإشعارات مع الشارة
          Consumer<NotificationNotifier>(
            builder: (context, notif, _) {
              return _buildSquircleIcon(
                icon: Icons.notifications_none_rounded,
                themeFlag: themeFlag,
                tooltip: 'الإشعارات',
                badge: notif.unreadCount > 0
                    ? Positioned(
                        top: -6,
                        right: -6,
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
                            '${notif.unreadCount > 99 ? "99+" : notif.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.of(context).pushNamed(AppRouter.notificationsRoute);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(BuildContext context, bool themeFlag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () {
                  Navigator.of(context).pushNamed(AppRouter.searchRoute);
                },
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: themeFlag
                        ? Colors.white.withOpacity(0.06)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: themeFlag
                          ? Colors.white.withOpacity(0.08)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: themeFlag ? Colors.white60 : Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'ابحث عن الملابس أو الماركات...',
                          style: TextStyle(
                            fontSize: 13,
                            color: themeFlag
                                ? Colors.white60
                                : Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildSquircleIcon(
            icon: Icons.filter_list_rounded,
            themeFlag: themeFlag,
            tooltip: 'تصفية المنتجات',
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.searchRoute);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryWidget(CatalogProvider notifier, bool themeFlag) {
    final categories = notifier.categories;

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // خيار "الكل" الافتراضي
            return EcommerceCategoryChip(
              model: const CategoryChipItem(
                id: null,
                name: 'الكل',
                icon: Icons.all_inclusive_rounded,
              ),
              isSelected: _selectedCategoryId == null,
              themeFlag: themeFlag,
              onSelected: (item) {
                setState(() => _selectedCategoryId = null);
              },
            );
          }

          final cat = categories[index - 1];
          return EcommerceCategoryChip(
            model: CategoryChipItem(
              id: cat.id,
              name: cat.name,
              imageUrl: cat.imageUrl,
              icon: Icons.checkroom_outlined,
            ),
            isSelected: _selectedCategoryId == cat.id,
            themeFlag: themeFlag,
            onSelected: (item) {
              setState(() {
                if (_selectedCategoryId == item.id) {
                  _selectedCategoryId = null;
                } else {
                  _selectedCategoryId = item.id;
                }
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildAllProductsGrid(List<ProductItem> products, bool themeFlag) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final prod = products[index];
        return EcommerceProductCard(
          product: prod,
          themeFlag: themeFlag,
          heroTag: 'grid_${prod.id}',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final catalogNotifier = Provider.of<CatalogProvider>(context);

    // المنتجات بعد التصفية
    final allProducts = catalogNotifier.products;
    final rawFiltered = _selectedCategoryId == null
        ? allProducts
        : allProducts
            .where((p) => p.categoryId == _selectedCategoryId)
            .toList();

    // إزالة أي عناصر مكررة لضمان تفادي تعارض المفاتيح والرسوم
    final uniqueMap = <String, ProductItem>{};
    for (final p in rawFiltered) {
      uniqueMap[p.id] = p;
    }
    final filteredProducts = uniqueMap.values.toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor:
            themeFlag ? AppColors.mirage : const Color(0xfffbfbfb),
        body: RefreshIndicator(
          color: themeFlag ? Colors.white : AppColors.rawSienna,
          onRefresh: () => catalogNotifier.loadInitialData(
            refresh: true,
            context: context,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. الشريط العلوي (App Bar)
                _buildAppBar(context, themeFlag),

                // 2. شريط البحث مع زر الفلترة
                _buildSearch(context, themeFlag),

                // 3. شرائح التصنيفات الأفقية
                _buildCategoryWidget(catalogNotifier, themeFlag),

                // 4. شبكة عرض المنتجات
                if (catalogNotifier.isLoading && allProducts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ShimmerEffects.loadShimmer(context: context),
                  )
                else if (filteredProducts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'لا توجد ملابس في هذا القسم حالياً',
                        style: TextStyle(
                          color: themeFlag
                              ? AppColors.creamColor
                              : AppColors.mirage,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  )
                else
                  _buildAllProductsGrid(filteredProducts, themeFlag),

                const SizedBox(height: 80), // مسافة لمنع التداخل مع شريط التنقل السفلي
              ],
            ),
          ),
        ),
      ),
    );
  }
}
