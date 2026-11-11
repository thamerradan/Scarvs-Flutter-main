// يدير المقاس المحدد لمتغيرات المنتج.
import 'package:flutter/material.dart';
import 'package:scarvs/features/catalog/data/models/product_variant_model.dart';

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

  // دعم التوافق مع الكود القديم
  bool get sizeEight => _size == '8' || _size == '40';
  bool get sizeNine => _size == '9' || _size == '41';
  bool get sizeTen => _size == '10' || _size == '42';
  bool get sizeEleven => _size == '11' || _size == '43';

  void selectSizeEight() {
    _size = '40';
    notifyListeners();
  }

  void selectSizeNine() {
    _size = '41';
    notifyListeners();
  }

  void selectSizeTen() {
    _size = '42';
    notifyListeners();
  }

  void selectSizeEleven() {
    _size = '43';
    notifyListeners();
  }
}
