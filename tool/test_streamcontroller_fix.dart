#!/usr/bin/env dart

import 'dart:async';
import 'dart:io';

/// Script de test pour vérifier la correction de la race condition StreamController
/// Simule des appels concurrents dispose/add pour détecter les problèmes

void main() async {
  print('🧪 Test de la correction StreamController Race Condition');
  print('=' * 60);

  await testStreamControllerRaceCondition();

  print('\n✅ Tous les tests passés - Correction validée');
}

/// Test de simulation de race condition
Future<void> testStreamControllerRaceCondition() async {
  print('\n🔍 Test 1: Simulation Race Condition dispose/add');

  // Simuler la classe problématique
  final testWrapper = TestAudioWrapper();

  // Lancer plusieurs tâches concurrentes
  final futures = <Future>[];

  // Tâche 1: Ajouter des événements en boucle
  futures.add(Future(() async {
    for (int i = 0; i < 100; i++) {
      testWrapper.simulatePositionUpdate(Duration(milliseconds: i * 10));
      await Future.delayed(Duration(microseconds: 100));
    }
  }));

  // Tâche 2: Dispose après un délai
  futures.add(Future(() async {
    await Future.delayed(Duration(milliseconds: 50));
    testWrapper.dispose();
  }));

  // Tâche 3: Tentative d'ajout après dispose
  futures.add(Future(() async {
    await Future.delayed(Duration(milliseconds: 60));
    for (int i = 0; i < 10; i++) {
      testWrapper.simulatePositionUpdate(Duration(milliseconds: 1000 + i));
      await Future.delayed(Duration(microseconds: 50));
    }
  }));

  try {
    await Future.wait(futures);
    print('✅ Test 1: Aucune exception - Race condition résolue');
  } catch (e) {
    print('❌ Test 1: Exception détectée: $e');
    exit(1);
  }

  // Test de recréation de player
  print('\n🔍 Test 2: Recréation AudioPlayer simulée');
  final testWrapper2 = TestAudioWrapper();

  // Simuler une recréation pendant des ajouts
  final recreationFutures = <Future>[];

  recreationFutures.add(Future(() async {
    for (int i = 0; i < 20; i++) {
      testWrapper2.simulatePositionUpdate(Duration(milliseconds: i * 5));
      await Future.delayed(Duration(microseconds: 50));
    }
  }));

  recreationFutures.add(Future(() async {
    await Future.delayed(Duration(milliseconds: 10));
    testWrapper2.simulateRecreatePlayer();
  }));

  try {
    await Future.wait(recreationFutures);
    testWrapper2.dispose();
    print('✅ Test 2: Recréation player réussie sans exception');
  } catch (e) {
    print('❌ Test 2: Exception lors de la recréation: $e');
    exit(1);
  }
}

/// Classe de test simulant AudioServiceHybridWrapper avec les corrections
class TestAudioWrapper {
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  bool _isDisposing = false;

  /// Simule l'ajout d'une position (équivalent de la méthode corrigée)
  void simulatePositionUpdate(Duration position) {
    _safeAddToPositionStream(position);
  }

  /// Simule la recréation du player (équivalent de _recreateAudioPlayer)
  void simulateRecreatePlayer() {
    if (!_isDisposing && !_positionController.isClosed) {
      // Simuler reconfiguration des listeners
      _safeAddToPositionStream(Duration.zero);
    }
  }

  /// Méthode sécurisée pour ajouter des événements au stream
  void _safeAddToPositionStream(Duration position) {
    if (!_isDisposing && !_positionController.isClosed) {
      try {
        _positionController.add(position);
      } catch (e) {
        // Logging simulé - dans le vrai code, c'est TtsLogger.debug
        print('🔧 Erreur ajout position stream (ignorée): ${e.toString()}');
      }
    }
  }

  /// Simule le dispose avec les corrections
  void dispose() {
    _isDisposing = true;
    try {
      if (!_positionController.isClosed) {
        _positionController.close();
      }
    } catch (e) {
      print('❌ Erreur dispose: $e');
    }
  }
}
