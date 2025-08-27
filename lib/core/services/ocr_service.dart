abstract class OcrService {
  Future<String> recognizeImage(String imagePath, {String language = 'auto'});
  Future<String> recognizePdf(String pdfPath, {String language = 'auto'});
}

class StubOcrService implements OcrService {
  @override
  Future<String> recognizeImage(String imagePath, {String language = 'auto'}) async {
    return 'Texte OCR depuis image ($language)';
  }

  @override
  Future<String> recognizePdf(String pdfPath, {String language = 'auto'}) async {
    return 'Texte OCR depuis PDF ($language)';
  }
}

