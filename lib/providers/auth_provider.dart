// يدير حالة المصادقة وعمليات تسجيل الدخول والتسجيل.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/models/profile_model.dart';
import 'package:scarvs/services/auth_service.dart';
import 'package:scarvs/services/user_service.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/core/utils/snackbar_util.dart';
import 'package:scarvs/providers/cart_provider.dart';
import 'package:scarvs/providers/notification_provider.dart';
import 'package:scarvs/providers/order_provider.dart';
import 'package:scarvs/providers/owner_provider.dart';
import 'package:scarvs/providers/user_provider.dart';

class AuthenticationNotifier with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSendingOtp = false;
  bool get isSendingOtp => _isSendingOtp;

  UserProfile? _currentProfile;
  bool get isOwner => _currentProfile?.isOwner ?? false;
  String get userRole => _currentProfile?.role ?? 'customer';

  /// هل المستخدم مسجل الدخول حالياً؟
  bool get isAuthenticated => _authService.isAuthenticated;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// جلب الملف الشخصي الحالي
  Future<UserProfile?> fetchCurrentUserProfile() async {
    if (!_authService.isAuthenticated) {
      _currentProfile = null;
      AuthGuard.setRole(null);
      notifyListeners();
      return null;
    }
    try {
      _currentProfile = await _profileService.getProfile();
      AuthGuard.setRole(_currentProfile?.role);
      notifyListeners();
      return _currentProfile;
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // Phone OTP Auth (المصادقة برقم الهاتف - الطريقة الجديدة)
  // ============================================================

  String? _lastGeneratedOtp;
  String? get lastGeneratedOtp => _lastGeneratedOtp;

  /// إرسال رمز OTP إلى رقم الهاتف
  Future<bool> sendPhoneOtp({
    required BuildContext context,
    required String phone,
    bool isSignUp = false,
  }) async {
    _isSendingOtp = true;
    notifyListeners();
    try {
      final otp = await _authService.sendOtp(
        phone: phone,
        isSignUp: isSignUp,
      );
      _lastGeneratedOtp = otp;
      notifyListeners();

    
      return true;
    } on SocketException catch (_) {
      if (context.mounted) SnackUtil.showNetworkError(context);
      return false;
    } catch (e) {
      if (context.mounted) {
        SnackUtil.show(context, e.toString().replaceAll('Exception: ', ''));
      }
      return false;
    } finally {
      _isSendingOtp = false;
      notifyListeners();
    }
  }

  /// التحقق من رمز OTP وإكمال تسجيل الدخول / إنشاء الحساب
  /// [fullName] و [email] اختياريان عند إنشاء حساب جديد
  /// [returnRoute] المسار للرجوع إليه بعد نجاح التسجيل (null = الرئيسية)
  Future<bool> verifyPhoneOtp({
    required BuildContext context,
    required String phone,
    required String token,
    String? fullName,
    String? email,
    String? returnRoute,
  }) async {
    _setLoading(true);
    try {
      final res = await _authService.verifyOtp(
        phone: phone,
        token: token,
        fullName: fullName,
        email: email,
      );

      if (res.user != null) {
        // إذا كان إنشاء حساب جديد، نحفظ الاسم والبريد في metadata وفي profiles
        if (fullName != null && fullName.trim().isNotEmpty) {
          try {
            await _authService.updateUserMetadata(
              fullName: fullName.trim(),
              phone: phone,
              email: email,
            );
            // إنشاء/تحديث سجل في profiles
            await _profileService.upsertProfile(
              fullName: fullName.trim(),
              phone: phone,
              email: email,
            );
          } catch (_) {}
        }

        // جلب الملف الشخصي
        await fetchCurrentUserProfile();

        if (context.mounted) {
          SnackUtil.show(
            context,
            fullName != null
                ? 'تم إنشاء حسابك بنجاح! مرحباً بك 🎉'
                : 'تم تسجيل الدخول بنجاح 👋',
          );
          final userRole = _currentProfile?.role ?? 'customer';
          if (userRole == 'owner') {
            Navigator.pushReplacementNamed(
              context,
              AppRouter.ownerDashboardRoute,
            );
          } else {
            Navigator.pushReplacementNamed(
              context,
              AppRouter.customerHomeRoute,
            );
          }
        }
        return true;
      }
      return false;
    } on SocketException catch (_) {
      if (context.mounted) SnackUtil.showNetworkError(context);
      return false;
    } catch (e) {
      if (context.mounted) {
        SnackUtil.show(context, e.toString().replaceAll('Exception: ', ''));
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تسجيل الخروج → تنظيف شامل لكافة البيانات والاشتراكات ثم الرجوع للرئيسية
  Future<void> signOut({required BuildContext context}) async {
    _setLoading(true);
    try {
      // 1. إنهاء الجلسة في Supabase أولاً
      await _authService.signOut();

      // 2. تنظيف اشتراك الإشعارات اللحظية وقائمة الإشعارات
      if (context.mounted) {
        try {
          Provider.of<NotificationNotifier>(context, listen: false).clear();
        } catch (_) {}

        // 3. تنظيف السلة المحلية
        try {
          Provider.of<CartNotifier>(context, listen: false).clearLocalCart();
        } catch (_) {}

        // 4. تنظيف بيانات المستخدم الشخصية
        try {
          Provider.of<UserProvider>(context, listen: false).clear();
        } catch (_) {}

        // 5. تنظيف قائمة طلبات المستخدم
        try {
          Provider.of<OrderNotifier>(context, listen: false).clear();
        } catch (_) {}

        // 6. تنظيف بيانات لوحة تحكم المالك إن وجدت
        try {
          Provider.of<OwnerNotifier>(context, listen: false).clear();
        } catch (_) {}
      }

      // 7. تنظيف بيانات الجلسة والدور المخزن في الحارس
      _currentProfile = null;
      AuthGuard.clear();
      notifyListeners();

      // 8. التوجيه المباشر إلى الواجهة الرئيسية للمتجر وإفراغ سجل التنقل
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.customerHomeRoute,
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) SnackUtil.show(context, 'حدث خطأ أثناء تسجيل الخروج: $e');
    } finally {
      _setLoading(false);
    }
  }
}
