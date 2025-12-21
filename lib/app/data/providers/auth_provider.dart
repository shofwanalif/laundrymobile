import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/notification_handler.dart'; // Import handler Anda

class AuthProvider extends GetxService {
  final SupabaseService _supabaseService = Get.find();

  // Inisialisasi NotificationHandler
  NotificationHandler get notificationHandler => NotificationHandler();

  User? get currentUser => _supabaseService.currentUser;
  Stream<AuthState> get authStateChanges => _supabaseService.authStateChanges;

  // Login
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await notificationHandler.updateTokenToSupabase();
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final userId = currentUser?.id;

      //  hapus token sebelum sign out selagi session masih valid
      if (userId != null) {
        await _supabaseService.client
            .from('profiles')
            .update({'fcm_token': null})
            .eq('id', userId);
      }

      await _supabaseService.client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Register
  Future<AuthResponse> register(
    String email,
    String password, {
    required String name,
    String? phone,
  }) async {
    try {
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _supabaseService.client.from('profiles').upsert({
          'id': response.user!.id,
          'name': name,
          'phone': phone ?? '',
          'role': 'user',
        });
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getUserRole(String userId) async {
    final response = await _supabaseService.client
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single();
    return response['role'] ?? 'user';
  }

  Future<String> getUserName(String userId) async {
    final response = await _supabaseService.client
        .from('profiles')
        .select('name')
        .eq('id', userId)
        .single();
    return response['name'] ?? 'user';
  }

  bool get isAuthenticated => currentUser != null;
}
