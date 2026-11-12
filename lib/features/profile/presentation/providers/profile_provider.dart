// يدير جلب بيانات الملف الشخصي وتحديثها وتغيير كلمة المرور.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scarvs/features/profile/data/models/profile_model.dart';
import 'package:scarvs/features/auth/data/auth_service.dart';
import 'package:scarvs/features/profile/data/profile_service.dart';
import 'package:scarvs/core/utils/snackbar_util.dart';

class UserNotifier with ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  String? get getUserEmail {
    final email = _profile?.email;
    if (email != null &&
        email.isNotEmpty &&
        !email.endsWith('@phone.scarvs.app')) {
      return email;
    }
    final authEmail = _authService.currentUser?.email;
    if (authEmail != null &&
        authEmail.isNotEmpty &&
        !authEmail.endsWith('@phone.scarvs.app')) {
      return authEmail;
    }
    return null;
  }
  String? get getUserName =>
      _profile?.fullName.isNotEmpty == true ? _profile!.fullName : 'عميل';
  String get getuserAddress => _profile?.address.isNotEmpty == true
      ? _profile!.address
      : 'لم يتم تحديد العنوان';
  String get getuserPhoneNumber => _profile?.phone.isNotEmpty == true
      ? _profile!.phone
      : (_authService.currentUser?.phone ?? 'غير متوفر');
  String get getUserCity => _profile?.city.isNotEmpty == true ? _profile!.city : '';
  bool get isOwner => _profile?.isOwner ?? false;
  String get userRole => _profile?.role ?? 'customer';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// جلب بيانات المستخدم الحالية من Supabase
  Future<void> getUserData({
    String? token,
    required BuildContext context,
  }) async {
    if (!_authService.isAuthenticated) return;
    _isLoading = true;
    try {
      _profile = await _profileService.getProfile();
      notifyListeners();
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
      // Ignore or log error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب تفاصيل المستخدم
  Future<void> getUserDetails({
    String? userEmail,
    required BuildContext context,
  }) async {
    await getUserData(context: context);
  }

  /// تحديث بيانات المستخدم
  Future<bool> updateUserDetails({
    String? userEmail,
    required String userAddress,
    String? userPhoneNo,
    String? fullName,
    String? city,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final phone = userPhoneNo ?? _profile?.phone;
      _profile = await _profileService.updateProfile(
        fullName: fullName,
        phone: phone,
        email: userEmail,
        address: userAddress,
        city: city,
      );
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackUtil.stylishSnackBar(
            text: 'تم تحديث البيانات بنجاح',
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
            text: 'فشل التحديث: $e',
            context: context,
          ),
        );
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تغيير كلمة المرور
  Future<bool> changePassword({
    String? userEmail,
    String? oluserpassword,
    required String newuserpassword,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.updatePassword(newPassword: newuserpassword);
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
            text: 'فشل تغيير كلمة المرور: $e',
            context: context,
          ),
        );
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
