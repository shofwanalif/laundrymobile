import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/laundry_service.dart';

class HttpService {
  static const baseUrl = 'https://68fcacc896f6ff19b9f5ea11.mockapi.io/services';

  Future<List<LaundryService>> getAllServices() async {
    try {
      final url = Uri.parse(baseUrl);
      final stopwatch = Stopwatch()..start();

      final response = await http.get(url);
      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds; // Waktu dalam milidetik
      print('⏱️ Response time: $elapsed ms');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        return jsonData.map((item) => LaundryService.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Eror get data services: $e');
    }
  }
}
