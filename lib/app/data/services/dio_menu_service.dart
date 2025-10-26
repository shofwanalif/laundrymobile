// packages/services/services/menu_service.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class MenuService extends GetxService {
  final Dio _dio = Dio();

  Future<List<dynamic>> getServices() async {
    try {
      // Ganti dengan URL API Anda
      final response = await _dio.get(
        'https://68fcacc896f6ff19b9f5ea11.mockapi.io/services',
        options: Options(
          receiveTimeout: Duration(seconds: 10),
          sendTimeout: Duration(seconds: 10),
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}