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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xff222831),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.amber),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        newNotif.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        newNotif.message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  /// جلب الإشعارات
  Future<void> fetchNotifications({BuildContext? context}) async {
    _setLoading(true);
    try {
      _notifications = await _service.fetchNotifications();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(text: e.toString(), context: context),
        );
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

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}
