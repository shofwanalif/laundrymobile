// packages/services/services/menu_service.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class MenuService extends GetxService {
  final Dio _dio = Dio();

  MenuService() {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[DIO] $obj'),
      ),
    );
  }

  Future<List<dynamic>> getServices() async {
    final stopwatch = Stopwatch()..start(); // Mulai timer

    try {
      print('⏳ Memulai fetch data dari API...');

      final response = await _dio.get(
        'https://68fcacc896f6ff19b9f5ea11.mockapi.io/services',
        options: Options(
          receiveTimeout: Duration(seconds: 10),
          sendTimeout: Duration(seconds: 10),
        ),
      );

      stopwatch.stop(); // Hentikan timer setelah request selesai
      print('✅ Fetch data selesai dalam ${stopwatch.elapsedMilliseconds} ms');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } on DioException catch (e) {
      stopwatch.stop(); // Pastikan stopwatch dihentikan meskipun error
      print('❌ Fetch gagal setelah ${stopwatch.elapsedMilliseconds} ms');

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      stopwatch.stop();
      print('⚠️ Terjadi error setelah ${stopwatch.elapsedMilliseconds} ms');
      throw Exception('Unexpected error: $e');
    }
  }
}
