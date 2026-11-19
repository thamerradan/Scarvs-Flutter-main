// يعرض شاشة البداية ويحدد وجهة التطبيق بعد اكتمال التهيئة.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/constants/app_assets.dart';
import 'package:scarvs/core/theme/app_colors.dart';
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
  Future<void> _initializeAndNavigate() async {
    final minDelay = Future.delayed(const Duration(milliseconds: 4000));

    Future<void> initAuth() async {
      if (SupabaseConfig.isConfigured && AppSupabase.isAuthenticated) {
        try {
          final authNotifier =
              Provider.of<AuthenticationNotifier>(context, listen: false);
          await authNotifier.fetchCurrentUserProfile();
        } catch (_) {}
      }
    }

    await Future.wait([minDelay, initAuth()]);

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
    _initializeAndNavigate();
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
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                themeFlag ? Colors.white : AppColors.mirage,
                BlendMode.srcIn,
              ),
              child: Lottie.asset(
                AppAssets.tamannaLogo,
                width: 260,
                height: 260,
                fit: BoxFit.contain,
                repeat: false,
              ),
            ),
           
          ],
        ),
      ),
    );
  }
}
