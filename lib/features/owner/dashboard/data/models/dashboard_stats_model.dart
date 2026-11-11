// يمثل الإحصاءات المعروضة في لوحة تحكم المتجر.
class DashboardStatsModel {
  final int totalOrders;
  final int pendingOrders;
  final int preparingOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final double todaySales;
  final double monthSales;
  final double totalSales;
  final int lowStockCount;
  final int outOfStockCount;
  final int totalProducts;
  final int totalCustomers;

  DashboardStatsModel({
    this.totalOrders = 0,
    this.pendingOrders = 0,
    this.preparingOrders = 0,
    this.shippedOrders = 0,
    this.deliveredOrders = 0,
    this.cancelledOrders = 0,
    this.todaySales = 0.0,
    this.monthSales = 0.0,
    this.totalSales = 0.0,
    this.lowStockCount = 0,
    this.outOfStockCount = 0,
    this.totalProducts = 0,
    this.totalCustomers = 0,
  });
}

