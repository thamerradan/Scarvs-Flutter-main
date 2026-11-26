// تعرض إعدادات المتجر وتتيح للمالك تعديلها.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scarvs/core/theme/app_colors.dart';
import 'package:scarvs/core/theme/app_spacing.dart';
import 'package:scarvs/models/store_settings_model.dart';
import 'package:scarvs/providers/owner_provider.dart';
import 'package:scarvs/providers/theme_provider.dart';
import 'package:scarvs/core/widgets/app_buttons.dart';
import 'package:scarvs/core/widgets/app_card.dart';
import 'package:scarvs/core/widgets/app_page_header.dart';
import 'package:scarvs/core/widgets/app_state_view.dart';
import 'package:scarvs/core/widgets/app_text_field.dart';

class OwnerSettingsScreen extends StatefulWidget {
  const OwnerSettingsScreen({super.key});

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
      freeShippingLimit:
          double.tryParse(_freeShippingController.text.trim()) ?? 300.0,
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
            // شريط العنوان الموحد
            AppPageHeader(
              title: 'إعدادات المتجر',
              actions: [
                AppRefreshButton(
                  onPressed: () =>
                      ownerNotifier.fetchStoreSettings(context: context),
                  isLoading: ownerNotifier.isSettingsLoading,
                ),
              ],
            ),

            // النموذج
            Expanded(
              child: AppStateView(
                isLoading: ownerNotifier.isSettingsLoading,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSectionTitle('البيانات العامة', themeFlag),
                      AppSpacing.gapH8,
                      AppTextField(
                        textEditingController: _nameController,
                        labelText: 'اسم المتجر',
                        hintText: 'أدخل اسم المتجر',
                        prefixIcon: const Icon(Icons.store),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'مطلوب' : null,
                      ),
                      AppSpacing.gapH12,
                      AppTextField(
                        textEditingController: _phoneController,
                        labelText: 'رقم هاتف المتجر',
                        hintText: '05xxxxxxxx',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      AppSpacing.gapH12,
                      AppTextField(
                        textEditingController: _whatsappController,
                        labelText: 'رقم الواتساب',
                        hintText: '9665xxxxxxxx',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.chat),
                      ),
                      AppSpacing.gapH24,

                      _buildSectionTitle('الشحن والتوصيل', themeFlag),
                      AppSpacing.gapH8,
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              textEditingController: _shippingFeeController,
                              labelText: 'رسوم الشحن الافتراضية',
                              hintText: '25',
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Icons.local_shipping),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'مطلوب' : null,
                            ),
                          ),
                          AppSpacing.gapW12,
                          Expanded(
                            child: AppTextField(
                              textEditingController: _freeShippingController,
                              labelText: 'الحد الأدنى للشحن المجاني',
                              hintText: '300',
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Icons.card_giftcard),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'مطلوب' : null,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.gapH24,

                      _buildSectionTitle('طرق الدفع وحالة النظام', themeFlag),
                      AppSpacing.gapH8,
                      AppCard(
                        padding: EdgeInsets.zero,
                        hasShadow: false,
                        child: SwitchListTile(
                          title: const Text('تفعيل الدفع عند الاستلام (COD)'),
                          subtitle:
                              const Text('إتاحة الدفع كاش عند استلام الشحنة'),
                          value: _codEnabled,
                          activeThumbColor:
                              themeFlag ? Colors.white : AppColors.rawSienna,
                          onChanged: (val) =>
                              setState(() => _codEnabled = val),
                        ),
                      ),
                      AppSpacing.gapH8,
                      AppCard(
                        padding: EdgeInsets.zero,
                        hasShadow: false,
                        child: SwitchListTile(
                          title: const Text('وضع الصيانة المؤقت'),
                          subtitle:
                              const Text('إيقاف استقبال طلبات جديدة مؤقتاً'),
                          value: _maintenanceMode,
                          activeThumbColor:
                              themeFlag ? Colors.white : AppColors.rawSienna,
                          onChanged: (val) =>
                              setState(() => _maintenanceMode = val),
                        ),
                      ),
                      AppSpacing.gapH32,

                      // زر الحفظ
                      AppPrimaryButton(
                        text: 'حفظ التغييرات',
                        isLoading: ownerNotifier.isSaving,
                        onPressed: _saveSettings,
                      ),
                      AppSpacing.gapH24,
                    ],
                  ),
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
        color: (themeFlag ? AppColors.creamColor : AppColors.mirage)
            .withValues(alpha: 0.8),
      ),
    );
  }
}
