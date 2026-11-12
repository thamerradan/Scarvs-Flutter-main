// يمثل إعدادات المتجر مثل الشحن وطرق الدفع.
class StoreSettingsModel {
  final String id;
  final String storeName;
  final String? logoUrl;
  final String? phone;
  final String? whatsapp;
  final double shippingFee;
  final double freeShippingLimit;
  final bool cashOnDeliveryEnabled;
  final bool onlinePaymentEnabled;
  final bool maintenanceMode;

  StoreSettingsModel({
    required this.id,
    required this.storeName,
    this.logoUrl,
    this.phone,
    this.whatsapp,
    required this.shippingFee,
    required this.freeShippingLimit,
    required this.cashOnDeliveryEnabled,
    required this.onlinePaymentEnabled,
    required this.maintenanceMode,
  });

  factory StoreSettingsModel.fromJson(Map<String, dynamic> json) {
    return StoreSettingsModel(
      id: json['id'] as String? ?? '',
      storeName: json['store_name'] as String? ?? 'متجر سكارفس للأحذية',
      logoUrl: json['logo_url'] as String?,
      phone: json['phone'] as String? ?? '+966500000000',
      whatsapp: json['whatsapp'] as String? ?? '+966500000000',
      shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 25.00,
      freeShippingLimit: (json['free_shipping_limit'] as num?)?.toDouble() ?? 300.00,
      cashOnDeliveryEnabled: json['cash_on_delivery_enabled'] as bool? ?? true,
      onlinePaymentEnabled: json['online_payment_enabled'] as bool? ?? false,
      maintenanceMode: json['maintenance_mode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_name': storeName,
      'logo_url': logoUrl,
      'phone': phone,
      'whatsapp': whatsapp,
      'shipping_fee': shippingFee,
      'free_shipping_limit': freeShippingLimit,
      'cash_on_delivery_enabled': cashOnDeliveryEnabled,
      'online_payment_enabled': onlinePaymentEnabled,
      'maintenance_mode': maintenanceMode,
    };
  }

  StoreSettingsModel copyWith({
    String? id,
    String? storeName,
    String? logoUrl,
    String? phone,
    String? whatsapp,
    double? shippingFee,
    double? freeShippingLimit,
    bool? cashOnDeliveryEnabled,
    bool? onlinePaymentEnabled,
    bool? maintenanceMode,
  }) {
    return StoreSettingsModel(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      logoUrl: logoUrl ?? this.logoUrl,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      shippingFee: shippingFee ?? this.shippingFee,
      freeShippingLimit: freeShippingLimit ?? this.freeShippingLimit,
      cashOnDeliveryEnabled: cashOnDeliveryEnabled ?? this.cashOnDeliveryEnabled,
      onlinePaymentEnabled: onlinePaymentEnabled ?? this.onlinePaymentEnabled,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
    );
  }
}

