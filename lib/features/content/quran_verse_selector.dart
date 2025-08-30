import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/services/quran_corpus_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

/// Widget pour sélectionner des versets du Coran
/// Supporte : verset unique, plage de versets, versets de plusieurs sourates, sourate complète
class QuranVerseSelector extends ConsumerStatefulWidget {
  final Function(String versesText, String versesRefs) onVersesSelected;
  final String locale; // 'fr' ou 'ar'

  const QuranVerseSelector({
    super.key,
    required this.onVersesSelected,
    required this.locale,
  });

  @override
  ConsumerState<QuranVerseSelector> createState() => _QuranVerseSelectorState();
}

class _QuranVerseSelectorState extends ConsumerState<QuranVerseSelector> {
  // Type de sélection
  String _selectionType = 'single'; // single, range, mixed, surah

  // Pour verset unique ou plage
  int? _selectedSurah;
  int? _startVerse;
  int? _endVerse;

  // Pour sélection mixte
  final List<VerseReference> _mixedVerses = [];
  final _mixedInputController = TextEditingController();

  // Pour sourate complète
  final List<int> _selectedSurahs = [];

  // Métadonnées des sourates
  List<Map<String, dynamic>> _surahsMetadata = [];

  @override
  void initState() {
    super.initState();
    _loadSurahsMetadata();
  }

  Future<void> _loadSurahsMetadata() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/corpus/surahs_metadata.json');
      final List<dynamic> data = json.decode(jsonString);
      setState(() {
        _surahsMetadata = data.cast<Map<String, dynamic>>();
      });
      print('🔧 DEBUG: Loaded ${_surahsMetadata.length} surahs metadata');
      if (_surahsMetadata.length >= 2) {
        print('🔧 DEBUG: Surah 2 data: ${_surahsMetadata[1]}');
      }
    } catch (e) {
      print('Erreur lors du chargement des métadonnées : $e');
    }
  }

  @override
  void dispose() {
    _mixedInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Ajouter des versets du Coran',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        // Sélecteur de type
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Verset unique'),
              selected: _selectionType == 'single',
              onSelected: (_) => setState(() => _selectionType = 'single'),
            ),
            ChoiceChip(
              label: const Text('Plage de versets'),
              selected: _selectionType == 'range',
              onSelected: (_) => setState(() => _selectionType = 'range'),
            ),
            ChoiceChip(
              label: const Text('Versets mixtes'),
              selected: _selectionType == 'mixed',
              onSelected: (_) => setState(() => _selectionType = 'mixed'),
            ),
            ChoiceChip(
              label: const Text('Sourate complète'),
              selected: _selectionType == 'surah',
              onSelected: (_) => setState(() => _selectionType = 'surah'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Interface selon le type sélectionné
        if (_selectionType == 'single') _buildSingleVerseSelector(),
        if (_selectionType == 'range') _buildRangeSelector(),
        if (_selectionType == 'mixed') _buildMixedSelector(),
        if (_selectionType == 'surah') _buildSurahSelector(),

        const SizedBox(height: 16),

        // Bouton d'ajout
        Center(
          child: FilledButton.icon(
            onPressed: _canAddVerses() ? _addVerses : null,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter les versets'),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleVerseSelector() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _selectedSurah,
            decoration: const InputDecoration(
              labelText: 'Sourate',
              border: OutlineInputBorder(),
            ),
            items: _surahsMetadata.map((surah) {
              return DropdownMenuItem(
                value: surah['number'] as int,
                child: Text(
                  '${surah['number']}. ${surah['frenchName'] ?? surah['name']}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList(),
            isExpanded: true,
            onChanged: (value) {
              setState(() {
                _selectedSurah = value;
                _startVerse = null;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Verset',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _startVerse = int.tryParse(value);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRangeSelector() {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          value: _selectedSurah,
          decoration: const InputDecoration(
            labelText: 'Sourate',
            border: OutlineInputBorder(),
          ),
          items: _surahsMetadata.map((surah) {
            return DropdownMenuItem(
              value: surah['number'] as int,
              child: Text(
                '${surah['number']}. ${surah['frenchName'] ?? surah['name']}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          isExpanded: true,
          onChanged: (value) {
            print('🔧 DEBUG: Surah dropdown changed to: $value');
            setState(() {
              _selectedSurah = value;
              _startVerse = null;
              _endVerse = null;
            });
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Verset début',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  print('🔧 DEBUG: Start verse changed to: $value');
                  setState(() {
                    _startVerse = int.tryParse(value);
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Verset fin',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  print('🔧 DEBUG: End verse changed to: $value');
                  setState(() {
                    _endVerse = int.tryParse(value);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMixedSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _mixedInputController,
          decoration: const InputDecoration(
            labelText: 'Références (ex: 2:255, 112:1-4, 1:1-7)',
            helperText:
                'Format: sourate:verset ou sourate:début-fin, séparés par des virgules',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        if (_mixedVerses.isNotEmpty) ...[
          Text('Versets sélectionnés:',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: _mixedVerses.map((ref) {
              return Chip(
                label: Text(ref.toString()),
                onDeleted: () {
                  setState(() {
                    _mixedVerses.remove(ref);
                  });
                },
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _parseMixedInput,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Valider les références'),
        ),
      ],
    );
  }

  Widget _buildSurahSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sélectionner une ou plusieurs sourates:',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: _surahsMetadata.length,
            itemBuilder: (context, index) {
              final surah = _surahsMetadata[index];
              final surahNumber = surah['number'] as int;
              final isSelected = _selectedSurahs.contains(surahNumber);

              return CheckboxListTile(
                title: Text(
                    '${surah['number']}. ${surah['frenchName'] ?? surah['name']}'),
                subtitle: Text('${surah['numberOfAyahs']} versets'),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedSurahs.add(surahNumber);
                    } else {
                      _selectedSurahs.remove(surahNumber);
                    }
                  });
                },
              );
            },
          ),
        ),
        if (_selectedSurahs.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('${_selectedSurahs.length} sourate(s) sélectionnée(s)',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }

  bool _canAddVerses() {
    switch (_selectionType) {
      case 'single':
        return _selectedSurah != null && _startVerse != null;
      case 'range':
        return _selectedSurah != null &&
            _startVerse != null &&
            _endVerse != null;
      case 'mixed':
        return _mixedVerses.isNotEmpty;
      case 'surah':
        return _selectedSurahs.isNotEmpty;
      default:
        return false;
    }
  }

  void _parseMixedInput() {
    final input = _mixedInputController.text.trim();
    if (input.isEmpty) return;

    final references = input.split(',');
    final parsedRefs = <VerseReference>[];

    for (final ref in references) {
      final trimmed = ref.trim();
      final parts = trimmed.split(':');
      if (parts.length != 2) continue;

      final surah = int.tryParse(parts[0]);
      if (surah == null) continue;

      final versePart = parts[1];
      if (versePart.contains('-')) {
        // Plage de versets
        final verseParts = versePart.split('-');
        if (verseParts.length != 2) continue;

        final start = int.tryParse(verseParts[0]);
        final end = int.tryParse(verseParts[1]);
        if (start != null && end != null) {
          parsedRefs.add(
              VerseReference(surah: surah, startVerse: start, endVerse: end));
        }
      } else {
        // Verset unique
        final verse = int.tryParse(versePart);
        if (verse != null) {
          parsedRefs.add(
              VerseReference(surah: surah, startVerse: verse, endVerse: verse));
        }
      }
    }

    setState(() {
      _mixedVerses.clear();
      _mixedVerses.addAll(parsedRefs);
    });
  }

  Future<void> _addVerses() async {
    print('🔧 DEBUG: _addVerses() appelé');
    final corpus = ref.read(quranCorpusServiceProvider);
    final buffer = StringBuffer();
    final refs = StringBuffer();

    print('🔧 DEBUG: Type de sélection: $_selectionType');

    try {
      switch (_selectionType) {
        case 'single':
          if (_selectedSurah != null && _startVerse != null) {
            print(
                '🔧 DEBUG: Récupération sourate $_selectedSurah, verset $_startVerse');
            final verses = await corpus.getRange(
                _selectedSurah!, _startVerse!, _startVerse!);
            print('🔧 DEBUG: ${verses.length} versets récupérés');
            _appendVersesToBuffer(verses, buffer);
            refs.write('$_selectedSurah:$_startVerse');
          } else {
            print(
                '🔧 DEBUG: Paramètres manquants - sourate: $_selectedSurah, verset: $_startVerse');
          }
          break;

        case 'range':
          if (_selectedSurah != null &&
              _startVerse != null &&
              _endVerse != null) {
            print(
                '🔧 DEBUG: About to call getRange($_selectedSurah, $_startVerse, $_endVerse)');
            final verses = await corpus.getRange(
                _selectedSurah!, _startVerse!, _endVerse!);
            print('🔧 DEBUG: getRange returned ${verses.length} verses');
            _appendVersesToBuffer(verses, buffer);
            refs.write('$_selectedSurah:$_startVerse-$_endVerse');
          } else {
            print(
                '🔧 DEBUG: Range params missing - surah: $_selectedSurah, start: $_startVerse, end: $_endVerse');
          }
          break;

        case 'mixed':
          for (int i = 0; i < _mixedVerses.length; i++) {
            final ref = _mixedVerses[i];
            final verses =
                await corpus.getRange(ref.surah, ref.startVerse, ref.endVerse);
            _appendVersesToBuffer(verses, buffer);

            if (i > 0) refs.write(', ');
            if (ref.startVerse == ref.endVerse) {
              refs.write('${ref.surah}:${ref.startVerse}');
            } else {
              refs.write('${ref.surah}:${ref.startVerse}-${ref.endVerse}');
            }
          }
          break;

        case 'surah':
          for (int i = 0; i < _selectedSurahs.length; i++) {
            final surahNumber = _selectedSurahs[i];
            final surahMeta =
                _surahsMetadata.firstWhere((s) => s['number'] == surahNumber);
            final numberOfAyahs = surahMeta['numberOfAyahs'] as int;

            final verses = await corpus.getRange(surahNumber, 1, numberOfAyahs);
            _appendVersesToBuffer(verses, buffer);

            if (i > 0) refs.write(', ');
            refs.write('$surahNumber:1-$numberOfAyahs');
          }
          break;
      }

      final versesText = buffer.toString().trim();
      final versesRefs = refs.toString();

      print('🔧 DEBUG: Texte généré: ${versesText.length} caractères');
      print('🔧 DEBUG: Refs générées: $versesRefs');

      if (versesText.isNotEmpty) {
        print('🔧 DEBUG: Appel de la callback onVersesSelected');
        widget.onVersesSelected(versesText, versesRefs);

        // Réinitialiser
        setState(() {
          _selectedSurah = null;
          _startVerse = null;
          _endVerse = null;
          _mixedVerses.clear();
          _selectedSurahs.clear();
          _mixedInputController.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Versets ajoutés avec succès')),
          );
        }
      } else {
        print('🔧 DEBUG: Aucun texte généré !');
      }
    } catch (e) {
      print('🔧 DEBUG: Erreur dans _addVerses: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _appendVersesToBuffer(List<dynamic> verses, StringBuffer buffer) {
    for (final verse in verses) {
      final text =
          widget.locale == 'ar' ? (verse.textAr ?? '') : (verse.textFr ?? '');

      if (text.isNotEmpty) {
        // Ajouter le texte du verset avec le marqueur de numéro à la fin
        buffer.write(text.trim());
        buffer.write(' {{V:${verse.ayah}}}');
        buffer.writeln();
      }
    }
    buffer.writeln(); // Ligne vide entre les sections
  }
}

/// Référence à un verset ou une plage de versets
class VerseReference {
  final int surah;
  final int startVerse;
  final int endVerse;

  VerseReference({
    required this.surah,
    required this.startVerse,
    required this.endVerse,
  });

  @override
  String toString() {
    if (startVerse == endVerse) {
      return '$surah:$startVerse';
    } else {
      return '$surah:$startVerse-$endVerse';
    }
  }
}
