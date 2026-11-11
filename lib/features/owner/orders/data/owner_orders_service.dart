// ينفذ عمليات جلب طلبات المتجر وإدارتها للمالك.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_tables.dart';
import 'package:scarvs/features/orders/data/models/order_model.dart';

class OwnerOrdersService {
  final SupabaseClient _client = AppSupabase.client;

  Future<List<OrderModel>> fetchAllOrders({String? statusFilter}) async {
    try {
      var query = _client.from(SupabaseTables.orders).select('''
        id,
        order_number,
        user_id,
        subtotal,
        shipping_fee,
        discount,
        total,
        payment_method,
        payment_status,
        order_status,
        shipping_address,
        city,
        phone,
        notes,
        created_at,
        profiles (
          full_name,
          email,
          phone
        ),
        order_items (
          id,
          order_id,
          product_id,
          product_name,
          product_image,
          size,
          quantity,
          unit_price,
          total_price
        )
      ''');

      if (statusFilter != null && statusFilter != 'all') {
        query = query.eq('order_status', statusFilter);
      }

      final data = await query.order('created_at', ascending: false);
      return (data as List).map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      throw 'فشل جلب طلبات المتجر: $e';
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _client
          .from(SupabaseTables.orders)
          .update({'order_status': newStatus})
          .eq('id', orderId);
    } catch (e) {
      throw 'فشل تحديث حالة الطلب: $e';
    }
  }
}
