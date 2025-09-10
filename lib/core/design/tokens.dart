import 'package:flutter/material.dart';

/// Design tokens Material 3 centralisés
class DesignTokens {
  DesignTokens._();

  // Spacing (Material 3 8dp grid)
  static const double space0 = 0;
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;
  static const double space12 = 48;
  static const double space16 = 64;
  
  // Radius (Material 3)
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 28;
  
  // Breakpoints responsive
  static const double breakpointCompact = 600;
  static const double breakpointMedium = 840;
  static const double breakpointExpanded = 1200;
  static const double breakpointLarge = 1600;
  
  // Tap targets WCAG
  static const double tapTargetMin = 48;
  static const double tapTargetComfortable = 56;
  
  // Elevation (Material 3 tone-based)
  static const double elevationLevel0 = 0;
  static const double elevationLevel1 = 1;
  static const double elevationLevel2 = 3;
  static const double elevationLevel3 = 6;
  static const double elevationLevel4 = 8;
  static const double elevationLevel5 = 12;
  
  // Animation durations
  static const Duration durationShort = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationLong = Duration(milliseconds: 500);
  static const Duration durationExtraLong = Duration(milliseconds: 700);
}

/// Extensions utilitaires pour les tokens
extension DesignTokensExtensions on BuildContext {
  /// Breakpoint actuel selon Material 3
  String get currentBreakpoint {
    final width = MediaQuery.of(this).size.width;
    if (width < DesignTokens.breakpointCompact) return 'compact';
    if (width < DesignTokens.breakpointMedium) return 'medium';
    if (width < DesignTokens.breakpointExpanded) return 'expanded';
    return 'large';
  }
  
  /// Est-ce un écran compact (mobile)
  bool get isCompact => MediaQuery.of(this).size.width < DesignTokens.breakpointCompact;
  
  /// Est-ce un écran medium (tablette portrait)
  bool get isMedium {
    final width = MediaQuery.of(this).size.width;
    return width >= DesignTokens.breakpointCompact && width < DesignTokens.breakpointMedium;
  }
  
  /// Est-ce un écran expanded (tablette landscape)
  bool get isExpanded {
    final width = MediaQuery.of(this).size.width;
    return width >= DesignTokens.breakpointMedium && width < DesignTokens.breakpointExpanded;
  }
  
  /// Est-ce un grand écran (desktop)
  bool get isLarge => MediaQuery.of(this).size.width >= DesignTokens.breakpointExpanded;
}