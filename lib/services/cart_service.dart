// ينفذ عمليات قراءة السلة وإضافة عناصرها وتحديثها وحذفها.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scarvs/models/cart_item_model.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_tables.dart';

class CartService {
  final SupabaseClient _client = AppSupabase.client;

  /// جلب عناصر سلة المستخدم الحالي
  Future<List<CartItemModel>> fetchCartItems() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];

    try {
      final data = await _client.from(SupabaseTables.cartItems).select('''
        id,
        user_id,
        product_id,
        variant_id,
        quantity,
        created_at,
        products (
          id,
          name,
          price,
          main_image_url,
          is_active
        ),
        product_variants (
          id,
          size,
          stock_quantity,
          is_available
        )
      ''').eq('user_id', uid).order('created_at', ascending: true);

      return (data as List).map((e) => CartItemModel.fromJson(e)).toList();
    } catch (e) {
      throw 'فشل جلب عناصر السلة: $e';
    }
  }

  /// إضافة منتج إلى السلة أو زيادة كميته إن كان موجوداً
  Future<bool> addToCart({
    required String productId,
    String? variantId,
    int quantity = 1,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw 'يجب تسجيل الدخول أولاً لإضافة منتجات إلى السلة';

    try {
      // إذا لم يتم تمرير variantId، نبحث عن المقاس الافتراضي المتوفر للمنتج
      String? targetVariantId = variantId;
      if (targetVariantId == null || targetVariantId.isEmpty) {
        final variants = await _client
            .from(SupabaseTables.productVariants)
            .select('id, stock_quantity, is_available')
            .eq('product_id', productId)
            .limit(1);

        if ((variants as List).isNotEmpty) {
          targetVariantId = variants.first['id'] as String;
        }
      }

      // التحقق مما إذا كان العنصر موجوداً بالفعل في سلة المستخدم
      var existingQuery = _client
          .from(SupabaseTables.cartItems)
          .select('id, quantity')
          .eq('user_id', uid)
          .eq('product_id', productId);

      if (targetVariantId != null) {
        existingQuery = existingQuery.eq('variant_id', targetVariantId);
      } else {
        existingQuery = existingQuery.filter('variant_id', 'is', null);
      }

      final existing = await existingQuery.maybeSingle();

      if (existing != null) {
        // تحديث الكمية بزيادتها
        final currentQty = (existing['quantity'] as num).toInt();
        await _client
            .from(SupabaseTables.cartItems)
            .update({'quantity': currentQty + quantity})
            .eq('id', existing['id']);
      } else {
        // إدخال عنصر جديد في السلة
        await _client.from(SupabaseTables.cartItems).insert({
          'user_id': uid,
          'product_id': productId,
          'variant_id': targetVariantId,
          'quantity': quantity,
        });
      }

      return true;
    } catch (e) {
      throw 'حدث خطأ أثناء الإضافة إلى السلة: $e';
    }
  }

  /// تعديل كمية عنصر في السلة
  Future<bool> updateQuantity({
    required String cartItemId,
    required int newQuantity,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return false;

    try {
      if (newQuantity <= 0) {
        return await deleteFromCart(cartItemId);
      }

      await _client
          .from(SupabaseTables.cartItems)
          .update({'quantity': newQuantity})
          .eq('id', cartItemId)
          .eq('user_id', uid);

      return true;
    } catch (e) {
      throw 'حدث خطأ أثناء تعديل الكمية: $e';
    }
  }

  /// حذف عنصر من السلة
  Future<bool> deleteFromCart(String cartItemId) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return false;

    try {
      await _client
          .from(SupabaseTables.cartItems)
          .delete()
          .eq('id', cartItemId)
          .eq('user_id', uid);

      return true;
    } catch (e) {
      throw 'حدث خطأ أثناء الحذف من السلة: $e';
    }
  }

  /// تفريغ السلة بالكامل
  Future<bool> clearCart() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return false;

    try {
      await _client
          .from(SupabaseTables.cartItems)
          .delete()
          .eq('user_id', uid);

      return true;
    } catch (e) {
      throw 'حدث خطأ أثناء تفريغ السلة: $e';
    }
  }

  /// جلب إعدادات رسوم التوصيل والحد الأدنى للشحن المجاني
  Future<Map<String, double>> fetchShippingConfig() async {
    try {
      final data = await _client
          .from(SupabaseTables.storeSettings)
          .select('shipping_fee, free_shipping_limit')
          .limit(1)
          .maybeSingle();

      if (data == null) {
        return {'shipping_fee': 25.0, 'free_shipping_limit': 300.0};
      }

      return {
        'shipping_fee': (data['shipping_fee'] as num?)?.toDouble() ?? 25.0,
        'free_shipping_limit':
            (data['free_shipping_limit'] as num?)?.toDouble() ?? 300.0,
      };
    } catch (_) {
      return {'shipping_fee': 25.0, 'free_shipping_limit': 300.0};
    }
  }
}
