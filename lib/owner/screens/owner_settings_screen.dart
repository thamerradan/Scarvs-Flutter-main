// تعرض إعدادات المتجر وتتيح للمالك تعديلها.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/models/store_settings_model.dart';
import 'package:scarvs/providers/auth_provider.dart';
import 'package:scarvs/providers/owner_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/widgets/app_back_button.dart';
import 'package:scarvs/core/widgets/app_loader.dart';

class OwnerSettingsScreen extends StatefulWidget {
  const OwnerSettingsScreen({Key? key}) : super(key: key);

  @override
  State<OwnerSettingsScreen> createState() => _OwnerSettingsScreenState();
}

class _OwnerSettingsScreenState extends State<OwnerSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _shippingFeeController;
  late final TextEditingController _freeShippingController;

  bool _codEnabled = true;
  bool _onlinePaymentEnabled = false;
  bool _maintenanceMode = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _whatsappController = TextEditingController();
    _shippingFeeController = TextEditingController();
    _freeShippingController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ownerNotifier = Provider.of<OwnerNotifier>(context, listen: false);
      await ownerNotifier.fetchStoreSettings(context: context);
      final s = ownerNotifier.storeSettings;
      if (s != null) {
        _nameController.text = s.storeName;
        _phoneController.text = s.phone ?? '';
        _whatsappController.text = s.whatsapp ?? '';
        _shippingFeeController.text = s.shippingFee.toStringAsFixed(0);
        _freeShippingController.text = s.freeShippingLimit.toStringAsFixed(0);
        setState(() {
          _codEnabled = s.cashOnDeliveryEnabled;
          _onlinePaymentEnabled = s.onlinePaymentEnabled;
          _maintenanceMode = s.maintenanceMode;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _shippingFeeController.dispose();
    _freeShippingController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    final ownerNotifier = Provider.of<OwnerNotifier>(context, listen: false);

    final current = ownerNotifier.storeSettings;
    final updated = StoreSettingsModel(
      id: current?.id ?? '',
      storeName: _nameController.text.trim(),
      logoUrl: current?.logoUrl,
      phone: _phoneController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      shippingFee: double.tryParse(_shippingFeeController.text.trim()) ?? 25.0,
      freeShippingLimit: double.tryParse(_freeShippingController.text.trim()) ?? 300.0,
      cashOnDeliveryEnabled: _codEnabled,
      onlinePaymentEnabled: _onlinePaymentEnabled,
      maintenanceMode: _maintenanceMode,
    );

    await ownerNotifier.saveStoreSettings(updated, context: context);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeFlag = themeNotifier.darkTheme;
    final ownerNotifier = Provider.of<OwnerNotifier>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeFlag ? AppColors.mirage : AppColors.creamColor,
        body: Column(
          children: [
            // الهيدر
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  AppBackPop(themeFlag: themeFlag),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'إعدادات المتجر ⚙️',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeFlag ? AppColors.creamColor : AppColors.mirage,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // النموذج
            Expanded(
              child: ownerNotifier.isLoading
                  ? customLoader(isDark: themeFlag, themeFlag: themeFlag, context: context)
                  : Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildSectionTitle('البيانات العامة', themeFlag),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                            decoration: _inputDecoration(
                              label: 'اسم المتجر',
                              icon: Icons.store,
                              themeFlag: themeFlag,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            decoration: _inputDecoration(
                              label: 'رقم هاتف المتجر',
                              icon: Icons.phone,
                              themeFlag: themeFlag,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _whatsappController,
                            decoration: _inputDecoration(
                              label: 'رقم الواتساب لخدمة العملاء',
                              icon: Icons.chat,
                              themeFlag: themeFlag,
                            ),
                          ),
                          const SizedBox(height: 24),

                          _buildSectionTitle('سياسة الشحن والتوصيل', themeFlag),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _shippingFeeController,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                                  decoration: _inputDecoration(
                                    label: 'رسوم الشحن الافتراضية (ر.س)',
                                    icon: Icons.local_shipping,
                                    themeFlag: themeFlag,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _freeShippingController,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                                  decoration: _inputDecoration(
                                    label: 'الحد الأدنى للشحن المجاني (ر.س)',
                                    icon: Icons.card_giftcard,
                                    themeFlag: themeFlag,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          _buildSectionTitle('طرق الدفع وحالة النظام', themeFlag),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            tileColor: themeFlag ? Colors.white10 : Colors.white,
                            title: const Text('تفعيل الدفع عند الاستلام (COD)'),
                            subtitle: const Text('إتاحة الدفع كاش عند استلام الشحنة'),
                            value: _codEnabled,
                            activeColor: Colors.green,
                            onChanged: (val) => setState(() => _codEnabled = val),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            tileColor: themeFlag ? Colors.white10 : Colors.white,
                            title: const Text('وضع الصيانة المؤقت 🛑'),
                            subtitle: const Text('إيقاف استقبال طلبات جديدة مؤقتاً'),
                            value: _maintenanceMode,
                            activeColor: Colors.red,
                            onChanged: (val) => setState(() => _maintenanceMode = val),
                          ),
                          const SizedBox(height: 32),

                          // زر الحفظ
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.rawSienna,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 3,
                              ),
                              onPressed: ownerNotifier.isSaving ? null : _saveSettings,
                              child: ownerNotifier.isSaving
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'حفظ التغييرات ✅',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // زر تسجيل الخروج
                          SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.logout),
                              label: const Text(
                                'تسجيل الخروج من لوحة التحكم',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('تسجيل الخروج'),
                                    content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: const Text('إلغاء'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                        ),
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: const Text(
                                          'تسجيل خروج',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true && context.mounted) {
                                  await Provider.of<AuthenticationNotifier>(
                                    context,
                                    listen: false,
                                  ).signOut(context: context);
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool themeFlag) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: (themeFlag ? AppColors.creamColor : AppColors.mirage).withOpacity(0.8),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required bool themeFlag,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: themeFlag ? Colors.white10 : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: (themeFlag ? AppColors.creamColor : AppColors.mirage).withOpacity(0.15),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: (themeFlag ? AppColors.creamColor : AppColors.mirage).withOpacity(0.15),
        ),
      ),
    );
  }
}
