import 'package:share_plus/share_plus.dart';
import 'share_adapter.dart';

// Factory function for conditional import
ShareAdapter createShareAdapter() => MobileShareAdapter();

class MobileShareAdapter implements ShareAdapter {
  @override
  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  @override
  Future<void> shareFiles(List<String> paths,
      {String? text, String? subject}) async {
    final files = paths.map((p) => XFile(p)).toList();
    await Share.shareXFiles(files, text: text, subject: subject);
  }
}
