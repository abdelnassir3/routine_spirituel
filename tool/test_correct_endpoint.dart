#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Test de l'endpoint Edge-TTS correct
void main() async {
  print('🎯 Test Endpoint Edge-TTS Correct');
  print('=' * 50);

  final baseUrl = 'http://168.231.112.71:8010';
  final endpoint = '$baseUrl/api/tts';
  final apiKey =
      'e828cb8856742db10d4c87bace9889c3795ff63b1343b0ced4b2156113db826a';

  await testCorrectEndpoint(endpoint, apiKey);

  print('\n📊 Test endpoint correct terminé');
}

/// Test du bon endpoint avec authentification
Future<void> testCorrectEndpoint(String endpoint, String apiKey) async {
  print('\n🌐 Test endpoint: $endpoint');

  final client = HttpClient();
  client.connectionTimeout = Duration(seconds: 15);

  try {
    final request = await client.postUrl(Uri.parse(endpoint));

    // Headers avec authentification
    request.headers.contentType = ContentType.json;
    request.headers.add('Authorization', 'Bearer $apiKey');
    request.headers.add('X-API-Key', apiKey);
    request.headers.add('User-Agent', 'ProjetSpirit/1.0.0 (Test)');

    // Payload de test
    final testPayload = {
      'text': 'السلام عليكم',
      'voice': 'ar-SA-HamedNeural',
    };

    request.add(utf8.encode(jsonEncode(testPayload)));

    print('  📤 Envoi requête avec auth...');
    final response = await request.close();

    print('  📥 Réponse: ${response.statusCode} ${response.reasonPhrase}');
    print('  📊 Content-Type: ${response.headers.contentType}');
    print('  📏 Content-Length: ${response.headers.contentLength ?? 'N/A'}');

    if (response.statusCode == 200) {
      final audioBytes = await response.toList();
      final totalBytes =
          audioBytes.fold<int>(0, (sum, chunk) => sum + chunk.length);

      print('  ✅ Edge-TTS Synthèse: OK ($totalBytes bytes)');

      if (totalBytes > 0 && audioBytes.isNotEmpty) {
        final firstChunk = audioBytes.first;
        if (firstChunk.length >= 4) {
          final header = firstChunk.take(4).toList();
          final isValidMp3 = header[0] == 0xFF && (header[1] & 0xE0) == 0xE0;
          print('  🎵 Header MP3: ${isValidMp3 ? '✅ Valide' : '❌ Invalide'}');
          print(
              '      Raw: ${header.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
        }

        print('  📊 Edge-TTS Service: FONCTIONNEL');
      }
    } else {
      final errorBody = await response.transform(utf8.decoder).join();
      print('  ❌ Erreur: $errorBody');

      if (response.statusCode == 401 || response.statusCode == 403) {
        print('  🔑 Problème authentification détecté');
      }
    }
  } catch (e) {
    print('  ❌ Erreur requête: $e');
  } finally {
    client.close();
  }
}
