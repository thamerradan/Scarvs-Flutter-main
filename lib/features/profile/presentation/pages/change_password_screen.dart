// تعرض نموذج تغيير كلمة مرور المستخدم.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/app/theme/app_colors.dart';
import 'package:scarvs/features/auth/presentation/providers/auth_provider.dart';
import 'package:scarvs/app/providers/theme_provider.dart';
import 'package:scarvs/shared/widgets/custom_animated_container.dart';
import 'package:scarvs/shared/widgets/custom_back_button.dart';
import 'package:scarvs/shared/widgets/custom_text_field.dart';
import 'package:scarvs/shared/widgets/custom_text_style.dart';
import 'package:scarvs/shared/widgets/dimensions_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
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
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    CustomBackPop(themeFlag: themeFlag),
                    const SizedBox(width: 8),
                    Text(
                      'تغيير كلمة المرور',
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
                  padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 20.0),
                  child: Column(
                    children: [
                      CustomTextField.customTextField(
                        textEditingController: newPassController,
                        hintText: 'كلمة المرور الجديدة',
                        obscureText: _obscureNew,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNew = !_obscureNew;
                            });
                          },
                        ),
                        onChanged: (val) {
                          authNotifier.checkPasswordStrength(password: val);
                        },
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'يرجى إدخال كلمة المرور الجديدة';
                          }
                          if (val.length < 6) {
                            return 'كلمة المرور يجب ألا تقل عن 6 أحرف';
                          }
                          return null;
                        },
                      ),
                      if (authNotifier.passwordLevel.isNotEmpty) ...[
                        vSizedBox1,
                        Row(
                          children: [
                            Text(authNotifier.passwordEmoji,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
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
                      ],
                      vSizedBox2,
                      CustomTextField.customTextField(
                        textEditingController: confirmPassController,
                        hintText: 'تأكيد كلمة المرور الجديدة',
                        obscureText: _obscureConfirm,
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirm = !_obscureConfirm;
                            });
                          },
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'يرجى تأكيد كلمة المرور';
                          }
                          if (val != newPassController.text) {
                            return 'كلمتا المرور غير متطابقتين';
                          }
                          return null;
                        },
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
                          onPressed: authNotifier.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    final success =
                                        await authNotifier.updatePassword(
                                      context: context,
                                      newPassword:
                                          newPassController.text.trim(),
                                    );
                                    if (success && mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  }
                                },
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
                                  'تحديث كلمة المرور',
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
