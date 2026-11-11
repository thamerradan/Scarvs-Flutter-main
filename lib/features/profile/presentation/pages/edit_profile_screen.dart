// تعرض نموذج تعديل بيانات الملف الشخصي.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/app/theme/app_colors.dart';
import 'package:scarvs/app/providers/theme_provider.dart';
import 'package:scarvs/features/profile/presentation/providers/profile_provider.dart';
import 'package:scarvs/shared/widgets/custom_back_button.dart';
import 'package:scarvs/shared/widgets/custom_text_field.dart';
import 'package:scarvs/shared/widgets/custom_text_style.dart';
import 'package:scarvs/shared/widgets/dimensions_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;
  late final TextEditingController cityController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final userNotifier = Provider.of<UserNotifier>(context, listen: false);
    nameController =
        TextEditingController(text: userNotifier.getUserName ?? '');
    emailController =
        TextEditingController(text: userNotifier.getUserEmail ?? '');
    phoneController = TextEditingController(
        text: userNotifier.getuserPhoneNumber != 'غير متوفر'
            ? userNotifier.getuserPhoneNumber
            : '');
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
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final userNotifier = Provider.of<UserNotifier>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    CustomBackPop(themeFlag: themeFlag),
                    const SizedBox(width: 8),
                    Text(
                      'تعديل البيانات الشخصية',
                      style: CustomTextWidget.bodyTextB2(
                        color: themeFlag
                            ? AppColors.creamColor
                            : AppColors.mirage,
                      ),
                    ),
                  ],
                ),
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                  child: Column(
                    children: [
                      CustomTextField.customTextField(
                        textEditingController: nameController,
                        hintText: 'الاسم الكامل',
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'يرجى إدخال الاسم'
                            : null,
                      ),
                      vSizedBox2,
                      CustomTextField.customTextField(
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
                      vSizedBox2,
                      CustomTextField.customTextField(
                        textEditingController: phoneController,
                        hintText: 'رقم الهاتف',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'يرجى إدخال رقم الهاتف';
                          }
                          return null;
                        },
                      ),
                      vSizedBox2,
                      CustomTextField.customTextField(
                        textEditingController: cityController,
                        hintText: 'المدينة',
                        prefixIcon: const Icon(Icons.location_city_outlined),
                      ),
                      vSizedBox2,
                      CustomTextField.customTextField(
                        textEditingController: addressController,
                        hintText: 'العنوان بالتفصيل',
                        prefixIcon: const Icon(Icons.home_outlined),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'يرجى إدخال العنوان'
                            : null,
                      ),
                      vSizedBox3,
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.rawSienna,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: userNotifier.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    final success =
                                        await userNotifier.updateUserDetails(
                                      fullName: nameController.text.trim(),
                                      userEmail: emailController.text.trim(),
                                      userPhoneNo: phoneController.text.trim(),
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
                          child: userNotifier.isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'حفظ التعديلات',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
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
