// يدير بيانات المنتجات والأصناف وعمليات تحميلها وتخزينها المؤقت محلياً.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scarvs/models/category_model.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/services/catalog_service.dart';
import 'package:scarvs/core/utils/snackbar_util.dart';

class CatalogProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  static const String _cachedCategoriesKey = 'cached_categories_json';
  static const String _cachedProductsKey = 'cached_products_json';
  static const String _cachedCatalogTimeKey = 'cached_catalog_timestamp';
  static const Duration _cacheTtl = Duration(minutes: 10);

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  List<ProductItem> _products = [];
  List<ProductItem> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasLoaded = false;
  bool get hasLoaded => _hasLoaded;

  /// إبطال كاش الكتالوج حتى يعاد جلبه عند فتح متجر العميل
  void invalidate() {
    _hasLoaded = false;
  }

  /// استرجاع البيانات المخزنة محلياً للعرض الفوري وفحص عمر الكاش
  Future<bool> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastTimeMs = prefs.getInt(_cachedCatalogTimeKey) ?? 0;
      final cachedCatsRaw = prefs.getString(_cachedCategoriesKey);
      final cachedProdsRaw = prefs.getString(_cachedProductsKey);

      bool updated = false;
      if (cachedCatsRaw != null && _categories.isEmpty) {
        final List list = jsonDecode(cachedCatsRaw) as List;
        _categories = list
            .map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
            .toList();
        updated = true;
      }
      if (cachedProdsRaw != null && _products.isEmpty) {
        final List list = jsonDecode(cachedProdsRaw) as List;
        _products = list
            .map((p) => ProductItem.fromJson(p as Map<String, dynamic>))
            .toList();
        updated = true;
      }
      if (updated) {
        notifyListeners();
      }

      final isFresh = (DateTime.now().millisecondsSinceEpoch - lastTimeMs) <
          _cacheTtl.inMilliseconds;
      return updated && isFresh;
    } catch (e) {
      debugPrint('Error loading cached catalog: $e');
      return false;
    }
  }

  /// حفظ البيانات محلياً مع ختم الوقت
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          _cachedCatalogTimeKey, DateTime.now().millisecondsSinceEpoch);
      await prefs.setString(
        _cachedCategoriesKey,
        jsonEncode(_categories.map((c) => c.toJson()).toList()),
      );
      await prefs.setString(
        _cachedProductsKey,
        jsonEncode(_products.map((p) => p.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving catalog to cache: $e');
    }
  }

  /// تحميل البيانات الأولية للرئيسية (الأصناف والمنتجات) مع التخزين المؤقت والعرض اللحظي
  Future<void> loadInitialData(
      {bool refresh = false, BuildContext? context}) async {
    if (_isLoading) return;

    // 1. عرض البيانات من الكاش المحلي فوراً إن وجدت
    bool cacheIsFresh = false;
    if (_products.isEmpty || _categories.isEmpty) {
      cacheIsFresh = await _loadFromCache();
    }

    // إذا كان الكاش حديثاً ولم يُطلب تحديث صريح، نكتفي به لتوفير الاستعلامات
    if (cacheIsFresh && !refresh && _hasLoaded) {
      return;
    }

    if (_hasLoaded &&
        !refresh &&
        _products.isNotEmpty &&
        _categories.isNotEmpty) {
      return;
    }

    // 2. إذا توفرت بيانات من الكاش، لا نعيق المستخدم بمؤشر تحميل
    _isLoading = _products.isEmpty || _categories.isEmpty;
    if (_isLoading) {
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        _productService.fetchCategories(),
        _productService.fetchProducts(),
      ]);

      _categories = results[0] as List<CategoryModel>;
      _products = results[1] as List<ProductItem>;
      _hasLoaded = true;

      // حفظ أحدث نسخة محلية مجمعة
      _saveToCache();
    } on SocketException catch (_) {
      if (_products.isEmpty && context != null && context.mounted) {
        SnackUtil.showNetworkError(context);
      }
    } catch (e) {
      debugPrint('Error loading initial product data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب تفاصيل المنتج بالـ ID
  Future<ProductItem?> fetchProductDetail({
    BuildContext? context,
    required dynamic id,
  }) async {
    try {
      return await _productService.fetchProductDetail(id.toString());
    } on SocketException catch (_) {
      SnackUtil.showNetworkError(context);
      return null;
    } catch (e) {
      debugPrint('Error fetchProductDetail: $e');
      return null;
    }
  }

  /// تنفيذ استعلام منتجات مع معالجة أخطاء الشبكة بشكل موحد
  Future<List<ProductItem>> _runProductQuery(
    BuildContext context,
    Future<List<ProductItem>> Function() query,
  ) async {
    try {
      return await query();
    } on SocketException catch (_) {
      if (context.mounted) SnackUtil.showNetworkError(context);
      return [];
    } catch (_) {
      return [];
    }
  }

  /// جلب منتجات تصنيف معين بواسطة المعرّف أو الاسم
  Future<List<ProductItem>> fetchProductCategory({
    required BuildContext context,
    dynamic categoryName,
    String? categoryId,
  }) {
    return _runProductQuery(
      context,
      () => _productService.fetchProducts(
        categoryId: categoryId,
        categoryName: categoryName?.toString(),
      ),
    );
  }

  /// البحث عن منتج بالاسم
  Future<List<ProductItem>> searchProduct({
    required BuildContext context,
    required dynamic productName,
  }) {
    return _runProductQuery(
      context,
      () => _productService.fetchProducts(
        searchQuery: productName?.toString(),
      ),
    );
  }
}
