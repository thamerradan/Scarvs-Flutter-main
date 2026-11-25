// يمثل بيانات المنتج المعروضة والمستخدمة في المتجر.
import 'package:scarvs/models/product_variant_model.dart';

class ProductItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? oldPrice;
  final String? categoryId;
  final String? categoryName;
  final String mainImageUrl;
  final bool isActive;
  final bool isFeatured;
  final List<String> images;
  final List<ProductVariant> variants;

  ProductItem({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    this.oldPrice,
    this.categoryId,
    this.categoryName,
    required this.mainImageUrl,
    this.isActive = true,
    this.isFeatured = false,
    this.images = const [],
    this.variants = const [],
  });

  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  int? get discountPercentage {
    if (!hasDiscount) return null;
    return (((oldPrice! - price) / oldPrice!) * 100).round();
  }

  int get totalStock => variants.fold(0, (sum, v) => sum + v.stockQuantity);
  bool get inStock => variants.isEmpty ? true : totalStock > 0;

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    // قراءة صور المنتج إن وجدت
    List<String> imgList = [];
    if (json['product_images'] != null && json['product_images'] is List) {
      imgList = (json['product_images'] as List)
          .map((img) => img['image_url']?.toString() ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    }
    final mainImg = json['main_image_url']?.toString() ??
        json['product_image']?.toString() ??
        (imgList.isNotEmpty ? imgList.first : '');

    // بناء قائمة جميع صور المنتج وتفادي التكرار
    final List<String> allImages = [];
    if (mainImg.isNotEmpty) {
      allImages.add(mainImg);
    }
    for (final url in imgList) {
      if (!allImages.contains(url)) {
        allImages.add(url);
      }
    }

    // قراءة المقاسات والمخزون إن وجدت
    List<ProductVariant> varList = [];
    if (json['product_variants'] != null && json['product_variants'] is List) {
      varList = (json['product_variants'] as List)
          .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    // قراءة اسم الصنف
    String? catName;
    if (json['categories'] != null && json['categories'] is Map) {
      catName = json['categories']['name']?.toString();
    } else if (json['category_name'] != null) {
      catName = json['category_name']?.toString();
    }

    return ProductItem(
      id: json['id']?.toString() ?? json['product_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['product_name']?.toString() ?? '',
      description: json['description']?.toString() ??
          json['product_description']?.toString() ??
          '',
      price: (json['price'] as num?)?.toDouble() ??
          double.tryParse(json['product_price']?.toString() ?? '0') ??
          0.0,
      oldPrice: (json['old_price'] as num?)?.toDouble(),
      categoryId: json['category_id']?.toString(),
      categoryName: catName,
      mainImageUrl: mainImg,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      images: allImages,
      variants: varList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'old_price': oldPrice,
      'category_id': categoryId,
      'category_name': categoryName,
      'main_image_url': mainImageUrl,
      'is_active': isActive,
      'is_featured': isFeatured,
      'product_images': images.map((url) => {'image_url': url}).toList(),
      'product_variants': variants.map((v) => v.toJson()).toList(),
    };
  }
}
