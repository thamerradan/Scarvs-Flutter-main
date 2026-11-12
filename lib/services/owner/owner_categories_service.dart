// ينفذ عمليات إدارة تصنيفات المتجر للمالك بما فيها الإضافة والتعديل والحذف.
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scarvs/core/supabase/storage_service.dart';
import 'package:scarvs/core/supabase/supabase_client.dart';
import 'package:scarvs/core/supabase/supabase_tables.dart';
import 'package:scarvs/models/category_model.dart';

class OwnerCategoriesService {
  final SupabaseClient _client = AppSupabase.client;
  final StorageService _storageService = StorageService();

  Future<List<CategoryModel>> fetchAllCategories() async {
    try {
      final data = await _client
          .from(SupabaseTables.categories)
          .select()
          .order('sort_order', ascending: true);

      return (data as List).map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw 'فشل جلب التصنيفات: $e';
    }
  }

  Future<void> addCategory({
    required String name,
    String? imageUrl,
    File? imageFile,
    int sortOrder = 0,
  }) async {
    try {
      var finalUrl = imageUrl ?? '';
      if (imageFile != null) {
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        finalUrl = await _storageService.uploadCategoryImage(
          file: imageFile,
          categoryId: tempId,
        );
      }

      await _client.from(SupabaseTables.categories).insert({
        'name': name,
        'image_url': finalUrl.isNotEmpty ? finalUrl : null,
        'sort_order': sortOrder,
        'is_active': true,
      });
    } catch (e) {
      throw 'فشل إضافة التصنيف: $e';
    }
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    String? imageUrl,
    File? imageFile,
    int? sortOrder,
    bool? isActive,
  }) async {
    try {
      var finalUrl = imageUrl;
      if (imageFile != null) {
        final tempId = id;
        finalUrl = await _storageService.uploadCategoryImage(
          file: imageFile,
          categoryId: tempId,
        );
      }

      final Map<String, dynamic> updates = {
        'name': name,
      };

      if (finalUrl != null) {
        updates['image_url'] = finalUrl.isNotEmpty ? finalUrl : null;
      }
      if (sortOrder != null) {
        updates['sort_order'] = sortOrder;
      }
      if (isActive != null) {
        updates['is_active'] = isActive;
      }

      await _client
          .from(SupabaseTables.categories)
          .update(updates)
          .eq('id', id);
    } catch (e) {
      throw 'فشل تعديل التصنيف: $e';
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _client
          .from(SupabaseTables.categories)
          .delete()
          .eq('id', categoryId);
    } catch (e) {
      throw 'فشل حذف التصنيف: $e';
    }
  }
}
