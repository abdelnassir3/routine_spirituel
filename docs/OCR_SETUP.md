OCR Setup (FR + AR)
===================

Overview
--------
- iOS/macOS: Uses Apple Vision (supports French + Arabic). No extra setup required.
- Android: Uses MLKit by default (French OK). For Arabic, switch OCR engine to Tesseract and provide traineddata.
- Web/Desktop (non-macOS): Stub (no OCR) unless you add a compatible backend.

Android: Tesseract Data
-----------------------
1) Download traineddata:
   - Arabic: ara.traineddata
   - French: fra.traineddata
   - Source: https://github.com/tesseract-ocr/tessdata_best (higher accuracy)
             or https://github.com/tesseract-ocr/tessdata (smaller, faster)

2) Place them in the project at:
   assets/tessdata/ara.traineddata
   assets/tessdata/fra.traineddata

3) Ensure `pubspec.yaml` contains:
   flutter:
     assets:
       - assets/tessdata/

4) In the app, select OCR engine: "Tesseract" (or leave "Auto" and run on Apple devices for AR).

Notes
-----
- PDF OCR is limited to the first 5 pages by default for performance.
- On Android, if traineddata is missing, OCR may return empty text — a SnackBar will suggest switching engines.
- You can import via file picker or the "Chemin..." button (paste a full path, e.g., from CleanShot).

