// تعرض الملف الشخصي وروابط إدارة الحساب.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_spacing.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/providers/auth_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/providers/user_provider.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/core/widgets/app_buttons.dart';
import 'package:scarvs/core/widgets/dimensions_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthGuard.isLoggedIn) {
        Provider.of<UserProvider>(context, listen: false)
            .getUserData(context: context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final userNotifier = Provider.of<UserProvider>(context);
    final authNotifier = Provider.of<AuthenticationNotifier>(context);

    return SafeArea(
      child: AuthProtected(
        returnRoute: AppRouter.profileRoute,
        message: 'سجّل دخولك لعرض ملفك الشخصي وإدارة طلباتك',
        child: Scaffold(
          backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Text(
                        'الملف الشخصي',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: themeFlag
                              ? AppColors.creamColor
                              : AppColors.mirage,
                        ),
                      ),
                    ],
                  ),
                ),
                vSizedBox1,
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _createAccountInformation(
                        context: context,
                        themeFlag: themeFlag,
                        userNotifier: userNotifier,
                      ),
                      const Divider(height: 32),
                      _buildMenuItem(
                        context: context,
                        title: 'طلباتي',
                        icon: Icons.local_shipping_outlined,
                        themeFlag: themeFlag,
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(AppRouter.ordersRoute);
                        },
                      ),
                      _buildMenuItem(
                        context: context,
                        title: 'تعديل البيانات',
                        icon: Icons.person_outline,
                        themeFlag: themeFlag,
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(AppRouter.editProfileRoute)
                              .then((_) =>
                                  userNotifier.getUserData(context: context));
                        },
                      ),
                      _buildMenuItem(
                        context: context,
                        title: 'إعدادات التطبيق والمظهر',
                        icon: Icons.settings_outlined,
                        themeFlag: themeFlag,
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(AppRouter.appSettingsRoute);
                        },
                      ),
                      AppSpacing.gapH24,
                      AppDangerButton(
                        text: 'تسجيل الخروج',
                        icon: Icons.power_settings_new,
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text('تسجيل الخروج',
                                  textAlign: TextAlign.right),
                              content: const Text(
                                'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
                                textAlign: TextAlign.right,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('إلغاء'),
                                ),
                                AppDangerButton(
                                  text: 'خروج',
                                  height: 38,
                                  width: 80,
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && mounted) {
                            await authNotifier.signOut(context: context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool themeFlag,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.chevron_left, // اتجاه السهم في RTL
              size: 22,
              color: themeFlag ? AppColors.creamColor : AppColors.mirage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _createAccountInformation({
    required BuildContext context,
    required bool themeFlag,
    required UserProvider userNotifier,
  }) {
    final userName = userNotifier.getUserName ?? 'عميل تمنى';
    final roleName = userNotifier.isOwner ? 'مالك المتجر' : 'عميل';
    final double profilePictureSize = MediaQuery.of(context).size.width / 4.5;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: profilePictureSize,
            height: profilePictureSize,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(AppRouter.accountInfo);
              },
              child: CircleAvatar(
                backgroundColor:
                    themeFlag ? AppColors.creamColor : AppColors.mirage,
                radius: profilePictureSize - 4,
                child: Hero(
                  tag: 'profilePicture',
                  child: ClipOval(
                    child: SvgPicture.network(
                      'https://api.dicebear.com/9.x/big-smile/svg?seed=$userName',
                      semanticsLabel: 'avatar',
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: themeFlag
                            ? Colors.white.withOpacity(0.12)
                            : AppColors.rawSienna.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: themeFlag
                              ? Colors.white.withOpacity(0.3)
                              : AppColors.rawSienna.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        roleName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: themeFlag ? Colors.white : AppColors.rawSienna,
                        ),
                      ),
                    ),
                    if (userNotifier.getuserPhoneNumber != 'غير متوفر')
                      Text(
                        userNotifier.getuserPhoneNumber,
                        style: TextStyle(
                          fontSize: 12,
                          color: (themeFlag
                                  ? AppColors.creamColor
                                  : AppColors.mirage)
                              .withOpacity(0.7),
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.accountInfo);
                  },
                  child: Row(
                    children: [
                      Text(
                        'عرض معلومات الحساب',
                        style: TextStyle(
                          fontSize: 13,
                          color: (themeFlag
                                  ? AppColors.creamColor
                                  : AppColors.mirage)
                              .withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_left,
                        size: 18,
                        color:
                            themeFlag ? AppColors.creamColor : AppColors.mirage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
