// ينفذ رفع الصور والملفات إلى تخزين Supabase وحذفها.
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';
import 'supabase_tables.dart';

class StorageService {
  final SupabaseClient _client = AppSupabase.client;

  /// رفع صورة إلى إحدى حاويات Supabase Storage والحصول على الرابط العام
  Future<String> uploadImage({
    required File file,
    required String bucket,
    required String path,
  }) async {
    try {
      final ext = file.path.split('.').last.toLowerCase();
      final mimeType = ext == 'png'
          ? 'image/png'
          : ext == 'webp'
              ? 'image/webp'
              : 'image/jpeg';

      await _client.storage.from(bucket).upload(
            path,
            file,
            fileOptions: FileOptions(
              contentType: mimeType,
              upsert: true,
            ),
          );

      final publicUrl = _client.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw 'حدث خطأ أثناء رفع الصورة: $e';
    }
  }

  /// رفع صورة منتج
  Future<String> uploadProductImage({
    required File file,
    required String productId,
    String? fileName,
  }) async {
    final name = fileName ?? 'main_${DateTime.now().millisecondsSinceEpoch}';
    final path = '$productId/$name';
    return uploadImage(
      file: file,
      bucket: SupabaseTables.productImagesBucket,
      path: path,
    );
  }

  /// رفع صورة تصنيف
  Future<String> uploadCategoryImage({
    required File file,
    required String categoryId,
  }) async {
    final path = '$categoryId/category_${DateTime.now().millisecondsSinceEpoch}';
    return uploadImage(
      file: file,
      bucket: SupabaseTables.categoryImagesBucket,
      path: path,
    );
  }
}
