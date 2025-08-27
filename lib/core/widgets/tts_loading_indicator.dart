import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider pour gérer l'état de chargement TTS
final ttsLoadingStateProvider = StateNotifierProvider<TtsLoadingNotifier, TtsLoadingState>((ref) {
  return TtsLoadingNotifier();
});

/// État de chargement TTS
class TtsLoadingState {
  final bool isLoading;
  final String? message;
  final bool isFirstTime;
  
  const TtsLoadingState({
    this.isLoading = false,
    this.message,
    this.isFirstTime = false,
  });
  
  TtsLoadingState copyWith({
    bool? isLoading,
    String? message,
    bool? isFirstTime,
  }) {
    return TtsLoadingState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }
}

/// Gestionnaire d'état pour le chargement TTS
class TtsLoadingNotifier extends StateNotifier<TtsLoadingState> {
  TtsLoadingNotifier() : super(const TtsLoadingState());
  
  void startLoading({bool isFirstTime = false}) {
    state = state.copyWith(
      isLoading: true,
      isFirstTime: isFirstTime,
      message: isFirstTime 
        ? 'Première synthèse en cours...\nCela peut prendre 3-10 secondes.\nLes prochaines fois seront instantanées !'
        : 'Chargement de la voix...',
    );
  }
  
  void stopLoading() {
    state = state.copyWith(isLoading: false, message: null);
  }
  
  void updateMessage(String message) {
    state = state.copyWith(message: message);
  }
}

/// Widget indicateur de chargement TTS
class TtsLoadingIndicator extends ConsumerWidget {
  const TtsLoadingIndicator({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingState = ref.watch(ttsLoadingStateProvider);
    
    if (!loadingState.isLoading) {
      return const SizedBox.shrink();
    }
    
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animation de chargement spéciale pour Coqui
                if (loadingState.isFirstTime) ...[
                  const Icon(
                    Icons.rocket_launch,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                ],
                
                // Message principal
                Text(
                  loadingState.isFirstTime 
                    ? 'Préparation de la voix Coqui...'
                    : 'Synthèse vocale...',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                
                // Message détaillé
                if (loadingState.message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    loadingState.message!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
                
                // Barre de progression pour première fois
                if (loadingState.isFirstTime) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'Voix naturelle haute qualité',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension pour faciliter l'utilisation
extension TtsLoadingExtension on WidgetRef {
  /// Joue un texte avec indicateur de chargement
  Future<void> playTextWithLoading(
    String text, {
    required String voice,
    required Future<void> Function() playFunction,
    bool checkCache = true,
  }) async {
    final loadingNotifier = read(ttsLoadingStateProvider.notifier);
    
    try {
      // Vérifier si c'est la première fois (pas en cache)
      bool isFirstTime = false;
      if (checkCache) {
        // TODO: Vérifier le cache pour déterminer si c'est la première fois
        // Pour l'instant, on suppose que c'est la première fois si le texte est long
        isFirstTime = text.length > 100;
      }
      
      // Afficher le chargement
      loadingNotifier.startLoading(isFirstTime: isFirstTime);
      
      // Jouer le texte
      await playFunction();
      
    } finally {
      // Masquer le chargement
      loadingNotifier.stopLoading();
    }
  }
}