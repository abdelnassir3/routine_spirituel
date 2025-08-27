#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Test des différentes voix arabes pour trouver celles qui fonctionnent
void main() async {
  print('🎤 Test Voix Arabes Edge-TTS');
  print('=' * 45);
  
  final baseUrl = 'http://168.231.112.71:8010';
  final endpoint = '$baseUrl/api/tts';
  final apiKey = 'e828cb8856742db10d4c87bace9889c3795ff63b1343b0ced4b2156113db826a';
  
  // Test de plusieurs voix arabes pour trouver celles qui marchent
  final arabicVoices = [
    'ar-SA-ZariyahNeural',  // Femme Arabie Saoudite
    'ar-SA-HamedNeural',    // Homme Arabie Saoudite (problématique)
    'ar-EG-SalmaNeural',    // Femme Égypte
    'ar-EG-ShakirNeural',   // Homme Égypte
    'ar-AE-FatimaNeural',   // Femme Émirats
    'ar-JO-SanaNeural',     // Femme Jordanie
  ];
  
  for (String voice in arabicVoices) {
    await testArabicVoice(endpoint, apiKey, voice);
  }
  
  print('\n📊 Test des voix arabes terminé');
}

/// Test d'une voix arabe spécifique
Future<void> testArabicVoice(String endpoint, String apiKey, String voice) async {
  print('\n🎤 Test $voice');
  
  final client = HttpClient();
  client.connectionTimeout = Duration(seconds: 15);
  
  try {
    final request = await client.postUrl(Uri.parse(endpoint));
    
    request.headers.contentType = ContentType.json;
    request.headers.add('Authorization', 'Bearer $apiKey');
    request.headers.add('X-API-Key', apiKey);
    
    final payload = {
      'text': 'بسم الله',  // Court et simple
      'voice': voice,
    };
    
    request.add(utf8.encode(jsonEncode(payload)));
    
    final response = await request.close();
    print('  📥 Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      
      try {
        final jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['success'] == true && jsonResponse['audio'] != null) {
          final audioLength = jsonResponse['audio'].toString().length;
          print('  ✅ SUCCÈS - Audio généré ($audioLength chars)');
        } else {
          print('  ❌ Réponse invalide: ${jsonResponse.toString().substring(0, 100)}...');
        }
      } catch (e) {
        print('  ❌ Erreur parsing JSON: $e');
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