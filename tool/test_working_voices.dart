#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Test avec différentes voix pour identifier celles qui fonctionnent
void main() async {
  print('🎤 Test Voix Fonctionnelles Edge-TTS');
  print('=' * 45);

  final baseUrl = 'http://168.231.112.71:8010';
  final endpoint = '$baseUrl/api/tts';
  final apiKey =
      'e828cb8856742db10d4c87bace9889c3795ff63b1343b0ced4b2156113db826a';

  // Test de voix confirmées et alternatives
  final testVoices = [
    {
      'voice': 'fr-FR-HenriNeural',
      'text': 'Bonjour le monde',
      'language': 'Français'
    },
    {
      'voice': 'en-US-JennyNeural',
      'text': 'Hello world',
      'language': 'Anglais US'
    },
    {
      'voice': 'en-GB-SoniaNeural',
      'text': 'Hello world',
      'language': 'Anglais UK'
    },
    {'voice': 'ar-SA-HamedNeural', 'text': 'مرحبا', 'language': 'Arabe SA'},
    {
      'voice': 'ar-EG-SalmaNeural',
      'text': 'أهلا وسهلا',
      'language': 'Arabe EG'
    },
    {
      'voice': 'ar-SA-ZariyahNeural',
      'text': 'السلام عليكم',
      'language': 'Arabe SA F'
    },
  ];

  print('🔍 Test de ${testVoices.length} voix...\n');

  final workingVoices = <String>[];
  final failedVoices = <String>[];

  for (final voiceTest in testVoices) {
    final result = await testVoice(endpoint, apiKey, voiceTest);
    if (result) {
      workingVoices.add('${voiceTest['voice']} (${voiceTest['language']})');
    } else {
      failedVoices.add('${voiceTest['voice']} (${voiceTest['language']})');
    }
  }

  // Résumé final
  print('\n📊 RÉSULTATS FINAUX');
  print('=' * 30);
  print('✅ Voix fonctionnelles: ${workingVoices.length}');
  for (final voice in workingVoices) {
    print('   - $voice');
  }
  print('\n❌ Voix en échec: ${failedVoices.length}');
  for (final voice in failedVoices) {
    print('   - $voice');
  }

  if (workingVoices.isNotEmpty) {
    print('\n✅ Edge-TTS Service: OPÉRATIONNEL');
  } else {
    print('\n❌ Edge-TTS Service: PROBLÈME GÉNÉRAL');
  }
}

/// Test d'une voix spécifique
Future<bool> testVoice(
    String endpoint, String apiKey, Map<String, String> voiceTest) async {
  final voice = voiceTest['voice']!;
  final text = voiceTest['text']!;
  final language = voiceTest['language']!;

  print('🎤 Test $voice ($language)');

  final client = HttpClient();
  client.connectionTimeout = Duration(seconds: 10);

  try {
    final request = await client.postUrl(Uri.parse(endpoint));

    request.headers.contentType = ContentType.json;
    request.headers.add('Authorization', 'Bearer $apiKey');
    request.headers.add('X-API-Key', apiKey);

    final payload = {
      'text': text,
      'voice': voice,
    };

    request.add(utf8.encode(jsonEncode(payload)));

    final response = await request.close();
    print('   📥 Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();

      try {
        final jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['success'] == true ||
            jsonResponse['audio'] != null ||
            jsonResponse['audio_url'] != null) {
          print('   ✅ SUCCÈS - Réponse valide');
          return true;
        } else {
          print('   ⚠️ Réponse JSON sans audio');
          return false;
        }
      } catch (e) {
        // Peut-être de l'audio brut
        if (responseBody.length > 1000) {
          // Audio brut probable
          print('   ✅ SUCCÈS - Audio brut reçu (${responseBody.length} chars)');
          return true;
        } else {
          print('   ❌ Réponse courte non-JSON');
          return false;
        }
      }
    } else {
      final errorBody = await response.transform(utf8.decoder).join();
      print(
          '   ❌ Erreur ${response.statusCode}: ${errorBody.substring(0, 100)}');
      return false;
    }
  } catch (e) {
    print('   ❌ Exception: $e');
    return false;
  } finally {
    client.close();
  }
}
