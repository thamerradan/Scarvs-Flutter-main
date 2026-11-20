// تعرض منتجات المتجر وتتيح للمالك إدارتها بكفاءة وسرعة.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_spacing.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/providers/catalog_provider.dart';
import 'package:scarvs/providers/owner_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/widgets/app_buttons.dart';
import 'package:scarvs/core/widgets/app_card.dart';
import 'package:scarvs/core/widgets/app_network_image.dart';
import 'package:scarvs/core/widgets/app_page_header.dart';
import 'package:scarvs/core/widgets/app_state_view.dart';

class OwnerProductsScreen extends StatefulWidget {
  const OwnerProductsScreen({Key? key}) : super(key: key);

  @override
  State<OwnerProductsScreen> createState() => _OwnerProductsScreenState();
}

class _OwnerProductsScreenState extends State<OwnerProductsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OwnerNotifier>(context, listen: false)
          .fetchProducts(context: context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, ProductItem product) {
    final ownerNotifier = Provider.of<OwnerNotifier>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف المنتج', textAlign: TextAlign.right),
        content: Text(
          'هل أنت متأكد من حذف المنتج "${product.name}"؟ سيتم حذف جميع المقاسات والمخزون المرتبط به.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          AppDangerButton(
            text: 'حذف نهائي',
            height: 40,
            width: 100,
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await ownerNotifier.deleteProduct(product.id, context: context);
              if (ok && context.mounted) {
                Provider.of<CatalogProvider>(context, listen: false).invalidate();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final ownerNotifier = Provider.of<OwnerNotifier>(context);

    final normalizedQuery = _searchQuery.toLowerCase();
    final filteredProducts = ownerNotifier.products.where((p) {
      if (normalizedQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(normalizedQuery) ||
          (p.categoryName?.toLowerCase().contains(normalizedQuery) ?? false);
    }).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: themeFlag ? Colors.white : AppColors.rawSienna,
          elevation: 4,
          icon: Icon(Icons.add, color: themeFlag ? AppColors.mirage : Colors.white),
          label: Text(
            'إضافة منتج جديد',
            style: TextStyle(
                color: themeFlag ? AppColors.mirage : Colors.white,
                fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(AppRouter.ownerProductFormRoute);
          },
        ),
        body: Column(
          children: [
            // شريط العنوان الموحد
            AppPageHeader(
              title: 'إدارة المنتجات',
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'تحديث',
                  color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                  onPressed: () => ownerNotifier.fetchProducts(context: context),
                ),
              ],
            ),

            // شريط البحث
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'بحث باسم المنتج أو الماركة...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: themeFlag ? Colors.white10 : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            AppSpacing.gapH8,

            // قائمة المنتجات بحالات التحميل والفراغ الموحدة
            Expanded(
              child: AppStateView(
                isLoading: ownerNotifier.isProductsLoading,
                isEmpty: filteredProducts.isEmpty,
                emptyMessage: _searchQuery.isNotEmpty
                    ? 'لا توجد منتجات تطابق البحث'
                    : 'لا توجد منتجات مسجلة في المتجر حالياً',
                emptyIcon: Icons.inventory_2_outlined,
                onRetry: () => ownerNotifier.fetchProducts(context: context),
                child: RefreshIndicator(
                  onRefresh: () => ownerNotifier.fetchProducts(context: context),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(
                        context: context,
                        product: product,
                        themeFlag: themeFlag,
                        ownerNotifier: ownerNotifier,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required BuildContext context,
    required ProductItem product,
    required bool themeFlag,
    required OwnerNotifier ownerNotifier,
  }) {
    // حساب إجمالي المخزون في جميع المقاسات
    int totalStock = 0;
    for (var v in product.variants) {
      totalStock += v.stock;
    }

    return AppCard(
      padding: AppSpacing.paddingCard,
      borderRadius: AppSpacing.radiusLg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // صورة المنتج
          AppNetworkImage.thumbnail(
            url: product.mainImageUrl,
            width: 80,
            height: 80,
            borderRadius: AppSpacing.radiusMd,
            errorWidget: const Icon(Icons.image_outlined, size: 36, color: Colors.grey),
          ),
          AppSpacing.gapW12,

          // تفاصيل المنتج
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                        ),
                      ),
                    ),
                    // سويتش التفعيل / التعطيل
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: product.isActive,
                        activeThumbColor: themeFlag ? Colors.white : AppColors.rawSienna,
                        onChanged: (val) async {
                          await ownerNotifier.toggleProductStatus(
                            product.id,
                            val,
                            context: context,
                          );
                          if (context.mounted) {
                            Provider.of<CatalogProvider>(context, listen: false).invalidate();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Text(
                  product.categoryName ?? 'بدون تصنيف',
                  style: TextStyle(
                    fontSize: 12,
                    color: themeFlag ? AppColors.creamColor : AppColors.rawSienna,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(0)} ر.س',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: themeFlag ? Colors.white : AppColors.rawSienna,
                      ),
                    ),
                    if (product.oldPrice != null && product.oldPrice! > product.price) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${product.oldPrice!.toStringAsFixed(0)} ر.س',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: product.variants.isEmpty || totalStock > 0
                            ? Colors.green.withValues(alpha: 0.12)
                            : Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.variants.isEmpty
                            ? 'متاح'
                            : (totalStock > 0 ? '$totalStock قطعة' : 'نفذ المخزون'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: product.variants.isEmpty || totalStock > 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // زر التعديل
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRouter.ownerProductFormRoute,
                          arguments: product,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: themeFlag
                              ? Colors.white.withValues(alpha: 0.12)
                              : AppColors.rawSienna.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 14,
                                color: themeFlag ? Colors.white : AppColors.rawSienna),
                            const SizedBox(width: 4),
                            Text('تعديل',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: themeFlag ? Colors.white : AppColors.rawSienna,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // زر الحذف
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _confirmDelete(context, product),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.delete_outline, size: 14, color: Colors.red),
                            SizedBox(width: 4),
                            Text('حذف', style: TextStyle(fontSize: 12, color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
