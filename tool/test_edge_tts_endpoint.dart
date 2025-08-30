#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Script de diagnostic pour tester l'endpoint Edge-TTS
void main() async {
  print('🔍 Diagnostic Endpoint Edge-TTS');
  print('=' * 50);

  final endpoint1 = 'http://168.231.112.71:8010';
  final endpoint2 = 'http://168.231.112.71:8001';

  await testEndpoint(endpoint1, 'Endpoint Principal');
  await testEndpoint(endpoint2, 'Endpoint Alternatif');

  await testSynthesisEndpoint(endpoint1);

  print('\n📊 Résumé du diagnostic terminé');
}

/// Test de connectivité d'un endpoint
Future<void> testEndpoint(String baseUrl, String label) async {
  print('\n🌐 Test $label: $baseUrl');

  final client = HttpClient();
  client.connectionTimeout = Duration(seconds: 10);

  try {
    // Test 1: Health check
    print('  📡 Test connectivité...');
    final healthUrl = '$baseUrl/health';

    try {
      final request = await client.getUrl(Uri.parse(healthUrl));
      final response = await request.close();

      print('  ✅ Connectivité: OK (${response.statusCode})');

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        print(
            '  📄 Réponse health: ${responseBody.substring(0, responseBody.length > 100 ? 100 : responseBody.length)}...');
      }
    } catch (e) {
      print('  ❌ Health endpoint inaccessible: $e');

      // Test basique de ping TCP
      await testTcpConnection(baseUrl);
    }
  } catch (e) {
    print('  ❌ Erreur générale: $e');
  } finally {
    client.close();
  }
}

/// Test de connexion TCP basique
Future<void> testTcpConnection(String url) async {
  try {
    final uri = Uri.parse(url);
    final host = uri.host;
    final port = uri.port;

    print('  🔌 Test TCP $host:$port...');

    final socket =
        await Socket.connect(host, port, timeout: Duration(seconds: 5));
    await socket.close();

    print('  ✅ TCP: Connexion OK');
  } catch (e) {
    print('  ❌ TCP: Échec connexion - $e');
  }
}

/// Test de l'endpoint de synthèse
Future<void> testSynthesisEndpoint(String baseUrl) async {
  print('\n🎯 Test endpoint de synthèse: $baseUrl/synthesize');

  final client = HttpClient();
  client.connectionTimeout = Duration(seconds: 15);

  try {
    final synthesizeUrl = '$baseUrl/synthesize';
    final request = await client.postUrl(Uri.parse(synthesizeUrl));

    // Headers
    request.headers.contentType = ContentType.json;

    // Payload de test minimal
    final testPayload = {
      'text': 'السلام عليكم', // Test court en arabe
      'voice': 'ar-SA-HamedNeural',
      'format': 'mp3',
      'sample_rate': 22050,
    };

    // Envoyer la requête
    request.add(utf8.encode(jsonEncode(testPayload)));

    print('  📤 Envoi requête synthèse...');
    final response = await request.close();

    print('  📥 Réponse: ${response.statusCode} ${response.reasonPhrase}');
    print('  📊 Content-Type: ${response.headers.contentType}');
    print('  📏 Content-Length: ${response.headers.contentLength ?? 'N/A'}');

    if (response.statusCode == 200) {
      // Lire quelques bytes pour vérifier
      final audioBytes = await response.toList();
      final totalBytes =
          audioBytes.fold<int>(0, (sum, chunk) => sum + chunk.length);

      print('  ✅ Synthèse: OK ($totalBytes bytes)');

      if (totalBytes > 0) {
        final firstChunk = audioBytes.first;
        if (firstChunk.length >= 4) {
          final header = firstChunk.take(4).toList();
          final isValidMp3 = header[0] == 0xFF && (header[1] & 0xE0) == 0xE0;
          print(
              '  🎵 Header MP3: ${isValidMp3 ? '✅ Valide' : '❌ Invalide'} (${header.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')})');
        }
      }
    } else {
      final errorBody = await response.transform(utf8.decoder).join();
      print('  ❌ Erreur synthèse: $errorBody');
    }
  } catch (e) {
    print('  ❌ Échec test synthèse: $e');
  } finally {
    client.close();
  }
}
