// ينفذ قراءة إعدادات المتجر وحفظها.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_tables.dart';
import 'package:scarvs/models/store_settings_model.dart';

class OwnerSettingsService {
  final SupabaseClient _client = AppSupabase.client;

  Future<StoreSettingsModel> fetchStoreSettings() async {
    try {
      final data = await _client
          .from(SupabaseTables.storeSettings)
          .select()
          .limit(1)
          .maybeSingle();

      if (data == null) {
        final created = await _client
            .from(SupabaseTables.storeSettings)
            .insert({
              'store_name': 'متجر تمنى للملابس',
              'shipping_fee': 25.00,
              'free_shipping_limit': 300.00,
              'cash_on_delivery_enabled': true,
            })
            .select()
            .single();
        return StoreSettingsModel.fromJson(created);
      }

      return StoreSettingsModel.fromJson(data);
    } catch (e) {
      throw 'فشل جلب إعدادات المتجر: $e';
    }
  }

  Future<void> updateStoreSettings(StoreSettingsModel settings) async {
    try {
      await _client
          .from(SupabaseTables.storeSettings)
          .update(settings.toJson())
          .eq('id', settings.id);
    } catch (e) {
      throw 'فشل حفظ إعدادات المتجر: $e';
    }
  }
}
