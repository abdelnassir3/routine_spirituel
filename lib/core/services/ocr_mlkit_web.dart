// Web-safe version of MLKit OCR service that doesn't import pdfx
import 'package:flutter/foundation.dart';
import 'package:spiritual_routines/core/services/ocr_service.dart';

class MlkitOcrService implements OcrService {
  @override
  Future<String> recognizeImage(String imagePath,
      {String language = 'auto'}) async {
    debugPrint('OCR not supported on web platform');
    return '';
  }

  @override
  Future<String> recognizePdf(String pdfPath,
      {String language = 'auto'}) async {
    debugPrint('PDF OCR not supported on web platform');
    return '';
  }

  @override
  bool get isAvailable => false;
}
