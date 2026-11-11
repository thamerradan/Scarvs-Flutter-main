// يقرأ إعدادات Supabase ومفاتيح الاتصال من البيئة.
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static Future<void> loadEnv() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // إذا لم يتوفر الملف سيتم الاعتماد على القيم المباشرة
    }
  }

  /// قراءة المتغيرات من .env
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static bool get isConfigured =>
      url.isNotEmpty &&
      anonKey.isNotEmpty &&
      !url.contains('YOUR_SUPABASE_URL') &&
      !anonKey.contains('YOUR_SUPABASE_ANON_KEY');
}
