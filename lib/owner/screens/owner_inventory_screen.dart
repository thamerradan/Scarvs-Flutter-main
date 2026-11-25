// تعرض مخزون المتجر وتتيح للمالك متابعة الكميات بدقة وسرعة.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_spacing.dart';
import 'package:scarvs/core/widgets/app_buttons.dart';
import 'package:scarvs/core/widgets/app_card.dart';
import 'package:scarvs/core/widgets/app_network_image.dart';
import 'package:scarvs/core/widgets/app_page_header.dart';
import 'package:scarvs/core/widgets/app_state_view.dart';
import 'package:scarvs/core/widgets/app_status_badge.dart';
import 'package:scarvs/core/widgets/app_text_field.dart';
import 'package:scarvs/providers/owner_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';

class OwnerInventoryScreen extends StatefulWidget {
  const OwnerInventoryScreen({super.key});

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
    final ownerNotifier = Provider.of<OwnerNotifier>(context, listen: false);
    final ctrl = TextEditingController(text: currentStock.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تحديد كمية المخزون', textAlign: TextAlign.right),
        content: AppTextField(
          textEditingController: ctrl,
          labelText: 'الكمية الجديدة',
          hintText: '0',
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          AppTextButton(
            text: 'إلغاء',
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          AppPrimaryButton(
            text: 'تحديث',
            height: 40,
            width: 90,
            onPressed: () async {
              final newStock = int.tryParse(ctrl.text.trim());
              if (newStock != null && newStock >= 0) {
                Navigator.of(ctx).pop();
                await ownerNotifier.updateStock(variantId, newStock, context: context);
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
            // شريط العنوان الموحد
            AppPageHeader(
              title: 'إدارة المخزون',
              actions: [
                AppRefreshButton(
                  onPressed: () => ownerNotifier.fetchInventory(context: context),
                  isLoading: ownerNotifier.isInventoryLoading,
                ),
              ],
            ),

            // فلاتر الحالة
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  _buildFilterChip('الكل', 'all', themeFlag),
                  AppSpacing.gapW8,
                  _buildFilterChip('قريب من النفاد', 'low', themeFlag),
                  AppSpacing.gapW8,
                  _buildFilterChip('نفذ تماماً', 'out', themeFlag),
                ],
              ),
            ),
            AppSpacing.gapH8,

            // قائمة عناصر المخزون بحالات التحميل الموحدة
            Expanded(
              child: AppStateView(
                isLoading: ownerNotifier.isInventoryLoading,
                isEmpty: filteredList.isEmpty,
                emptyMessage: 'لا توجد منتجات ضمن هذا الفلتر',
                emptyIcon: Icons.check_circle_outline,
                onRetry: () => ownerNotifier.fetchInventory(context: context),
                child: RefreshIndicator(
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
    final isUpdating = ownerNotifier.isVariantUpdating(variantId);

    Color tagColor = Colors.green;
    String tagText = 'متوفر';
    if (stock == 0) {
      tagColor = Colors.red;
      tagText = 'نفذ المخزون';
    } else if (stock <= 5) {
      tagColor = Colors.orange;
      tagText = 'قارب على النفاد';
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: AppSpacing.radiusLg,
      child: Row(
        children: [
          // صورة مصغرة
          AppNetworkImage.thumbnail(
            url: imageUrl ?? '',
            width: 50,
            height: 50,
            borderRadius: AppSpacing.radiusSm,
            errorWidget: const Icon(Icons.image, color: Colors.grey),
          ),
          AppSpacing.gapW12,

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
                            ? Colors.white.withValues(alpha: 0.15)
                            : AppColors.rawSienna.withValues(alpha: 0.15),
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
                    AppStatusBadge(
                      text: tagText,
                      color: tagColor,
                      fontSize: 10,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      borderRadius: 6,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // وحدة التحكم بالكمية (+ / -) مع حماية ضد السباق والضغط المتكرر
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 22),
                onPressed: (!isUpdating && stock > 0)
                    ? () => ownerNotifier.updateStock(variantId, stock - 1, context: context)
                    : null,
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: isUpdating
                    ? null
                    : () => _showSetStockDialog(context, variantId, stock),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isUpdating
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              themeFlag ? AppColors.creamColor : AppColors.mirage,
                            ),
                          ),
                        )
                      : Text(
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
                onPressed: !isUpdating
                    ? () => ownerNotifier.updateStock(variantId, stock + 1, context: context)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
