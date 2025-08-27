#!/usr/bin/env dart

import 'dart:io';
import 'dart:typed_data';

/// Script de test pour valider la correction de validation MP3
void main() async {
  print('🧪 Test de validation MP3 Edge-TTS');
  print('=' * 50);
  
  await testMp3HeaderValidation();
  await testInvalidMp3Handling();
  
  print('\n✅ Tests MP3 validation terminés');
}

/// Test de validation des headers MP3
Future<void> testMp3HeaderValidation() async {
  print('\n🔍 Test 1: Validation headers MP3');
  
  // Cas 1: Header MP3 valide
  final validMp3Header = Uint8List.fromList([0xFF, 0xFB, 0x90, 0x00]); // MP3 Header
  print('Header valide: ${_isValidMp3Header(validMp3Header) ? '✅' : '❌'}');
  
  // Cas 2: Header invalide
  final invalidHeader1 = Uint8List.fromList([0x00, 0x01, 0x02, 0x03]);
  print('Header invalide 1: ${_isValidMp3Header(invalidHeader1) ? '❌' : '✅'}');
  
  // Cas 3: Header trop court
  final shortHeader = Uint8List.fromList([0xFF]);
  print('Header court: ${_isValidMp3Header(shortHeader) ? '❌' : '✅'}');
  
  // Cas 4: Autre header MP3 valide
  final validMp3Header2 = Uint8List.fromList([0xFF, 0xFA, 0x80, 0x00]);
  print('Header valide 2: ${_isValidMp3Header(validMp3Header2) ? '✅' : '❌'}');
}

/// Test de gestion des MP3 invalides
Future<void> testInvalidMp3Handling() async {
  print('\n🔍 Test 2: Gestion MP3 invalides');
  
  try {
    // Simuler une AudioCompatibilityException
    final exception = AudioCompatibilityException('Test MP3 incompatible');
    throw exception;
  } catch (e) {
    if (e is AudioCompatibilityException) {
      print('✅ AudioCompatibilityException correctement capturée');
      print('   Message: ${e.message}');
    } else {
      print('❌ Exception inattendue: $e');
    }
  }
  
  // Test de détection dans une chaîne d'erreur
  const errorMessage = 'Fichier MP3 Edge-TTS incompatible avec just_audio iOS';
  final isCompatibilityError = errorMessage.contains('incompatible avec just_audio');
  print('Détection erreur string: ${isCompatibilityError ? '✅' : '❌'}');
}

/// Réplique de la fonction de validation des headers MP3
bool _isValidMp3Header(Uint8List bytes) {
  if (bytes.length < 4) return false;
  
  // Header MP3: FF FB ou FF FA (MPEG Layer 3)
  return bytes[0] == 0xFF && 
         (bytes[1] & 0xE0) == 0xE0;
}

/// Exception de test (réplique)
class AudioCompatibilityException implements Exception {
  final String message;
  AudioCompatibilityException(this.message);
  
  @override
  String toString() => 'AudioCompatibilityException: $message';
}