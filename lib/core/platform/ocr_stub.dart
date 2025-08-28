// Stub pour google_mlkit_text_recognition sur les plateformes non supportées

class TextRecognitionScript {
  static const latin = TextRecognitionScript._('latin');
  final String value;
  const TextRecognitionScript._(this.value);
}

class TextRecognizer {
  TextRecognizer({TextRecognitionScript? script});

  Future<RecognizedText> processImage(InputImage image) async {
    return RecognizedText(text: '');
  }

  Future<void> close() async {}
}

class InputImage {
  static InputImage fromFilePath(String path) {
    return InputImage();
  }
}

class RecognizedText {
  final String text;
  RecognizedText({required this.text});
}
