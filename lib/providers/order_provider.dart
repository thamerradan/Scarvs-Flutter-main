// يدير تحميل طلبات المستخدم وتفاصيلها وحالتها.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scarvs/models/order_model.dart';
import 'package:scarvs/services/order_service.dart';
import 'package:scarvs/core/utils/snackbar_util.dart';

class OrderNotifier with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  OrderModel? _currentOrder;
  OrderModel? get currentOrder => _currentOrder;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// جلب كافة طلبات العميل
  Future<List<OrderModel>> fetchUserOrders({BuildContext? context}) async {
    _setLoading(true);
    try {
      _orders = await _orderService.fetchUserOrders();
      notifyListeners();
      return _orders;
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
      _setLoading(false);
    }
  }

  /// جلب تفاصيل طلب محدد
  Future<OrderModel?> fetchOrderDetail(
    String orderId, {
    BuildContext? context,
  }) async {
    _setLoading(true);
    try {
      _currentOrder = await _orderService.fetchOrderDetail(orderId);
      notifyListeners();
      return _currentOrder;
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
    } catch (_) {
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// إتمام الطلب وإنشاؤه
  Future<Map<String, dynamic>?> placeOrder({
    required BuildContext context,
    required String shippingAddress,
    required String city,
    required String phone,
    String? notes,
    String paymentMethod = 'cash_on_delivery',
  }) async {
    _setLoading(true);
    try {
      final res = await _orderService.placeOrder(
        shippingAddress: shippingAddress,
        city: city,
        phone: phone,
        notes: notes,
        paymentMethod: paymentMethod,
      );

      // إعادة تحميل قائمة الطلبات
      await fetchUserOrders(context: context);
      return res;
    } on SocketException catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'يرجى التحقق من اتصالك بالإنترنت',
            context: context,
          ),
        );
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: e.toString(),
            context: context,
          ),
        );
      }
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// إلغاء الطلب
  Future<bool> cancelOrder(
    String orderId, {
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      final success = await _orderService.cancelOrder(orderId);
      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackUtil.stylishSnackBar(
              text: 'تم إلغاء الطلب بنجاح',
              context: context,
            ),
          );
        }
        await fetchUserOrders(context: context);
        if (_currentOrder?.id == orderId) {
          await fetchOrderDetail(orderId, context: context);
        }
      }
      return success;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: e.toString(),
            context: context,
          ),
        );
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تنظيف قائمة الطلبات عند تسجيل الخروج
  void clear() {
    _orders = [];
    _currentOrder = null;
    _isLoading = false;
    notifyListeners();
  }
}
