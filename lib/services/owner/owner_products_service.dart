// ينفذ عمليات إنشاء منتجات المتجر وتعديلها وحذفها مع إدارة الصور المتعددة.
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scarvs/core/supabase/storage_service.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_tables.dart';
import 'package:scarvs/models/product_model.dart';

class OwnerProductsService {
  final SupabaseClient _client = AppSupabase.client;
  final StorageService _storageService = StorageService();

  Future<List<ProductItem>> fetchAllOwnerProducts() async {
    try {
      final data = await _client.from(SupabaseTables.products).select('''
        id,
        name,
        description,
        price,
        old_price,
        category_id,
        main_image_url,
        is_active,
        is_featured,
        created_at,
        categories (
          id,
          name
        ),
        product_variants (
          id,
          product_id,
          size,
          stock_quantity,
          is_available
        ),
        product_images (
          id,
          product_id,
          image_url,
          sort_order
        )
      ''').order('created_at', ascending: false);

      return (data as List).map((e) => ProductItem.fromJson(e)).toList();
    } catch (e) {
      throw 'فشل جلب المنتجات للإدارة: $e';
    }
  }

  Future<String> saveProduct({
    String? id,
    required String name,
    required String description,
    required double price,
    double? oldPrice,
    String? categoryId,
    String? mainImageUrl,
    File? imageFile,
    List<File> newImageFiles = const [],
    List<String> existingImageUrls = const [],
    bool isActive = true,
    bool isFeatured = false,
  }) async {
    try {
      final tempId = id ?? DateTime.now().millisecondsSinceEpoch.toString();
      final List<String> allFinalUrls = [];

      // 1. إضافة الروابط الحالية المعتمدة مسبقاً
      for (final u in existingImageUrls) {
        if (u.trim().isNotEmpty && !allFinalUrls.contains(u.trim())) {
          allFinalUrls.add(u.trim());
        }
      }

      // 2. إذا وُجد رابط مباشر منفرد ولم يكن مضافاً
      if (mainImageUrl != null && mainImageUrl.trim().isNotEmpty) {
        if (!allFinalUrls.contains(mainImageUrl.trim())) {
          allFinalUrls.insert(0, mainImageUrl.trim());
        }
      }

      // 3. رفع ملف الصورة الفردية (للتوافق القديم)
      if (imageFile != null) {
        final uploaded = await _storageService.uploadProductImage(
          file: imageFile,
          productId: tempId,
          fileName: 'main_${DateTime.now().millisecondsSinceEpoch}',
        );
        if (!allFinalUrls.contains(uploaded)) {
          allFinalUrls.insert(0, uploaded);
        }
      }

      // 4. رفع قائمة الصور المتعددة الجديدة
      for (int i = 0; i < newImageFiles.length; i++) {
        final f = newImageFiles[i];
        final uploaded = await _storageService.uploadProductImage(
          file: f,
          productId: tempId,
          fileName: 'extra_${i}_${DateTime.now().millisecondsSinceEpoch}',
        );
        if (!allFinalUrls.contains(uploaded)) {
          allFinalUrls.add(uploaded);
        }
      }

      // تحديد الصورة الرئيسية كأول صورة
      final String? finalMainImage = allFinalUrls.isNotEmpty
          ? allFinalUrls.first
          : (mainImageUrl?.isNotEmpty == true ? mainImageUrl : null);

      final payload = {
        'name': name,
        'description': description,
        'price': price,
        'old_price': oldPrice,
        'category_id': categoryId,
        'main_image_url': finalMainImage,
        'is_active': isActive,
        'is_featured': isFeatured,
      };

      String productId;
      if (id != null && id.isNotEmpty) {
        await _client
            .from(SupabaseTables.products)
            .update(payload)
            .eq('id', id);
        productId = id;
      } else {
        final result = await _client
            .from(SupabaseTables.products)
            .insert(payload)
            .select('id')
            .single();
        productId = result['id'] as String;
      }

      // 5. حفظ كافة روابط الصور في جدول product_images مع ترتيبها
      await _client
          .from(SupabaseTables.productImages)
          .delete()
          .eq('product_id', productId);

      if (allFinalUrls.isNotEmpty) {
        final toInsert = allFinalUrls.asMap().entries.map((entry) {
          return {
            'product_id': productId,
            'image_url': entry.value,
            'sort_order': entry.key,
          };
        }).toList();

        await _client.from(SupabaseTables.productImages).insert(toInsert);
      }

      return productId;
    } catch (e) {
      throw 'فشل حفظ بيانات المنتج وصوره: $e';
    }
  }

  Future<void> saveProductVariants(
    String productId,
    List<Map<String, dynamic>> variants,
  ) async {
    try {
      await _client
          .from(SupabaseTables.productVariants)
          .delete()
          .eq('product_id', productId);

      if (variants.isNotEmpty) {
        final toInsert = variants.map((variant) {
          return {
            'product_id': productId,
            'size': variant['size'],
            'stock_quantity': variant['stock_quantity'] ?? 0,
            'is_available': (variant['stock_quantity'] ?? 0) > 0,
          };
        }).toList();

        await _client.from(SupabaseTables.productVariants).insert(toInsert);
      }
    } catch (e) {
      throw 'فشل حفظ مقاسات ومخزون المنتج: $e';
    }
  }

  Future<void> toggleProductActive(String productId, bool isActive) async {
    try {
      await _client
          .from(SupabaseTables.products)
          .update({'is_active': isActive})
          .eq('id', productId);
    } catch (e) {
      throw 'فشل تغيير حالة تفعيل المنتج: $e';
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _client
          .from(SupabaseTables.products)
          .delete()
          .eq('id', productId);
    } catch (e) {
      throw 'فشل حذف المنتج: $e';
    }
  }
}
