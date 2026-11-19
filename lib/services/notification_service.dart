// ينفذ جلب إشعارات المستخدم وتحديثها.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scarvs/models/notification_model.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_tables.dart';

class NotificationService {
  final SupabaseClient _client = AppSupabase.client;

  /// جلب قائمة إشعارات المستخدم الحالي
  Future<List<NotificationModel>> fetchNotifications() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await _client
          .from(SupabaseTables.notifications)
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (data as List).map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      throw 'فشل جلب الإشعارات: $e';
    }
  }

  /// جلب عدد الإشعارات غير المقروءة فقط بصورة سريعة وخفيفة
  Future<int> fetchUnreadCount() async {
    final user = _client.auth.currentUser;
    if (user == null) return 0;

    try {
      final res = await _client
          .from(SupabaseTables.notifications)
          .count(CountOption.exact)
          .eq('user_id', user.id)
          .eq('is_read', false);
      return res;
    } catch (_) {
      return 0;
    }
  }

  /// تحديد إشعار كمقروء
  Future<void> markAsRead(String notificationId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      await _client
          .from(SupabaseTables.notifications)
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', user.id);
    } catch (e) {
      throw 'فشل تحديث حالة الإشعار: $e';
    }
  }

  /// تحديد جميع إشعارات المستخدم الحالي كمقروءة
  Future<void> markAllAsRead() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      await _client
          .from(SupabaseTables.notifications)
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);
    } catch (e) {
      throw 'فشل تحديث الإشعارات: $e';
    }
  }

  /// الاشتراك في التنبيهات اللحظية الخاصة بالمستخدم الحالي فقط
  RealtimeChannel subscribeToNotifications(Function(NotificationModel) onNew) {
    final user = _client.auth.currentUser;
    final channelName = 'notifications_${user?.id ?? "global"}';

    final channel = _client.channel(channelName);
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: SupabaseTables.notifications,
      filter: user != null
          ? PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: user.id,
            )
          : null,
      callback: (payload) {
        final record = payload.newRecord;
        if (record.isNotEmpty) {
          final notif = NotificationModel.fromJson(record);
          onNew(notif);
        }
      },
    ).subscribe();

    return channel;
  }
}
