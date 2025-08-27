import Cocoa
import FlutterMacOS
import Vision

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // MethodChannel for macOS Vision OCR
    let channel = FlutterMethodChannel(name: "macos_ocr", binaryMessenger: flutterViewController.engine.binaryMessenger)
    channel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "recognizeImage":
        guard let args = call.arguments as? [String: Any], let path = args["path"] as? String else {
          result(FlutterError(code: "bad_args", message: "Missing 'path'", details: nil))
          return
        }
        self?.recognizeText(atPath: path) { text, error in
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

    super.awakeFromNib()
  }

  private func recognizeText(atPath path: String, completion: @escaping (String?, Error?) -> Void) {
    guard let image = NSImage(contentsOfFile: path) else {
      completion(nil, NSError(domain: "macos_ocr", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot load image"]))
      return
    }

    guard let cgImage = image.cgImage() else {
      completion(nil, NSError(domain: "macos_ocr", code: -2, userInfo: [NSLocalizedDescriptionKey: "Cannot create CGImage"]))
      return
    }

    if #available(macOS 10.15, *) {
      let request = VNRecognizeTextRequest { request, error in
        if let error = error { completion(nil, error); return }
        let observations = request.results as? [VNRecognizedTextObservation] ?? []
        let lines = observations.compactMap { $0.topCandidates(1).first?.string }
        completion(lines.joined(separator: "\n"), nil)
      }
      request.recognitionLevel = .accurate
      request.usesLanguageCorrection = true
      // Prefer FR + AR; Vision auto-detects but hint may help
      request.recognitionLanguages = ["fr-FR", "ar"]

      let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          try handler.perform([request])
        } catch {
          completion(nil, error)
        }
      }
    } else {
      completion(nil, NSError(domain: "macos_ocr", code: -3, userInfo: [NSLocalizedDescriptionKey: "Requires macOS 10.15+"]))
    }
  }
}

private extension NSImage {
  func cgImage() -> CGImage? {
    var proposedRect = CGRect(origin: .zero, size: self.size)
    return self.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)
  }
}
