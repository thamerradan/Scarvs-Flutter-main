// يدير تحميل إشعارات المستخدم وتحديثها.
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scarvs/models/notification_model.dart';
import 'package:scarvs/services/notification_service.dart';
import 'package:scarvs/core/utils/snackbar_util.dart';

class NotificationNotifier with ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  RealtimeChannel? _subscription;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// بدء الاستماع للإشعارات اللحظية
  void initRealtime(BuildContext context) {
    if (_subscription != null) return;

    _subscription = _service.subscribeToNotifications((newNotif) {
      _notifications.insert(0, newNotif);
      _unreadCount++;
      notifyListeners();

      // عرض تنبيه منبثق للمستخدم فور وصول الإشعار
      if (context.mounted) {
        SnackUtil.showNotification(
          context,
          title: newNotif.title,
          message: newNotif.message,
        );
      }
    });
  }

  /// جلب عدد الإشعارات غير المقروءة فقط للرئيسية
  Future<void> fetchUnreadCountOnly() async {
    try {
      _unreadCount = await _service.fetchUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  /// جلب الإشعارات
  Future<void> fetchNotifications({BuildContext? context}) async {
    _setLoading(true);
    try {
      _notifications = await _service.fetchNotifications();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    } catch (e) {
      if (context != null && context.mounted) {
        SnackUtil.show(context, e.toString());
      }
    } finally {
      _setLoading(false);
    }
  }

  /// تحديد إشعار كمقروء
  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      final idx = _notifications.indexWhere((n) => n.id == notificationId);
      if (idx != -1 && !_notifications[idx].isRead) {
        _notifications[idx] = _notifications[idx].copyWith(isRead: true);
        if (_unreadCount > 0) _unreadCount--;
        notifyListeners();
      }
    } catch (_) {}
  }

  /// تحديد جميع الإشعارات كمقروءة
  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (_) {}
  }

  /// إلغاء اشتراك Realtime وتنظيف الإشعارات عند تسجيل الخروج
  void clear() {
    try {
      _subscription?.unsubscribe();
    } catch (_) {}
    _subscription = null;
    _notifications = [];
    _unreadCount = 0;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}
