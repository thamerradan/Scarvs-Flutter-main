// يمثل الطلب وبياناته وحالته وعناصره.
import 'package:flutter/material.dart';
import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String shippingAddress;
  final String city;
  final String phone;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItemModel> items;
  final String? customerName;
  final String? customerEmail;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.shippingAddress,
    required this.city,
    required this.phone,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.items = const [],
    this.customerName,
    this.customerEmail,
  });

  bool get canCancel => orderStatus == 'pending';

  String get statusArabic => orderStatusArabic;

  String get orderStatusArabic {
    switch (orderStatus.toLowerCase()) {
      case 'pending':
        return 'قيد المراجعة';
      case 'confirmed':
        return 'تم التأكيد';
      case 'preparing':
        return 'جاري التجهيز';
      case 'shipped':
        return 'تم الشحن 🚚';
      case 'delivered':
        return 'تم التسليم بنجاح ✅';
      case 'cancelled':
        return 'ملغي ❌';
      default:
        return orderStatus;
    }
  }

  Color get statusColor {
    switch (orderStatus.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'shipped':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (orderStatus.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.inventory_2_outlined;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.task_alt;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String get paymentMethodArabic {
    switch (paymentMethod.toLowerCase()) {
      case 'cash_on_delivery':
      default:
        return 'الدفع عند الاستلام';
    }
  }

  String get paymentStatusArabic {
    switch (paymentStatus.toLowerCase()) {
      case 'cash_on_delivery':
        return 'عند الاستلام';
      case 'paid':
        return 'تم الدفع';
      case 'pending':
        return 'معلق';
      case 'failed':
        return 'فشلت العملية';
      case 'refunded':
        return 'مسترجع';
      default:
        return paymentStatus;
    }
  }

  int get totalItemsCount => items.fold(0, (sum, i) => sum + i.quantity);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItemModel> itemsList = [];
    if (json['order_items'] != null && json['order_items'] is List) {
      itemsList = (json['order_items'] as List)
          .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    String? customerName;
    String? customerEmail;
    if (json['profiles'] != null && json['profiles'] is Map) {
      final profile = json['profiles'] as Map<String, dynamic>;
      customerName = profile['full_name']?.toString();
      customerEmail = profile['email']?.toString();
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ?? 'ORD-000',
      userId: json['user_id']?.toString() ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method']?.toString() ?? 'cash_on_delivery',
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      orderStatus: json['order_status']?.toString() ?? 'pending',
      shippingAddress: json['shipping_address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      items: itemsList,
      customerName: customerName,
      customerEmail: customerEmail,
    );
  }
}
