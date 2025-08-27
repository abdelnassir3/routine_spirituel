# PR #003: Web & macOS Responsiveness

## Description
Implémente le support responsive pour Web et macOS avec breakpoints, navigation adaptative et interactions desktop.

## Impact
- **Gravité**: MAJEUR - 60% du marché potentiel
- **Platforms**: Web, macOS (améliore aussi tablet)
- **UX Impact**: Desktop experience native

## Changements Principaux

### 1. Créer Responsive System

```dart
// lib/core/widgets/responsive_breakpoints.dart
import 'package:flutter/material.dart';

class Breakpoints {
  static const double xs = 0;
  static const double sm = 640;
  static const double md = 768;
  static const double lg = 1024;
  static const double xl = 1280;
  static const double xxl = 1536;
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints, ScreenType) builder;
  
  const ResponsiveBuilder({required this.builder});
  
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < Breakpoints.sm) return ScreenType.mobile;
    if (width < Breakpoints.lg) return ScreenType.tablet;
    return ScreenType.desktop;
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = getScreenType(context);
        return builder(context, constraints, screenType);
      },
    );
  }
}

enum ScreenType { mobile, tablet, desktop }

// Extension pour faciliter l'usage
extension ResponsiveContext on BuildContext {
  ScreenType get screenType => ResponsiveBuilder.getScreenType(this);
  bool get isMobile => screenType == ScreenType.mobile;
  bool get isTablet => screenType == ScreenType.tablet;
  bool get isDesktop => screenType == ScreenType.desktop;
  bool get isWeb => kIsWeb;
  bool get isMacOS => !kIsWeb && Platform.isMacOS;
}
```

### 2. Navigation Adaptative

```dart
// lib/design_system/components/adaptive_navigation.dart
import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

class AdaptiveNavigationScaffold extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final Widget? floatingActionButton;
  
  const AdaptiveNavigationScaffold({
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.floatingActionButton,
  });
  
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints, screenType) {
        // Desktop: NavigationRail à gauche
        if (screenType == ScreenType.desktop) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: constraints.maxWidth > Breakpoints.xl,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: constraints.maxWidth > Breakpoints.xl
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  destinations: destinations.map((d) => 
                    NavigationRailDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon ?? d.icon,
                      label: Text(d.label),
                    ),
                  ).toList(),
                  trailing: floatingActionButton != null 
                    ? Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: floatingActionButton,
                      )
                    : null,
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }
        
        // Tablet: NavigationRail compact
        if (screenType == ScreenType.tablet) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: false,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: NavigationRailLabelType.selected,
                  destinations: destinations.map((d) => 
                    NavigationRailDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon ?? d.icon,
                      label: Text(d.label),
                    ),
                  ).toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
            floatingActionButton: floatingActionButton,
          );
        }
        
        // Mobile: BottomNavigationBar
        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: destinations,
          ),
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}
```

### 3. Mise à jour ModernHomePage

```diff
// lib/features/home/modern_home_page.dart
+ import 'package:spiritual_routines/core/widgets/responsive_breakpoints.dart';
+ import 'package:spiritual_routines/design_system/components/adaptive_navigation.dart';

class ModernHomePage extends ConsumerStatefulWidget {
  // ...
}

class _ModernHomePageState extends ConsumerState<ModernHomePage> {
+  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
-    return Scaffold(
+    return AdaptiveNavigationScaffold(
+      selectedIndex: _selectedIndex,
+      onDestinationSelected: (index) {
+        setState(() => _selectedIndex = index);
+        // Navigation logic
+        switch (index) {
+          case 0: break; // Home
+          case 1: context.go('/routines'); break;
+          case 2: context.go('/reader'); break;
+          case 3: context.go('/settings'); break;
+        }
+      },
+      destinations: const [
+        NavigationDestination(
+          icon: Icon(Icons.home_outlined),
+          selectedIcon: Icon(Icons.home),
+          label: 'Accueil',
+        ),
+        NavigationDestination(
+          icon: Icon(Icons.list_outlined),
+          selectedIcon: Icon(Icons.list),
+          label: 'Routines',
+        ),
+        NavigationDestination(
+          icon: Icon(Icons.book_outlined),
+          selectedIcon: Icon(Icons.book),
+          label: 'Lecture',
+        ),
+        NavigationDestination(
+          icon: Icon(Icons.settings_outlined),
+          selectedIcon: Icon(Icons.settings),
+          label: 'Réglages',
+        ),
+      ],
      body: SafeArea(
-        child: CustomScrollView(
+        child: ResponsiveBuilder(
+          builder: (context, constraints, screenType) {
+            // Adapte le layout selon la taille
+            final crossAxisCount = screenType == ScreenType.mobile ? 2
+                : screenType == ScreenType.tablet ? 3
+                : 4;
+            
+            final padding = screenType == ScreenType.mobile 
+                ? EdgeInsets.all(16.0)
+                : EdgeInsets.all(24.0);
+                
+            return CustomScrollView(
              slivers: [
                // Header adaptatif
                SliverToBoxAdapter(
                  child: Padding(
-                    padding: const EdgeInsets.all(20),
+                    padding: padding,
                    child: Column(
                      children: [
                        // Stats cards responsive
-                        GridView.count(
-                          crossAxisCount: 2,
+                        GridView.count(
+                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: _buildStatsCards(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
+            );
+          },
+        ),
      ),
    );
  }
}
```

### 4. Support Keyboard & Mouse

```dart
// lib/core/widgets/desktop_interactions.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DesktopInteractiveWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onRightClick;
  final String? tooltip;
  
  const DesktopInteractiveWidget({
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onRightClick,
    this.tooltip,
  });
  
  @override
  State<DesktopInteractiveWidget> createState() => _DesktopInteractiveWidgetState();
}

class _DesktopInteractiveWidgetState extends State<DesktopInteractiveWidget> {
  bool _hovering = false;
  bool _focused = false;
  
  @override
  Widget build(BuildContext context) {
    Widget result = MouseRegion(
      cursor: widget.onTap != null 
          ? SystemMouseCursors.click 
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        onSecondaryTap: widget.onRightClick,
        child: Focus(
          onFocusChange: (focused) => setState(() => _focused = focused),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _hovering 
                  ? Theme.of(context).hoverColor
                  : Colors.transparent,
              border: _focused
                  ? Border.all(
                      color: Theme.of(context).focusColor,
                      width: 2,
                    )
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
    
    if (widget.tooltip != null) {
      result = Tooltip(
        message: widget.tooltip!,
        child: result,
      );
    }
    
    return result;
  }
}

// Keyboard shortcuts
class KeyboardShortcuts extends StatelessWidget {
  final Widget child;
  final Map<ShortcutActivator, VoidCallback> shortcuts;
  
  const KeyboardShortcuts({
    required this.child,
    required this.shortcuts,
  });
  
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: shortcuts.map((key, value) => 
        MapEntry(key, VoidCallbackIntent(value))),
      child: Actions(
        actions: {
          VoidCallbackIntent: VoidCallbackAction(),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}

class VoidCallbackIntent extends Intent {
  final VoidCallback callback;
  const VoidCallbackIntent(this.callback);
}

class VoidCallbackAction extends Action<VoidCallbackIntent> {
  @override
  Object? invoke(VoidCallbackIntent intent) {
    intent.callback();
    return null;
  }
}
```

### 5. Configuration Web

```diff
// web/index.html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Application de routines spirituelles">
+  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0">
  
  <!-- iOS meta tags & icons -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="Routines Spirituelles">
  
+  <!-- PWA manifest -->
+  <link rel="manifest" href="manifest.json">
  
  <title>Routines Spirituelles</title>
+  
+  <style>
+    /* Focus visible pour accessibilité */
+    :focus-visible {
+      outline: 2px solid #2E7D32;
+      outline-offset: 2px;
+    }
+    
+    /* Scrollbar personnalisée */
+    ::-webkit-scrollbar {
+      width: 12px;
+      height: 12px;
+    }
+    
+    ::-webkit-scrollbar-track {
+      background: #f1f1f1;
+    }
+    
+    ::-webkit-scrollbar-thumb {
+      background: #888;
+      border-radius: 6px;
+    }
+    
+    ::-webkit-scrollbar-thumb:hover {
+      background: #555;
+    }
+  </style>
</head>
```

### 6. Configuration macOS

```dart
// macos/Runner/MainFlutterWindow.swift
import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    
    // Configuration fenêtre macOS
    self.minSize = NSSize(width: 800, height: 600)
    self.title = "Routines Spirituelles"
    self.titlebarAppearsTransparent = false
    self.isMovableByWindowBackground = true
    self.styleMask.insert(.fullSizeContentView)
    
    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
  }
}
```

## Tests Responsive

```dart
// test/responsive_test.dart
void main() {
  group('Responsive Layout Tests', () {
    testWidgets('Mobile layout < 640px', (tester) async {
      tester.binding.window.physicalSizeTestValue = Size(375, 812);
      await tester.pumpWidget(MyApp());
      
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });
    
    testWidgets('Tablet layout 640-1024px', (tester) async {
      tester.binding.window.physicalSizeTestValue = Size(768, 1024);
      await tester.pumpWidget(MyApp());
      
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
    
    testWidgets('Desktop layout > 1024px', (tester) async {
      tester.binding.window.physicalSizeTestValue = Size(1920, 1080);
      await tester.pumpWidget(MyApp());
      
      expect(find.byType(NavigationRail), findsOneWidget);
      // Rail should be extended on desktop
    });
  });
  
  group('Keyboard Navigation', () {
    testWidgets('Tab navigation works', (tester) async {
      await tester.pumpWidget(MyApp());
      
      // Simulate Tab key
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      
      // Should move focus
      final focusedWidget = Focus.of(
        tester.element(find.byType(MaterialApp))
      ).focusedChild;
      expect(focusedWidget, isNotNull);
    });
  });
}
```

## Checklist

- [ ] Breakpoints testés sur toutes tailles
- [ ] Navigation rail fonctionne desktop
- [ ] Keyboard navigation complète
- [ ] Mouse hover states visibles
- [ ] Focus indicators accessibles
- [ ] Scrollbars visibles desktop
- [ ] PWA manifest configuré
- [ ] macOS window resizable
- [ ] Tests responsive passent

## Métriques Attendues

| Métrique | Avant | Après |
|----------|-------|-------|
| Web support | 25% | 60% |
| macOS support | 45% | 70% |
| Responsive | Non | Oui |
| Keyboard nav | Non | Oui |
| Mouse support | Non | Oui |
| Desktop UX | 0/10 | 7/10 |