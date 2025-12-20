import 'package:get/get.dart';
import 'package:laundrymobile/app/data/models/address_model.dart';
import '../services/supabase_service.dart';

class AddressProvider extends GetxService {
  final SupabaseService _supabase = Get.find();
  static const String _tableName = 'addresses';

  Future<void> createAddress(Map<String, dynamic> data) async {
    try {
      await _supabase.from(_tableName).insert(data);
    } catch (e) {
      throw Exception('Create address failed: $e');
    }
  }

  Future<List<AddressModel>> getUserAddresses(String userId) async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return response.map((e) => AddressModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Fetch addresses failed: $e');
    }
  }

  Future<void> updateAddress(String id, Map<String, dynamic> data) async {
    try {
      await _supabase
          .from(_tableName)
          .update({
            ...data,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Update address failed: $e');
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await _supabase
          .from(_tableName)
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', addressId);
    } catch (e) {
      throw Exception('Soft delete address failed: $e');
    }
  }

  Future<AddressModel?> getAddressById(String addressId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', addressId)
          .eq('is_active', true)
          .maybeSingle();

      return response != null ? AddressModel.fromMap(response) : null;
    } catch (_) {
      return null;
    }
  }
}