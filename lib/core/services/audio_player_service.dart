import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  AudioPlayerService() : _player = AudioPlayer();
  final AudioPlayer _player;

  Future<void> playFile(String path) async {
    await _player.setFilePath(path);
    await _player.play();
    await _player.processingStateStream
        .firstWhere((s) => s == ProcessingState.completed);
    await _player.stop();
  }

  Future<void> playFromBytes(Uint8List audioData) async {
    try {
      if (kIsWeb) {
        // Web: lire via Data URI
        final dataUri =
            Uri.dataFromBytes(audioData, mimeType: 'audio/mpeg').toString();
        await _player.setUrl(dataUri);
        await _player.play();
        await _player.processingStateStream
            .firstWhere((s) => s == ProcessingState.completed);
        await _player.stop();
      } else {
        // Créer un fichier temporaire pour stocker les données audio
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
            '${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await tempFile.writeAsBytes(audioData);

        // Jouer le fichier
        await _player.setFilePath(tempFile.path);
        await _player.play();

        // Attendre la fin de la lecture
        await _player.processingStateStream
            .firstWhere((s) => s == ProcessingState.completed);
        await _player.stop();

        // Supprimer le fichier temporaire
        await tempFile.delete();
      }
    } catch (e) {
      print('Erreur lors de la lecture audio: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  // ===== Méthodes de contrôle audio =====

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  // ===== Propriétés et streams =====

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<bool> get isPlayingStream => _player.playerStateStream
      .map((state) => state.playing);

  bool get isPlaying => _player.playing;

  bool get isPaused => _player.processingState != ProcessingState.idle && !_player.playing;

  Duration get duration => _player.duration ?? Duration.zero;

  Duration get position => _player.position;

  void dispose() {
    _player.dispose();
  }
}

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final svc = AudioPlayerService();
  ref.onDispose(svc.dispose);
  return svc;
});
