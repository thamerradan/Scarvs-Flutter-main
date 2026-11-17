// يعرض شاشة البداية ويحدد وجهة التطبيق بعد اكتمال التهيئة.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_fonts.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/providers/auth_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_config.dart';
import 'package:scarvs/core/utils/auth_guard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _checkSessionAndNavigate() async {
    // التحقق من جلسة Supabase الحالية (إذا كان مسجلاً، نجلب بياناته في الخلفية)
    if (SupabaseConfig.isConfigured && AppSupabase.isAuthenticated) {
      if (!mounted) return;
      try {
        final authNotifier =
            Provider.of<AuthenticationNotifier>(context, listen: false);
        await authNotifier.fetchCurrentUserProfile();
      } catch (_) {}
    }

    if (!mounted) return;
    final userRole = AuthGuard.currentUserRole;
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

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _checkSessionAndNavigate);
  }

  @override
  Widget build(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    var themeFlag = themeNotifier.darkTheme;
    return Scaffold(
      backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'تنمى',
              style: TextStyle(
                color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                fontFamily: AppFonts.contax,
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أرقى تشكيلة من الملابس والأزياء المتنوعة',
              style: TextStyle(
                color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                    .withOpacity(0.7),
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
