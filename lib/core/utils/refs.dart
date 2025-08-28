class VerseRange {
  final int surah;
  final int start;
  final int end;
  const VerseRange(this.surah, this.start, this.end);
}

List<VerseRange> parseRefs(String input) {
  final parts = input.split(RegExp(r'[;,]\s*'));
  final reSurah = RegExp(r'^(\d{1,3})$');
  final reAyah = RegExp(r'^(\d{1,3}):(\d{1,3})(?:-(\d{1,3}))?$');
  final ranges = <VerseRange>[];
  for (final p in parts) {
    final s = p.trim();
    if (s.isEmpty) continue;
    final ms = reSurah.firstMatch(s);
    if (ms != null) {
      final surah = int.parse(ms.group(1)!);
      ranges.add(VerseRange(surah, 1, 999));
      continue;
    }
    final ma = reAyah.firstMatch(s);
    if (ma != null) {
      final surah = int.parse(ma.group(1)!);
      final a = int.parse(ma.group(2)!);
      final b = int.parse((ma.group(3) ?? ma.group(2))!);
      ranges.add(VerseRange(surah, a, b));
    }
  }
  return ranges;
}
