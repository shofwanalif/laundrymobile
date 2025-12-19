import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/services_model.dart';
import '../services/supabase_service.dart';

class ServicesProvider extends GetxService {
  final SupabaseService _supabase = Get.find<SupabaseService>();

  Future<List<ServicesModel>> getServices() async {
    try {
      final response = await _supabase
          .from('services')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => ServicesModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('error fetch: $e');
      rethrow;
    }
  }

  Future<void> createService(ServicesModel service) async {
    try {
      await _supabase.from('services').insert(service.toJsonForInsert());
      debugPrint('Services created successfully: ${service.serviceName}');
    } catch (e) {
      debugPrint('error create service: $e');
      rethrow;
    }
  }

  Future<void> updateService(ServicesModel service) async {
    final serviceId = service.id;

    if (serviceId == null) {
      throw ArgumentError('id is required for update');
    }

    try {
      await _supabase
          .from('services')
          .update(service.toJsonForUpdate())
          .eq('id', serviceId);
      debugPrint('service updated succesfully');
    } catch (e) {
      debugPrint('error update service: $e');
      rethrow;
    }
  }

  Future<void> deletedService(int id) async {
    try {
      await _supabase.from('services').delete().eq('id', id);

      debugPrint('service deleted successfully');
    } catch (e) {
      debugPrint('error deleting service : $e');
      rethrow;
    }
  }

  /// Upload gambar service ke Supabase Storage
  /// Returns: URL publik gambar yang diupload
  Future<String> uploadServiceImage(File imageFile, String fileName) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final path = 'services/$fileName';

      // Upload ke bucket 'service_images'
      await _supabase.storage
          .from('service_images')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Dapatkan public URL
      final publicUrl = _supabase.storage
          .from('service_images')
          .getPublicUrl(path);

      debugPrint('Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  /// Hapus gambar dari storage
  Future<void> deleteServiceImage(String imageUrl) async {
    try {
      // Extract path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      // Path biasanya: .../storage/v1/object/public/service_images/services/filename.jpg
      final bucketIndex = pathSegments.indexOf('service_images');
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _supabase.storage.from('service_images').remove([filePath]);
        debugPrint('Image deleted: $filePath');
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
      // Don't rethrow - image deletion failure shouldn't break the flow
    }
  }
}
