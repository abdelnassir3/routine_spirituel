abstract class AudioTtsService {
  Future<void> playText(
    String text, {
    required String voice,
    double speed = 0.55,
    double pitch = 1.0,
    bool allowFallback = false,
  });
  Future<void> stop();
  Stream<Duration> positionStream();
  Future<void> cacheIfNeeded(String text, {required String voice, double speed = 1.0});
  // Optional helpers for UI
  // Returns list of voices as {name, locale}
  // Implementations may return empty when unsupported
}

extension AudioTtsUi on AudioTtsService {
  // Default empty implementation; concrete service can override by exposing
  // a method with the same name via interface in the future if needed.
}
