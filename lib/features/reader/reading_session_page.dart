import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';
import 'package:spiritual_routines/core/services/content_service.dart';
import 'package:spiritual_routines/core/services/session_service.dart';
import 'package:spiritual_routines/features/counter/smart_counter.dart';
import 'package:spiritual_routines/features/reader/current_progress.dart';
import 'package:spiritual_routines/features/session/session_state.dart';
import 'package:spiritual_routines/features/counter/hands_free_controller.dart';
import 'package:spiritual_routines/features/reader/reading_prefs.dart';
import 'package:spiritual_routines/design_system/inspired_theme.dart';
import 'package:spiritual_routines/core/providers/tts_adapter_provider.dart';
import 'package:spiritual_routines/core/providers/haptic_provider.dart';
import 'package:spiritual_routines/core/services/hybrid_audio_service.dart';
import 'package:spiritual_routines/core/services/user_settings_service.dart';
import 'package:spiritual_routines/core/services/progress_service.dart';
import 'package:spiritual_routines/core/services/task_audio_prefs.dart';

class ReadingSessionPage extends ConsumerStatefulWidget {
  final int taskId;
  final String taskTitle;
  final String? initialProgress;

  const ReadingSessionPage({
    super.key,
    required this.taskId,
    required this.taskTitle,
    this.initialProgress,
  });

  @override
  ConsumerState<ReadingSessionPage> createState() => _ReadingSessionPageState();
}

class _ReadingSessionPageState extends ConsumerState<ReadingSessionPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  
  static const String defaultContent = '''بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ
اَلْحَمْدُ لِلّٰهِ رَبِّ الْعٰلَمِيْنَ
اَلرَّحْمٰنِ الرَّحِيْمِ
مٰلِكِ يَوْمِ الدِّيْنِ
اِيَّاكَ نَعْبُدُ وَ اِيَّاكَ نَسْتَعِيْنُ
اِهْدِنَا الصِّرَاطَ الْمُسْتَقِيْمَ
صِرَاطَ الَّذِيْنَ اَنْعَمْتَ عَلَيْهِمْ
غَيْرِ الْمَغْضُوْبِ عَلَيْهِمْ وَلَا الضَّآلِّيْنَ''';

  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  bool _isReadingMode = false;
  bool _isListening = false;
  bool _showProgress = false;
  String _sessionId = '';
  List<Map<String, dynamic>> _verseIndicators = [];
  double _readingProgress = 0.0;
  Duration _readingDuration = Duration.zero;
  String _lastText = '';
  Timer? _saveTimer;
  Timer? _progressTimer;
  
  // State variables for performance
  bool _isInitialized = false;
  bool _hasTextChanged = false;
  String _cachedContent = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _fadeController.forward();
    
    _initializeSession();
    _focusNode.addListener(_onFocusChanged);
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveTimer?.cancel();
    _progressTimer?.cancel();
    _animationController.dispose();
    _fadeController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _saveProgress();
        break;
      case AppLifecycleState.resumed:
        _loadProgress();
        break;
      default:
        break;
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _showProgress = true;
      _animationController.forward();
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && !_focusNode.hasFocus) {
          setState(() {
            _showProgress = false;
          });
          _animationController.reverse();
        }
      });
    }
  }

  void _onTextChanged() {
    if (!_hasTextChanged) {
      _hasTextChanged = true;
    }
    
    final currentText = _textController.text;
    if (currentText != _lastText) {
      _lastText = currentText;
      
      // Annuler le timer précédent et en créer un nouveau
      _saveTimer?.cancel();
      _saveTimer = Timer(const Duration(seconds: 1), () {
        _saveProgress();
        _updateVerseIndicators();
      });
    }
  }

  Future<void> _initializeSession() async {
    try {
      // Générer un ID de session unique
      _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Charger le contenu initial
      await _loadInitialContent();
      
      // Marquer comme initialisé
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      
      // Démarrer le timer de progression
      _startProgressTimer();
      
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation de la session: $e');
      if (mounted) {
        setState(() {
          _textController.text = defaultContent;
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _loadInitialContent() async {
    try {
      // Pour l'instant, utiliser le contenu par défaut
      // final contentService = ref.read(contentServiceProvider);
      // final taskContent = await contentService.getByTaskAndLocale(widget.taskId.toString(), 'ar');
      final taskContent = null; // Temporaire
      
      String contentToLoad = defaultContent;
      
      // if (taskContent != null && taskContent.content?.isNotEmpty == true) {
      //   contentToLoad = taskContent.content!;
      // } else 
      if (widget.initialProgress?.isNotEmpty == true) {
        contentToLoad = widget.initialProgress!;
      }
      
      if (mounted) {
        setState(() {
          _textController.text = contentToLoad;
          _cachedContent = contentToLoad;
        });
      }
      
      // Charger la progression sauvegardée
      await _loadProgress();
      
    } catch (e) {
      print('❌ Erreur lors du chargement du contenu: $e');
      if (mounted) {
        setState(() {
          _textController.text = defaultContent;
          _cachedContent = defaultContent;
        });
      }
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isReadingMode) {
        _readingDuration = _readingDuration + const Duration(seconds: 30);
        _updateReadingProgress();
      }
    });
  }

  void _updateReadingProgress() {
    if (_textController.text.isNotEmpty) {
      // Estimation simple basée sur la longueur du texte et le temps
      final textLength = _textController.text.length;
      final timeInMinutes = _readingDuration.inMinutes;
      
      // Supposons une vitesse de lecture d'environ 200 mots par minute
      final wordsRead = timeInMinutes * 200;
      final estimatedTotalWords = textLength / 5; // Approximation
      
      setState(() {
        _readingProgress = (wordsRead / estimatedTotalWords).clamp(0.0, 1.0);
      });
    }
  }

  Future<void> _saveProgress() async {
    if (!_hasTextChanged && _readingDuration == Duration.zero) return;
    
    try {
      // TODO: Implémenter la sauvegarde de progression
      // final sessionService = ref.read(sessionServiceProvider);
      // await sessionService.saveSessionProgress(
      //   _sessionId,
      //   widget.taskId,
      //   _textController.text,
      //   _readingProgress,
      //   _readingDuration,
      // );
      
      _hasTextChanged = false;
      print('✅ Progression sauvegardée (simulation)');
      
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde: $e');
    }
  }

  Future<void> _loadProgress() async {
    try {
      // TODO: Implémenter le chargement de progression
      // final sessionService = ref.read(sessionServiceProvider);
      // final progress = await sessionService.getSessionProgress(_sessionId, widget.taskId);
      
      // if (progress != null && mounted) {
      //   setState(() {
      //     _readingProgress = progress['progress'] ?? 0.0;
      //     _readingDuration = Duration(seconds: progress['duration'] ?? 0);
      //   });
      // }
      print('✅ Progression chargée (simulation)');
    } catch (e) {
      print('❌ Erreur lors du chargement de la progression: $e');
    }
  }

  Future<void> _updateVerseIndicators() async {
    final text = _textController.text;
    if (text.isEmpty) return;

    try {
      // Détection simple basée sur la longueur et les caractères arabes
      final indicators = <Map<String, dynamic>>[];
      final lines = text.split('\n');
      int position = 0;
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isNotEmpty && _containsArabic(line)) {
          indicators.add({
            'start': position,
            'end': position + line.length,
            'line': i,
            'type': 'verse'
          });
        }
        position += lines[i].length + 1; // +1 for newline
      }
      
      if (mounted) {
        setState(() {
          _verseIndicators = indicators;
        });
      }
    } catch (e) {
      print('❌ Erreur lors de la détection des versets: $e');
    }
  }
  
  bool _containsArabic(String text) {
    return text.contains(RegExp(r'[\u0600-\u06FF]'));
  }

  void _toggleReadingMode() {
    setState(() {
      _isReadingMode = !_isReadingMode;
    });
    
    if (_isReadingMode) {
      _focusNode.unfocus();
      _startProgressTimer();
    } else {
      _progressTimer?.cancel();
      _saveProgress();
    }
  }

  Future<void> _playAudio() async {
    if (_isListening) {
      await _stopAudio();
      return;
    }

    setState(() {
      _isListening = true;
    });

    try {
      final text = _textController.text;
      if (text.isEmpty) {
        _showSnackBar('Aucun texte à lire');
        setState(() {
          _isListening = false;
        });
        return;
      }

      print('🎧 DEBUG: Début de la lecture audio');
      print('🎧 DEBUG: Texte à lire (${text.length} caractères): ${text.substring(0, text.length > 100 ? 100 : text.length)}...');

      // Obtenir la configuration TTS depuis les préférences utilisateur
      final userSettingsService = ref.read(userSettingsServiceProvider);
      // TODO: implémenter getTtsConfig ou utiliser les méthodes individuelles
      final ttsSpeed = await userSettingsService.getTtsSpeed();
      final ttsPitch = await userSettingsService.getTtsPitch();
      final ttsVoiceFr = await userSettingsService.getTtsPreferredFr();
      
      print('🎧 DEBUG: Configuration TTS:');
      print('  - Vitesse: $ttsSpeed');
      print('  - Pitch: $ttsPitch');
      print('  - Voix FR: $ttsVoiceFr');

      // Utiliser le service TTS hybride (même logique que le mode mains libres)
      final hybridTts = ref.read(hybridAudioServiceProvider);
      print('🎧 DEBUG: Service TTS hybride actuel: ${hybridTts.runtimeType}');
      
      // Vérifier que c'est bien le service hybride
      if (hybridTts is! HybridAudioService) {
        print('⚠️ ATTENTION: Service TTS hybride incorrect: ${hybridTts.runtimeType}');
      }

      // Lancer la lecture audio avec le service hybride
      await hybridTts.speak(text);
      
      print('✅ DEBUG: Lecture audio lancée avec succès');

    } catch (e, stackTrace) {
      print('❌ Erreur lors de la lecture audio: $e');
      print('❌ Stack trace: $stackTrace');
      _showSnackBar('Erreur lors de la lecture: ${e.toString()}');
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _stopAudio() async {
    try {
      final hybridTts = ref.read(hybridAudioServiceProvider);
      await hybridTts.stop();
      
      setState(() {
        _isListening = false;
      });
      
      print('✅ DEBUG: Lecture audio arrêtée');
    } catch (e) {
      print('❌ Erreur lors de l\'arrêt audio: $e');
      setState(() {
        _isListening = false;
      });
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showVerseSelector() async {
    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) => const VerseSelector(),
    );
    
    if (result != null) {
      await _insertVerse(result['surah']!, result['ayah']!);
    }
  }

  Future<void> _insertVerse(int surah, int ayah) async {
    try {
      // Pour l'instant, insérer un texte simple
      final verseText = 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ'; // Bismillah as example
      
      final currentText = _textController.text;
      final selection = _textController.selection;
      
      final before = currentText.substring(0, selection.baseOffset);
      final after = currentText.substring(selection.extentOffset);
      
      final newText = '$before\n$verseText\n$after';
      
      setState(() {
        _textController.text = newText;
        _textController.selection = TextSelection.collapsed(
          offset: before.length + verseText.length + 2,
        );
      });
      
      await _updateVerseIndicators();
      
    } catch (e) {
      _showSnackBar('Erreur lors de l\'insertion du verset: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.taskTitle),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskTitle),
        elevation: 0,
        actions: [
          if (!_isReadingMode) ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Ajouter un verset',
              onPressed: _showVerseSelector,
            ),
          ],
          IconButton(
            icon: Icon(_isListening ? Icons.stop : Icons.volume_up),
            tooltip: _isListening ? 'Arrêter' : 'Écouter',
            onPressed: _playAudio,
          ),
          IconButton(
            icon: Icon(_isReadingMode ? Icons.edit : Icons.chrome_reader_mode),
            tooltip: _isReadingMode ? 'Modifier' : 'Mode lecture',
            onPressed: _toggleReadingMode,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            if (_showProgress && !_isReadingMode)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return SizeTransition(
                    sizeFactor: _animationController,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          LinearProgressIndicator(value: _readingProgress),
                          const SizedBox(height: 4),
                          Text('Progression: ${(_readingProgress * 100).toStringAsFixed(1)}%'),
                          Text('Durée: ${_readingDuration.inMinutes}min'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isReadingMode 
                    ? _buildReadingView()
                    : _buildEditingView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditingView() {
    return Column(
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            scrollController: _scrollController,
            maxLines: null,
            expands: true,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              height: 1.8,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Commencez à écrire ou collez votre texte ici...',
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 18,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadingView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: SelectableText(
          _textController.text.isEmpty ? 'Aucun contenu à afficher' : _textController.text,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 20,
            height: 2.0,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class VerseSelector extends ConsumerStatefulWidget {
  const VerseSelector({super.key});

  @override
  ConsumerState<VerseSelector> createState() => _VerseSelectorState();
}

class _VerseSelectorState extends ConsumerState<VerseSelector> {
  int selectedSurah = 1;
  int selectedAyah = 1;
  int maxAyah = 7; // Al-Fatiha par défaut

  @override
  Widget build(BuildContext context) {
    
    return AlertDialog(
      title: const Text('Sélectionner un verset'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sélecteur de sourate simplifié
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Sourate',
                border: OutlineInputBorder(),
              ),
              value: selectedSurah,
              items: List.generate(114, (index) {
                final surahNumber = index + 1;
                return DropdownMenuItem<int>(
                  value: surahNumber,
                  child: Text('$surahNumber. Sourate $surahNumber'),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedSurah = value;
                    // Adapter maxAyah selon quelques sourates connues
                    if (value == 1) maxAyah = 7;       // Al-Fatiha
                    else if (value == 2) maxAyah = 286; // Al-Baqarah
                    else if (value == 114) maxAyah = 6; // An-Nas
                    else maxAyah = 20; // Valeur par défaut
                    selectedAyah = 1;
                  });
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Sélecteur de verset
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Verset',
                border: OutlineInputBorder(),
              ),
              value: selectedAyah,
              items: List.generate(maxAyah, (index) {
                final ayahNumber = index + 1;
                return DropdownMenuItem<int>(
                  value: ayahNumber,
                  child: Text('Verset $ayahNumber'),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedAyah = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop({
            'surah': selectedSurah,
            'ayah': selectedAyah,
          }),
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}