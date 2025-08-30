import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../persistence/isar_web_stub.dart';

/// Service pour charger les versets du Coran depuis les assets JSON sur web
class QuranCorpusWebService {
  static final QuranCorpusWebService _instance = QuranCorpusWebService._();
  QuranCorpusWebService._();
  factory QuranCorpusWebService() => _instance;

  List<Map<String, dynamic>>? _versesData;
  bool _isLoading = false;

  /// Charge les données depuis le fichier JSON
  Future<void> _ensureLoaded() async {
    if (_versesData != null || _isLoading) return;
    
    _isLoading = true;
    try {
      print('📖 Loading Quran corpus from assets...');
      final jsonString = await rootBundle.loadString('assets/corpus/quran_full_fixed.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _versesData = jsonData.cast<Map<String, dynamic>>();
      print('✅ Loaded ${_versesData!.length} verses from corpus');
    } catch (e) {
      print('❌ Error loading Quran corpus: $e');
      _versesData = [];
    } finally {
      _isLoading = false;
    }
  }

  /// Récupère une plage de versets
  Future<List<VerseDoc>> getRange(int surah, int start, int end) async {
    await _ensureLoaded();
    
    if (_versesData == null || _versesData!.isEmpty) {
      print('⚠️ No verses data available');
      return [];
    }

    print('🔍 Searching for surah $surah, verses $start-$end');
    
    final verses = _versesData!
        .where((v) => 
            v['surah'] == surah && 
            v['ayah'] >= start && 
            v['ayah'] <= end)
        .map((v) {
          final verse = VerseDoc();
          verse.id = (v['surah'] * 1000 + v['ayah']);
          verse.surah = v['surah'];
          verse.ayah = v['ayah'];
          verse.textAr = v['textAr'];
          verse.textFr = v['textFr'];
          return verse;
        })
        .toList();
    
    print('✅ Found ${verses.length} verses for surah $surah, range $start-$end');
    return verses;
  }

  /// Récupère tous les versets d'une sourate
  Future<List<VerseDoc>> getSurah(int surah) async {
    await _ensureLoaded();
    
    if (_versesData == null || _versesData!.isEmpty) {
      return [];
    }

    final verses = _versesData!
        .where((v) => v['surah'] == surah)
        .map((v) {
          final verse = VerseDoc();
          verse.id = (v['surah'] * 1000 + v['ayah']);
          verse.surah = v['surah'];
          verse.ayah = v['ayah'];
          verse.textAr = v['textAr'];
          verse.textFr = v['textFr'];
          return verse;
        })
        .toList();
    
    print('✅ Found ${verses.length} verses for surah $surah');
    return verses;
  }
}

/// Provider pour le service web
final quranCorpusWebServiceProvider = Provider<QuranCorpusWebService>((ref) {
  return QuranCorpusWebService();
});