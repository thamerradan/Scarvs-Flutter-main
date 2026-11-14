// يدير حالة المالك والبيانات المشتركة لواجهات الإدارة.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scarvs/models/category_model.dart';
import 'package:scarvs/models/dashboard_stats_model.dart';
import 'package:scarvs/models/order_model.dart';
import 'package:scarvs/models/product_model.dart';
import 'package:scarvs/models/store_settings_model.dart';
import 'package:scarvs/services/owner/owner_categories_service.dart';
import 'package:scarvs/services/owner/owner_dashboard_service.dart';
import 'package:scarvs/services/owner/owner_inventory_service.dart';
import 'package:scarvs/services/owner/owner_orders_service.dart';
import 'package:scarvs/services/owner/owner_products_service.dart';
import 'package:scarvs/services/owner/owner_settings_service.dart';
import 'package:scarvs/core/utils/snackbar_util.dart';

class OwnerNotifier with ChangeNotifier {
  final OwnerDashboardService _dashboardService = OwnerDashboardService();
  final OwnerOrdersService _ordersService = OwnerOrdersService();
  final OwnerProductsService _productsService = OwnerProductsService();
  final OwnerInventoryService _inventoryService = OwnerInventoryService();
  final OwnerCategoriesService _categoriesService = OwnerCategoriesService();
  final OwnerSettingsService _settingsService = OwnerSettingsService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  // 1. الإحصائيات
  DashboardStatsModel _stats = DashboardStatsModel();
  DashboardStatsModel get stats => _stats;

  // 2. الطلبات
  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;
  String _selectedStatus = 'all';
  String get selectedStatus => _selectedStatus;

  // 3. المنتجات
  List<ProductItem> _products = [];
  List<ProductItem> get products => _products;

  // 4. المخزون
  List<Map<String, dynamic>> _inventory = [];
  List<Map<String, dynamic>> get inventory => _inventory;

  // 5. التصنيفات
  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  // 6. الإعدادات
  StoreSettingsModel? _storeSettings;
  StoreSettingsModel? get storeSettings => _storeSettings;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  // ===========================================================================
  // 1. Dashboard
  // ===========================================================================

  Future<void> fetchDashboard({BuildContext? context}) async {
    _setLoading(true);
    try {
      _stats = await _dashboardService.fetchDashboardStats();
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(text: e.toString(), context: context),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================================
  // 2. Orders
  // ===========================================================================

  Future<void> fetchOrders(
      {String? statusFilter, BuildContext? context}) async {
    _setLoading(true);
    if (statusFilter != null) {
      _selectedStatus = statusFilter;
    }
    try {
      _orders =
          await _ordersService.fetchAllOrders(statusFilter: _selectedStatus);
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(text: e.toString(), context: context),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateOrderStatus(
    String orderId,
    String newStatus, {
    required BuildContext context,
  }) async {
    try {
      await _ordersService.updateOrderStatus(orderId, newStatus);
      // تحديث الحالة محلياً في القائمة فوراً
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final current = _orders[index];
        _orders[index] = OrderModel(
          id: current.id,
          orderNumber: current.orderNumber,
          userId: current.userId,
          subtotal: current.subtotal,
          shippingFee: current.shippingFee,
          discount: current.discount,
          total: current.total,
          paymentMethod: current.paymentMethod,
          paymentStatus: current.paymentStatus,
          orderStatus: newStatus,
          shippingAddress: current.shippingAddress,
          city: current.city,
          phone: current.phone,
          notes: current.notes,
          createdAt: current.createdAt,
          updatedAt: DateTime.now(),
          items: current.items,
          customerName: current.customerName,
          customerEmail: current.customerEmail,
        );
        notifyListeners();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'تم تحديث حالة الطلب بنجاح ✅',
            context: context,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(text: e.toString(), context: context),
        );
      }
      return false;
    }
  }

  // ===========================================================================
  // 3. Products
  // ===========================================================================

  Future<void> fetchProducts({BuildContext? context}) async {
    _setLoading(true);
    try {
      _products = await _productsService.fetchAllOwnerProducts();
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(text: e.toString(), context: context),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveProduct({
    String? id,
    required String name,
    required String description,
    required double price,
    double? oldPrice,
    String? categoryId,
    String? mainImageUrl,
    File? imageFile,
    List<File> newImageFiles = const [],
    List<String> existingImageUrls = const [],
    bool isActive = true,
    bool isFeatured = false,
    required List<Map<String, dynamic>> variants,
    required BuildContext context,
  }) async {
    _setSaving(true);
    try {
      final prodId = await _productsService.saveProduct(
        id: id,
        name: name,
        description: description,
        price: price,
        oldPrice: oldPrice,
        categoryId: categoryId,
        mainImageUrl: mainImageUrl,
        imageFile: imageFile,
        newImageFiles: newImageFiles,
        existingImageUrls: existingImageUrls,
        isActive: isActive,
        isFeatured: isFeatured,
      );

      await _productsService.saveProductVariants(prodId, variants);
      await fetchProducts();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: id == null
                ? 'تمت إضافة المنتج بنجاح 🎉'
                : 'تم تعديل المنتج بنجاح ✅',
            context: context,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(text: e.toString(), context: context),
        );
      }
      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<void> toggleProductStatus(
    String productId,
    bool isActive, {
    required BuildContext context,
  }) async {
    try {
      await _productsService.toggleProductActive(productId, isActive);
      final idx = _products.indexWhere((p) => p.id == productId);
      if (idx != -1) {
        _products[idx] = ProductItem(
          id: _products[idx].id,
          name: _products[idx].name,
          description: _products[idx].description,
          price: _products[idx].price,
          oldPrice: _products[idx].oldPrice,
          categoryId: _products[idx].categoryId,
          categoryName: _products[idx].categoryName,
          mainImageUrl: _products[idx].mainImageUrl,
          isActive: isActive,
          isFeatured: _products[idx].isFeatured,
          variants: _products[idx].variants,
          images: _products[idx].images,
        );
        notifyListeners();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(text: e.toString(), context: context),
        );
      }
    }
  }

  Future<bool> deleteProduct(String productId,
      {required BuildContext context}) async {
    try {
      await _productsService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'تم حذف المنتج بنجاح 🗑️',
            context: context,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(text: e.toString(), context: context),
        );
      }
      return false;
    }
  }

  // ===========================================================================
  // 4. Inventory
  // ===========================================================================

  Future<void> fetchInventory({BuildContext? context}) async {
    _setLoading(true);
    try {
      _inventory = await _inventoryService.fetchInventoryList();
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(text: e.toString(), context: context),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateStock(
    String variantId,
    int newStock, {
    required BuildContext context,
  }) async {
    try {
      await _inventoryService.updateVariantStock(variantId, newStock);
      final idx = _inventory.indexWhere((v) => v['id'] == variantId);
      if (idx != -1) {
        _inventory[idx]['stock_quantity'] = newStock;
        _inventory[idx]['is_available'] = newStock > 0;
        notifyListeners();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'تم تحديث المخزون إلى $newStock قطعة ✅',
            context: context,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(text: e.toString(), context: context),
        );
      }
    }
  }

  // ===========================================================================
  // 5. Categories
  // ===========================================================================

  Future<void> fetchCategories({BuildContext? context}) async {
    _setLoading(true);
    try {
      _categories = await _categoriesService.fetchAllCategories();
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(text: e.toString(), context: context),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addCategory({
    required String name,
    String? imageUrl,
    File? imageFile,
    int sortOrder = 0,
    required BuildContext context,
  }) async {
    _setSaving(true);
    try {
      await _categoriesService.addCategory(
        name: name,
        imageUrl: imageUrl,
        imageFile: imageFile,
        sortOrder: sortOrder,
      );
      await fetchCategories();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'تمت إضافة التصنيف بنجاح ✅',
            context: context,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(text: e.toString(), context: context),
        );
      }
      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> updateCategory({
    required String id,
    required String name,
    String? imageUrl,
    File? imageFile,
    int? sortOrder,
    bool? isActive,
    required BuildContext context,
  }) async {
    _setSaving(true);
    try {
      await _categoriesService.updateCategory(
        id: id,
        name: name,
        imageUrl: imageUrl,
        imageFile: imageFile,
        sortOrder: sortOrder,
        isActive: isActive,
      );
      await fetchCategories();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'تم تعديل التصنيف بنجاح ✅',
            context: context,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(text: e.toString(), context: context),
        );
      }
      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> deleteCategory(
    String categoryId, {
    required BuildContext context,
  }) async {
    try {
      await _categoriesService.deleteCategory(categoryId);
      _categories.removeWhere((c) => c.id == categoryId);
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'تم حذف التصنيف 🗑️',
            context: context,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(text: e.toString(), context: context),
        );
      }
      return false;
    }
  }

  // ===========================================================================
  // 6. Settings
  // ===========================================================================

  Future<void> fetchStoreSettings({BuildContext? context}) async {
    _setLoading(true);
    try {
      _storeSettings = await _settingsService.fetchStoreSettings();
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(text: e.toString(), context: context),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveStoreSettings(
    StoreSettingsModel settings, {
    required BuildContext context,
  }) async {
    _setSaving(true);
    try {
      await _settingsService.updateStoreSettings(settings);
      _storeSettings = settings;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'تم حفظ إعدادات المتجر بنجاح ✅',
            context: context,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(text: e.toString(), context: context),
        );
      }
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// تنظيف بيانات لوحة تحكم المالك عند تسجيل الخروج
  void clear() {
    _stats = DashboardStatsModel();
    _orders = [];
    _selectedStatus = 'all';
    _products = [];
    _inventory = [];
    _categories = [];
    _storeSettings = null;
    _isLoading = false;
    _isSaving = false;
    notifyListeners();
  }
}
