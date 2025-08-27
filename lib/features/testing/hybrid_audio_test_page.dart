import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/smart_tts_enhanced_service.dart';
import '../../core/services/audio/edge_tts_test.dart';
import '../../core/services/audio/test_hybrid_audio.dart';
import '../../core/services/text/farasa_test.dart';
import '../../core/services/text/farasa_diacritization_service.dart';

/// Page de test pour le système audio hybride
class HybridAudioTestPage extends ConsumerStatefulWidget {
  const HybridAudioTestPage({super.key});

  @override
  ConsumerState<HybridAudioTestPage> createState() => _HybridAudioTestPageState();
}

class _HybridAudioTestPageState extends ConsumerState<HybridAudioTestPage> {
  String _logs = '';
  bool _isLoading = false;
  
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = 'السلام عليكم، بسم الله الرحمن الرحيم';
  }

  void _addLog(String message) {
    setState(() {
      _logs += '${DateTime.now().toString().substring(11, 19)} $message\n';
    });
  }

  Future<void> _testVpsConnection() async {
    setState(() {
      _isLoading = true;
      _logs = '';
    });
    
    _addLog('🧪 Test de connexion VPS Edge-TTS...');
    
    try {
      final summary = await EdgeTtsVpsTest.runAllTestsAndGetSummary();
      _addLog(summary);
    } catch (e) {
      _addLog('❌ Erreur test VPS: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testHybridSystem() async {
    setState(() {
      _isLoading = true;
      _logs = '';
    });
    
    _addLog('🧪 Test du système audio hybride...');
    
    try {
      final ttsService = ref.read(smartTtsEnhancedProvider);
      await HybridAudioTest.runTests(ttsService);
      _addLog('✅ Tests système hybride terminés');
    } catch (e) {
      _addLog('❌ Erreur test hybride: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testCustomText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _logs = '';
    });
    
    _addLog('🎵 Test lecture: "$text"');
    
    try {
      final ttsService = ref.read(smartTtsEnhancedProvider);
      
      // Analyser le contenu
      final analysis = ttsService.analyzeContent(text);
      final preview = ttsService.previewContentType(text);
      
      _addLog('📊 $preview');
      _addLog('🎯 Type: ${analysis.contentType}');
      
      if (analysis.verses.isNotEmpty) {
        _addLog('📜 Versets: ${analysis.verses.length}');
      }
      
      _addLog('🌐 Langues: ${(analysis.languageRatio.arabic * 100).round()}% AR, ${(analysis.languageRatio.french * 100).round()}% FR');
      
      // Tenter la lecture
      _addLog('▶️ Démarrage lecture...');
      await ttsService.playHighQuality(text);
      _addLog('✅ Lecture démarrée avec succès');
      
    } catch (e) {
      _addLog('❌ Erreur lecture: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _stopAudio() async {
    try {
      final ttsService = ref.read(smartTtsEnhancedProvider);
      await ttsService.stop();
      _addLog('⏹️ Audio arrêté');
    } catch (e) {
      _addLog('❌ Erreur arrêt: $e');
    }
  }

  Future<void> _testFarasa() async {
    setState(() {
      _isLoading = true;
      _logs = '';
    });
    
    _addLog('🔤 Test de diacritisation Farasa...');
    
    try {
      await FarasaTest.runTests();
      _addLog('✅ Tests Farasa terminés');
    } catch (e) {
      _addLog('❌ Erreur test Farasa: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testDiacritization() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _logs = '';
    });
    
    _addLog('🔤 Test diacritisation: "$text"');
    
    try {
      // Test de diacritisation
      final result = await FarasaDiacritizationService.diacritizeText(text);
      _addLog('📝 Original: $text');
      _addLog('✨ Diacritisé: $result');
      
      // Vérifier si des harakat ont été ajoutés
      final hasHarakat = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]').hasMatch(result);
      if (hasHarakat) {
        _addLog('✅ Harakat détectés dans le résultat');
      } else {
        _addLog('⚠️ Aucun harakat détecté (normal si texte déjà diacritisé ou API indisponible)');
      }
      
      // Stats du cache
      final stats = FarasaDiacritizationService.getCacheStats();
      _addLog('📊 Cache: ${stats['cacheSize']}/${stats['maxCacheSize']} (${stats['usagePercent']}%)');
      
    } catch (e) {
      _addLog('❌ Erreur diacritisation: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Audio Hybride'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section de test de texte personnalisé
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎵 Test Audio Personnalisé',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Texte à tester',
                        hintText: 'Entrez du texte français, arabe, ou avec marqueurs coraniques {{V:1:1}}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _testCustomText,
                            child: const Text('🎵 Tester Audio'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testDiacritization,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[600],
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('🔤'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _stopAudio,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('⏹️'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Boutons de test
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testVpsConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('📡 Test VPS'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testHybridSystem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('🧪 Test Hybride'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testFarasa,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('🔤 Test Farasa'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Zone de logs
            Expanded(
              child: Card(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '📋 Logs',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _logs = '';
                              });
                            },
                            icon: const Icon(Icons.clear),
                            tooltip: 'Effacer les logs',
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _logs.isEmpty ? 'Aucun log...' : _logs,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}