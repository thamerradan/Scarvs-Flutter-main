// ينفذ عمليات المصادقة وإدارة جلسة المستخدم.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_tables.dart';

class AuthService {
  final SupabaseClient _client = AppSupabase.client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isAuthenticated => currentUser != null;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ============================================================
  // Phone OTP Auth (نظام التحقق المباشر عبر قاعدة البيانات)
  // ============================================================

  /// إرسال رمز OTP إلى رقم الهاتف عبر قاعدة البيانات المباشرة
  /// [isSignUp]: للتحقق من عدم تكرار الرقم عند إنشاء حساب جديد، أو وجوده عند تسجيل الدخول
  Future<String?> sendOtp({
    required String phone,
    bool isSignUp = false,
  }) async {
    final cleanPhone = phone.trim();
    try {
      final res = await _client.rpc('generate_phone_otp', params: {
        'p_phone': cleanPhone,
        'p_is_signup': isSignUp,
      });

      if (res is Map && res['success'] == true) {
        final otp = res['otp']?.toString();
        return otp;
      } else {
        final msg = res is Map ? res['message']?.toString() : null;
        throw msg ?? 'فشل إنشاء رمز التحقق في قاعدة البيانات';
      }
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (err.contains('function') || err.contains('does not exist') || err.contains('404')) {
        throw 'يرجى تشغيل كود SQL الخاص بنظام OTP في Supabase SQL Editor أولاً';
      }
      rethrow;
    }
  }

  /// التحقق من رمز OTP وإكمال تسجيل الدخول أو إنشاء الحساب
  /// البريد اختياري: إذا لم يتم تمريره يكون null ولا يتم إضافة بريد تلقائي في profiles
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
    String? fullName,
    String? email,
  }) async {
    final cleanPhone = phone.trim();
    final cleanToken = token.trim();
    final cleanEmail = (email != null && email.trim().isNotEmpty) ? email.trim() : null;

    try {
      // 1. التحقق من الرمز في جدول phone_verifications عبر RPC
      final res = await _client.rpc('verify_phone_otp', params: {
        'p_phone': cleanPhone,
        'p_token': cleanToken,
      });

      if (res is! Map || res['success'] != true) {
        final msg = res is Map ? res['message']?.toString() : null;
        throw msg ?? 'رمز التحقق غير صحيح أو انتهت صلاحيته';
      }

      // 2. تسجيل دخول / إنشاء حساب العميل في Supabase Auth لربط الجلسة
      final digits = cleanPhone.replaceAll(RegExp(r'[^0-9]'), '');
      final virtualEmail = '$digits@phone.scarvs.app';
      final virtualPass = 'Sc@rvs_#_$digits';

      AuthResponse authResponse;
      try {
        authResponse = await _client.auth.signInWithPassword(
          email: virtualEmail,
          password: virtualPass,
        );
      } catch (_) {
        // إذا كان الحساب جديداً، نقوم بإنشائه
        authResponse = await _client.auth.signUp(
          email: virtualEmail,
          password: virtualPass,
          data: {
            'full_name': fullName?.trim() ?? '',
            'phone': cleanPhone,
            'email': cleanEmail,
            'role': 'customer',
          },
        );
      }

      // 3. تحديث جدول profiles لضمان أن البريد اختياري تماماً (إما البريد الحقيقي أو null ولا يتم تخزين بريد تلقائي أبداً)
      if (authResponse.user != null) {
        try {
          await _client.from(SupabaseTables.profiles).update({
            'email': cleanEmail,
            if (fullName != null && fullName.trim().isNotEmpty)
              'full_name': fullName.trim(),
            'phone': cleanPhone,
          }).eq('id', authResponse.user!.id);
        } catch (_) {}
      }

      return authResponse;
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (err.contains('function') || err.contains('does not exist') || err.contains('404')) {
        throw 'يرجى تشغيل كود SQL الخاص بنظام OTP في Supabase SQL Editor أولاً';
      }
      rethrow;
    }
  }

  /// تحديث بيانات المستخدم (الاسم / الهاتف / البريد)
  Future<UserResponse> updateUserMetadata({
    required String fullName,
    String? phone,
    String? email,
  }) async {
    try {
      final cleanEmail = (email != null && email.trim().isNotEmpty) ? email.trim() : null;
      return await _client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullName.trim(),
            if (phone != null) 'phone': phone.trim(),
            if (cleanEmail != null) 'email': cleanEmail,
            'role': 'customer',
          },
        ),
      );
    } catch (e) {
      throw 'فشل تحديث بيانات المستخدم: $e';
    }
  }

  // ============================================================
  // Email/Password Auth (المسار الكلاسيكي / المالك)
  // ============================================================

  /// تسجيل الدخول بالبريد وكلمة المرور
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } catch (e) {
      throw 'فشل تسجيل الدخول: ${e.toString()}';
    }
  }

  /// إنشاء حساب جديد بالبريد وكلمة المرور
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final cleanPhone = phone?.trim();
      final cleanEmail = email.trim();

      // فحص عدم تكرار الهاتف إن وجد
      if (cleanPhone != null && cleanPhone.isNotEmpty) {
        final existing = await _client
            .from(SupabaseTables.profiles)
            .select('id')
            .eq('phone', cleanPhone)
            .maybeSingle();
        if (existing != null) {
          throw 'رقم الهاتف هذا مسجل مسبقاً، يرجى تسجيل الدخول بدلاً من إنشاء حساب جديد';
        }
      }

      final response = await _client.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {
          'full_name': fullName.trim(),
          if (cleanPhone != null && cleanPhone.isNotEmpty) 'phone': cleanPhone,
          'role': 'customer',
        },
      );
      return response;
    } catch (e) {
      throw 'فشل إنشاء الحساب: ${e.toString()}';
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw 'فشل تسجيل الخروج: ${e.toString()}';
    }
  }

  /// إعادة تعيين كلمة المرور عبر البريد
  Future<void> resetPassword({required String email}) async {
    return resetPasswordForEmail(email);
  }

  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      throw 'فشل إرسال رابط استعادة كلمة المرور: ${e.toString()}';
    }
  }

  /// تحديث كلمة المرور للمستخدم المسجل حالياً
  Future<UserResponse> updatePassword({required String newPassword}) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      throw 'فشل تحديث كلمة المرور: ${e.toString()}';
    }
  }

  /// جلب معرّف المستخدم الحالي
  String? get currentUserId => currentUser?.id;

  /// جلب البريد الحقيقي للمستخدم (إن لم يكن بريداً تلقائياً)
  String? get userEmail {
    final e = currentUser?.email;
    if (e == null || e.endsWith('@phone.scarvs.app')) return null;
    return e;
  }
}
