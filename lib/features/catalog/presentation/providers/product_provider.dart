// يدير بيانات المنتجات والتصنيفات وعمليات تحميلها.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scarvs/features/catalog/data/models/category_model.dart';
import 'package:scarvs/features/catalog/data/models/product_model.dart';
import 'package:scarvs/features/catalog/data/product_service.dart';
import 'package:scarvs/core/utils/snackbar_util.dart';

class ProductNotifier with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  List<ProductItem> _products = [];
  List<ProductItem> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasLoaded = false;
  bool get hasLoaded => _hasLoaded;

  ProductItem? _currentProduct;
  ProductItem? get currentProduct => _currentProduct;


  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  void setSelectedCategory(String? categoryName) {
    _selectedCategory = categoryName;
    notifyListeners();
  }

  /// تحميل البيانات الأولية للرئيسية (التصنيفات والمنتجات) مرة واحدة مع التخزين المؤقت
  Future<void> loadInitialData({bool refresh = false, BuildContext? context}) async {
    if (_hasLoaded && !refresh && _products.isNotEmpty && _categories.isNotEmpty) {
      return;
    }


    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _productService.fetchCategories(),
        _productService.fetchProducts(),
      ]);

      _categories = results[0] as List<CategoryModel>;
      _products = results[1] as List<ProductItem>;
      _hasLoaded = true;
    } on SocketException catch (_) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'يرجى التحقق من اتصالك بالإنترنت',
            context: context,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading initial product data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب التصنيفات
  Future<List<CategoryModel>> fetchCategories({BuildContext? context}) async {
    if (_categories.isNotEmpty) return _categories;
    try {
      _categories = await _productService.fetchCategories();
      notifyListeners();
      return _categories;
    } catch (_) {
      return [];
    }
  }

  /// جلب كافة المنتجات
  Future<List<ProductItem>> fetchProducts({
    BuildContext? context,
    bool? featuredOnly,
    String? categoryId,
    String? categoryName,
  }) async {
    try {
      final list = await _productService.fetchProducts(
        featuredOnly: featuredOnly,
        categoryId: categoryId,
        categoryName: categoryName,
      );
      if (categoryId == null && categoryName == null && featuredOnly == null) {
        _products = list;
        notifyListeners();
      }
      return list;
    } catch (_) {
      return [];
    }
  }


  /// جلب تفاصيل المنتج بالـ ID
  Future<ProductItem?> fetchProductDetail({
    BuildContext? context,
    required dynamic id,
  }) async {
    try {
      final item = await _productService.fetchProductDetail(id.toString());
      _currentProduct = item;
      return item;
    } on SocketException catch (_) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'يرجى التحقق من اتصالك بالإنترنت',
            context: context,
          ),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error fetchProductDetail: $e');
      return null;
    }
  }

  /// جلب منتجات تصنيف معين بواسطة المعرّف أو الاسم
  Future<List<ProductItem>> fetchProductCategory({
    required BuildContext context,
    dynamic categoryName,
    String? categoryId,
  }) async {
    try {
      final list = await _productService.fetchProducts(
        categoryId: categoryId,
        categoryName: categoryName?.toString(),
      );
      return list;
    } on SocketException catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'يرجى التحقق من اتصالك بالإنترنت',
            context: context,
          ),
        );
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// البحث عن منتج بالاسم
  Future<List<ProductItem>> searchProduct({
    required BuildContext context,
    required dynamic productName,
  }) async {
    try {
      final list = await _productService.fetchProducts(
        searchQuery: productName?.toString(),
      );
      return list;
    } on SocketException catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'يرجى التحقق من اتصالك بالإنترنت',
            context: context,
          ),
        );
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
