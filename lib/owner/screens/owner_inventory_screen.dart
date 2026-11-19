// تعرض مخزون المتجر وتتيح للمالك متابعة الكميات.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/providers/owner_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/widgets/app_back_button.dart';
import 'package:scarvs/core/widgets/app_loader.dart';
import 'package:scarvs/core/widgets/app_network_image.dart';

class OwnerInventoryScreen extends StatefulWidget {
  const OwnerInventoryScreen({Key? key}) : super(key: key);

  @override
  State<OwnerInventoryScreen> createState() => _OwnerInventoryScreenState();
}

class _OwnerInventoryScreenState extends State<OwnerInventoryScreen> {
  String _filter = 'all'; // 'all', 'low', 'out'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OwnerNotifier>(context, listen: false)
          .fetchInventory(context: context);
    });
  }

  void _showSetStockDialog(BuildContext context, String variantId, int currentStock) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ownerNotifier = Provider.of<OwnerNotifier>(context, listen: false);
    final ctrl = TextEditingController(text: currentStock.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تحديد كمية المخزون', textAlign: TextAlign.right),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(labelText: 'الكمية الجديدة'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : AppColors.rawSienna,
              foregroundColor: isDark ? AppColors.mirage : Colors.white,
            ),
            onPressed: () async {
              final newStock = int.tryParse(ctrl.text.trim());
              if (newStock != null && newStock >= 0) {
                Navigator.of(ctx).pop();
                await ownerNotifier.updateStock(variantId, newStock, context: context);
              }
            },
            child: Text('تحديث',
                style: TextStyle(
                    color: isDark ? AppColors.mirage : Colors.white)),
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

    final filteredList = ownerNotifier.inventory.where((v) {
      final stock = (v['stock_quantity'] as num?)?.toInt() ?? 0;
      if (_filter == 'out') return stock == 0;
      if (_filter == 'low') return stock > 0 && stock <= 5;
      return true;
    }).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: Column(
          children: [
            // الهيدر
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  AppBackButton(
                    themeFlag: themeFlag,
                    fallbackRoute: AppRouter.ownerDashboardRoute,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'إدارة المخزون 📊',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                    onPressed: () => ownerNotifier.fetchInventory(context: context),
                  ),
                ],
              ),
            ),

            // فلاتر الحالة
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  _buildFilterChip('الكل', 'all', themeFlag),
                  const SizedBox(width: 8),
                  _buildFilterChip('قريب من النفاد ⚠️', 'low', themeFlag),
                  const SizedBox(width: 8),
                  _buildFilterChip('نفذ تماماً ❌', 'out', themeFlag),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // قائمة عناصر المخزون
            Expanded(
              child: ownerNotifier.isLoading
                  ? AppLoader(themeFlag: themeFlag)
                  : filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: Colors.green.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'لا توجد منتجات ضمن هذا الفلتر',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => ownerNotifier.fetchInventory(context: context),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: filteredList.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              return _buildInventoryCard(
                                context: context,
                                item: item,
                                themeFlag: themeFlag,
                                ownerNotifier: ownerNotifier,
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String key, bool themeFlag) {
    final isSelected = _filter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: themeFlag ? Colors.white : AppColors.rawSienna,
      labelStyle: TextStyle(
        color: isSelected
            ? (themeFlag ? AppColors.mirage : Colors.white)
            : (themeFlag ? AppColors.creamColor : AppColors.mirage),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: themeFlag ? Colors.white10 : Colors.white,
      onSelected: (selected) {
        if (selected) setState(() => _filter = key);
      },
    );
  }

  Widget _buildInventoryCard({
    required BuildContext context,
    required Map<String, dynamic> item,
    required bool themeFlag,
    required OwnerNotifier ownerNotifier,
  }) {
    final variantId = item['id'] as String;
    final size = item['size']?.toString() ?? '';
    final stock = (item['stock_quantity'] as num?)?.toInt() ?? 0;
    final product = item['products'] as Map<String, dynamic>?;
    final productName = product?['name']?.toString() ?? 'منتج بدون اسم';
    final imageUrl = product?['main_image_url']?.toString();

    Color tagColor = Colors.green;
    String tagText = 'متوفر';
    if (stock == 0) {
      tagColor = Colors.red;
      tagText = 'نفذ المخزون';
    } else if (stock <= 5) {
      tagColor = Colors.orange;
      tagText = 'قارب على النفاد';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: themeFlag ? AppColors.mirage : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: themeFlag ? Colors.white10 : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          // صورة مصغرة
          SizedBox(
            width: 50,
            height: 50,
            child: AppNetworkImage(
              url: imageUrl ?? '',
              fit: BoxFit.cover,
              borderRadius: 8,
              cacheWidth: 150,
              errorWidget: const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),

          // الاسم والمقاس
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: themeFlag
                            ? Colors.white.withOpacity(0.15)
                            : AppColors.rawSienna.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'مقاس: $size',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: themeFlag ? Colors.white : AppColors.rawSienna,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tagText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: tagColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // وحدة التحكم بالكمية (+ / -)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 22),
                onPressed: stock > 0
                    ? () => ownerNotifier.updateStock(variantId, stock - 1, context: context)
                    : null,
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _showSetStockDialog(context, variantId, stock),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (themeFlag ? AppColors.creamColor : AppColors.mirage).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$stock',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 22),
                onPressed: () =>
                    ownerNotifier.updateStock(variantId, stock + 1, context: context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
