// يمثل بيانات تصنيف المنتجات.
class CategoryModel {
  final String id;
  final String name;
  final String? imageUrl;
  final bool isActive;
  final int sortOrder;
  final DateTime? createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }
}

