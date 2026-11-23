// تعرض تصنيفات المتجر وتتيح للمالك إدارتها (إضافة وتعديل وحذف).
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_spacing.dart';
import 'package:scarvs/core/utils/app_message.dart';
import 'package:scarvs/models/category_model.dart';
import 'package:scarvs/providers/catalog_provider.dart';
import 'package:scarvs/providers/owner_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/widgets/app_buttons.dart';
import 'package:scarvs/core/widgets/app_card.dart';
import 'package:scarvs/core/widgets/app_network_image.dart';
import 'package:scarvs/core/widgets/app_page_header.dart';
import 'package:scarvs/core/widgets/app_state_view.dart';

class OwnerCategoriesScreen extends StatefulWidget {
  const OwnerCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<OwnerCategoriesScreen> createState() => _OwnerCategoriesScreenState();
}

class _OwnerCategoriesScreenState extends State<OwnerCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OwnerNotifier>(context, listen: false)
          .fetchCategories(context: context);
    });
  }

  /// نافذة منبثقة موحدة لإضافة تصنيف جديد أو تعديل تصنيف حالي
  void _showCategoryDialog(BuildContext context, {CategoryModel? category}) {
    final ownerNotifier = Provider.of<OwnerNotifier>(context, listen: false);
    final isEditing = category != null;

    final nameCtrl = TextEditingController(text: category?.name ?? '');
    final urlCtrl = TextEditingController(text: category?.imageUrl ?? '');
    File? localImageFile;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            backgroundColor: isDark ? const Color(0xFF222831) : Colors.white,
            title: Text(
              isEditing ? 'تعديل التصنيف' : 'إضافة تصنيف جديد',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // معاينة صورة التصنيف
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isDark
                                ? Colors.white30
                                : AppColors.rawSienna.withValues(alpha: 0.3)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: localImageFile != null
                            ? Image.file(localImageFile!, fit: BoxFit.cover)
                            : AppNetworkImage(
                                url: urlCtrl.text.trim(),
                                fit: BoxFit.cover,
                                cacheWidth: 200,
                                errorWidget: const Icon(Icons.broken_image, size: 36, color: Colors.grey),
                              ),
                      ),
                    ),
                  ),
                  AppSpacing.gapH16,

                  // حقل اسم التصنيف
                  TextField(
                    controller: nameCtrl,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      labelText: 'اسم التصنيف / الماركة *',
                      hintText: 'مثال: رسمي، كاجوال، شتوي',
                      prefixIcon: const Icon(Icons.label_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  AppSpacing.gapH12,

                  // حقل رابط الصورة المباشر
                  TextField(
                    controller: urlCtrl,
                    onChanged: (_) => setDialogState(() {}),
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      labelText: 'رابط صورة الشعار (URL اختياري)',
                      prefixIcon: const Icon(Icons.link),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  AppSpacing.gapH12,

                  // زر اختيار صورة من معرض الجهاز
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(
                        localImageFile != null
                            ? 'تم اختيار صورة جديدة'
                            : isEditing && (category.imageUrl?.isNotEmpty ?? false)
                                ? 'تغيير صورة الشعار'
                                : 'اختيار صورة من الجهاز',
                      ),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 75,
                          maxWidth: 1200,
                          maxHeight: 1200,
                        );
                        if (picked != null) {
                          setDialogState(() {
                            localImageFile = File(picked.path);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('إلغاء'),
              ),
              AppPrimaryButton(
                text: isEditing ? 'حفظ التعديلات' : 'إضافة التصنيف',
                height: 42,
                width: 130,
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) {
                    AppMessage.error(context, 'يرجى كتابة اسم التصنيف');
                    return;
                  }

                  Navigator.of(ctx).pop();

                  final finalUrl = urlCtrl.text.trim().isNotEmpty ? urlCtrl.text.trim() : null;

                  if (isEditing) {
                    await ownerNotifier.updateCategory(
                      id: category.id,
                      name: name,
                      imageUrl: finalUrl,
                      imageFile: localImageFile,
                      context: context,
                    );
                  } else {
                    await ownerNotifier.addCategory(
                      name: name,
                      imageUrl: finalUrl,
                      imageFile: localImageFile,
                      context: context,
                    );
                  }
                  if (context.mounted) {
                    // إبطال كاش الكتالوج دون إطلاق طلب شبكة فوري أثناء وجود المالك هنا
                    Provider.of<CatalogProvider>(context, listen: false).invalidate();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, CategoryModel category) {
    final ownerNotifier = Provider.of<OwnerNotifier>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف التصنيف', textAlign: TextAlign.right),
        content: Text(
          'هل أنت متأكد من حذف تصنيف "${category.name}"؟\n(ملاحظة: المنتجات التابعة له لن تُحذف وستبقى بدون تصنيف).',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          AppDangerButton(
            text: 'حذف',
            height: 40,
            width: 80,
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await ownerNotifier.deleteCategory(category.id, context: context);
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        floatingActionButton: AppFloatingAddButton(
          label: 'إضافة تصنيف',
          onPressed: () => _showCategoryDialog(context),
        ),
        body: Column(
          children: [
            // شريط العنوان الموحد
            AppPageHeader(
              title: 'إدارة التصنيفات',
              actions: [
                AppRefreshButton(
                  onPressed: () => ownerNotifier.fetchCategories(context: context),
                  isLoading: ownerNotifier.isCategoriesLoading,
                ),
              ],
            ),

            // قائمة التصنيفات بحالات التحميل والفراغ الموحدة
            Expanded(
              child: AppStateView(
                isLoading: ownerNotifier.isCategoriesLoading,
                isEmpty: ownerNotifier.categories.isEmpty,
                emptyMessage: 'لا توجد تصنيفات حالياً في المتجر',
                emptyIcon: Icons.category_outlined,
                onRetry: () => ownerNotifier.fetchCategories(context: context),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: ownerNotifier.categories.length,
                  separatorBuilder: (_, __) => AppSpacing.gapH8,
                  itemBuilder: (context, index) {
                    final cat = ownerNotifier.categories[index];
                    return AppCard(
                      borderRadius: AppSpacing.radiusMd,
                      padding: EdgeInsets.zero,
                      onTap: () => _showCategoryDialog(context, category: cat),
                      child: ListTile(
                        leading: AppNetworkImage.thumbnail(
                          url: cat.imageUrl ?? '',
                          width: 48,
                          height: 48,
                          borderRadius: AppSpacing.radiusSm,
                          errorWidget: const Icon(Icons.category, color: Colors.grey),
                        ),
                        title: Text(
                          cat.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                          ),
                        ),
                        subtitle: Text(
                          cat.imageUrl != null && cat.imageUrl!.isNotEmpty
                              ? 'شعار مخصص متوفر'
                              : 'بدون شعار',
                          style: TextStyle(
                            fontSize: 12,
                            color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_outlined,
                                  color: themeFlag ? Colors.white : AppColors.rawSienna),
                              tooltip: 'تعديل التصنيف',
                              onPressed: () => _showCategoryDialog(context, category: cat),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              tooltip: 'حذف التصنيف',
                              onPressed: () => _confirmDelete(context, cat),
                            ),
                          ],
                        ),
                      ),
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
}
