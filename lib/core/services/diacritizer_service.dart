abstract class DiacritizerService {
  Future<String> diacritize(String arabicText);
}

class StubDiacritizerService implements DiacritizerService {
  @override
  Future<String> diacritize(String arabicText) async {
    // Stub: returns same text; replace with real diacritization later
    return arabicText;
  }
}

