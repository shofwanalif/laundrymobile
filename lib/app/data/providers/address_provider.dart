import 'package:get/get.dart';
import 'package:laundrymobile/app/data/models/address_model.dart';
import '../services/supabase_service.dart';

class AddressProvider extends GetxService {
  final SupabaseService _supabase = Get.find();

  // ===================== USER =====================

  /// ➕ CREATE ADDRESS
  Future<void> createAddress(Map<String, dynamic> data) async {
    try {
      await _supabase.from('addresses').insert(data);
    } catch (e) {
      throw Exception('Create address failed: $e');
    }
  }

  /// 📍 GET USER ADDRESSES
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    try {
      final response = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((e) => AddressModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Fetch addresses failed: $e');
    }
  }

  /// ✏️ UPDATE ADDRESS
Future<void> updateAddress(String id, Map<String, dynamic> data) async {
  try {
    await _supabase
        .from('addresses')
        .update({
          ...data, // Mengambil semua data dari payload (label, address, lat, lng)
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  } catch (e) {
    throw Exception('Update address failed: $e');
  }
}

  /// ❌ DELETE ADDRESS
  Future<void> deleteAddress(String addressId) async {
    try {
      await _supabase.from('addresses').delete().eq('id', addressId);
    } catch (e) {
      throw Exception('Delete address failed: $e');
    }
  }

  // ===================== SHARED =====================

  /// 🔍 GET ADDRESS BY ID
  Future<Map<String, dynamic>?> getAddressById(String addressId) async {
    try {
      final response = await _supabase
          .from('addresses')
          .select()
          .eq('id', addressId)
          .single();

      return response;
    } catch (_) {
      return null;
    }
  }
}
