#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Test avec voix arabes alternatives pour identifier celles qui fonctionnent
void main() async {
  print('🎤 Test Voix Arabes Alternatives');
  print('=' * 45);

  final baseUrl = 'http://168.231.112.71:8010';
  final endpoint = '$baseUrl/api/tts';
  final apiKey =
      'e828cb8856742db10d4c87bace9889c3795ff63b1343b0ced4b2156113db826a';

  // Test des voix arabes alternatives disponibles
  final arabicVoices = [
    {'voice': 'ar-DZ-AminaNeural', 'country': 'Algérie', 'gender': 'F'},
    {'voice': 'ar-BH-AliNeural', 'country': 'Bahrain', 'gender': 'M'},
    {'voice': 'ar-IQ-BasselNeural', 'country': 'Iraq', 'gender': 'M'},
    {'voice': 'ar-KW-NouraNeural', 'country': 'Koweït', 'gender': 'F'},
    {'voice': 'ar-LB-LaylaNeural', 'country': 'Liban', 'gender': 'F'},
    {'voice': 'ar-MA-JamalNeural', 'country': 'Maroc', 'gender': 'M'},
    {'voice': 'ar-OM-AbdullahNeural', 'country': 'Oman', 'gender': 'M'},
    {'voice': 'ar-QA-AmalNeural', 'country': 'Qatar', 'gender': 'F'},
    {'voice': 'ar-SY-AmanyNeural', 'country': 'Syrie', 'gender': 'F'},
    {'voice': 'ar-TN-HediNeural', 'country': 'Tunisie', 'gender': 'M'},
    {'voice': 'ar-AE-HamdanNeural', 'country': 'UAE', 'gender': 'M'},
    {'voice': 'ar-YE-MaryamNeural', 'country': 'Yemen', 'gender': 'F'},
  ];

  print('🔍 Test de ${arabicVoices.length} voix arabes alternatives...\n');

  final workingVoices = <Map<String, String>>[];
  final failedVoices = <Map<String, String>>[];

  for (final voiceInfo in arabicVoices) {
    final success = await testArabicVoice(endpoint, apiKey, voiceInfo);
    if (success) {
      workingVoices.add(voiceInfo);
    } else {
      failedVoices.add(voiceInfo);
    }
  }

  // Résumé final
  print('\n📊 RÉSULTATS VOIX ARABES');
  print('=' * 35);
  print('✅ Voix arabes fonctionnelles: ${workingVoices.length}');
  for (final voice in workingVoices) {
    print('   - ${voice['voice']} (${voice['country']}, ${voice['gender']})');
  }

  print('\n❌ Voix arabes en échec: ${failedVoices.length}');
  for (final voice in failedVoices) {
    print('   - ${voice['voice']} (${voice['country']}, ${voice['gender']})');
  }

  if (workingVoices.isNotEmpty) {
    print('\n✅ SOLUTION: Utiliser les voix arabes alternatives disponibles');
    print(
        '🔧 Recommandation: ${workingVoices.first['voice']} comme voix par défaut');
  } else {
    print('\n❌ PROBLÈME: Aucune voix arabe ne fonctionne - problème serveur');
  }
}

/// Test d'une voix arabe spécifique avec diagnostic détaillé
Future<bool> testArabicVoice(
    String endpoint, String apiKey, Map<String, String> voiceInfo) async {
  final voice = voiceInfo['voice']!;
  final country = voiceInfo['country']!;

  print('🎤 Test $voice ($country)');

  final client = HttpClient();
  client.connectionTimeout = Duration(seconds: 12);

  try {
    final request = await client.postUrl(Uri.parse(endpoint));

    request.headers.contentType = ContentType.json;
    request.headers.add('Authorization', 'Bearer $apiKey');
    request.headers.add('X-API-Key', apiKey);

    // Texte très simple pour éviter les problèmes d'encoding
    final payload = {
      'text': 'مرحبا', // Simple "Bonjour"
      'voice': voice,
    };

    request.add(utf8.encode(jsonEncode(payload)));

    final response = await request.close();
    print('   📥 Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      // Lire la réponse pour déterminer le format
      final responseBody = await response.transform(utf8.decoder).join();

      try {
        final jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['success'] == true || jsonResponse['audio'] != null) {
          print('   ✅ SUCCÈS - Réponse JSON valide');
          return true;
        }
      } catch (e) {
        // Peut-être de l'audio brut
        if (responseBody.length > 500) {
          // Audio probable
          print('   ✅ SUCCÈS - Audio reçu (${responseBody.length} chars)');
          return true;
        }
      }

      print('   ⚠️ Réponse 200 mais contenu invalide');
      return false;
    } else if (response.statusCode == 500) {
      final errorBody = await response.transform(utf8.decoder).join();
      print('   ❌ Erreur serveur: ${errorBody.substring(0, 50)}...');
      return false;
    } else {
      final errorBody = await response.transform(utf8.decoder).join();
      print(
          '   ❌ Erreur ${response.statusCode}: ${errorBody.substring(0, 50)}...');
      return false;
    }
  } catch (e) {
    print('   ❌ Exception: $e');
    return false;
  } finally {
    client.close();
  }
}
