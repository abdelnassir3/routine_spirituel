import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';

import 'package:spiritual_routines/core/services/ocr_service.dart';

/// Tesseract-based OCR via platform channel on Android.
/// Falls back to stub elsewhere.
class TesseractOcrService implements OcrService {
  static const _channel = MethodChannel('android_ocr');

  @override
  Future<String> recognizeImage(String imagePath,
      {String language = 'auto'}) async {
    if (kIsWeb) return 'OCR non supporté sur Web (Tesseract)';
    try {
      final text = await _channel.invokeMethod<String>('recognizeImage', {
        'path': imagePath,
        'lang': _mapLang(language),
      });
      return text ?? '';
    } catch (e) {
      return 'Erreur OCR Tesseract: $e';
    }
  }

  @override
  Future<String> recognizePdf(String pdfPath,
      {String language = 'auto'}) async {
    final doc = await PdfDocument.openFile(pdfPath);
    final pageCount = await doc.pagesCount;
    final buffer = StringBuffer();
    for (int i = 1; i <= pageCount; i++) {
      final page = await doc.getPage(i);
      final pageImage =
          await page.render(width: page.width, height: page.height);
      await page.close();
      if (pageImage == null) continue;
      final temp = await _writeTempPng(pageImage.bytes);
      final text = await recognizeImage(temp.path, language: language);
      buffer.writeln(text);
      if (i >= 5) break;
    }
    return buffer.toString();
  }

  String _mapLang(String lang) {
    switch (lang) {
      case 'ar':
        return 'ara';
      case 'fr':
        return 'fra';
      default:
        return 'eng';
    }
  }

  Future<File> _writeTempPng(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file =
        File('${dir.path}/ocr_${DateTime.now().microsecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
