// packages/services/services/maps_service.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class MapsService extends GetxService {
  late final Dio _dio;
  
  static const double shopLatitude = -7.91344817661956;
  static const double shopLongitude = 112.6001638391805;

  @override
  void onInit() {
    super.onInit();
    _setupDio();
  }

  void _setupDio() {
    _dio = Dio();
    
    // Tambahkan LogInterceptor untuk debugging OSM
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: false,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (object) {
        print('🗺️ [OSM DIO] $object');
      },
    ));
  }

  Future<String> getShopAddress() async {
    try {
      print('🚀 [MAPS SERVICE] Requesting address from OSM...');
      print('📍 [MAPS SERVICE] Coordinates: lat=$shopLatitude, lon=$shopLongitude');
      
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': shopLatitude.toString(),
          'lon': shopLongitude.toString(),
          'zoom': 18,
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'LaundryMobileApp/1.0',
          },
          receiveTimeout: Duration(seconds: 10),
        ),
      );
      
      print('✅ [MAPS SERVICE] OSM API call successful!');
      print('🏠 [MAPS SERVICE] Raw response: ${response.data}');
      
      if (response.statusCode == 200) {
        final address = response.data['display_name'] ?? 'Alamat tidak tersedia';
        print('📍 [MAPS SERVICE] Parsed address: $address');
        return address;
      } else {
        print('❌ [MAPS SERVICE] OSM Error: ${response.statusCode}');
        throw Exception('Failed to get address from OSM: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [MAPS SERVICE] OSM DioException!');
      print('❌ [MAPS SERVICE] Error type: ${e.type}');
      print('❌ [MAPS SERVICE] Error message: ${e.message}');
      print('❌ [MAPS SERVICE] Response: ${e.response?.data}');
      
      return _getFallbackAddress();
    } catch (e) {
      print('💥 [MAPS SERVICE] OSM Unexpected error: $e');
      return _getFallbackAddress();
    }
  }

  String _getFallbackAddress() {
    print('🔄 [MAPS SERVICE] Using fallback address');
    return 'Jl. Contoh Alamat Toko No. 123, Jakarta Pusat';
  }

  double get shopLat => shopLatitude;
  double get shopLon => shopLongitude;
}