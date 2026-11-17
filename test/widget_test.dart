// يختبر نماذج متغيرات المنتج وإعدادات المتجر.
import 'package:flutter_test/flutter_test.dart';
import 'package:scarvs/models/product_variant_model.dart';
import 'package:scarvs/models/store_settings_model.dart';

void main() {
  test('ProductVariant model test', () {
    final variant = ProductVariant(
      id: '1',
      productId: 'p1',
      size: '42',
      stockQuantity: 5,
      isAvailable: true,
    );

    expect(variant.size, '42');
    expect(variant.stock, 5);
    expect(variant.inStock, true);
  });

  test('StoreSettingsModel test', () {
    final settings = StoreSettingsModel(
      id: 's1',
      storeName: 'متجر تنمى للملابس',
      shippingFee: 25.0,
      freeShippingLimit: 300.0,
      cashOnDeliveryEnabled: true,
      onlinePaymentEnabled: true,
      maintenanceMode: false,
    );

    expect(settings.storeName, 'متجر تنمى للملابس');
    expect(settings.shippingFee, 25.0);
    expect(settings.cashOnDeliveryEnabled, true);
  });
}
