// packages/services/services/maps_service.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class MapsService extends GetxService {
  final Dio _dio = Dio();

  // GANTI DENGAN KOORDINAT TOKO MITRA ANDA
  static const double shopLatitude = -7.91344817661956;
  static const double shopLongitude = 112.6001638391805;

  Future<String> getShopAddress() async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': shopLatitude,
          'lon': shopLongitude,
          'zoom': 18,
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'CemerLaund/1.0', // Required by OSM
          },
          receiveTimeout: Duration(seconds: 10),
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data['display_name'] ?? 'Alamat tidak tersedia';
      } else {
        throw Exception('Failed to get address from OSM');
      }
    } on DioException catch (e) {
      // Fallback ke alamat manual jika OSM error
      return 'Jl. Alamat Toko Mitra No. 123, Jakarta'; // GANTI DENGAN ALAMAT TOKO
    } catch (e) {
      return 'Jl. Alamat Toko Mitra No. 123, Jakarta'; // GANTI DENGAN ALAMAT TOKO
    }
  }

  // Getter untuk koordinat toko
  double get shopLat => shopLatitude;
  double get shopLon => shopLongitude;
}