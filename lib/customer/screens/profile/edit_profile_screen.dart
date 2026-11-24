// تعرض نموذج تعديل بيانات الملف الشخصي.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_spacing.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/providers/user_provider.dart';
import 'package:scarvs/core/widgets/app_buttons.dart';
import 'package:scarvs/core/widgets/app_page_header.dart';
import 'package:scarvs/core/widgets/app_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController addressController;
  late final TextEditingController cityController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final userNotifier = Provider.of<UserProvider>(context, listen: false);
    nameController =
        TextEditingController(text: userNotifier.getUserName);
    emailController =
        TextEditingController(text: userNotifier.getUserEmail ?? '');
    addressController = TextEditingController(
        text: userNotifier.getuserAddress != 'لم يتم تحديد العنوان'
            ? userNotifier.getuserAddress
            : '');
    cityController = TextEditingController(text: userNotifier.getUserCity);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final userNotifier = Provider.of<UserProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const AppPageHeader(
                title: 'تعديل البيانات الشخصية',
                fallbackRoute: AppRouter.profileRoute,
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                  child: Column(
                    children: [
                      AppTextField(
                        textEditingController: nameController,
                        hintText: 'الاسم الكامل',
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'يرجى إدخال الاسم'
                            : null,
                      ),
                      AppSpacing.gapH16,
                      AppTextField(
                        textEditingController: emailController,
                        hintText: 'البريد الإلكتروني (اختياري)',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (val) {
                          if (val != null && val.trim().isNotEmpty) {
                            final emailRegex =
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(val.trim())) {
                              return 'يرجى إدخال بريد إلكتروني صالح';
                            }
                          }
                          return null;
                        },
                      ),
                      AppSpacing.gapH16,
                      AppTextField(
                        textEditingController: cityController,
                        hintText: 'المدينة',
                        prefixIcon: const Icon(Icons.location_city_outlined),
                      ),
                      AppSpacing.gapH16,
                      AppTextField(
                        textEditingController: addressController,
                        hintText: 'العنوان بالتفصيل',
                        prefixIcon: const Icon(Icons.home_outlined),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'يرجى إدخال العنوان'
                            : null,
                      ),
                      AppSpacing.gapH32,
                      AppPrimaryButton(
                        text: 'حفظ التعديلات',
                        isLoading: userNotifier.isLoading,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final success =
                                await userNotifier.updateUserDetails(
                              fullName: nameController.text.trim(),
                              userEmail: emailController.text.trim(),
                              city: cityController.text.trim(),
                              userAddress:
                                  addressController.text.trim(),
                              context: context,
                            );
                            if (success && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
