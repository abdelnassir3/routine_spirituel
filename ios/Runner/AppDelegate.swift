import Flutter
import UIKit
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // MethodChannel for iOS Vision OCR (reuse same API as macOS)
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "macos_ocr", binaryMessenger: controller.binaryMessenger)
    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "recognizeImage":
        guard let args = call.arguments as? [String: Any], let path = args["path"] as? String else {
          result(FlutterError(code: "bad_args", message: "Missing 'path'", details: nil))
          return
        }
        self.recognizeText(atPath: path) { text, error in
          if let error = error {
            result(FlutterError(code: "ocr_error", message: error.localizedDescription, details: nil))
          } else {
            result(text ?? "")
          }
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func recognizeText(atPath path: String, completion: @escaping (String?, Error?) -> Void) {
    guard let image = UIImage(contentsOfFile: path) else {
      completion(nil, NSError(domain: "ios_ocr", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot load image"]))
      return
    }
    guard let cgImage = image.cgImage else {
      completion(nil, NSError(domain: "ios_ocr", code: -2, userInfo: [NSLocalizedDescriptionKey: "Cannot create CGImage"]))
      return
    }
    if #available(iOS 16.0, *) {
      // iOS 16+ with better Arabic support
      let request = VNRecognizeTextRequest { request, error in
        if let error = error { completion(nil, error); return }
        let observations = request.results as? [VNRecognizedTextObservation] ?? []
        let lines = observations.compactMap { $0.topCandidates(1).first?.string }
        completion(lines.joined(separator: "\n"), nil)
      }
      request.recognitionLevel = .accurate
      request.usesLanguageCorrection = false  // Disable for Arabic
      // Try Arabic-specific languages
      request.recognitionLanguages = ["ar-SA", "ar", "fr-FR", "en-US"]
      request.automaticallyDetectsLanguage = true
      let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          try handler.perform([request])
        } catch {
          completion(nil, error)
        }
      }
    } else if #available(iOS 13.0, *) {
      // Fallback for older iOS versions
      let request = VNRecognizeTextRequest { request, error in
        if let error = error { completion(nil, error); return }
        let observations = request.results as? [VNRecognizedTextObservation] ?? []
        let lines = observations.compactMap { $0.topCandidates(1).first?.string }
        completion(lines.joined(separator: "\n"), nil)
      }
      request.recognitionLevel = .accurate
      request.usesLanguageCorrection = false
      request.recognitionLanguages = ["ar", "fr-FR"]
      let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          try handler.perform([request])
        } catch {
          completion(nil, error)
        }
      }
    } else {
      completion(nil, NSError(domain: "ios_ocr", code: -3, userInfo: [NSLocalizedDescriptionKey: "Requires iOS 13+"]))
    }
  }
}
