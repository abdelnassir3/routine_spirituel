import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

/// Breakpoint definitions following standard responsive design practices
class Breakpoints {
  static const double xs = 0;
  static const double sm = 640;
  static const double md = 768;
  static const double lg = 1024;
  static const double xl = 1280;
  static const double xxl = 1536;
}

/// Screen type classification for responsive layouts
enum ScreenType { mobile, tablet, desktop }

/// Main responsive builder widget that adapts layout based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints, ScreenType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  /// Get the current screen type based on width
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

/// Extension methods for easy responsive checks
extension ResponsiveContext on BuildContext {
  /// Get the current screen type
  ScreenType get screenType => ResponsiveBuilder.getScreenType(this);

  /// Check if current screen is mobile
  bool get isMobile => screenType == ScreenType.mobile;

  /// Check if current screen is tablet
  bool get isTablet => screenType == ScreenType.tablet;

  /// Check if current screen is desktop
  bool get isDesktop => screenType == ScreenType.desktop;

  /// Check if running on web platform
  bool get isWeb => kIsWeb;

  /// Check if running on macOS platform
  bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Get responsive value based on screen type
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive padding based on screen type
  EdgeInsets get responsivePadding {
    return responsive(
      mobile: const EdgeInsets.all(16.0),
      tablet: const EdgeInsets.all(20.0),
      desktop: const EdgeInsets.all(24.0),
    );
  }

  /// Get responsive grid columns based on screen type
  int get responsiveColumns {
    return responsive(
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );
  }
}

/// Responsive widget that shows/hides based on screen type
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool hiddenOnMobile;
  final bool hiddenOnTablet;
  final bool hiddenOnDesktop;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.hiddenOnMobile = false,
    this.hiddenOnTablet = false,
    this.hiddenOnDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;

    bool shouldHide = false;
    switch (screenType) {
      case ScreenType.mobile:
        shouldHide = hiddenOnMobile;
        break;
      case ScreenType.tablet:
        shouldHide = hiddenOnTablet;
        break;
      case ScreenType.desktop:
        shouldHide = hiddenOnDesktop;
        break;
    }

    return Visibility(
      visible: !shouldHide,
      child: child,
    );
  }
}

/// Responsive container that adapts width based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final AlignmentGeometry alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;

    // Default max widths based on screen type
    final defaultMaxWidth = screenType == ScreenType.mobile
        ? double.infinity
        : screenType == ScreenType.tablet
            ? 768.0
            : 1200.0;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? defaultMaxWidth,
        ),
        padding: padding ?? context.responsivePadding,
        child: child,
      ),
    );
  }
}

/// Responsive grid widget that adapts columns based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
  });

  @override
  Widget build(BuildContext context) {
    final columns = context.responsive(
      mobile: mobileColumns ?? 1,
      tablet: tabletColumns ?? 2,
      desktop: desktopColumns ?? 3,
    );

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      mainAxisSpacing: runSpacing,
      crossAxisSpacing: spacing,
      children: children,
    );
  }
}
