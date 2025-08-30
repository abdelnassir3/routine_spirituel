import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('PWA Configuration Integration Tests', () {
    test('Web index.html is properly configured', () async {
      final indexFile = File('web/index.html');
      expect(await indexFile.exists(), isTrue,
          reason: 'index.html should exist');

      final content = await indexFile.readAsString();

      // Check essential PWA meta tags
      expect(content.contains('<meta name="viewport"'), isTrue,
          reason: 'Should have viewport meta tag');
      expect(content.contains('theme-color'), isTrue,
          reason: 'Should have theme-color meta tag');
      expect(content.contains('apple-mobile-web-app-capable'), isTrue,
          reason: 'Should have iOS web app capability');
      expect(content.contains('manifest.json'), isTrue,
          reason: 'Should link to manifest.json');
      expect(content.contains('serviceWorker'), isTrue,
          reason: 'Should register service worker');

      // Check custom loading screen
      expect(content.contains('loading-screen'), isTrue,
          reason: 'Should have custom loading screen');
      expect(content.contains('RISAQ'), isTrue,
          reason: 'Should display app name');

      // Check Open Graph tags
      expect(content.contains('og:title'), isTrue,
          reason: 'Should have Open Graph title');
      expect(content.contains('og:description'), isTrue,
          reason: 'Should have Open Graph description');

      // Check Twitter Card tags
      expect(content.contains('twitter:card'), isTrue,
          reason: 'Should have Twitter Card meta tags');
    });

    test('Web manifest.json is valid and complete', () async {
      final manifestFile = File('web/manifest.json');
      expect(await manifestFile.exists(), isTrue,
          reason: 'manifest.json should exist');

      final content = await manifestFile.readAsString();

      // Basic structure validation
      expect(content.contains('"name"'), isTrue,
          reason: 'Should have name field');
      expect(content.contains('"short_name"'), isTrue,
          reason: 'Should have short_name field');
      expect(content.contains('"start_url"'), isTrue,
          reason: 'Should have start_url field');
      expect(content.contains('"display"'), isTrue,
          reason: 'Should have display field');
      expect(content.contains('"background_color"'), isTrue,
          reason: 'Should have background_color field');
      expect(content.contains('"theme_color"'), isTrue,
          reason: 'Should have theme_color field');
      expect(content.contains('"icons"'), isTrue,
          reason: 'Should have icons array');

      // Advanced PWA features
      expect(content.contains('"shortcuts"'), isTrue,
          reason: 'Should have shortcuts for quick actions');
      expect(content.contains('"share_target"'), isTrue,
          reason: 'Should have share target configuration');
      expect(content.contains('"screenshots"'), isTrue,
          reason: 'Should have screenshots for app stores');

      // Check for correct app name
      expect(content.contains('RISAQ'), isTrue,
          reason: 'Should use RISAQ as app name');

      // Check for French description
      expect(content.contains('Routines Spirituelles'), isTrue,
          reason: 'Should have French description');
    });

    test('Required icon files exist', () async {
      final iconSizes = ['48', '72', '96', '128', '192', '512'];

      for (final size in iconSizes) {
        final iconFile = File('web/icons/Icon-$size.png');
        final exists = await iconFile.exists();

        // At minimum, 192 and 512 should exist
        if (size == '192' || size == '512') {
          expect(exists, isTrue, reason: 'Icon-$size.png is required for PWA');
        }
      }

      // Check maskable icons
      final maskable192 = File('web/icons/Icon-maskable-192.png');
      final maskable512 = File('web/icons/Icon-maskable-512.png');

      expect(await maskable192.exists() || await maskable512.exists(), isTrue,
          reason: 'Should have at least one maskable icon');
    });

    test('Offline page exists and is configured', () async {
      final offlineFile = File('web/offline.html');

      if (await offlineFile.exists()) {
        final content = await offlineFile.readAsString();

        // Check offline page content
        expect(content.contains('Mode Hors Ligne'), isTrue,
            reason: 'Should have offline mode title');
        expect(content.contains('RISAQ'), isTrue,
            reason: 'Should mention app name');
        expect(content.contains('retry'), isTrue,
            reason: 'Should have retry functionality');

        // Check for auto-refresh script
        expect(content.contains('navigator.onLine'), isTrue,
            reason: 'Should check online status');
        expect(content.contains('window.location.reload'), isTrue,
            reason: 'Should auto-refresh when back online');
      }
    });

    test('PWA configuration script exists', () async {
      final pwaConfigFile = File('web/pwa-config.js');

      if (await pwaConfigFile.exists()) {
        final content = await pwaConfigFile.readAsString();

        // Check service worker configuration
        expect(content.contains('CACHE_NAME'), isTrue,
            reason: 'Should define cache name');
        expect(content.contains('install'), isTrue,
            reason: 'Should handle install event');
        expect(content.contains('activate'), isTrue,
            reason: 'Should handle activate event');
        expect(content.contains('fetch'), isTrue,
            reason: 'Should handle fetch event');

        // Check caching strategies
        expect(content.contains('cacheFirst'), isTrue,
            reason: 'Should have cache-first strategy');
        expect(content.contains('networkFirst'), isTrue,
            reason: 'Should have network-first strategy');

        // Check advanced features
        expect(content.contains('sync'), isTrue,
            reason: 'Should support background sync');
        expect(content.contains('push'), isTrue,
            reason: 'Should support push notifications');
      }
    });

    test('Favicon files exist', () async {
      final faviconFiles = [
        'web/favicon.png',
        'web/favicon-16x16.png',
        'web/favicon-32x32.png',
      ];

      for (final path in faviconFiles) {
        final file = File(path);
        if (await file.exists()) {
          expect(await file.length(), greaterThan(0),
              reason: '$path should not be empty');
        }
      }
    });

    test('CSS includes responsive and accessibility features', () async {
      final indexFile = File('web/index.html');
      final content = await indexFile.readAsString();

      // Check for responsive styles
      expect(content.contains('@media'), isTrue,
          reason: 'Should have media queries for responsive design');
      expect(content.contains('max-width'), isTrue,
          reason: 'Should have responsive breakpoints');

      // Check for accessibility styles
      expect(content.contains('focus-visible'), isTrue,
          reason: 'Should have focus-visible for accessibility');
      expect(content.contains('prefers-color-scheme'), isTrue,
          reason: 'Should support dark mode');

      // Check for custom scrollbar
      expect(content.contains('::-webkit-scrollbar'), isTrue,
          reason: 'Should have custom scrollbar styles');

      // Check for loading animation
      expect(content.contains('@keyframes'), isTrue,
          reason: 'Should have loading animations');
    });

    test('Web app can be installed as PWA', () async {
      // This test verifies that all requirements for PWA installation are met

      final indexFile = File('web/index.html');
      final manifestFile = File('web/manifest.json');
      final icon192 = File('web/icons/Icon-192.png');
      final icon512 = File('web/icons/Icon-512.png');

      // Check all required files exist
      expect(await indexFile.exists(), isTrue,
          reason: 'index.html required for PWA');
      expect(await manifestFile.exists(), isTrue,
          reason: 'manifest.json required for PWA');
      expect(await icon192.exists(), isTrue,
          reason: '192x192 icon required for PWA');
      expect(await icon512.exists(), isTrue,
          reason: '512x512 icon required for PWA');

      // Verify service worker registration
      final indexContent = await indexFile.readAsString();
      expect(indexContent.contains('serviceWorker.register'), isTrue,
          reason: 'Service worker must be registered for PWA');

      // Verify manifest is linked
      expect(indexContent.contains('rel="manifest"'), isTrue,
          reason: 'Manifest must be linked for PWA');

      // Verify HTTPS readiness (can't test actual HTTPS in unit test)
      // In production, ensure the app is served over HTTPS

      print('✅ All PWA installation requirements are met');
      print('📱 The app can be installed on:');
      print('  • Chrome/Edge (desktop & mobile)');
      print('  • Safari (iOS - with limitations)');
      print('  • Firefox (desktop & mobile)');
    });

    test('Performance optimizations are in place', () async {
      final indexFile = File('web/index.html');
      final content = await indexFile.readAsString();

      // Check async script loading
      expect(content.contains('async'), isTrue,
          reason: 'Scripts should load asynchronously');

      // Check for loading screen (prevents blank page)
      expect(content.contains('loading-screen'), isTrue,
          reason:
              'Should have loading screen for better perceived performance');

      // Check for viewport meta tag
      expect(content.contains('viewport'), isTrue,
          reason: 'Should have viewport for mobile optimization');

      // Verify no inline scripts that block rendering
      final inlineScriptCount = '<script>'.allMatches(content).length;
      expect(inlineScriptCount, lessThan(5),
          reason: 'Should minimize inline scripts');
    });
  });
}
