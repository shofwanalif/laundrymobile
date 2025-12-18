import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/supabase_service.dart';

class ServicesProvider extends GetxService {
  final SupabaseService _supabase = Get.find<SupabaseService>();

  /// GET all services
  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await _supabase
          .from('services')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) =>
              ServiceModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetch services: $e');
      rethrow;
    }
  }

  /// CREATE service (admin only)
  Future<void> createService(ServiceModel service) async {
    try {
      await _supabase
          .from('services')
          .insert(service.toMap());

      debugPrint('Service created successfully: ${service.name}');
    } catch (e) {
      debugPrint('Error create service: $e');
      rethrow;
    }
  }

  /// UPDATE service (admin only)
  Future<void> updateService(ServiceModel service) async {
    try {
      await _supabase
          .from('services')
          .update(service.toMap())
          .eq('id', service.id);

      debugPrint('Service updated successfully');
    } catch (e) {
      debugPrint('Error update service: $e');
      rethrow;
    }
  }

  /// DELETE service (admin only)
  Future<void> deleteService(String id) async {
    try {
      await _supabase
          .from('services')
          .delete()
          .eq('id', id);

      debugPrint('Service deleted successfully');
    } catch (e) {
      debugPrint('Error deleting service: $e');
      rethrow;
    }
  }
}
