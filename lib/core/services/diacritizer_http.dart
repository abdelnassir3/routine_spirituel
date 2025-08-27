import 'package:dio/dio.dart';

import 'package:spiritual_routines/core/services/diacritizer_service.dart';

class HttpDiacritizerService implements DiacritizerService {
  HttpDiacritizerService(this.endpoint);
  final String endpoint; // POST endpoint accepting {text} returns {text}

  @override
  Future<String> diacritize(String arabicText) async {
    final client = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20)));
    final resp = await client.post(endpoint, data: {'text': arabicText});
    if (resp.statusCode == 200) {
      final data = resp.data;
      if (data is Map && data['text'] is String) return data['text'] as String;
      if (data is String) return data;
    }
    throw Exception('Diacritizer API error: ${resp.statusCode}');
  }
}
