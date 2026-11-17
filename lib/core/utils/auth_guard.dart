// يوفر أدوات للتحقق من تسجيل الدخول وحماية العمليات والشاشات.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/providers/auth_provider.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';

/// AuthGuard - الحارس الموحد للتحقق من تسجيل الدخول
///
/// يستخدم عند محاولة تنفيذ أي عملية تتطلب حساباً:
/// - إضافة منتج للسلة
/// - فتح السلة
/// - الانتقال لـ Checkout
/// - فتح الملف الشخصي
/// - مشاهدة الطلبات
///
/// مثال الاستخدام:
/// ```dart
/// AuthGuard.requireAuth(
///   context: context,
///   returnRoute: AppRouter.cartRoute,
///   onAuthenticated: () => Navigator.pushNamed(context, AppRouter.cartRoute),
/// );
/// ```
class AuthGuard {
  AuthGuard._();

  static String? _cachedRole;

  /// تعيين الدور الحالي يدوياً عند تحديث الملف الشخصي
  static void setRole(String? role) {
    _cachedRole = role;
  }

  /// تنظيف الدور المخزن عند تسجيل الخروج
  static void clear() {
    _cachedRole = null;
  }

  /// هل المستخدم مسجل الدخول حالياً؟
  static bool get isLoggedIn => AppSupabase.isAuthenticated;

  /// دور المستخدم الحالي ('owner', 'customer', 'guest')
  static String get currentUserRole {
    if (_cachedRole != null && _cachedRole!.isNotEmpty) {
      return _cachedRole!;
    }
    final user = AppSupabase.client.auth.currentUser;
    if (user == null) return 'guest';
    final metadataRole = user.userMetadata?['role']?.toString();
    if (metadataRole != null && metadataRole.isNotEmpty) {
      return metadataRole;
    }
    return 'customer';
  }

  /// هل المستخدم الحالي هو مالك/مدير المتجر؟
  static bool get isOwner => currentUserRole == 'owner';

  /// التحقق من تسجيل الدخول وتنفيذ العملية أو عرض Dialog التسجيل
  static void requireAuth({
    required BuildContext context,
    required VoidCallback onAuthenticated,
    String? returnRoute,
    String? customMessage,
  }) {
    if (isLoggedIn) {
      onAuthenticated();
    } else {
      _showLoginDialog(
        context: context,
        returnRoute: returnRoute,
        customMessage: customMessage,
      );
    }
  }

  /// عرض Dialog يطلب من الزائر تسجيل الدخول
  static void _showLoginDialog({
    required BuildContext context,
    String? returnRoute,
    String? customMessage,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // أيقونة
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : AppColors.rawSienna.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 36,
                    color: isDark ? Colors.white : AppColors.rawSienna,
                  ),
                ),
                const SizedBox(height: 16),
                // العنوان
                const Text(
                  'تسجيل الدخول مطلوب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // الرسالة
                Text(
                  customMessage ??
                      'لإكمال هذه العملية، يرجى تسجيل الدخول برقم هاتفك',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // زر تسجيل الدخول
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : AppColors.rawSienna,
                      foregroundColor: isDark ? AppColors.mirage : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pushNamed(
                        AppRouter.phoneAuthRoute,
                        arguments: PhoneAuthArgs(
                          returnRoute: returnRoute,
                          isSignUp: false,
                        ),
                      );
                    },
                    child: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // زر إنشاء حساب جديد
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : AppColors.rawSienna,
                      side: BorderSide(
                        color: isDark ? Colors.white24 : AppColors.rawSienna,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pushNamed(
                        AppRouter.phoneAuthRoute,
                        arguments: PhoneAuthArgs(
                          returnRoute: returnRoute,
                          isSignUp: true,
                        ),
                      );
                    },
                    child: const Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // زر إلغاء
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'ليس الآن',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// بيانات للانتقال إلى شاشة Phone Auth
class PhoneAuthArgs {
  final String? returnRoute;
  final bool isSignUp;
  const PhoneAuthArgs({this.returnRoute, this.isSignUp = false});
}

/// Extension مساعد لاستخدام AuthGuard بسهولة من أي Widget
extension AuthGuardContext on BuildContext {
  void requireAuth({
    required VoidCallback onAuthenticated,
    String? returnRoute,
    String? customMessage,
  }) {
    AuthGuard.requireAuth(
      context: this,
      onAuthenticated: onAuthenticated,
      returnRoute: returnRoute,
      customMessage: customMessage,
    );
  }
}

/// Widget يحمي شاشة كاملة - يعرضها للمسجلين فقط
class AuthProtected extends StatelessWidget {
  final Widget child;
  final String? returnRoute;
  final String? message;

  const AuthProtected({
    super.key,
    required this.child,
    this.returnRoute,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthenticationNotifier>(context);

    if (authNotifier.isAuthenticated) {
      return child;
    }

    return _GuestPlaceholder(
      returnRoute: returnRoute,
      message: message,
    );
  }
}

class _GuestPlaceholder extends StatelessWidget {
  final String? returnRoute;
  final String? message;

  const _GuestPlaceholder({this.returnRoute, this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : AppColors.rawSienna.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: isDark ? Colors.white : AppColors.rawSienna,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message ?? 'يرجى تسجيل الدخول للمتابعة',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'استمتع بتجربة تسوق مميزة مع حساب شخصي',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : AppColors.rawSienna,
                  foregroundColor: isDark ? AppColors.mirage : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRouter.phoneAuthRoute,
                    arguments: PhoneAuthArgs(
                      returnRoute: returnRoute,
                      isSignUp: false,
                    ),
                  );
                },
                child: const Text(
                  'تسجيل الدخول ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : AppColors.rawSienna,
                  side: BorderSide(
                    color: isDark ? Colors.white24 : AppColors.rawSienna,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRouter.phoneAuthRoute,
                    arguments: PhoneAuthArgs(
                      returnRoute: returnRoute,
                      isSignUp: true,
                    ),
                  );
                },
                child: const Text(
                  'إنشاء حساب جديد',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
