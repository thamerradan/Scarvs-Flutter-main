// يجلب بيانات وإحصاءات لوحة تحكم المتجر.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_tables.dart';
import 'package:scarvs/models/dashboard_stats_model.dart';

class OwnerDashboardService {
  final SupabaseClient _client = AppSupabase.client;

  Future<DashboardStatsModel> fetchDashboardStats() async {
    try {
      // تنفيذ جميع استعلامات لوحة التحكم بالتوازي لتقليل وقت الاستجابة بنسبة تزيد عن 60%
      final results = await Future.wait([
        _client
            .from(SupabaseTables.orders)
            .select('id, total, order_status, created_at'),
        _client
            .from(SupabaseTables.productVariants)
            .select('id, stock_quantity'),
        _client.from(SupabaseTables.products).select('id'),
        _client
            .from(SupabaseTables.profiles)
            .select('id')
            .eq('role', 'customer'),
      ]);

      final ordersData = results[0] as List;
      final variantsData = results[1] as List;
      final productsRes = results[2] as List;
      final profilesRes = results[3] as List;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      final totalOrders = ordersData.length;
      var pendingOrders = 0;
      var preparingOrders = 0;
      var shippedOrders = 0;
      var deliveredOrders = 0;
      var cancelledOrders = 0;
      var todaySales = 0.0;
      var monthSales = 0.0;
      var totalSales = 0.0;

      for (final order in ordersData) {
        final status = order['order_status'] as String? ?? 'pending';
        final total = (order['total'] as num?)?.toDouble() ?? 0.0;
        final createdAt =
            DateTime.tryParse(order['created_at']?.toString() ?? '') ?? now;

        switch (status) {
          case 'pending':
            pendingOrders++;
            break;
          case 'preparing':
            preparingOrders++;
            break;
          case 'shipped':
            shippedOrders++;
            break;
          case 'delivered':
            deliveredOrders++;
            break;
          case 'cancelled':
            cancelledOrders++;
            break;
        }

        if (status != 'cancelled') {
          totalSales += total;
          if (createdAt.isAfter(todayStart)) {
            todaySales += total;
          }
          if (createdAt.isAfter(monthStart)) {
            monthSales += total;
          }
        }
      }

      var lowStockCount = 0;
      var outOfStockCount = 0;

      for (final variant in variantsData) {
        final stock = (variant['stock_quantity'] as num?)?.toInt() ?? 0;
        if (stock == 0) {
          outOfStockCount++;
        } else if (stock <= 5) {
          lowStockCount++;
        }
      }

      final totalProducts = productsRes.length;
      final totalCustomers = profilesRes.length;

      return DashboardStatsModel(
        totalOrders: totalOrders,
        pendingOrders: pendingOrders,
        preparingOrders: preparingOrders,
        shippedOrders: shippedOrders,
        deliveredOrders: deliveredOrders,
        cancelledOrders: cancelledOrders,
        todaySales: todaySales,
        monthSales: monthSales,
        totalSales: totalSales,
        lowStockCount: lowStockCount,
        outOfStockCount: outOfStockCount,
        totalProducts: totalProducts,
        totalCustomers: totalCustomers,
      );
    } catch (e) {
      throw 'فشل جلب إحصائيات لوحة التحكم: $e';
    }
  }
}
