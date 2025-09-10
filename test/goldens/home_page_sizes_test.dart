import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/features/home/modern_home_page.dart';
import 'package:spiritual_routines/design_system/inspired_theme.dart';

void main() {
  testGoldens('ModernHomePage - responsive sizes', (tester) async {
    final devices = [
      Device.phone,           // 360×800
      Device.tabletPortrait,  // 768×1024
      Device.tabletLandscape, // 1024×768
      const Device(          // Desktop
        name: 'desktop',
        size: Size(1280, 800),
        devicePixelRatio: 1.0,
      ),
    ];
    
    await tester.pumpWidgetBuilder(
      const ProviderScope(
        child: ModernHomePage(),
      ),
      wrapper: materialAppWrapper(
        theme: InspiredTheme.light,
      ),
    );
    
    await multiScreenGolden(
      tester,
      'home_page_responsive',
      devices: devices,
    );
  });

  testGoldens('ModernHomePage - dark theme', (tester) async {
    await tester.pumpWidgetBuilder(
      const ProviderScope(
        child: ModernHomePage(),
      ),
      wrapper: materialAppWrapper(
        theme: InspiredTheme.dark,
      ),
    );
    
    await screenMatchesGolden(tester, 'home_page_dark');
  });
}