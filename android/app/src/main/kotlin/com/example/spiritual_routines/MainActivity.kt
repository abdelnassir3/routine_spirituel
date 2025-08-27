package com.example.spiritual_routines

import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.googlecode.tesseract.android.TessBaseAPI
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
  private val CHANNEL = "android_ocr"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "recognizeImage" -> {
          val path = call.argument<String>("path")
          val lang = call.argument<String>("lang") ?: "eng"
          if (path == null) {
            result.error("bad_args", "Missing 'path'", null)
            return@setMethodCallHandler
          }
          try {
            val text = recognizeWithTesseract(path, lang)
            result.success(text)
          } catch (e: Exception) {
            result.error("ocr_error", e.message, null)
          }
        }
        else -> result.notImplemented()
      }
    }
  }

  private fun recognizeWithTesseract(imagePath: String, lang: String): String {
    val ctx = applicationContext
    val filesDir = ctx.filesDir
    val tessDir = File(filesDir, "tessdata")
    if (!tessDir.exists()) tessDir.mkdirs()

    // Ensure traineddata exists (copy from Flutter assets if present)
    ensureTrainedData("ara")
    ensureTrainedData("fra")
    ensureTrainedData("eng")

    val baseApi = TessBaseAPI()
    baseApi.init(filesDir.absolutePath, lang)
    val bmp = BitmapFactory.decodeFile(imagePath)
    baseApi.setImage(bmp)
    val text = baseApi.utF8Text
    baseApi.end()
    return text ?: ""
  }

  private fun ensureTrainedData(code: String) {
    val ctx = applicationContext
    val dest = File(ctx.filesDir, "tessdata/$code.traineddata")
    if (dest.exists()) return
    try {
      val loader = io.flutter.embedding.engine.loader.FlutterLoader()
      loader.startInitialization(ctx)
      loader.ensureInitializationComplete(ctx, null)
      val key = loader.getLookupKeyForAsset("tessdata/$code.traineddata")
      ctx.assets.open(key).use { input ->
        dest.parentFile?.mkdirs()
        FileOutputStream(dest).use { output ->
          input.copyTo(output)
        }
      }
    } catch (e: Exception) {
      // Asset not present; leave missing. Caller should handle empty results.
    }
  }
}
