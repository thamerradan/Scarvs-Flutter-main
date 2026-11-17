// تعرض معلومات الحساب المرتبطة بالمستخدم.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/providers/user_provider.dart';
import 'package:scarvs/core/widgets/app_back_button.dart';
import 'package:scarvs/core/widgets/custom_text_style.dart';

class AccountInformationScreen extends StatefulWidget {
  const AccountInformationScreen({Key? key}) : super(key: key);

  @override
  State<AccountInformationScreen> createState() =>
      _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false)
          .getUserData(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final double profilePictureSize = MediaQuery.of(context).size.width / 3.5;
    final userNotifier = Provider.of<UserProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppBackButton(
                    themeFlag: themeFlag,
                    fallbackRoute: AppRouter.profileRoute,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'معلومات الحساب',
                    style: CustomTextWidget.bodyTextB2(
                      color:
                          themeFlag ? AppColors.creamColor : AppColors.mirage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: profilePictureSize,
                      height: profilePictureSize,
                      child: CircleAvatar(
                        backgroundColor:
                            themeFlag ? AppColors.creamColor : AppColors.mirage,
                        radius: profilePictureSize,
                        child: ClipOval(
                          child: SvgPicture.network(
                            'https://api.dicebear.com/9.x/big-smile/svg?seed=${userNotifier.getUserName ?? "user"}',
                            semanticsLabel: 'avatar',
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userNotifier.getUserName ?? '',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            themeFlag ? AppColors.creamColor : AppColors.mirage,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
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
                        userNotifier.isOwner ? '👑 مالك المتجر' : 'عميل',
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
              const SizedBox(height: 35),
              _buildInfoTile(
                title: 'البريد الإلكتروني',
                value: userNotifier.getUserEmail ?? 'لم تتم إضافة بريد إلكتروني',
                icon: Icons.email_outlined,
                themeFlag: themeFlag,
              ),
              _buildInfoTile(
                title: 'رقم الهاتف',
                value: userNotifier.getuserPhoneNumber,
                icon: Icons.phone_outlined,
                themeFlag: themeFlag,
              ),
              _buildInfoTile(
                title: 'المدينة',
                value: userNotifier.getUserCity.isNotEmpty
                    ? userNotifier.getUserCity
                    : 'لم تحدد',
                icon: Icons.location_city_outlined,
                themeFlag: themeFlag,
              ),
              _buildInfoTile(
                title: 'العنوان',
                value: userNotifier.getuserAddress,
                icon: Icons.home_outlined,
                themeFlag: themeFlag,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
    required bool themeFlag,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: themeFlag
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeFlag
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: themeFlag ? Colors.white : AppColors.rawSienna,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
                        .withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: themeFlag ? AppColors.creamColor : AppColors.mirage,
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
