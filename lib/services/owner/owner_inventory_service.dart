// ينفذ عمليات جلب مخزون المنتجات وتحديثه.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_tables.dart';

class OwnerInventoryService {
  final SupabaseClient _client = AppSupabase.client;

  Future<List<Map<String, dynamic>>> fetchInventoryList() async {
    try {
      final data = await _client.from(SupabaseTables.productVariants).select('''
        id,
        product_id,
        size,
        stock_quantity,
        is_available,
        products (
          id,
          name,
          main_image_url,
          price
        )
      ''').order('stock_quantity', ascending: true);

      return List<Map<String, dynamic>>.from(data as List);
    } catch (e) {
      throw 'فشل جلب بيانات المخزون: $e';
    }
  }

  Future<void> updateVariantStock(String variantId, int newStock) async {
    try {
      await _client.from(SupabaseTables.productVariants).update({
        'stock_quantity': newStock,
        'is_available': newStock > 0,
      }).eq('id', variantId);
    } catch (e) {
      throw 'فشل تحديث كمية المخزون: $e';
    }
  }
}
