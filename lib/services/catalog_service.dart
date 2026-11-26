// ينفذ عمليات جلب المنتجات والأصناف والبحث في الكتالوج.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scarvs/models/category_model.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_tables.dart';

class ProductService {
  final SupabaseClient _client = AppSupabase.client;

  /// جلب كافة الأصناف النشطة
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final data = await _client
          .from(SupabaseTables.categories)
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (data as List).map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw 'فشل جلب الأصناف: $e';
    }
  }

  /// جلب المنتجات مع الفلترة والصنف والبحث
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

      // فلترة باسم الصنف إذا تم تمريره
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
}
