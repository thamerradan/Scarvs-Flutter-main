// يعرض إتمام الشراء واختيار التوصيل وطريقة الدفع.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/constants/app_routes.dart';
import 'package:scarvs/providers/cart_provider.dart';
import 'package:scarvs/providers/order_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/providers/user_provider.dart';
import 'package:scarvs/core/utils/auth_guard.dart';
import 'package:scarvs/core/widgets/app_back_button.dart';
import 'package:scarvs/core/widgets/app_text_field.dart';
import 'package:scarvs/core/widgets/dimensions_widget.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController phoneController;
  late final TextEditingController cityController;
  late final TextEditingController addressController;
  late final TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    final userNotifier = Provider.of<UserProvider>(context, listen: false);
    phoneController = TextEditingController(
      text: userNotifier.getuserPhoneNumber != 'غير متوفر'
          ? userNotifier.getuserPhoneNumber
          : '',
    );
    cityController = TextEditingController(text: userNotifier.getUserCity);
    addressController = TextEditingController(
      text: userNotifier.getuserAddress != 'لم يتم تحديد العنوان'
          ? userNotifier.getuserAddress
          : '',
    );
    notesController = TextEditingController();
  }

  @override
  void dispose() {
    phoneController.dispose();
    cityController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cartNotifier = Provider.of<CartNotifier>(context, listen: false);
    if (cartNotifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('السلة فارغة!', textAlign: TextAlign.right)),
      );
      return;
    }

    final orderNotifier = Provider.of<OrderNotifier>(context, listen: false);

    final res = await orderNotifier.placeOrder(
      context: context,
      shippingAddress: addressController.text.trim(),
      city: cityController.text.trim(),
      phone: phoneController.text.trim(),
      notes: notesController.text.trim(),
      paymentMethod: 'cash_on_delivery',
    );

    if (res != null && res['success'] == true && mounted) {
      // تفريغ السلة في التطبيق وتحديثها
      await cartNotifier.loadCart(silent: true);
      if (!mounted) return;

      final orderNumber = res['order_number']?.toString() ?? '';

      // العودة تلقائياً ومباشرة إلى الصفحة الرئيسية
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.homeRoute,
        (route) => false,
      );

      // إظهار إشعار فوري أنيق بنجاح استلام الطلب ورقم الطلب
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xff1E232A),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تم استلام طلبك بنجاح! 🎉',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    if (orderNumber.isNotEmpty)
                      Text(
                        'رقم الطلب: #$orderNumber',
                        style: const TextStyle(
                          color: AppColors.rawSienna,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final cartNotifier = Provider.of<CartNotifier>(context);
    final orderNotifier = Provider.of<OrderNotifier>(context);

    return SafeArea(
      child: AuthProtected(
        returnRoute: AppRouter.checkoutRoute,
        message: 'يرجى تسجيل الدخول برقم الهاتف لمتابعة الطلب',
        child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppBackPop(themeFlag: themeFlag),
                    const SizedBox(width: 8),
                    Text(
                      'إتمام الطلب والشحن',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                      ),
                    ),
                  ],
                ),
                vSizedBox2,

                // 1. قسم بيانات التوصيل
                Text(
                  'بيانات التوصيل 📍',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                  ),
                ),
                vSizedBox1,
                AppTextField(
                  textEditingController: phoneController,
                  hintText: 'رقم الهاتف للتواصل',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'يرجى إدخال رقم الهاتف'
                      : null,
                ),
                vSizedBox1,
                AppTextField(
                  textEditingController: cityController,
                  hintText: 'المدينة',
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'يرجى إدخال المدينة'
                      : null,
                ),
                vSizedBox1,
                AppTextField(
                  textEditingController: addressController,
                  hintText: 'العنوان بالتفصيل (الحي، الشارع، المبنى)',
                  prefixIcon: const Icon(Icons.home_outlined),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'يرجى إدخال العنوان'
                      : null,
                ),
                vSizedBox1,
                AppTextField(
                  textEditingController: notesController,
                  hintText: 'ملاحظات إضافية للتوصيل (اختياري)',
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                ),

                vSizedBox3,

                // 2. قسم طريقة الدفع
                Text(
                  'طريقة الدفع 💵',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                  ),
                ),
                vSizedBox1,
                // طريقة الدفع الحصرية: الدفع عند الاستلام
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: themeFlag ? Colors.white10 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.rawSienna,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        color: AppColors.rawSienna,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الدفع عند الاستلام (كاش) 💵',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ادفع نقداً لمندوب التوصيل عند استلام الطلب',
                              style: TextStyle(
                                fontSize: 12,
                                color: (themeFlag
                                        ? AppColors.creamColor
                                        : AppColors.mirage)
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 22,
                      ),
                    ],
                  ),
                ),

                vSizedBox3,

                // 3. ملخص الحساب
                Text(
                  'ملخص الحساب 🧾',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                  ),
                ),
                vSizedBox1,
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeFlag ? Colors.white.withOpacity(0.06) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: themeFlag ? Colors.white12 : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('عدد الأحذية'),
                          Text('${cartNotifier.totalItemsCount} قطعة'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('المجموع الفرعي'),
                          Text('${cartNotifier.subtotal.toStringAsFixed(0)} ر.س'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('رسوم التوصيل'),
                          Text(
                            cartNotifier.actualShippingFee == 0
                                ? 'مجاناً 🎉'
                                : '${cartNotifier.actualShippingFee.toStringAsFixed(0)} ر.س',
                            style: TextStyle(
                              color: cartNotifier.actualShippingFee == 0
                                  ? Colors.green
                                  : null,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'المبلغ الإجمالي',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${cartNotifier.total.toStringAsFixed(0)} ر.س',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: AppColors.rawSienna,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                vSizedBox3,

                // زر تأكيد الطلب
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rawSienna,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    onPressed: orderNotifier.isLoading ? null : _submitOrder,
                    child: orderNotifier.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'تأكيد الطلب الآن 📦',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
