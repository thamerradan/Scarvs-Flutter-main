// تعرض إعدادات التطبيق التي يمكن للمستخدم تخصيصها.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/widgets/app_back_button.dart';
import 'package:scarvs/core/widgets/custom_text_style.dart';
import 'package:scarvs/core/widgets/dimensions_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final textColor = themeFlag ? AppColors.creamColor : AppColors.mirage;

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  AppBackButton(
                    themeFlag: themeFlag,
                    fallbackRoute: AppRouter.profileRoute,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'إعدادات التطبيق',
                    style: CustomTextWidget.bodyTextB2(
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            vSizedBox1,
            Consumer<ThemeNotifier>(
              builder: (context, notifier, _) {
                return SwitchListTile.adaptive(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  secondary: Icon(
                    themeFlag ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    color: themeFlag ? Colors.white : AppColors.rawSienna,
                  ),
                  title: Text(
                    'الوضع الداكن',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  value: themeFlag,
                  activeThumbColor: themeFlag ? Colors.white : AppColors.rawSienna,
                  activeTrackColor: themeFlag ? Colors.white38 : AppColors.rawSienna.withValues(alpha: 0.4),
                  onChanged: (bool value) {
                    notifier.toggleTheme();
                  },
                );
              },
            ),
            const Divider(height: 16),
            vSizedBox2,
            Text(
              'إصدار التطبيق',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: themeFlag
                    ? Colors.white.withValues(alpha: 0.12)
                    : AppColors.rawSienna.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: themeFlag ? Colors.white : AppColors.rawSienna,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
