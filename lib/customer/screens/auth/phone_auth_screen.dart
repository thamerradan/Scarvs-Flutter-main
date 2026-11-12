// يعرض التحقق من رقم الهاتف وإدخال رمز المصادقة.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/providers/auth_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/utils/auth_guard.dart';

class PhoneAuthScreen extends StatefulWidget {
  final PhoneAuthArgs args;
  const PhoneAuthScreen({super.key, required this.args});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  // ============================================================
  // المتغيرات الأساسية
  // ============================================================
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  late bool _isSignUp;
  bool _otpSent = false;
  String _phoneFormatted = '';
  String _selectedCountry = '+967'; // اليمن افتراضياً

  // العد التنازلي لإعادة الإرسال (60 ثانية)
  int _resendCooldown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.args.isSignUp;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // توحيد صيغة رقم الهاتف (اليمني والسعودي) للصيغة الدولية
  // ============================================================
  String _normalizePhone(String input) {
    String phone = input.trim().replaceAll(RegExp(r'\s+'), '');

    // إذا كان يحتوي على رمز الدولة مسبقاً بالصيغة الدولية
    if (phone.startsWith('+967') || phone.startsWith('+966')) {
      return phone;
    }
    if (phone.startsWith('967') || phone.startsWith('966')) {
      return '+$phone';
    }

    // إذا بدأ بـ 0 (محلي)
    if (phone.startsWith('0')) {
      final stripped = phone.substring(1);
      // إذا كان يمنياً يبدأ بـ 7 بعد الصفر (07xxxxxxxx)
      if (stripped.startsWith('7') && stripped.length == 9) {
        return '+967$stripped';
      }
      // إذا كان سعودياً يبدأ بـ 5 بعد الصفر (05xxxxxxxx)
      if (stripped.startsWith('5') && stripped.length == 9) {
        return '+966$stripped';
      }
      return '$_selectedCountry$stripped';
    }

    // إذا بدأ بـ 7 وطوله 9 أرقام (رقم نقال يمني)
    if (phone.startsWith('7') && phone.length == 9) {
      return '+967$phone';
    }

    // إذا بدأ بـ 5 وطوله 9 أرقام (رقم نقال سعودي)
    if (phone.startsWith('5') && phone.length == 9) {
      return '+966$phone';
    }

    // الاعتماد على الدولة المختارة
    if (!phone.startsWith('+')) {
      return '$_selectedCountry$phone';
    }

    return phone;
  }

  bool _isValidPhone(String normalized) {
    // رقم يمني: +967 متبوع بـ 9 أرقام (شركات النقال 77, 73, 71, 70, 78)
    final yemenRegex = RegExp(r'^\+967[0-9]{9}$');
    // رقم سعودي: +966 متبوع بـ 5 و 8 أرقام
    final saudiRegex = RegExp(r'^\+9665[0-9]{8}$');

    return yemenRegex.hasMatch(normalized) || saudiRegex.hasMatch(normalized);
  }

  // ============================================================
  // الخطوة الأولى: إرسال OTP
  // ============================================================
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    _phoneFormatted = _normalizePhone(_phoneController.text);

    final authNotifier =
        Provider.of<AuthenticationNotifier>(context, listen: false);
    final success = await authNotifier.sendPhoneOtp(
      context: context,
      phone: _phoneFormatted,
      isSignUp: _isSignUp,
    );

    if (success && mounted) {
      setState(() {
        _otpSent = true;
        _resendCooldown = 60;
      });
      _startResendTimer();
    }
  }

  // ============================================================
  // الخطوة الثانية: التحقق من OTP
  // ============================================================
  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رمز التحقق')),
      );
      return;
    }

    final emailText = _emailController.text.trim();
    final authNotifier =
        Provider.of<AuthenticationNotifier>(context, listen: false);
    await authNotifier.verifyPhoneOtp(
      context: context,
      phone: _phoneFormatted,
      token: _otpController.text.trim(),
      fullName: _isSignUp ? _nameController.text.trim() : null,
      email: (_isSignUp && emailText.isNotEmpty) ? emailText : null,
      returnRoute: widget.args.returnRoute,
    );
  }

  // ============================================================
  // إعادة إرسال OTP
  // ============================================================
  Future<void> _resendOtp() async {
    if (_resendCooldown > 0) return;
    _otpController.clear();

    final authNotifier =
        Provider.of<AuthenticationNotifier>(context, listen: false);
    final success = await authNotifier.sendPhoneOtp(
      context: context,
      phone: _phoneFormatted,
      isSignUp: _isSignUp,
    );

    if (success && mounted) {
      setState(() => _resendCooldown = 60);
      _startResendTimer();
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  // ============================================================
  // Build
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final authNotifier = Provider.of<AuthenticationNotifier>(context);

    final bgColor = themeFlag ? AppColors.mirage : AppColors.creamColor;
    final textColor = themeFlag ? AppColors.creamColor : AppColors.mirage;

    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // زر الرجوع
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.arrow_back_ios, color: textColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 20),

                // العنوان والوصف
                _buildHeader(textColor),

                const SizedBox(height: 36),

                if (!_otpSent)
                  // المرحلة الأولى: إدخال رقم الهاتف
                  _buildPhaseOne(textColor, authNotifier, themeFlag)
                else
                  // المرحلة الثانية: إدخال رمز OTP
                  _buildPhaseTwo(textColor, authNotifier, themeFlag),

                const SizedBox(height: 24),

                // تبديل بين تسجيل الدخول وإنشاء حساب
                if (!_otpSent) _buildToggleMode(textColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Widgets المساعدة
  // ============================================================

  Widget _buildHeader(Color textColor) {
    final title = _otpSent
        ? 'أدخل رمز التحقق'
        : (_isSignUp ? 'إنشاء حساب جديد' : 'تسجيل الدخول');

    final subtitle = _otpSent
        ? 'تم إرسال رمز مكوّن من 6 أرقام إلى\n$_phoneFormatted'
        : (_isSignUp
            ? 'أنشئ حسابك وابدأ التسوق بكل سهولة'
            : 'أهلاً بعودتك! سجّل دخولك برقم هاتفك');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // أيقونة
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.rawSienna.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            _otpSent ? Icons.sms_outlined : Icons.phone_android_outlined,
            color: AppColors.rawSienna,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: textColor.withValues(alpha: 0.6),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseOne(
      Color textColor, AuthenticationNotifier authNotifier, bool themeFlag) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // حقل الاسم (فقط عند إنشاء الحساب)
          if (_isSignUp) ...[
            _buildLabel('الاسم الكامل', textColor),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'أدخل اسمك الكامل',
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
              themeFlag: themeFlag,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'يرجى إدخال الاسم الكامل';
                }
                if (val.trim().length < 2) {
                  return 'الاسم يجب أن يكون حرفين على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // حقل البريد الإلكتروني (اختياري)
            _buildLabel('البريد الإلكتروني (اختياري)', textColor),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hint: 'name@example.com (اختياري)',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              themeFlag: themeFlag,
              validator: (val) {
                if (val != null && val.trim().isNotEmpty) {
                  if (!RegExp(r'^.+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')
                      .hasMatch(val.trim())) {
                    return 'يرجى إدخال بريد إلكتروني صالح أو تركه فارغاً';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],

          // حقل رقم الهاتف
          _buildLabel('رقم الهاتف', textColor),
          const SizedBox(height: 8),
          _buildPhoneField(textColor, themeFlag),
          const SizedBox(height: 28),

          // زر إرسال OTP
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rawSienna,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              onPressed:
                  authNotifier.isSendingOtp ? null : _sendOtp,
              child: authNotifier.isSendingOtp
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      _isSignUp ? 'إرسال رمز التحقق' : 'إرسال رمز الدخول',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseTwo(
      Color textColor, AuthenticationNotifier authNotifier, bool themeFlag) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (authNotifier.lastGeneratedOtp != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.rawSienna.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.rawSienna.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.key,
                        color: AppColors.rawSienna, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'رمز التحقق: ${authNotifier.lastGeneratedOtp}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.rawSienna,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    _otpController.text = authNotifier.lastGeneratedOtp!;
                  },
                  child: const Text(
                    'تعبئة تلقائية',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.rawSienna,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        // حقل رمز OTP
        _buildLabel('رمز التحقق', textColor),
        const SizedBox(height: 8),
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 12,
            color: textColor,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: '------',
            hintStyle: TextStyle(
              fontSize: 28,
              letterSpacing: 12,
              color: textColor.withValues(alpha: 0.3),
            ),
            filled: true,
            fillColor: themeFlag ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.rawSienna, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // رابط إعادة الإرسال والعد التنازلي
        Center(
          child: _resendCooldown > 0
              ? Text(
                  'يمكن إعادة الإرسال بعد $_resendCooldown ثانية',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                )
              : GestureDetector(
                  onTap: authNotifier.isSendingOtp ? null : _resendOtp,
                  child: Text(
                    authNotifier.isSendingOtp ? 'جاري الإرسال...' : 'إعادة إرسال الرمز',
                    style: const TextStyle(
                      color: AppColors.rawSienna,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 28),

        // زر التحقق
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rawSienna,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
            onPressed: authNotifier.isLoading ? null : _verifyOtp,
            child: authNotifier.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'تأكيد وإكمال',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),

        // العودة لتغيير الرقم
        Center(
          child: TextButton(
            onPressed: () {
              _resendTimer?.cancel();
              setState(() {
                _otpSent = false;
                _otpController.clear();
                _resendCooldown = 0;
              });
            },
            child: Text(
              'تغيير رقم الهاتف',
              style: TextStyle(color: textColor.withValues(alpha: 0.6)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label, Color textColor) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required bool themeFlag,
    TextDirection? textDirection,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final textColor = themeFlag ? AppColors.creamColor : AppColors.mirage;
    final effectiveDirection = textDirection ??
        (keyboardType == TextInputType.emailAddress ? TextDirection.ltr : TextDirection.rtl);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: effectiveDirection,
      textAlign: TextAlign.start,
      cursorColor: AppColors.rawSienna,
      style: GoogleFonts.cairo(
        color: textColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cairo(
          color: textColor.withValues(alpha: 0.45),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: AppColors.rawSienna, size: 22),
        filled: true,
        fillColor:
            themeFlag ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.rawSienna, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPhoneField(Color textColor, bool themeFlag) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr, // الأرقام تعرض LTR بشكل سليم مع بادئة الدولة
      textAlign: TextAlign.start,
      cursorColor: AppColors.rawSienna,
      style: GoogleFonts.cairo(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'يرجى إدخال رقم الهاتف';
        }
        final normalized = _normalizePhone(val.trim());
        if (!_isValidPhone(normalized)) {
          return _selectedCountry == '+967'
              ? 'يرجى إدخال رقم يمني صحيح (مثال: 771234567)'
              : 'يرجى إدخال رقم سعودي صحيح (مثال: 0512345678)';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: _selectedCountry == '+967'
            ? '7xxxxxxxx (مثال: 771234567)'
            : '5xxxxxxxx (مثال: 0512345678)',
        hintStyle: GoogleFonts.cairo(
          color: textColor.withValues(alpha: 0.4),
          fontSize: 13,
          letterSpacing: 0,
        ),
        prefixIcon: Container(
          margin: const EdgeInsetsDirectional.only(end: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: themeFlag
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCountry,
              dropdownColor: themeFlag ? AppColors.mirage : Colors.white,
              borderRadius: BorderRadius.circular(12),
              icon: const Icon(Icons.arrow_drop_down,
                  color: AppColors.rawSienna, size: 20),
              items: const [
                DropdownMenuItem(
                  value: '+967',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🇾🇪', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 4),
                      Text(
                        '+967',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: '+966',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🇸🇦', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 4),
                      Text(
                        '+966',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedCountry = val);
                }
              },
            ),
          ),
        ),
        filled: true,
        fillColor: themeFlag
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.rawSienna, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildToggleMode(Color textColor) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isSignUp ? 'لديك حساب بالفعل؟ ' : 'لا تملك حساباً؟ ',
            style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 14),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isSignUp = !_isSignUp;
                _nameController.clear();
              });
            },
            child: Text(
              _isSignUp ? 'تسجيل الدخول' : 'إنشاء حساب جديد',
              style: const TextStyle(
                color: AppColors.rawSienna,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
