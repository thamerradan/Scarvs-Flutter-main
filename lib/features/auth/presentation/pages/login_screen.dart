// يعرض شاشة تسجيل الدخول ويتعامل مع إدخال بيانات المستخدم.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/app/theme/app_colors.dart';
import 'package:scarvs/app/router/app_router.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/features/auth/presentation/providers/auth_provider.dart';
import 'package:scarvs/app/providers/theme_provider.dart';
import 'package:scarvs/features/auth/presentation/widgets/welcome_login_widget.dart';
import 'package:scarvs/shared/widgets/custom_text_field.dart';
import 'package:scarvs/shared/widgets/dimensions_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    userEmailController.dispose();
    userPassController.dispose();
    super.dispose();
  }

  void _userLogin() {
    if (_formKey.currentState!.validate()) {
      final authNotifier =
          Provider.of<AuthenticationNotifier>(context, listen: false);
      authNotifier.userLogin(
        context: context,
        useremail: userEmailController.text.trim(),
        userpassword: userPassController.text.trim(),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController =
        TextEditingController(text: userEmailController.text.trim());
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'استعادة كلمة المرور',
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'أدخل بريدك الإلكتروني المسجل وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'name@example.com',
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'يرجى إدخال البريد الإلكتروني';
                    }
                    if (!val.contains('@') || !val.contains('.')) {
                      return 'يرجى إدخال بريد إلكتروني صالح';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rawSienna,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (dialogFormKey.currentState!.validate()) {
                  final email = resetEmailController.text.trim();
                  Navigator.of(ctx).pop();
                  final authNotifier =
                      Provider.of<AuthenticationNotifier>(context, listen: false);
                  await authNotifier.resetPassword(
                    context: context,
                    email: email,
                  );
                }
              },
              child: const Text('إرسال الرابط', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
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
              welcomeTextLogin(themeFlag: themeFlag),
              vSizedBox2,
              Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 35.0, vertical: 6.0),
                        child: CustomTextField.customTextField(
                          textEditingController: userEmailController,
                          hintText: 'البريد الإلكتروني',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'يرجى إدخال البريد الإلكتروني';
                            }
                            if (!RegExp(
                                    r'^.+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')
                                .hasMatch(val.trim())) {
                              return 'يرجى إدخال بريد إلكتروني صالح';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 35.0, vertical: 6.0),
                        child: CustomTextField.customTextField(
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
                              return 'كلمة المرور يجب ألا تقل عن 6 أحرف';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: _showForgotPasswordDialog,
                            child: Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyle(
                                color: themeFlag
                                    ? AppColors.creamColor
                                    : AppColors.mirage,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      vSizedBox1,
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
                                authNotifier.isLoading ? null : _userLogin,
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
                                    'تسجيل الدخول',
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
                              'الدخول السريع برقم الهاتف',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                AppRouter.phoneAuthRoute,
                                arguments: const PhoneAuthArgs(isSignUp: false),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              vSizedBox2,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ليس لديك حساب بعد؟ ',
                    style: TextStyle(
                      color:
                          themeFlag ? AppColors.creamColor : AppColors.mirage,
                      fontSize: 14.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRouter.signUpRoute),
                    child: Text(
                      'أنشئ حساباً الآن',
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
