// ينفذ جلب الملف الشخصي للمستخدم وتحديثه.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scarvs/models/profile_model.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_tables.dart';

class ProfileService {
  final SupabaseClient _client = AppSupabase.client;

  /// جلب الملف الشخصي للمستخدم
  Future<UserProfile?> getProfile([String? userId]) async {
    final uid = userId ?? _client.auth.currentUser?.id;
    if (uid == null) return null;

    try {
      final data = await _client
          .from(SupabaseTables.profiles)
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (data == null) {
        // إذا لم يكن موجوداً، نقوم بإنشائه من بيانات المستخدم المسجل
        final user = _client.auth.currentUser;
        if (user != null && user.id == uid) {
          final rawEmail = user.email;
          final cleanEmail =
              (rawEmail != null && !rawEmail.endsWith('@phone.scarvs.app'))
                  ? rawEmail
                  : null;

          final newProfile = {
            'id': user.id,
            'full_name': user.userMetadata?['full_name'] ?? '',
            'email': cleanEmail,
            'phone': user.userMetadata?['phone'] ?? '',
            'role': 'customer',
          };
          final inserted = await _client
              .from(SupabaseTables.profiles)
              .upsert(newProfile)
              .select()
              .single();
          return UserProfile.fromJson(inserted);
        }
        return null;
      }
      return UserProfile.fromJson(data);
    } catch (e) {
      throw 'فشل جلب بيانات الملف الشخصي: $e';
    }
  }

  /// تحديث الملف الشخصي
  Future<UserProfile> updateProfile({
    String? fullName,
    String? phone,
    String? email,
    String? address,
    String? city,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw 'يجب تسجيل الدخول أولاً';

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (fullName != null) updates['full_name'] = fullName.trim();
    if (phone != null) updates['phone'] = phone.trim();
    if (email != null) {
      final clean = email.trim();
      updates['email'] = clean.isNotEmpty && !clean.endsWith('@phone.scarvs.app') ? clean : null;
    }
    if (address != null) updates['address'] = address.trim();
    if (city != null) updates['city'] = city.trim();

    try {
      final data = await _client
          .from(SupabaseTables.profiles)
          .update(updates)
          .eq('id', uid)
          .select()
          .single();

      return UserProfile.fromJson(data);
    } catch (e) {
      throw 'فشل تحديث بيانات الملف الشخصي: $e';
    }
  }

  /// إنشاء أو تحديث الملف الشخصي (upsert)
  Future<UserProfile?> upsertProfile({
    required String fullName,
    required String phone,
    String? email,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;

    final cleanEmail = (email != null &&
            email.trim().isNotEmpty &&
            !email.trim().endsWith('@phone.scarvs.app'))
        ? email.trim()
        : null;

    try {
      final data = await _client
          .from(SupabaseTables.profiles)
          .upsert({
            'id': uid,
            'full_name': fullName.trim(),
            'phone': phone.trim(),
            'email': cleanEmail,
            'role': 'customer',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      return UserProfile.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}
