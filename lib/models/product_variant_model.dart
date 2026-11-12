// يمثل متغيرات المنتج مثل المقاس والمخزون والتوفر.
class ProductVariant {
  final String id;
  final String productId;
  final String size;
  final int stockQuantity;
  final bool isAvailable;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.size,
    this.stockQuantity = 0,
    this.isAvailable = true,
  });

  bool get inStock => isAvailable && stockQuantity > 0;
  int get stock => stockQuantity;

  String get stockStatusArabic {
    if (!isAvailable || stockQuantity <= 0) return 'نفد من المخزون';
    if (stockQuantity <= 3) return 'متبقي $stockQuantity فقط!';
    return 'متوفر ($stockQuantity)';
  }

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id']?.toString() ?? '',
      productId: json['product_id'] as String? ?? '',
      size: json['size'] as String? ?? '',
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'size': size,
      'stock_quantity': stockQuantity,
      'is_available': isAvailable,
    };
  }
}