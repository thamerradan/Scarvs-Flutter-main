// يختبر نماذج متغيرات المنتج وإعدادات المتجر وويدجتس التصميم المشتركة.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scarvs/core/widgets/app_info_row.dart';
import 'package:scarvs/core/widgets/app_status_badge.dart';
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
      storeName: 'متجر تمنى للملابس',
      shippingFee: 25.0,
      freeShippingLimit: 300.0,
      cashOnDeliveryEnabled: true,
      onlinePaymentEnabled: true,
      maintenanceMode: false,
    );

    expect(settings.storeName, 'متجر تمنى للملابس');
    expect(settings.shippingFee, 25.0);
    expect(settings.cashOnDeliveryEnabled, true);
  });

  testWidgets('AppStatusBadge renders text and icon correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppStatusBadge(
            text: 'قيد التوصيل',
            color: Colors.blue,
            icon: Icons.local_shipping,
          ),
        ),
      ),
    );

    expect(find.text('قيد التوصيل'), findsOneWidget);
    expect(find.byIcon(Icons.local_shipping), findsOneWidget);
  });

  testWidgets('AppInfoRow renders label and value correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppInfoRow(
            label: 'العميل',
            value: 'أحمد',
            icon: Icons.person,
          ),
        ),
      ),
    );

    expect(find.text('العميل: '), findsOneWidget);
    expect(find.text('أحمد'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
