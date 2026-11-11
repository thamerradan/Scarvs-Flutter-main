// يوفر تهيئة عميل Supabase والوصول إلى حالة اتصاله.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class AppSupabase {
  AppSupabase._();

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => Supabase.instance.client.auth;
  static SupabaseStorageClient get storage => Supabase.instance.client.storage;
  static User? get currentUser => auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  /// تهيئة اتصال Supabase
  static Future<void> initialize({String? url, String? anonKey}) async {
    final effectiveUrl = url ?? SupabaseConfig.url;
    final effectiveAnonKey = anonKey ?? SupabaseConfig.anonKey;

    if (effectiveUrl.isEmpty || effectiveAnonKey.isEmpty) {
      throw ArgumentError(
        'بيانات الاتصال بـ Supabase غير متوفرة. يرجى ضبط SUPABASE_URL و SUPABASE_ANON_KEY في ملف .env',
      );
    }

    await Supabase.initialize(
      url: effectiveUrl,
      anonKey: effectiveAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        eventsPerSecond: 10,
      ),
    );
  }
}

