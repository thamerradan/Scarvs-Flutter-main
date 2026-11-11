// تعرض تصنيفات المتجر وتتيح للمالك إدارتها (إضافة وتعديل وحذف).
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/app/theme/app_colors.dart';
import 'package:scarvs/features/catalog/data/models/category_model.dart';
import 'package:scarvs/features/owner/presentation/providers/owner_provider.dart';
import 'package:scarvs/app/providers/theme_provider.dart';
import 'package:scarvs/shared/widgets/custom_back_button.dart';
import 'package:scarvs/shared/widgets/custom_loader.dart';

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
              isEditing ? 'تعديل التصنيف ✏️' : 'إضافة ماركة / تصنيف جديد ➕',
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
                        color: Colors.grey.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.rawSienna.withOpacity(0.3)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: localImageFile != null
                            ? Image.file(localImageFile!, fit: BoxFit.cover)
                            : urlCtrl.text.trim().isNotEmpty
                                ? Image.network(
                                    urlCtrl.text.trim(),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image, size: 36, color: Colors.grey),
                                  )
                                : const Icon(Icons.category, size: 36, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // حقل اسم التصنيف
                  TextField(
                    controller: nameCtrl,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      labelText: 'اسم التصنيف / الماركة *',
                      hintText: 'مثال: نيو بالانس',
                      prefixIcon: const Icon(Icons.label_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

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
                  const SizedBox(height: 12),

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
                            ? 'تم اختيار صورة جديدة ✅'
                            : isEditing && (category.imageUrl?.isNotEmpty ?? false)
                                ? 'تغيير صورة الشعار'
                                : 'اختيار صورة من الجهاز',
                      ),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rawSienna,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('يرجى كتابة اسم التصنيف')),
                    );
                    return;
                  }

                  Navigator.of(ctx).pop();

                  final finalUrl = urlCtrl.text.trim().isNotEmpty ? urlCtrl.text.trim() : null;

                  if (isEditing) {
                    // تعديل التصنيف الحالي
                    await ownerNotifier.updateCategory(
                      id: category.id,
                      name: name,
                      imageUrl: finalUrl,
                      imageFile: localImageFile,
                      context: context,
                    );
                  } else {
                    // إضافة تصنيف جديد
                    await ownerNotifier.addCategory(
                      name: name,
                      imageUrl: finalUrl,
                      imageFile: localImageFile,
                      context: context,
                    );
                  }
                },
                child: Text(
                  isEditing ? 'حفظ التعديلات ✅' : 'إضافة التصنيف ➕',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
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
        title: const Text('حذف التصنيف 🗑️', textAlign: TextAlign.right),
        content: Text(
          'هل أنت متأكد من حذف تصنيف "${category.name}"؟\n(ملاحظة: المنتجات التابعة له لن تُحذف وستبقى بدون تصنيف).',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ownerNotifier.deleteCategory(category.id, context: context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
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
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.rawSienna,
          elevation: 4,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('إضافة تصنيف', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () => _showCategoryDialog(context),
        ),
        body: Column(
          children: [
            // الهيدر
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  CustomBackPop(themeFlag: themeFlag),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'إدارة التصنيفات 🏷️',
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
                    onPressed: () => ownerNotifier.fetchCategories(context: context),
                  ),
                ],
              ),
            ),

            // قائمة التصنيفات
            Expanded(
              child: ownerNotifier.isLoading
                  ? customLoader(isDark: themeFlag, themeFlag: themeFlag, context: context)
                  : ownerNotifier.categories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 64,
                                color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                                    .withOpacity(0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'لا توجد تصنيفات حالياً',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                                      .withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.rawSienna),
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: const Text('إضافة أول تصنيف للمتجر', style: TextStyle(color: Colors.white)),
                                onPressed: () => _showCategoryDialog(context),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: ownerNotifier.categories.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final cat = ownerNotifier.categories[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: themeFlag ? AppColors.mirage : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: themeFlag ? Colors.white10 : Colors.black.withOpacity(0.06),
                                ),
                              ),
                              child: ListTile(
                                onTap: () => _showCategoryDialog(context, category: cat),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    color: Colors.grey.withOpacity(0.1),
                                    child: cat.imageUrl != null && cat.imageUrl!.isNotEmpty
                                        ? Image.network(
                                            cat.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.category),
                                          )
                                        : const Icon(Icons.category, color: Colors.grey),
                                  ),
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
                                      ? 'شعار مخصص متوفر ✅'
                                      : 'بدون شعار',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                                        .withOpacity(0.5),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // زر تعديل التصنيف
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: AppColors.rawSienna),
                                      tooltip: 'تعديل التصنيف',
                                      onPressed: () => _showCategoryDialog(context, category: cat),
                                    ),
                                    // زر حذف التصنيف
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
          ],
        ),
      ),
    );
  }
}
