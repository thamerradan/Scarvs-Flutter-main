// يدير المقاس المحدد لمتغيرات المنتج.
import 'package:flutter/material.dart';
import 'package:scarvs/models/product_variant_model.dart';

class SizeNotifier with ChangeNotifier {
  String _size = '41';
  ProductVariant? _selectedVariant;

  String get size => _size;
  String get getSize => _size;
  ProductVariant? get selectedVariant => _selectedVariant;

  void selectVariant(ProductVariant variant) {
    _selectedVariant = variant;
    _size = variant.size;
    notifyListeners();
  }

  void selectSizeString(String newSize) {
    _size = newSize;
    notifyListeners();
  }

  void initForProduct(List<ProductVariant> variants) {
    if (variants.isNotEmpty) {
      // اختيار أول مقاس متوفر في المخزون افتراضياً
      final available = variants.firstWhere(
        (v) => v.inStock,
        orElse: () => variants.first,
      );
      _selectedVariant = available;
      _size = available.size;
    }
  }

}
