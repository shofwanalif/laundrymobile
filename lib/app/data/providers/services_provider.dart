import 'package:get/get.dart';
import 'package:flutter/material.dart';
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
}
