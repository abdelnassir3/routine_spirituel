// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsCorpusGen {
  const $AssetsCorpusGen();

  /// File path: assets/corpus/quran_combined.json
  String get quranCombined => 'assets/corpus/quran_combined.json';

  /// File path: assets/corpus/quran_full.json
  String get quranFull => 'assets/corpus/quran_full.json';

  /// File path: assets/corpus/quran_full_backup.json
  String get quranFullBackup => 'assets/corpus/quran_full_backup.json';

  /// File path: assets/corpus/quran_full_fixed.json
  String get quranFullFixed => 'assets/corpus/quran_full_fixed.json';

  /// File path: assets/corpus/surahs_metadata.json
  String get surahsMetadata => 'assets/corpus/surahs_metadata.json';

  /// List of all assets
  List<String> get values => [
        quranCombined,
        quranFull,
        quranFullBackup,
        quranFullFixed,
        surahsMetadata
      ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/app_logo.png
  AssetGenImage get appLogo =>
      const AssetGenImage('assets/images/app_logo.png');

  /// File path: assets/images/islamic_logo.png
  AssetGenImage get islamicLogo =>
      const AssetGenImage('assets/images/islamic_logo.png');

  /// File path: assets/images/islamic_logo_hd.png
  AssetGenImage get islamicLogoHd =>
      const AssetGenImage('assets/images/islamic_logo_hd.png');

  /// File path: assets/images/sample_text_fr.png
  AssetGenImage get sampleTextFr =>
      const AssetGenImage('assets/images/sample_text_fr.png');

  /// List of all assets
  List<AssetGenImage> get values =>
      [appLogo, islamicLogo, islamicLogoHd, sampleTextFr];
}

class $AssetsTessdataGen {
  const $AssetsTessdataGen();

  /// File path: assets/tessdata/README.txt
  String get readme => 'assets/tessdata/README.txt';

  /// File path: assets/tessdata/ara.traineddata
  String get ara => 'assets/tessdata/ara.traineddata';

  /// File path: assets/tessdata/fra.traineddata
  String get fra => 'assets/tessdata/fra.traineddata';

  /// List of all assets
  List<String> get values => [readme, ara, fra];
}

class $AssetsTestImagesGen {
  const $AssetsTestImagesGen();

  /// File path: assets/test_images/README.md
  String get readme => 'assets/test_images/README.md';

  /// File path: assets/test_images/simple_arabic_ocr.png
  AssetGenImage get simpleArabicOcr =>
      const AssetGenImage('assets/test_images/simple_arabic_ocr.png');

  /// File path: assets/test_images/simple_arabic_test.html
  String get simpleArabicTest => 'assets/test_images/simple_arabic_test.html';

  /// File path: assets/test_images/test_arabic_ocr.png
  AssetGenImage get testArabicOcr =>
      const AssetGenImage('assets/test_images/test_arabic_ocr.png');

  /// File path: assets/test_images/test_arabic_ocr_2.png
  AssetGenImage get testArabicOcr2 =>
      const AssetGenImage('assets/test_images/test_arabic_ocr_2.png');

  /// File path: assets/test_images/test_french.png
  AssetGenImage get testFrench =>
      const AssetGenImage('assets/test_images/test_french.png');

  /// File path: assets/test_images/test_french_ocr.png
  AssetGenImage get testFrenchOcr =>
      const AssetGenImage('assets/test_images/test_french_ocr.png');

  /// File path: assets/test_images/test_french_text.png
  AssetGenImage get testFrenchText =>
      const AssetGenImage('assets/test_images/test_french_text.png');

  /// File path: assets/test_images/test_ocr_arabic.html
  String get testOcrArabic => 'assets/test_images/test_ocr_arabic.html';

  /// File path: assets/test_images/test_ocr_french.html
  String get testOcrFrench => 'assets/test_images/test_ocr_french.html';

  /// List of all assets
  List<dynamic> get values => [
        readme,
        simpleArabicOcr,
        simpleArabicTest,
        testArabicOcr,
        testArabicOcr2,
        testFrench,
        testFrenchOcr,
        testFrenchText,
        testOcrArabic,
        testOcrFrench
      ];
}

class Assets {
  const Assets._();

  static const $AssetsCorpusGen corpus = $AssetsCorpusGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsTessdataGen tessdata = $AssetsTessdataGen();
  static const $AssetsTestImagesGen testImages = $AssetsTestImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
