// يجلب بيانات وإحصاءات لوحة تحكم المتجر.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_tables.dart';
import 'package:scarvs/models/dashboard_stats_model.dart';

class OwnerDashboardService {
  final SupabaseClient _client = AppSupabase.client;

  Future<DashboardStatsModel> fetchDashboardStats() async {
    try {
      final ordersData = await _client
          .from(SupabaseTables.orders)
          .select('id, total, order_status, created_at');

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      final totalOrders = (ordersData as List).length;
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

      final variantsData = await _client
          .from(SupabaseTables.productVariants)
          .select('id, stock_quantity');

      var lowStockCount = 0;
      var outOfStockCount = 0;

      for (final variant in (variantsData as List)) {
        final stock = (variant['stock_quantity'] as num?)?.toInt() ?? 0;
        if (stock == 0) {
          outOfStockCount++;
        } else if (stock <= 5) {
          lowStockCount++;
        }
      }

      final productsRes =
          await _client.from(SupabaseTables.products).select('id');
      final totalProducts = (productsRes as List).length;

      final profilesRes = await _client
          .from(SupabaseTables.profiles)
          .select('id')
          .eq('role', 'customer');
      final totalCustomers = (profilesRes as List).length;

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
