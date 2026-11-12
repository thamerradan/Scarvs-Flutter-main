// يدير عناصر سلة التسوق وحساب إجمالياتها.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scarvs/features/cart/data/models/cart_item_model.dart';
import 'package:scarvs/features/cart/data/cart_service.dart';
import 'package:scarvs/core/utils/snackbar_util.dart';

class CartNotifier with ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItemModel> _cartItems = [];
  List<CartItemModel> get cartItems => _cartItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double _shippingFee = 25.0;
  double _freeShippingLimit = 300.0;

  double get shippingFee => _shippingFee;
  double get freeShippingLimit => _freeShippingLimit;

  double get subtotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isFreeShipping =>
      _freeShippingLimit > 0 && subtotal >= _freeShippingLimit;

  double get actualShippingFee =>
      (subtotal > 0 && isFreeShipping) ? 0.0 : (_cartItems.isEmpty ? 0.0 : _shippingFee);

  double get total => subtotal + actualShippingFee;

  int get totalItemsCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => _cartItems.isEmpty;

  /// تحميل عناصر السلة وإعدادات التوصيل
  Future<List<CartItemModel>> loadCart({
    BuildContext? context,
    bool silent = false,
  }) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final shippingConfig = await _cartService.fetchShippingConfig();
      _shippingFee = shippingConfig['shipping_fee'] ?? 25.0;
      _freeShippingLimit = shippingConfig['free_shipping_limit'] ?? 300.0;

      final items = await _cartService.fetchCartItems();
      _cartItems = items;
      return _cartItems;
    } on SocketException catch (_) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'يرجى التحقق من اتصالك بالإنترنت',
            context: context,
          ),
        );
      }
      return [];
    } catch (_) {
      return [];
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /// دعم التوافق مع الشاشة القديمة
  Future<List<CartItemModel>?> checkCartData({
    required BuildContext context,
    required String useremail,
  }) async {
    final list = await loadCart(context: context);
    return list.isEmpty ? null : list;
  }

  /// إضافة منتج إلى السلة مع تحديث فوري للواجهة ومزامنة في الخلفية (Optimistic Update)
  Future<bool> addToCart({
    String? useremail,
    required String productPrice,
    required String productName,
    required String productCategory,
    required String productImage,
    required BuildContext context,
    required String productSize,
    String? productId,
    String? variantId,
  }) async {
    final pid = productId ?? '';
    final parsedPrice = double.tryParse(productPrice) ?? 0.0;
    final previousItems = List<CartItemModel>.from(_cartItems);

    // 1. التحديث الفوري للواجهة (Optimistic UI Update)
    final existingIndex = _cartItems.indexWhere(
      (c) =>
          (pid.isNotEmpty && c.productId == pid) &&
          (variantId == null || c.variantId == variantId),
    );

    if (existingIndex != -1) {
      final currentItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = currentItem.copyWith(
        quantity: currentItem.quantity + 1,
      );
    } else {
      final tempItem = CartItemModel(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        userId: '',
        productId: pid.isNotEmpty ? pid : productName,
        variantId: variantId,
        quantity: 1,
        productName: productName,
        productPrice: parsedPrice,
        productImage: productImage,
        productSize: productSize,
        stockQuantity: 99,
        isAvailable: true,
      );
      _cartItems.add(tempItem);
    }
    // إشعار مستمعي الحالة بتحديث السلة والعداد فوراً
    notifyListeners();

    // 2. المزامنة بالخلفية مع قاعدة البيانات
    try {
      final success = await _cartService.addToCart(
        productId: pid.isNotEmpty ? pid : productName,
        variantId: variantId,
        quantity: 1,
      );

      if (success) {
        // مزامنة البيانات بصمت في الخلفية
        await loadCart(silent: true);
        return true;
      } else {
        // التراجع في حال فشل الإضافة
        _cartItems = previousItems;
        notifyListeners();
        return false;
      }
    } on SocketException catch (_) {
      _cartItems = previousItems;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'يرجى التحقق من اتصالك بالإنترنت',
            context: context,
          ),
        );
      }
      return false;
    } catch (e) {
      _cartItems = previousItems;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: e.toString(),
            context: context,
          ),
        );
      }
      return false;
    }
  }

  /// زيادة كمية عنصر في السلة مع تحديث فوري ومزامنة بالخلفية
  Future<void> incrementQuantity(
    CartItemModel item, {
    BuildContext? context,
  }) async {
    if (item.quantity >= item.stockQuantity) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'عذراً، وصلت إلى الحد الأقصى المتوفر بالمخزون (${item.stockQuantity})',
            context: context,
          ),
        );
      }
      return;
    }

    final newQty = item.quantity + 1;
    final index = _cartItems.indexWhere((c) => c.id == item.id);
    if (index != -1) {
      _cartItems[index] = item.copyWith(quantity: newQty);
      notifyListeners();
    }

    try {
      await _cartService.updateQuantity(
        cartItemId: item.id,
        newQuantity: newQty,
      );
      await loadCart(silent: true);
    } catch (_) {
      await loadCart(silent: true);
    }
  }

  /// تقليل كمية عنصر في السلة مع تحديث فوري ومزامنة بالخلفية
  Future<void> decrementQuantity(
    CartItemModel item, {
    BuildContext? context,
  }) async {
    final newQty = item.quantity - 1;
    if (newQty <= 0) {
      await deleteCartItem(item.id, context: context);
      return;
    }

    final index = _cartItems.indexWhere((c) => c.id == item.id);
    if (index != -1) {
      _cartItems[index] = item.copyWith(quantity: newQty);
      notifyListeners();
    }

    try {
      await _cartService.updateQuantity(
        cartItemId: item.id,
        newQuantity: newQty,
      );
      await loadCart(silent: true);
    } catch (_) {
      await loadCart(silent: true);
    }
  }

  /// حذف عنصر من السلة مع تحديث فوري ومزامنة بالخلفية
  Future<bool> deleteCartItem(
    String cartItemId, {
    BuildContext? context,
  }) async {
    final previousItems = List<CartItemModel>.from(_cartItems);
    _cartItems.removeWhere((c) => c.id == cartItemId);
    notifyListeners();

    try {
      final success = await _cartService.deleteFromCart(cartItemId);
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'تم حذف الحذاء من السلة',
            context: context,
          ),
        );
      }
      await loadCart(silent: true);
      return success;
    } catch (e) {
      _cartItems = previousItems;
      notifyListeners();
      return false;
    }
  }

  /// دعم التوافق مع الدوال القديمة
  Future<bool> deleteFromCart({
    required BuildContext context,
    required dynamic productId,
  }) async {
    final item = _cartItems.firstWhere(
      (c) => c.id == productId.toString() || c.productId == productId.toString(),
      orElse: () => _cartItems.first,
    );
    return await deleteCartItem(item.id, context: context);
  }

  void refresh() {
    loadCart();
  }
}
