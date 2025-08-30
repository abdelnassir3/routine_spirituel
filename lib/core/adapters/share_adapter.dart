abstract class ShareAdapter {
  Future<void> shareText(String text, {String? subject});
  Future<void> shareFiles(List<String> paths, {String? text, String? subject});
}
