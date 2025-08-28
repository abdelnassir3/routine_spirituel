import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';

import 'package:spiritual_routines/core/services/ocr_service.dart';

class MacosVisionOcrService implements OcrService {
  static const _channel = MethodChannel('macos_ocr');

  @override
  Future<String> recognizeImage(String imagePath,
      {String language = 'auto'}) async {
    final text = await _channel.invokeMethod<String>('recognizeImage', {
      'path': imagePath,
    });
    return text ?? '';
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
      // Limit pages for performance if necessary
      if (i >= 5) break;
    }
    return buffer.toString();
  }

  Future<File> _writeTempPng(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file =
        File('${dir.path}/ocr_${DateTime.now().microsecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
