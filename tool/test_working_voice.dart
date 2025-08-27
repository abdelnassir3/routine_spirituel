#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Test avec voix existante validée
void main() async {
  print('🎯 Test Voix Validée Edge-TTS');
  print('=' * 40);
  
  final baseUrl = 'http://168.231.112.71:8010';
  final endpoint = '$baseUrl/api/tts';
  final apiKey = 'e828cb8856742db10d4c87bace9889c3795ff63b1343b0ced4b2156113db826a';
  
  // Utiliser voix confirmée dans la réponse
  await testValidVoice(endpoint, apiKey, 'ar-SA-HamedNeural');
  await testValidVoice(endpoint, apiKey, 'fr-FR-HenriNeural');
}

/// Test avec voix confirmée
Future<void> testValidVoice(String endpoint, String apiKey, String voice) async {
  print('\n🎤 Test voix: $voice');
  
  final client = HttpClient();
  client.connectionTimeout = Duration(seconds: 20);
  
  try {
    final request = await client.postUrl(Uri.parse(endpoint));
    
    request.headers.contentType = ContentType.json;
    request.headers.add('Authorization', 'Bearer $apiKey');
    request.headers.add('X-API-Key', apiKey);
    
    // Payload minimal avec voix validée
    final payload = {
      'text': voice.startsWith('ar-') ? 'مرحبا' : 'Bonjour',
      'voice': voice,
    };
    
    request.add(utf8.encode(jsonEncode(payload)));
    
    print('  📤 Envoi: $payload');
    final response = await request.close();
    
    print('  📥 Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      
      try {
        final jsonResponse = jsonDecode(responseBody);
        print('  ✅ Réponse JSON: $jsonResponse');
        
        if (jsonResponse['audio_url'] != null) {
          print('  🎵 Audio URL: ${jsonResponse['audio_url']}');
          print('  ✅ Edge-TTS Service: OPÉRATIONNEL!');
          return;
        }
      } catch (e) {
        print('  ⚠️ Réponse non-JSON (peut-être binary): ${responseBody.length} chars');
        if (responseBody.startsWith('\xff\xfb') || responseBody.contains('audio')) {
          print('  ✅ Semble être de l audio brut - Service OK!');
        }
      }
    } else {
      final errorBody = await response.transform(utf8.decoder).join();
      print('  ❌ Erreur: $errorBody');
    }
    
  } catch (e) {
    print('  ❌ Exception: $e');
  } finally {
    client.close();
  }
}