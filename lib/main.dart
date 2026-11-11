// نقطة تشغيل التطبيق وتهيئة البيئة واتصال Supabase قبل عرض الواجهة.
import 'package:flutter/material.dart';
import 'package:scarvs/app/app.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل ملف البيئة .env
  await SupabaseConfig.loadEnv();

  // تهيئة Supabase إذا كانت المفاتيح متوفرة
  if (SupabaseConfig.isConfigured) {
    try {
      await AppSupabase.initialize();
    } catch (e) {
      debugPrint('تعذر تهيئة Supabase: $e');
    }
  } else {
    debugPrint('تنبيه: لم يتم ضبط مفاتيح Supabase في ملف .env بعد');
  }

  runApp(const Lava());
}
