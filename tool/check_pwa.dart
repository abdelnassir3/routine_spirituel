#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// PWA Configuration Checker for RISAQ
/// Validates that all PWA requirements are met
void main() async {
  print('🔍 Checking PWA Configuration for RISAQ...\n');

  var score = 0;
  var maxScore = 0;

  // Check index.html
  print('📄 Checking index.html...');
  final indexFile = File('web/index.html');
  if (await indexFile.exists()) {
    final content = await indexFile.readAsString();

    // Check viewport meta tag
    maxScore++;
    if (content.contains('viewport')) {
      print('  ✅ Viewport meta tag found');
      score++;
    } else {
      print('  ❌ Missing viewport meta tag');
    }

    // Check theme-color meta tag
    maxScore++;
    if (content.contains('theme-color')) {
      print('  ✅ Theme-color meta tag found');
      score++;
    } else {
      print('  ❌ Missing theme-color meta tag');
    }

    // Check apple-mobile-web-app-capable
    maxScore++;
    if (content.contains('apple-mobile-web-app-capable')) {
      print('  ✅ iOS web app capable meta tag found');
      score++;
    } else {
      print('  ❌ Missing iOS web app capable meta tag');
    }

    // Check manifest link
    maxScore++;
    if (content.contains('<link rel="manifest"')) {
      print('  ✅ Manifest link found');
      score++;
    } else {
      print('  ❌ Missing manifest link');
    }

    // Check service worker registration
    maxScore++;
    if (content.contains('serviceWorker')) {
      print('  ✅ Service worker registration found');
      score++;
    } else {
      print('  ❌ Missing service worker registration');
    }

    // Check custom loading screen
    maxScore++;
    if (content.contains('loading-screen')) {
      print('  ✅ Custom loading screen found');
      score++;
    } else {
      print('  ❌ Missing custom loading screen');
    }
  } else {
    print('  ❌ index.html not found');
  }

  print('\n📋 Checking manifest.json...');
  final manifestFile = File('web/manifest.json');
  if (await manifestFile.exists()) {
    try {
      final content = await manifestFile.readAsString();
      final manifest = jsonDecode(content) as Map<String, dynamic>;

      // Check required fields
      final requiredFields = [
        'name',
        'short_name',
        'start_url',
        'display',
        'background_color',
        'theme_color',
        'icons',
      ];

      for (final field in requiredFields) {
        maxScore++;
        if (manifest.containsKey(field)) {
          print('  ✅ $field found');
          score++;
        } else {
          print('  ❌ Missing $field');
        }
      }

      // Check icons
      if (manifest['icons'] is List) {
        final icons = manifest['icons'] as List;
        maxScore++;

        final has192 =
            icons.any((icon) => icon['sizes']?.contains('192x192') ?? false);
        final has512 =
            icons.any((icon) => icon['sizes']?.contains('512x512') ?? false);

        if (has192 && has512) {
          print('  ✅ Required icon sizes found (192x192, 512x512)');
          score++;
        } else {
          print('  ❌ Missing required icon sizes');
        }

        // Check maskable icons
        maxScore++;
        final hasMaskable =
            icons.any((icon) => icon['purpose']?.contains('maskable') ?? false);

        if (hasMaskable) {
          print('  ✅ Maskable icons found');
          score++;
        } else {
          print('  ⚠️  No maskable icons (optional but recommended)');
        }
      }

      // Check advanced features
      if (manifest.containsKey('shortcuts')) {
        print('  ✨ Shortcuts configured');
      }
      if (manifest.containsKey('share_target')) {
        print('  ✨ Share target configured');
      }
      if (manifest.containsKey('screenshots')) {
        print('  ✨ Screenshots configured');
      }
    } catch (e) {
      print('  ❌ Invalid manifest.json: $e');
    }
  } else {
    print('  ❌ manifest.json not found');
  }

  print('\n🎨 Checking icons...');
  final iconSizes = ['192', '512'];
  for (final size in iconSizes) {
    maxScore++;
    final iconFile = File('web/icons/Icon-$size.png');
    if (await iconFile.exists()) {
      print('  ✅ Icon-$size.png found');
      score++;
    } else {
      print('  ❌ Icon-$size.png not found');
    }
  }

  print('\n🔧 Checking PWA files...');

  // Check offline.html
  maxScore++;
  final offlineFile = File('web/offline.html');
  if (await offlineFile.exists()) {
    print('  ✅ offline.html found');
    score++;
  } else {
    print('  ⚠️  offline.html not found (optional)');
  }

  // Check pwa-config.js
  maxScore++;
  final pwaConfigFile = File('web/pwa-config.js');
  if (await pwaConfigFile.exists()) {
    print('  ✅ pwa-config.js found');
    score++;
  } else {
    print('  ⚠️  pwa-config.js not found (optional)');
  }

  // Calculate and display score
  print('\n' + '═' * 50);
  final percentage = ((score / maxScore) * 100).round();

  if (percentage >= 90) {
    print('🎉 EXCELLENT! PWA Score: $score/$maxScore ($percentage%)');
    print('Your app is fully PWA-ready!');
  } else if (percentage >= 70) {
    print('👍 GOOD! PWA Score: $score/$maxScore ($percentage%)');
    print('Your app meets most PWA requirements.');
  } else if (percentage >= 50) {
    print('⚠️  NEEDS WORK! PWA Score: $score/$maxScore ($percentage%)');
    print('Several PWA requirements are missing.');
  } else {
    print('❌ POOR! PWA Score: $score/$maxScore ($percentage%)');
    print('Many PWA requirements are not met.');
  }

  print('\n📚 PWA Best Practices:');
  print('  • Use HTTPS in production');
  print('  • Implement offline functionality');
  print('  • Add app shortcuts for quick actions');
  print('  • Configure Web Share API');
  print('  • Optimize performance (Lighthouse score > 90)');
  print('  • Test on real devices');

  print('\n🚀 To build for production:');
  print('  flutter build web --release --web-renderer html');
  print('  flutter build web --release --web-renderer canvaskit');

  exit(percentage >= 70 ? 0 : 1);
}
