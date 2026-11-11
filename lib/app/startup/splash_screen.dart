// يعرض شاشة البداية ويحدد وجهة التطبيق بعد اكتمال التهيئة.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scarvs/app/theme/app_colors.dart';
import 'package:scarvs/app/theme/app_fonts.dart';
import 'package:scarvs/app/constants/app_keys.dart';
import 'package:scarvs/app/router/app_router.dart';
import 'package:scarvs/features/auth/presentation/providers/auth_provider.dart';
import 'package:scarvs/app/providers/theme_provider.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _checkSessionAndNavigate() async {
    // التحقق أولاً من اكتمال شاشات التعريف (OnBoarding) مع التوافق التام مع القيم القديمة
    final prefs = await SharedPreferences.getInstance();
    final rawOnBoard = prefs.get(AppKeys.onBoardDone);
    bool onBoardDone = false;

    if (rawOnBoard is bool) {
      onBoardDone = rawOnBoard;
    } else if (rawOnBoard is String) {
      onBoardDone = rawOnBoard.toLowerCase() == 'true' || rawOnBoard == '1';
      // تنظيف القيمة القديمة من SharedPreferences وحفظها بصيغة boolean صحيحة
      await prefs.remove(AppKeys.onBoardDone);
      if (onBoardDone) {
        await prefs.setBool(AppKeys.onBoardDone, true);
      }
    } else if (rawOnBoard is num) {
      onBoardDone = rawOnBoard == 1;
      await prefs.remove(AppKeys.onBoardDone);
      if (onBoardDone) {
        await prefs.setBool(AppKeys.onBoardDone, true);
      }
    }

    if (!onBoardDone) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRouter.onBoardRoute);
      await prefs.setBool(AppKeys.onBoardDone, true);
      return;
    }

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
    // التوجه مباشرة للصفحة الرئيسية سواء كان المستخدم مسجلاً أو زائراً
    Navigator.of(context).pushReplacementNamed(AppRouter.homeRoute);
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
              'سكارفس',
              style: TextStyle(
                color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                fontFamily: AppFonts.contax,
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أفضل تشكيلة من الأحذية العصرية',
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
