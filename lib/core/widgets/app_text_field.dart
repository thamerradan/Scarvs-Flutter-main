// يوفر حقلاً نصياً مخصصاً لإدخال البيانات.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scarvs/core/theme/app_colors.dart';

/// حقل إدخال نصوص مخصص عالي التوافقية مع اللغة العربية (RTL) والأرقام/الإيميل (LTR).
/// تم حل مشكلة عدم حذف الحروف العربية وتصحيح موضع المؤشر ومحاذاة الأيقونات.
class AppTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final String? labelText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final int? minLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextDirection? textDirection;
  final TextAlign? textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool enabled;
  final TextStyle? style;

  const AppTextField({
    super.key,
    required this.textEditingController,
    required this.hintText,
    this.labelText,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.onTap,
    this.textDirection,
    this.textAlign,
    this.inputFormatters,
    this.textInputAction,
    this.focusNode,
    this.enabled = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.creamColor : AppColors.mirage;
    final hintColor = isDark
        ? AppColors.creamColor.withValues(alpha: 0.45)
        : AppColors.mirage.withValues(alpha: 0.45);
    final fillColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.grey.shade50;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.grey.shade300;

    // الحقول اللاتينية (أرقام الهواتف، البريد، الروابط، الأرقام، وكلمات المرور) تعمل بصيغة LTR
    // الحقول النصية العادية ترث التوجيه الطبيعي للتطبيق (RTL) بسلاسة لتجنب خلل حذف الحروف
    final bool isLtrField = keyboardType == TextInputType.emailAddress ||
        keyboardType == TextInputType.url ||
        keyboardType == TextInputType.phone ||
        keyboardType == TextInputType.number ||
        obscureText;

    final effectiveDirection = textDirection ?? (isLtrField ? TextDirection.ltr : null);
    final effectiveAlign = textAlign ?? (isLtrField ? TextAlign.start : TextAlign.start);

    return TextFormField(
      controller: textEditingController,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textDirection: effectiveDirection,
      textAlign: effectiveAlign,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      inputFormatters: inputFormatters,
      cursorColor: isDark ? Colors.white : AppColors.rawSienna,
      cursorWidth: 2.0,
      cursorRadius: const Radius.circular(2),
      // عدم تحديد height هنا هو الحل الجذري لمشكلة عدم استجابة زر الحذف (Backspace) في النصوص العربية
      style: style ??
          GoogleFonts.cairo(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.cairo(
          color: hintColor,
          fontSize: 14,
        ),
        hintText: hintText,
        hintStyle: GoogleFonts.cairo(
          color: hintColor,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        fillColor: fillColor,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        prefixIcon: prefixIcon != null
            ? IconTheme(
                data: IconThemeData(
                  color: isDark
                      ? AppColors.creamColor.withValues(alpha: 0.7)
                      : AppColors.rawSienna,
                  size: 22,
                ),
                child: prefixIcon!,
              )
            : null,
        suffixIcon: suffixIcon != null
            ? IconTheme(
                data: IconThemeData(
                  color: isDark
                      ? AppColors.creamColor.withValues(alpha: 0.7)
                      : Colors.grey.shade600,
                  size: 20,
                ),
                child: suffixIcon!,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white : AppColors.rawSienna,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5), width: 1),
        ),
        errorStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
