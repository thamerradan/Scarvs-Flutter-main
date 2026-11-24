/// أسماء الجداول والحاويات في Supabase
class SupabaseTables {
  // الجداول
  static const String profiles = 'profiles';
  static const String categories = 'categories';
  static const String products = 'products';
  static const String productImages = 'product_images';
  static const String productVariants = 'product_variants';
  static const String cartItems = 'cart_items';
  static const String orders = 'orders';
  static const String storeSettings = 'store_settings';
  static const String notifications = 'notifications';

  // حاويات التخزين (Storage Buckets)
  static const String productImagesBucket = 'product-images';
  static const String categoryImagesBucket = 'category-images';

  // الإجراءات المخزنة (RPCs)
  static const String placeOrderRpc = 'place_order_from_cart';
}

