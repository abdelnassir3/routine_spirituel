import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:spiritual_routines/core/services/ocr_service.dart';
import 'package:spiritual_routines/core/services/ocr_mlkit.dart'
    if (dart.library.js) '../services/ocr_mlkit_web.dart';
import 'package:spiritual_routines/core/services/ocr_tesseract.dart';
import 'package:spiritual_routines/core/services/ocr_macos_vision.dart';
import 'package:spiritual_routines/core/services/user_settings_service.dart';

/// Provides an OCR service depending on user preference and platform.
/// - Engine preference: 'auto' (default), 'mlkit', 'tesseract', 'stub'
/// - Platform guard: MLKit is mobile-only; others fallback gracefully.
final ocrProvider = FutureProvider<OcrService>((ref) async {
  final settings = ref.read(userSettingsServiceProvider);
  final engine = await settings.getOcrEngine();

  OcrService selectAuto() {
    if (kIsWeb) return StubOcrService();
    if (Platform.isMacOS) return MacosVisionOcrService();
    if (Platform.isIOS) return MacosVisionOcrService();
    // Android and others
    return MlkitOcrService();
  }

  switch (engine) {
    case 'mlkit':
      if (kIsWeb) return StubOcrService();
      try {
        return MlkitOcrService();
      } catch (_) {
        return StubOcrService();
      }
    case 'vision':
      if (kIsWeb) return StubOcrService();
      if (Platform.isMacOS || Platform.isIOS) return MacosVisionOcrService();
      return StubOcrService();
    case 'tesseract':
      // Currently a stub implementation; useful for desktop preparation.
      return TesseractOcrService();
    case 'stub':
      return StubOcrService();
    case 'auto':
    default:
      return selectAuto();
  }
});
