// يعرض نموذج إضافة منتج للمتجر أو تعديل بياناته مع إدارة الصور المتعددة.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_spacing.dart';
import 'package:scarvs/core/utils/snackbar_util.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/providers/catalog_provider.dart';
import 'package:scarvs/providers/owner_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/widgets/app_page_header.dart';
import 'package:scarvs/core/widgets/app_buttons.dart';
import 'package:scarvs/core/widgets/app_network_image.dart';
import 'package:scarvs/core/widgets/app_text_field.dart';

class _ProductImageEntry {
  final File? file;
  final String? url;

  _ProductImageEntry({this.file, this.url});

  bool get isFile => file != null;
}

class OwnerProductFormScreen extends StatefulWidget {
  final ProductItem? product;

  const OwnerProductFormScreen({super.key, this.product});

  @override
  State<OwnerProductFormScreen> createState() => _OwnerProductFormScreenState();
}

class _OwnerProductFormScreenState extends State<OwnerProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _oldPriceController;

  String? _selectedCategoryId;
  bool _isActive = true;
  bool _isFeatured = false;
  bool _hasSizes = false;

  // قائمة صور المنتج المتعددة (ملفات أو روابط)
  final List<_ProductImageEntry> _images = [];

  // قائمة المقاسات والمخزون
  final List<Map<String, dynamic>> _variants = [];

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
        text: p != null ? p.price.toStringAsFixed(0) : '');
    _oldPriceController = TextEditingController(
      text: p?.oldPrice != null ? p!.oldPrice!.toStringAsFixed(0) : '',
    );
    _selectedCategoryId = p?.categoryId;
    _isActive = p?.isActive ?? true;
    _isFeatured = p?.isFeatured ?? false;

    // استيراد صور المنتج الحالية
    if (p != null) {
      if (p.images.isNotEmpty) {
        for (final u in p.images) {
          if (u.trim().isNotEmpty) {
            _images.add(_ProductImageEntry(url: u.trim()));
          }
        }
      } else if (p.mainImageUrl.isNotEmpty) {
        _images.add(_ProductImageEntry(url: p.mainImageUrl));
      }
    }

    if (p != null && p.variants.isNotEmpty) {
      _hasSizes = true;
      for (var v in p.variants) {
        _variants.add({
          'size': v.size,
          'stock_quantity': v.stock,
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OwnerNotifier>(context, listen: false)
          .fetchCategories(context: context);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _oldPriceController.dispose();
    super.dispose();
  }

  /// فتح نافذة اختيار مصدر الصور
  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF222831) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'إضافة صور للمنتج',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'يمكنك اختيار أكثر من صورة معاً لعرض تفاصيل المنتج للعميل',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : AppColors.rawSienna.withValues(alpha: 0.12),
                      child: Icon(Icons.photo_library,
                          color: isDark ? Colors.white : AppColors.rawSienna),
                    ),
                    title: const Text('معرض الصور (عدة صور دفعة واحدة)'),
                    subtitle: const Text('حدد أكثر من صورة من ألبوم الهاتف'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _pickMultipleImages();
                    },
                  ),
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : AppColors.rawSienna.withValues(alpha: 0.12),
                      child: Icon(Icons.camera_alt,
                          color: isDark ? Colors.white : AppColors.rawSienna),
                    ),
                    title: const Text('التقاط بالكاميرا'),
                    subtitle: const Text('تصوير المنتج مباشرة الآن'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _pickCameraImage();
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickMultipleImages() async {
    try {
      final picker = ImagePicker();
      final pickedList = await picker.pickMultiImage(
        imageQuality: 75,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (pickedList.isNotEmpty) {
        setState(() {
          for (final item in pickedList) {
            _images.add(_ProductImageEntry(file: File(item.path)));
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      SnackUtil.show(context, 'تعذر اختيار الصور: $e');
    }
  }

  Future<void> _pickCameraImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (picked != null) {
        setState(() {
          _images.add(_ProductImageEntry(file: File(picked.path)));
        });
      }
    } catch (e) {
      if (!mounted) return;
      SnackUtil.show(context, 'تعذر التقاط الصورة: $e');
    }
  }

  void _makeMainImage(int index) {
    if (index > 0 && index < _images.length) {
      setState(() {
        final item = _images.removeAt(index);
        _images.insert(0, item);
      });
      SnackUtil.show(
        context,
        'تم تعيين الصورة كغلاف رئيسي للمنتج',
        duration: const Duration(seconds: 1),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _addVariantRow() {
    showDialog(
      context: context,
      builder: (ctx) {
        final sizeCtrl = TextEditingController();
        final stockCtrl = TextEditingController(text: '5');

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('إضافة مقاس جديد', textAlign: TextAlign.right),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                textEditingController: sizeCtrl,
                labelText: 'المقاس',
                hintText: 'L أو 40',
                textAlign: TextAlign.right,
              ),
              AppSpacing.gapH12,
              AppTextField(
                textEditingController: stockCtrl,
                labelText: 'الكمية المتوفرة',
                hintText: '5',
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
              ),
            ],
          ),
          actions: [
            AppTextButton(
              text: 'إلغاء',
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            AppPrimaryButton(
              text: 'إضافة',
              height: 40,
              width: 90,
              onPressed: () {
                final s = sizeCtrl.text.trim();
                final qty = int.tryParse(stockCtrl.text.trim()) ?? 0;
                if (s.isNotEmpty) {
                  setState(() {
                    _variants.add({'size': s, 'stock_quantity': qty});
                  });
                  Navigator.of(ctx).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_images.isEmpty) {
      SnackUtil.show(context, 'يرجى إضافة صورة واحدة على الأقل للمنتج');
      return;
    }

    if (_hasSizes && _variants.isEmpty) {
      SnackUtil.show(
        context,
        'لقد قمت بتفعيل المقاسات، يرجى إضافة مقاس واحد على الأقل أو إيقاف الخيار',
      );
      return;
    }

    final newFiles =
        _images.where((i) => i.isFile).map((i) => i.file!).toList();
    final existingUrls = _images
        .where((i) => !i.isFile && i.url != null)
        .map((i) => i.url!)
        .toList();

    final ownerNotifier = Provider.of<OwnerNotifier>(context, listen: false);

    final success = await ownerNotifier.saveProduct(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      oldPrice: _oldPriceController.text.trim().isNotEmpty
          ? double.tryParse(_oldPriceController.text.trim())
          : null,
      categoryId: _selectedCategoryId,
      newImageFiles: newFiles,
      existingImageUrls: existingUrls,
      isActive: _isActive,
      isFeatured: _isFeatured,
      variants: _hasSizes ? _variants : const [],
      context: context,
    );

    if (success && mounted) {
      Provider.of<CatalogProvider>(context, listen: false).invalidate();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final ownerNotifier = Provider.of<OwnerNotifier>(context);
    final isEditing = widget.product != null;

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: Column(
          children: [
            AppPageHeader(
              title: isEditing ? 'تعديل المنتج' : 'إضافة منتج جديد',
              fallbackRoute: AppRouter.ownerProductsRoute,
            ),

            // النموذج
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ==========================================
                    // قسم إدارة صور المنتج المتعددة
                    // ==========================================
                    _buildMultiImagesSection(themeFlag),
                    const SizedBox(height: 20),

                    // اسم المنتج
                    AppTextField(
                      textEditingController: _nameController,
                      labelText: 'اسم المنتج',
                      hintText: 'أدخل اسم المنتج',
                      prefixIcon: const Icon(Icons.shopping_bag_outlined),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'يرجى كتابة اسم المنتج'
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // الوصف
                    AppTextField(
                      textEditingController: _descController,
                      labelText: 'وصف المنتج وتفاصيله',
                      hintText: 'أدخل وصف المنتج وتفاصيله',
                      maxLines: 3,
                      prefixIcon: const Icon(Icons.description_outlined),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'يرجى كتابة وصف المنتج'
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // السعر والسعر القديم
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            textEditingController: _priceController,
                            labelText: 'السعر الحالي',
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.attach_money),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'مطلوب';
                              }
                              if (double.tryParse(val.trim()) == null) {
                                return 'غير صالح';
                              }
                              return null;
                            },
                          ),
                        ),
                        AppSpacing.gapW12,
                        Expanded(
                          child: AppTextField(
                            textEditingController: _oldPriceController,
                            labelText: 'السعر قبل الخصم',
                            hintText: 'اختياري',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.money_off),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gapH12,

                    // التصنيف (الماركة)
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      dropdownColor:
                          themeFlag ? AppColors.mirage : Colors.white,
                      decoration: _inputDecoration(
                        label: 'التصنيف',
                        icon: Icons.category_outlined,
                        themeFlag: themeFlag,
                      ),
                      items: ownerNotifier.categories.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(
                            c.name,
                            style: TextStyle(
                              color: themeFlag
                                  ? AppColors.creamColor
                                  : AppColors.mirage,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategoryId = val),
                    ),
                    const SizedBox(height: 14),

                    // خيارات التفعيل والظهور
                    SwitchListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      tileColor: themeFlag ? Colors.white10 : Colors.white,
                      title: const Text('المنتج نشط ومتاح للبيع'),
                      value: _isActive,
                      activeThumbColor:
                          themeFlag ? Colors.white : AppColors.rawSienna,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      tileColor: themeFlag ? Colors.white10 : Colors.white,
                      title: const Text('منتج مميز (يظهر في الرئيسية)'),
                      value: _isFeatured,
                      activeThumbColor:
                          themeFlag ? Colors.white : AppColors.rawSienna,
                      onChanged: (val) => setState(() => _isFeatured = val),
                    ),
                    const SizedBox(height: 8),

                    // خيار تحديد مقاسات للمنتج
                    SwitchListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      tileColor: themeFlag ? Colors.white10 : Colors.white,
                      title: const Text('تحديد مقاسات للمنتج'),
                      subtitle: Text(
                        _hasSizes
                            ? 'المنتج يتطلب مقاسات متعددة'
                            : 'المنتج بدون مقاس',
                        style: TextStyle(
                          fontSize: 12,
                          color: (themeFlag
                                  ? AppColors.creamColor
                                  : AppColors.mirage)
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      value: _hasSizes,
                      activeThumbColor:
                          themeFlag ? Colors.white : AppColors.rawSienna,
                      onChanged: (val) => setState(() => _hasSizes = val),
                    ),
                    if (_hasSizes) ...[
                      const SizedBox(height: 20),

                      // قسم إدارة المقاسات والمخزون
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المقاسات والمخزون (${_variants.length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: themeFlag
                                  ? AppColors.creamColor
                                  : AppColors.mirage,
                            ),
                          ),
                          AppTextButton(
                            icon: Icons.add,
                            text: 'إضافة مقاس',
                            textColor:
                                themeFlag ? Colors.white : AppColors.rawSienna,
                            onPressed: _addVariantRow,
                          ),
                        ],
                      ),
                      AppSpacing.gapH8,

                      // جدول المقاسات
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: themeFlag ? Colors.white10 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (themeFlag
                                    ? AppColors.creamColor
                                    : AppColors.mirage)
                                .withValues(alpha: 0.1),
                          ),
                        ),
                        child: _variants.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 16),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.straighten_outlined,
                                      size: 38,
                                      color: (themeFlag
                                              ? AppColors.creamColor
                                              : AppColors.mirage)
                                          .withValues(alpha: 0.3),
                                    ),
                                    AppSpacing.gapH8,
                                    Text(
                                      'لم تتم إضافة أي مقاسات بعد',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: (themeFlag
                                                ? AppColors.creamColor
                                                : AppColors.mirage)
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children:
                                    _variants.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final item = entry.value;

                                  return ListTile(
                                    dense: true,
                                    leading: CircleAvatar(
                                      backgroundColor: themeFlag
                                          ? Colors.white.withValues(alpha: 0.2)
                                          : AppColors.rawSienna
                                              .withValues(alpha: 0.2),
                                      radius: 16,
                                      child: Text(
                                        '${item['size']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: themeFlag
                                              ? Colors.white
                                              : AppColors.rawSienna,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    title: Text('المقاس: ${item['size']}'),
                                    subtitle: Text(
                                        'الكمية: ${item['stock_quantity']} قطعة'),
                                    trailing: IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _variants.removeAt(idx);
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                    const SizedBox(height: 30),

                    // زر الحفظ
                    AppPrimaryButton(
                      text: isEditing
                          ? 'حفظ التعديلات ✅'
                          : 'إضافة المنتج للمتجر 🚀',
                      isLoading: ownerNotifier.isSaving,
                      onPressed: _submitForm,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// قسم عرض وإدارة صور المنتج المتعددة
  Widget _buildMultiImagesSection(bool themeFlag) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: themeFlag ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
              .withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.photo_library_outlined,
                      color: themeFlag ? Colors.white : AppColors.rawSienna,
                      size: 20),
                  AppSpacing.gapW8,
                  Text(
                    'صور المنتج (${_images.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          themeFlag ? AppColors.creamColor : AppColors.mirage,
                    ),
                  ),
                ],
              ),
              AppPrimaryButton(
                text: 'إضافة صور',
                icon: Icons.add_a_photo,
                height: 38,
                width: 125,
                fontSize: 13,
                borderRadius: 10,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                onPressed: _showImageSourcePicker,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'الصورة الأولى ستكون هي الغلاف الرئيسي للمنتج، ويمكنك تعيين أي صورة كغلاف بالنقر عليها',
            style: TextStyle(
              fontSize: 11,
              color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                  .withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 14),
          if (_images.isEmpty)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _showImageSourcePicker,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: themeFlag
                        ? Colors.white30
                        : AppColors.rawSienna.withValues(alpha: 0.4),
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: themeFlag ? Colors.white : AppColors.rawSienna),
                    AppSpacing.gapH8,
                    const Text(
                      'انقر هنا لإضافة صور للمنتج 📸 (يمكنك اختيار عدة صور)',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // شريط أفقي لعرض كل الصور المضافة
            SizedBox(
              height: 155,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length + 1,
                separatorBuilder: (_, __) => AppSpacing.gapW12,
                itemBuilder: (context, index) {
                  // بطاقة إضافة صورة جديدة في نهاية القائمة
                  if (index == _images.length) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _showImageSourcePicker,
                      child: Container(
                        width: 110,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: themeFlag
                                  ? Colors.white24
                                  : AppColors.rawSienna.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: themeFlag
                                  ? Colors.white
                                  : AppColors.rawSienna,
                              radius: 18,
                              child: Icon(Icons.add,
                                  color: themeFlag
                                      ? AppColors.mirage
                                      : Colors.white,
                                  size: 20),
                            ),
                            AppSpacing.gapH8,
                            const Text('إضافة المزيد',
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }

                  final item = _images[index];
                  final isMain = index == 0;

                  return Container(
                    width: 125,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isMain
                            ? (themeFlag ? Colors.white : AppColors.rawSienna)
                            : Colors.grey.withValues(alpha: 0.3),
                        width: isMain ? 2.5 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 125,
                            height: 155,
                            child: item.isFile
                                ? Image.file(item.file!, fit: BoxFit.cover)
                                : AppNetworkImage(
                                    url: item.url!,
                                    fit: BoxFit.cover,
                                    cacheWidth: 300,
                                    errorWidget: const Icon(Icons.broken_image),
                                  ),
                          ),
                        ),

                        // شارة الصورة الرئيسية
                        if (isMain)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: themeFlag
                                    ? Colors.white
                                    : AppColors.rawSienna,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'الغلاف',
                                style: TextStyle(
                                    color: themeFlag
                                        ? AppColors.mirage
                                        : Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        else
                          Positioned(
                            bottom: 6,
                            left: 6,
                            right: 6,
                            child: InkWell(
                              onTap: () => _makeMainImage(index),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'تعيين كغلاف',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),

                        // زر الحذف
                        Positioned(
                          top: 6,
                          left: 6,
                          child: InkWell(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required bool themeFlag,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: themeFlag ? Colors.white10 : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
              .withValues(alpha: 0.15),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
              .withValues(alpha: 0.15),
        ),
      ),
    );
  }
}
