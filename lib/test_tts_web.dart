import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/adapters/tts_adapter.dart';
import 'core/adapters/tts_factory_web.dart';

/// Page de test simple pour vérifier le fonctionnement du TTS sur web
class TestTtsWebPage extends ConsumerStatefulWidget {
  const TestTtsWebPage({super.key});

  @override
  ConsumerState<TestTtsWebPage> createState() => _TestTtsWebPageState();
}

class _TestTtsWebPageState extends ConsumerState<TestTtsWebPage> {
  final TextEditingController _textController = TextEditingController();
  TtsAdapter? _ttsAdapter;
  String _status = 'Ready';
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    
    // Ajouter du texte de test par défaut
    _textController.text = "السلام عليكم ورحمة الله وبركاته";
  }

  void _initTts() async {
    try {
      print('🧪 TEST: Initialisation TTS Adapter...');
      _ttsAdapter = createTtsAdapter();
      setState(() {
        _status = 'TTS Adapter initialisé: ${_ttsAdapter.runtimeType}';
      });
      print('✅ TEST: TTS Adapter créé - ${_ttsAdapter.runtimeType}');
    } catch (e) {
      setState(() {
        _status = 'Erreur initialisation TTS: $e';
      });
      print('❌ TEST: Erreur init TTS: $e');
    }
  }

  void _testTts() async {
    if (_ttsAdapter == null) {
      setState(() {
        _status = 'TTS Adapter non initialisé';
      });
      return;
    }

    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _status = 'Veuillez saisir du texte à lire';
      });
      return;
    }

    try {
      setState(() {
        _isPlaying = true;
        _status = 'Lecture en cours...';
      });
      
      print('🧪 TEST: Début lecture - "${text.substring(0, text.length > 50 ? 50 : text.length)}..."');
      
      // Déterminer la voix selon le contenu
      String voice = 'fr-FR';
      if (_isArabicText(text)) {
        voice = 'ar-SA';
        print('🧪 TEST: Texte arabe détecté, utilisation voix: $voice');
      } else {
        print('🧪 TEST: Texte français détecté, utilisation voix: $voice');
      }
      
      await _ttsAdapter!.speak(
        text,
        voice: voice,
        speed: 0.65,
        pitch: 1.0,
      );
      
      setState(() {
        _status = '✅ Lecture terminée avec succès';
        _isPlaying = false;
      });
      print('✅ TEST: Lecture terminée avec succès');
      
    } catch (e) {
      setState(() {
        _status = '❌ Erreur lecture: $e';
        _isPlaying = false;
      });
      print('❌ TEST: Erreur lecture TTS: $e');
    }
  }

  void _stopTts() async {
    if (_ttsAdapter == null) return;
    
    try {
      print('🧪 TEST: Arrêt TTS...');
      await _ttsAdapter!.stop();
      setState(() {
        _status = 'TTS arrêté';
        _isPlaying = false;
      });
      print('✅ TEST: TTS arrêté');
    } catch (e) {
      setState(() {
        _status = 'Erreur arrêt TTS: $e';
        _isPlaying = false;
      });
      print('❌ TEST: Erreur arrêt TTS: $e');
    }
  }

  bool _isArabicText(String text) {
    if (text.isEmpty) return false;
    
    // Compter les caractères arabes
    int arabicChars = 0;
    for (int i = 0; i < text.length; i++) {
      final char = text.codeUnitAt(i);
      // Plage Unicode pour l'arabe: 0x0600-0x06FF
      if (char >= 0x0600 && char <= 0x06FF) {
        arabicChars++;
      }
    }
    
    // Si plus de 70% de caractères arabes, considérer comme texte arabe
    final arabicRatio = arabicChars / text.length;
    final isArabic = arabicRatio > 0.7;
    print('🧪 TEST: Détection langue - Caractères arabes: $arabicChars/${text.length} (${(arabicRatio * 100).round()}%) → ${isArabic ? "ARABE" : "FRANÇAIS"}');
    
    return isArabic;
  }

  @override
  void dispose() {
    _ttsAdapter?.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test TTS Web'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        color: _status.startsWith('❌') ? Colors.red :
                               _status.startsWith('✅') ? Colors.green :
                               Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Texte à lire
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Texte à lire',
                hintText: 'Saisissez du texte en français ou en arabe...',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Boutons de test
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isPlaying ? null : _testTts,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Test TTS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isPlaying ? _stopTts : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Arrêter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Textes de test prédéfinis
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Textes de test:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    
                    // Test français
                    ListTile(
                      title: const Text('Texte français'),
                      subtitle: const Text('Bonjour, ceci est un test de synthèse vocale française.'),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          _textController.text = 'Bonjour, ceci est un test de synthèse vocale française.';
                        },
                      ),
                    ),
                    
                    const Divider(),
                    
                    // Test arabe
                    ListTile(
                      title: const Text('Texte arabe'),
                      subtitle: const Text('السلام عليكم ورحمة الله وبركاته'),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          _textController.text = 'السلام عليكم ورحمة الله وبركاته';
                        },
                      ),
                    ),
                    
                    const Divider(),
                    
                    // Test coranique
                    ListTile(
                      title: const Text('Verset coranique'),
                      subtitle: const Text('بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ'),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          _textController.text = 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ';
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Instructions:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Ouvrez la console du navigateur (F12)\n'
                      '2. Saisissez ou sélectionnez un texte de test\n'
                      '3. Cliquez sur "Test TTS" pour lancer la synthèse\n'
                      '4. Vérifiez les logs dans la console\n'
                      '5. Écoutez l\'audio généré',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}