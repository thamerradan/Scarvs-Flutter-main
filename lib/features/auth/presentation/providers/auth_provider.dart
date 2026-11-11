// يدير حالة المصادقة وعمليات تسجيل الدخول والتسجيل.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scarvs/app/router/app_router.dart';
import 'package:scarvs/features/profile/data/models/profile_model.dart';
import 'package:scarvs/features/auth/data/auth_service.dart';
import 'package:scarvs/features/profile/data/profile_service.dart';
import 'package:scarvs/core/utils/snackbar_util.dart';

class AuthenticationNotifier with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSendingOtp = false;
  bool get isSendingOtp => _isSendingOtp;

  UserProfile? _currentProfile;
  UserProfile? get currentProfile => _currentProfile;
  bool get isOwner => _currentProfile?.isOwner ?? false;
  String get userRole => _currentProfile?.role ?? 'customer';

  /// هل المستخدم مسجل الدخول حالياً؟
  bool get isAuthenticated => _authService.isAuthenticated;

  // متغيرات قوة كلمة المرور (محتفظ بها للتوافق)
  String _passwordLevel = "";
  String get passwordLevel => _passwordLevel;
  String _passwordEmoji = "";
  String get passwordEmoji => _passwordEmoji;
  String _passwordTextArabic = "";
  String get passwordTextArabic => _passwordTextArabic;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// فحص قوة كلمة المرور
  void checkPasswordStrength({required String password}) {
    String mediumPattern = r'^(?=.*?[!@#\$&*~]).{8,}';
    String strongPattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';

    if (password.contains(RegExp(strongPattern))) {
      _passwordEmoji = '🚀';
      _passwordLevel = 'Strong';
      _passwordTextArabic = 'قوية جداً';
      notifyListeners();
    } else if (password.contains(RegExp(mediumPattern))) {
      _passwordEmoji = '🔥';
      _passwordLevel = 'Medium';
      _passwordTextArabic = 'متوسطة';
      notifyListeners();
    } else {
      _passwordEmoji = '😢';
      _passwordLevel = 'Weak';
      _passwordTextArabic = 'ضعيفة';
      notifyListeners();
    }
  }

  /// جلب الملف الشخصي الحالي
  Future<UserProfile?> fetchCurrentUserProfile() async {
    if (!_authService.isAuthenticated) {
      _currentProfile = null;
      notifyListeners();
      return null;
    }
    try {
      _currentProfile = await _profileService.getProfile();
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

      if (context.mounted && otp != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'رمز التحقق هو: $otp 🔑',
            context: context,
          ),
        );
      }
      return true;
    } on SocketException catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'يرجى التحقق من اتصالك بالإنترنت',
            context: context,
          ),
        );
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: e.toString().replaceAll('Exception: ', ''),
            context: context,
          ),
        );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackUtil.stylishSnackBar(
              text: fullName != null
                  ? 'تم إنشاء حسابك بنجاح! مرحباً بك 🎉'
                  : 'تم تسجيل الدخول بنجاح 👋',
              context: context,
            ),
          );
          // الرجوع إلى الشاشة المطلوبة أو الرئيسية
          if (returnRoute != null) {
            Navigator.of(context).pushReplacementNamed(returnRoute);
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouter.homeRoute,
              (route) => false,
            );
          }
        }
        return true;
      }
      return false;
    } on SocketException catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'يرجى التحقق من اتصالك بالإنترنت',
            context: context,
          ),
        );
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: e.toString().replaceAll('Exception: ', ''),
            context: context,
          ),
        );
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // Email/Password Auth (محتفظ بها للتوافق وللمالك)
  // ============================================================

  /// إنشاء حساب جديد (بريد + كلمة مرور - للمالك فقط)
  Future<void> createAccount({
    required BuildContext context,
    required String useremail,
    required String username,
    required String userpassword,
    String? phone,
  }) async {
    _setLoading(true);
    try {
      final res = await _authService.signUp(
        email: useremail,
        password: userpassword,
        fullName: username,
        phone: phone,
      );

      if (res.user != null) {
        await fetchCurrentUserProfile();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackUtil.stylishSnackBar(
              text: 'تم إنشاء الحساب بنجاح! مرحباً بك',
              context: context,
            ),
          );
          Navigator.of(context).pushReplacementNamed(AppRouter.homeRoute);
        }
      }
    } on SocketException catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'يرجى التحقق من اتصالك بالإنترنت',
            context: context,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: e.toString(),
            context: context,
          ),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  /// تسجيل الدخول (بريد + كلمة مرور - للمالك فقط)
  Future<void> userLogin({
    required BuildContext context,
    required String useremail,
    required String userpassword,
  }) async {
    _setLoading(true);
    try {
      final res = await _authService.signIn(
        email: useremail,
        password: userpassword,
      );

      if (res.user != null) {
        await fetchCurrentUserProfile();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackUtil.stylishSnackBar(
              text: 'تم تسجيل الدخول بنجاح',
              context: context,
            ),
          );
          Navigator.of(context).pushReplacementNamed(AppRouter.homeRoute);
        }
      }
    } on SocketException catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'يرجى التحقق من اتصالك بالإنترنت',
            context: context,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: e.toString(),
            context: context,
          ),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  /// استعادة كلمة المرور
  Future<bool> resetPassword({
    required BuildContext context,
    required String email,
  }) async {
    _setLoading(true);
    try {
      await _authService.resetPassword(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني',
            context: context,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: e.toString(),
            context: context,
          ),
        );
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تحديث كلمة المرور
  Future<bool> updatePassword({
    required BuildContext context,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await _authService.updatePassword(newPassword: newPassword);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'تم تغيير كلمة المرور بنجاح',
            context: context,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: e.toString(),
            context: context,
          ),
        );
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تسجيل الخروج → يرجع للرئيسية لا لصفحة Login
  Future<void> signOut({required BuildContext context}) async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentProfile = null;
      notifyListeners();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.homeRoute,
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'حدث خطأ أثناء تسجيل الخروج: $e',
            context: context,
          ),
        );
      }
    } finally {
      _setLoading(false);
    }
  }
}
