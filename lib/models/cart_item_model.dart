// يمثل عنصر السلة وبيانات المنتج والكمية والمقاس.
class CartItemModel {
  final String id;
  final String userId;
  final String productId;
  final String? variantId;
  final int quantity;
  final String productName;
  final double productPrice;
  final String productImage;
  final String productSize;
  final int stockQuantity;
  final bool isAvailable;

  CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.productSize,
    required this.stockQuantity,
    this.isAvailable = true,
  });

  double get totalPrice => productPrice * quantity;
  bool get isStockSufficient => isAvailable && stockQuantity >= quantity;

  // توافق مع الحقول السابقة
  String get productCategory => '';

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['products'] as Map<String, dynamic>? ?? {};
    final variant = json['product_variants'] as Map<String, dynamic>? ?? {};

    return CartItemModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      variantId: json['variant_id'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      productName: product['name'] as String? ??
          json['product_name'] as String? ??
          'حذاء',
      productPrice: (product['price'] as num?)?.toDouble() ??
          double.tryParse(json['product_price']?.toString() ?? '0') ??
          0.0,
      productImage: product['main_image_url'] as String? ??
          json['product_image'] as String? ??
          '',
      productSize: variant['size'] as String? ??
          json['product_size'] as String? ??
          json['size'] as String? ??
          '',
      stockQuantity: (variant['stock_quantity'] as num?)?.toInt() ?? 99,
      isAvailable: (variant['is_available'] as bool?) ??
          (product['is_active'] as bool?) ??
          true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'variant_id': variantId,
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({
    int? quantity,
  }) {
    return CartItemModel(
      id: id,
      userId: userId,
      productId: productId,
      variantId: variantId,
      quantity: quantity ?? this.quantity,
      productName: productName,
      productPrice: productPrice,
      productImage: productImage,
      productSize: productSize,
      stockQuantity: stockQuantity,
      isAvailable: isAvailable,
    );
  }
}

