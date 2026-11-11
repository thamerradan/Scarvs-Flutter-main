// ينفذ عمليات جلب المنتجات والتصنيفات والبحث في الكتالوج.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/category_model.dart';
import 'models/product_model.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_tables.dart';

class ProductService {
  final SupabaseClient _client = AppSupabase.client;


  /// جلب كافة التصنيفات النشطة
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final data = await _client
          .from(SupabaseTables.categories)
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (data as List).map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw 'فشل جلب التصنيفات: $e';
    }
  }

  /// جلب المنتجات مع الفلترة والتصنيف والبحث
  Future<List<ProductItem>> fetchProducts({
    String? categoryId,
    String? categoryName,
    String? searchQuery,
    bool? featuredOnly,
  }) async {
    try {
      var query = _client.from(SupabaseTables.products).select('''
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
      ''').eq('is_active', true);

      if (featuredOnly == true) {
        query = query.eq('is_featured', true);
      }

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        query = query.or(
          'name.ilike.%${searchQuery.trim()}%,description.ilike.%${searchQuery.trim()}%',
        );
      }

      final data = await query.order('created_at', ascending: false);

      List<ProductItem> list =
          (data as List).map((e) => ProductItem.fromJson(e)).toList();

      // فلترة باسم التصنيف إذا تم تمريره
      if (categoryName != null && categoryName.isNotEmpty) {
        list = list.where((p) {
          final cName = p.categoryName?.toLowerCase() ?? '';
          return cName.contains(categoryName.toLowerCase());
        }).toList();
      }

      return list;
    } catch (e) {
      throw 'فشل جلب المنتجات: $e';
    }
  }

  /// جلب تفاصيل منتج معين بالـ ID مع كافة المقاسات والصور
  Future<ProductItem?> fetchProductDetail(String id) async {
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
      ''').eq('id', id).maybeSingle();

      if (data == null) return null;
      return ProductItem.fromJson(data);
    } catch (e) {
      throw 'فشل جلب تفاصيل المنتج: $e';
    }
  }

  /// إضافة منتج جديد (صلاحية المالك)
  Future<ProductItem> createProduct({
    required String name,
    required String description,
    required double price,
    double? oldPrice,
    String? categoryId,
    required String mainImageUrl,
    bool isFeatured = false,
    List<Map<String, dynamic>> variants = const [],
    List<String> additionalImages = const [],
  }) async {
    try {
      final productRes = await _client
          .from(SupabaseTables.products)
          .insert({
            'name': name.trim(),
            'description': description.trim(),
            'price': price,
            'old_price': oldPrice,
            'category_id': categoryId,
            'main_image_url': mainImageUrl,
            'is_featured': isFeatured,
            'is_active': true,
          })
          .select()
          .single();

      final productId = productRes['id'] as String;

      // إدخال المقاسات والمخزون
      if (variants.isNotEmpty) {
        final variantsData = variants.map((v) => {
              'product_id': productId,
              'size': v['size'],
              'stock_quantity': v['stock_quantity'] ?? 0,
              'is_available': (v['stock_quantity'] ?? 0) > 0,
            }).toList();
        await _client.from(SupabaseTables.productVariants).insert(variantsData);
      }

      // إدخال الصور الإضافية
      if (additionalImages.isNotEmpty) {
        final imagesData = additionalImages.asMap().entries.map((entry) => {
              'product_id': productId,
              'image_url': entry.value,
              'sort_order': entry.key,
            }).toList();
        await _client.from(SupabaseTables.productImages).insert(imagesData);
      }

      final fullProduct = await fetchProductDetail(productId);
      return fullProduct ?? ProductItem.fromJson(productRes);
    } catch (e) {
      throw 'فشل إنشاء المنتج: $e';
    }
  }

  /// تم إلغاء البيانات الثابتة - يعتمد التطبيق كلياً على البيانات الحقيقية من المشرف
  Future<void> seedInitialDataIfEmpty() async {
    // تم إلغاء البذر التلقائي للأصناف والمنتجات الثابتة
  }
}
