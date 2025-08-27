#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Test final de l'endpoint Edge-TTS avec bon format
void main() async {
  print('🎯 Test Final Edge-TTS - Format Correct');
  print('=' * 50);
  
  final baseUrl = 'http://168.231.112.71:8010';
  final endpoint = '$baseUrl/api/tts';
  final apiKey = 'e828cb8856742db10d4c87bace9889c3795ff63b1343b0ced4b2156113db826a';
  
  await testWithCorrectFormat(endpoint, apiKey);
  await testVoicesEndpoint(baseUrl, apiKey);
  
  print('\n📊 Diagnostic Edge-TTS final terminé');
}

/// Test avec le format de requête correct
Future<void> testWithCorrectFormat(String endpoint, String apiKey) async {
  print('\n🌐 Test avec format de requête correct');
  
  final client = HttpClient();
  client.connectionTimeout = Duration(seconds: 15);
  
  try {
    final request = await client.postUrl(Uri.parse(endpoint));
    
    // Headers corrects
    request.headers.contentType = ContentType.json;
    request.headers.add('Authorization', 'Bearer $apiKey');
    request.headers.add('X-API-Key', apiKey);
    request.headers.add('User-Agent', 'ProjetSpirit/1.0.0');
    
    // Payload dans le bon format
    final correctPayload = {
      'text': 'مرحبا بكم', // Plus simple
      'voice': 'ar-SA-HamedNeural', 
      // Pas de rate/pitch pour éviter les erreurs
    };
    
    request.add(utf8.encode(jsonEncode(correctPayload)));
    
    print('  📤 Payload: $correctPayload');
    final response = await request.close();
    
    print('  📥 Status: ${response.statusCode} ${response.reasonPhrase}');
    
    if (response.statusCode == 200) {
      // Vérifier si c'est du JSON avec une URL audio
      final responseBody = await response.transform(utf8.decoder).join();
      print('  ✅ Réponse JSON: ${responseBody.substring(0, responseBody.length > 200 ? 200 : responseBody.length)}...');
      
      try {
        final jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['audio_url'] != null) {
          print('  🎵 Audio URL trouvée: ${jsonResponse['audio_url']}');
          await testAudioUrl(jsonResponse['audio_url']);
        }
      } catch (e) {
        print('  ⚠️ Réponse non-JSON: $responseBody');
      }
    } else {
      final errorBody = await response.transform(utf8.decoder).join();
      print('  ❌ Erreur ($response.statusCode): $errorBody');
    }
    
  } catch (e) {
    print('  ❌ Exception: $e');
  } finally {
    client.close();
  }
}

/// Test de l'endpoint /voices pour voir les voix disponibles
Future<void> testVoicesEndpoint(String baseUrl, String apiKey) async {
  print('\n🎤 Test endpoint voices');
  
  final client = HttpClient();
  try {
    final voicesUrl = '$baseUrl/voices';
    final request = await client.getUrl(Uri.parse(voicesUrl));
    
    request.headers.add('Authorization', 'Bearer $apiKey');
    request.headers.add('X-API-Key', apiKey);
    
    final response = await request.close();
    print('  📥 Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final body = await response.transform(utf8.decoder).join();
      final voices = jsonDecode(body);
      print('  🎤 Voix disponibles: ${voices.length} voix');
      
      // Afficher quelques voix arabes
      final arabicVoices = voices.where((v) => v['locale']?.startsWith('ar') == true).take(3);
      for (final voice in arabicVoices) {
        print('    - ${voice['short_name']} (${voice['gender']})');
      }
    } else {
      final errorBody = await response.transform(utf8.decoder).join();
      print('  ❌ Erreur voices: $errorBody');
    }
  } catch (e) {
    print('  ❌ Exception voices: $e');
  } finally {
    client.close();
  }
}

/// Test de téléchargement d'un fichier audio
Future<void> testAudioUrl(String audioUrl) async {
  print('  🔊 Test téléchargement audio: $audioUrl');
  
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(audioUrl));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final audioBytes = await response.toList();
      final totalBytes = audioBytes.fold<int>(0, (sum, chunk) => sum + chunk.length);
      
      print('    ✅ Audio téléchargé: $totalBytes bytes');
      
      // Vérifier header MP3
      if (audioBytes.isNotEmpty && audioBytes.first.length >= 4) {
        final header = audioBytes.first.take(4).toList();
        final isValidMp3 = header[0] == 0xFF && (header[1] & 0xE0) == 0xE0;
        print('    🎵 Format MP3: ${isValidMp3 ? '✅ Valide' : '❌ Invalide'}');
      }
    } else {
      print('    ❌ Échec téléchargement: ${response.statusCode}');
    }
  } catch (e) {
    print('    ❌ Exception audio: $e');
  } finally {
    client.close();
  }
}