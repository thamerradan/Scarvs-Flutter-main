// يعرض إنشاء حساب جديد ويتعامل مع بيانات التسجيل.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/providers/auth_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/widgets/auth_header.dart';
import 'package:scarvs/core/widgets/custom_animated_container.dart';
import 'package:scarvs/core/widgets/app_text_field.dart';
import 'package:scarvs/core/widgets/dimensions_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userPhoneController = TextEditingController();
  final TextEditingController userPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    userEmailController.dispose();
    userNameController.dispose();
    userPhoneController.dispose();
    userPassController.dispose();
    super.dispose();
  }

  void _createAccount() {
    if (_formKey.currentState!.validate()) {
      final authNotifier =
          Provider.of<AuthenticationNotifier>(context, listen: false);
      authNotifier.createAccount(
        context: context,
        useremail: userEmailController.text.trim(),
        username: userNameController.text.trim(),
        userpassword: userPassController.text.trim(),
        phone: userPhoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final authNotifier = Provider.of<AuthenticationNotifier>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              welcomeTextSignup(themeFlag: themeFlag),
              Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35.0, vertical: 6.0),
                        child: AppTextField.customTextField(
                          textEditingController: userNameController,
                          hintText: 'الاسم الكامل',
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'يرجى إدخال الاسم';
                            }
                            if (val.trim().length < 3) {
                              return 'الاسم يجب ألا يقل عن 3 أحرف';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35.0, vertical: 6.0),
                        child: AppTextField.customTextField(
                          textEditingController: userPhoneController,
                          hintText: 'رقم الهاتف',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'يرجى إدخال رقم الهاتف';
                            }
                            if (val.trim().length < 8) {
                              return 'رقم الهاتف يجب أن يتكون من 8 أرقام على الأقل';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35.0, vertical: 6.0),
                        child: AppTextField.customTextField(
                          textEditingController: userEmailController,
                          hintText: 'البريد الإلكتروني (اختياري)',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              if (!RegExp(
                                      r'^.+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')
                                  .hasMatch(val.trim())) {
                                return 'يرجى إدخال بريد إلكتروني صالح أو تركه فارغاً';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35.0, vertical: 6.0),
                        child: AppTextField.customTextField(
                          onChanged: (val) {
                            authNotifier.checkPasswordStrength(password: val);
                          },
                          textEditingController: userPassController,
                          hintText: 'كلمة المرور',
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'يرجى إدخال كلمة المرور';
                            }
                            if (val.length < 6) {
                              return 'كلمة المرور يجب أن لا تقل عن 6 أحرف';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (authNotifier.passwordLevel.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 35.0, vertical: 6.0),
                  child: Row(
                    children: [
                      Text(authNotifier.passwordEmoji,
                          style: const TextStyle(fontSize: 18)),
                      hSizedBox1,
                      Text(
                        'قوة كلمة المرور: ${authNotifier.passwordTextArabic}',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeFlag
                              ? AppColors.creamColor
                              : AppColors.mirage,
                        ),
                      ),
                      const Spacer(),
                      if (authNotifier.passwordLevel == 'Weak')
                        CustomAnimatedContainer.customAnimatedContainer(
                          height: 8,
                          width: MediaQuery.of(context).size.width * 0.25,
                          context: context,
                          color: Colors.red,
                          curve: Curves.easeIn,
                        ),
                      if (authNotifier.passwordLevel == 'Medium')
                        CustomAnimatedContainer.customAnimatedContainer(
                          height: 8,
                          width: MediaQuery.of(context).size.width * 0.45,
                          context: context,
                          color: Colors.amber,
                          curve: Curves.easeIn,
                        ),
                      if (authNotifier.passwordLevel == 'Strong')
                        CustomAnimatedContainer.customAnimatedContainer(
                          height: 8,
                          width: MediaQuery.of(context).size.width * 0.60,
                          context: context,
                          color: Colors.green,
                          curve: Curves.easeIn,
                        ),
                    ],
                  ),
                ),
              ],
              vSizedBox2,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rawSienna,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed:
                        authNotifier.isLoading ? null : _createAccount,
                    child: authNotifier.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'إنشاء الحساب',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              vSizedBox2,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.rawSienna,
                      side: const BorderSide(color: AppColors.rawSienna, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.phone_android_outlined, size: 20),
                    label: const Text(
                      'التسجيل السريع برقم الهاتف',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRouter.phoneAuthRoute,
                        arguments: const PhoneAuthArgs(isSignUp: true),
                      );
                    },
                  ),
                ),
              ),
              vSizedBox2,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لديك حساب بالفعل؟ ',
                    style: TextStyle(
                      color:
                          themeFlag ? AppColors.creamColor : AppColors.mirage,
                      fontSize: 14.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRouter.loginRoute),
                    child: Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        color: AppColors.rawSienna,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
              vSizedBox3,
            ],
          ),
        ),
      ),
    );
  }
}
