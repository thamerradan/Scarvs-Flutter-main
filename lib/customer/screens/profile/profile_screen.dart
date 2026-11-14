// تعرض الملف الشخصي وروابط إدارة الحساب.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/providers/auth_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/providers/user_provider.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/core/widgets/app_back_button.dart';
import 'package:scarvs/core/widgets/custom_text_style.dart';
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    AppBackButton(
                      fallbackRoute: AppRouter.customerHomeRoute,
                      themeFlag: themeFlag,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'الملف الشخصي',
                      style: CustomTextWidget.bodyTextB2(
                        color: themeFlag ? AppColors.creamColor : AppColors.mirage,
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
                    if (userNotifier.isOwner)
                      _buildMenuItem(
                        context: context,
                        title: 'لوحة تحكم المتجر 👑',
                        icon: Icons.dashboard_outlined,
                        themeFlag: themeFlag,
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRouter.ownerDashboardRoute);
                        },
                      ),
                    _buildMenuItem(
                      context: context,
                      title: 'طلباتي 📦',
                      icon: Icons.local_shipping_outlined,
                      themeFlag: themeFlag,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRouter.ordersRoute);
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      title: 'مركز الإشعارات 🔔',
                      icon: Icons.notifications_outlined,
                      themeFlag: themeFlag,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRouter.notificationsRoute);
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
                            .then((_) => userNotifier.getUserData(context: context));
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
                    const SizedBox(height: 24),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
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
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('خروج',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && mounted) {
                          await authNotifier.signOut(context: context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.power_settings_new,
                                color: Colors.red, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'تسجيل الخروج',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
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
    final userName = userNotifier.getUserName ?? 'عميل سكارفس';
    final roleName = userNotifier.isOwner ? 'مالك المتجر 👑' : 'عميل';
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
                        color: userNotifier.isOwner
                            ? AppColors.rawSienna.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        roleName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: userNotifier.isOwner
                              ? AppColors.rawSienna
                              : Colors.blue,
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
                        color: themeFlag
                            ? AppColors.creamColor
                            : AppColors.mirage,
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
