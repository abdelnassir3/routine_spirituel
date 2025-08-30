import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'share_adapter.dart';

// Factory function for conditional import
ShareAdapter createShareAdapter() => WebShareAdapter();

class WebShareAdapter implements ShareAdapter {
  @override
  Future<void> shareText(String text, {String? subject}) async {
    try {
      // Try Web Share API
      final nav = html.window.navigator;
      final any = nav as dynamic;
      if (any.share != null) {
        await (any.share({'title': subject ?? 'Share', 'text': text})
            as Future);
        return;
      }
    } catch (_) {}
    try {
      // Fallback: copy to clipboard
      await html.window.navigator.clipboard?.writeText(text);
      if (kDebugMode) {
        debugPrint('📋 Copied to clipboard for sharing');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Web share fallback failed: $e');
      }
    }
  }

  @override
  Future<void> shareFiles(List<String> paths,
      {String? text, String? subject}) async {
    // Web: cannot programmatically share arbitrary files reliably without user gesture.
    // Fallback to sharing text (path list) or clipboard copy.
    final message = (text != null && text.isNotEmpty)
        ? text
        : 'Files: \n${paths.join('\n')}';
    await shareText(message, subject: subject);
  }
}
