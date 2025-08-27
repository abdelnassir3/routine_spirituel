// Stub pour native_pdf_renderer sur les plateformes non supportées

import 'dart:typed_data';

class PdfDocument {
  final int pagesCount = 0;
  
  static Future<PdfDocument> openFile(String path) async {
    return PdfDocument();
  }
  
  Future<PdfPage> getPage(int pageNumber) async {
    return PdfPage();
  }
}

class PdfPage {
  final int width = 100;
  final int height = 100;
  
  Future<PdfPageImage?> render({
    required int width,
    required int height,
    required PdfPageFormat format,
  }) async {
    return null;
  }
  
  Future<void> close() async {}
}

class PdfPageImage {
  final Uint8List bytes = Uint8List(0);
}

enum PdfPageFormat {
  PNG,
  JPEG,
}