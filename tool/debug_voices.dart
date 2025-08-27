#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Debug des voix disponibles sur le serveur Edge-TTS
void main() async {
  print('🎤 Debug Voix Edge-TTS');
  print('=' * 40);
  
  final baseUrl = 'http://168.231.112.71:8010';
  final apiKey = 'e828cb8856742db10d4c87bace9889c3795ff63b1343b0ced4b2156113db826a';
  
  await debugVoices(baseUrl, apiKey);
  await testSimpleRequest(baseUrl, apiKey);
}

/// Debug des voix disponibles
Future<void> debugVoices(String baseUrl, String apiKey) async {
  print('\n🔍 Structure des voix');
  
  final client = HttpClient();
  try {
    final voicesUrl = '$baseUrl/voices';
    final request = await client.getUrl(Uri.parse(voicesUrl));
    
    request.headers.add('Authorization', 'Bearer $apiKey');
    request.headers.add('X-API-Key', apiKey);
    
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final body = await response.transform(utf8.decoder).join();
      print('📄 Réponse brute voices:');
      print(body);
      
      try {
        final voices = jsonDecode(body);
        print('\n📊 Type: ${voices.runtimeType}');
        print('📊 Contenu: $voices');
      } catch (e) {
        print('❌ Erreur parsing JSON: $e');
      }
    }
  } catch (e) {
    print('❌ Erreur: $e');
  } finally {
    client.close();
  }
}

/// Test avec requête très simple
Future<void> testSimpleRequest(String baseUrl, String apiKey) async {
  print('\n🧪 Test requête minimale');
  
  final client = HttpClient();
  try {
    final endpoint = '$baseUrl/api/tts';
    final request = await client.postUrl(Uri.parse(endpoint));
    
    request.headers.contentType = ContentType.json;
    request.headers.add('Authorization', 'Bearer $apiKey');
    
    // Requête ultra-simple
    final simplePayload = {
      'text': 'Hello',
    };
    
    request.add(utf8.encode(jsonEncode(simplePayload)));
    print('📤 Payload minimal: $simplePayload');
    
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    
    print('📥 Status: ${response.statusCode}');
    print('📄 Réponse: $body');
    
  } catch (e) {
    print('❌ Erreur: $e');
  } finally {
    client.close();
  }
}