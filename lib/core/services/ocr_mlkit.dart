import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spiritual_routines/core/platform/ocr_wrapper.dart';
import 'package:spiritual_routines/core/platform/platform_service.dart';
import 'package:spiritual_routines/core/services/ocr_service.dart';

// Import conditionnel pour éviter les erreurs sur desktop
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
    if (dart.library.js) '../platform/ocr_stub.dart';
import 'package:pdfx/pdfx.dart'
    if (dart.library.js) '../platform/pdf_stub.dart';

class MlkitOcrService implements OcrService {
  final OCRWrapper _ocrWrapper = OCRWrapper();
  final PlatformService _platform = PlatformService.instance;

  @override
  Future<String> recognizeImage(String imagePath,
      {String language = 'auto'}) async {
    // Utiliser le wrapper OCR pour cross-platform
    if (_ocrWrapper.isOCRAvailable) {
      final text = await _ocrWrapper.extractTextFromImage(imagePath);
      return text ?? '';
    }

    // Fallback pour desktop
    if (_platform.isDesktop) {
      debugPrint('OCR non disponible sur desktop. Import manuel requis.');
      return '';
    }

    // Sur mobile, utiliser google_mlkit si disponible
    if (_platform.isMobile) {
      try {
        const script = TextRecognitionScript.latin;
        final recognizer = TextRecognizer(script: script);
        try {
          final input = InputImage.fromFilePath(imagePath);
          final result = await recognizer.processImage(input);
          return result.text;
        } finally {
          await recognizer.close();
        }
      } catch (e) {
        debugPrint('Erreur OCR mobile: $e');
        return '';
      }
    }

    return '';
  }

  @override
  Future<String> recognizePdf(String pdfPath,
      {String language = 'auto'}) async {
    // PDF rendering n'est pas disponible sur toutes les plateformes
    if (!_platform.isMobile && !_platform.isMacOS) {
      debugPrint('PDF OCR non disponible sur cette plateforme');
      return '';
    }

    try {
      final doc = await PdfDocument.openFile(pdfPath);
      final pageCount = await doc.pagesCount;
      final buffer = StringBuffer();

      for (int i = 1; i <= pageCount; i++) {
        final page = await doc.getPage(i);
        final pageImage = await page.render(
            width: page.width, height: page.height, format: PdfPageImageFormat.png);
        await page.close();

        if (pageImage == null) continue;

        final temp = await _writeTempPng(pageImage.bytes);
        final text = await recognizeImage(temp.path, language: language);
        buffer.writeln(text);

        // Limiter le nombre de pages pour performance
        if (i >= 5) break;
      }

      return buffer.toString();
    } catch (e) {
      debugPrint('Erreur PDF OCR: $e');
      return '';
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
