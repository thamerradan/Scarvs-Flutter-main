// ينفذ عمليات إنشاء الطلبات وجلبها وتحديثها.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/order_model.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_tables.dart';

class OrderService {
  final SupabaseClient _client = AppSupabase.client;

  /// إتمام الطلب كمعاملة ذرية آمنة عبر Stored Procedure
  Future<Map<String, dynamic>> placeOrder({
    required String shippingAddress,
    required String city,
    required String phone,
    String? notes,
    String paymentMethod = 'cash_on_delivery',
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw 'يجب تسجيل الدخول أولاً لإتمام الطلب';

    try {
      final res = await _client.rpc(
        SupabaseTables.placeOrderRpc,
        params: {
          'p_shipping_address': shippingAddress.trim(),
          'p_city': city.trim(),
          'p_phone': phone.trim(),
          'p_notes': notes?.trim(),
          'p_payment_method': paymentMethod,
        },
      );

      final result = Map<String, dynamic>.from(res as Map);
      if (result['success'] != true) {
        throw result['message']?.toString() ?? 'فشل إنشاء الطلب';
      }

      return result;
    } catch (e) {
      throw 'حدث خطأ أثناء إنشاء الطلب: $e';
    }
  }

  /// جلب كافة طلبات العميل الحالي
  Future<List<OrderModel>> fetchUserOrders() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];

    try {
      final data = await _client.from(SupabaseTables.orders).select('''
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
      ''').eq('user_id', uid).order('created_at', ascending: false);

      return (data as List).map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      throw 'فشل جلب قائمة الطلبات: $e';
    }
  }

  /// جلب تفاصيل طلب محدد بالـ ID
  Future<OrderModel?> fetchOrderDetail(String orderId) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;

    try {
      final data = await _client.from(SupabaseTables.orders).select('''
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
      ''').eq('id', orderId).maybeSingle();

      if (data == null) return null;
      return OrderModel.fromJson(data);
    } catch (e) {
      throw 'فشل جلب تفاصيل الطلب: $e';
    }
  }

  /// إلغاء طلب قيد المراجعة
  Future<bool> cancelOrder(String orderId) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return false;

    try {
      await _client
          .from(SupabaseTables.orders)
          .update({
            'order_status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId)
          .eq('user_id', uid)
          .eq('order_status', 'pending');

      return true;
    } catch (e) {
      throw 'حدث خطأ أثناء إلغاء الطلب: $e';
    }
  }
}
